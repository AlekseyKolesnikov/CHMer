r"""Builds a WebHelp folder from an HTML Help (CHM) project.

  build_webhelp.py PROJECT.hhp OUTPUT_FOLDER

The files listed in the project's [FILES] section are copied with their paths relative to
the .hhp, so a topic opens as OUTPUT_FOLDER\<path>, the same name it has inside the CHM.
Each topic gets a stylesheet and two scripts injected before </head>. They add a header and
a Contents / Index / Search sidebar built from the project's .hhc and .hhk:

  <out>\webhelp\data.js     title, header links, contents tree and keyword index
  <out>\webhelp\search.js   plain text of every topic, loaded when the Search tab opens
  <out>\webhelp\webhelp.js, webhelp.css   the frame itself, copied from this script's folder
                                          (packed into build_webhelp.exe by build_webhelp_exe.bat)

Files the topics reference (images, stylesheets and what those reference) are copied too.
The data is loaded with <script> tags, not fetch(), because the help is meant to work from
file://, where browsers block fetch().

Only [FILES] decides which topics are published: links and contents or index entries that
point to other topics are reported as warnings. The project folder is never modified.

Text is read as UTF-8 when it is valid UTF-8, and messages are printed in UTF-8. The generated
data is ASCII, so it works in topics of any encoding; topics are copied without re-encoding.
"""

import argparse
import csv
import json
import posixpath
import re
import shutil
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import quote, unquote

SCRIPT_DIR = Path(__file__).resolve().parent
ASSET_DIR = 'webhelp'
ASSETS = ('webhelp.js', 'webhelp.css')
TOPIC_EXT = ('.htm', '.html')
# Text that is not UTF-8 was written by HTML Help Workshop or CHMer in the Windows ANSI code page,
# which hhc.exe needs for the contents and index files
ANSI = 'mbcs' if sys.platform == 'win32' else 'latin-1'

warnings = []


class BuildError(Exception):
    pass


def warn(message):
    warnings.append(message)
    print('  warning: ' + message)


def read_text(path):
    """UTF-8 with or without a BOM; HTML Help Workshop and CHMer write the ANSI code page."""
    data = path.read_bytes()
    if data.startswith(b'\xef\xbb\xbf'):
        return data[3:].decode('utf-8')
    try:
        return data.decode('utf-8')
    except UnicodeDecodeError:
        return data.decode(ANSI, errors='replace')


CHARSET = re.compile(rb'<meta[^>]+charset\s*=\s*["\']?([\w-]+)', re.I)


def decode_html(data):
    if data.startswith(b'\xef\xbb\xbf'):
        return data[3:].decode('utf-8', errors='replace')
    m = CHARSET.search(data[:4096])
    if m:
        try:
            return data.decode(m.group(1).decode('ascii'), errors='replace')
        except LookupError:
            pass
    try:
        return data.decode('utf-8')
    except UnicodeDecodeError:
        return data.decode(ANSI, errors='replace')


# ---------------------------------------------------------------------------
# Paths inside the project folder

class ProjectFiles:
    """Finds files under the project folder ignoring case, as Windows and the CHM compiler
    do, and returns their on-disk spelling."""

    def __init__(self, root):
        self.root = root
        self.listings = {}

    def resolve(self, rel):
        if rel is None:
            return None
        folder = self.root
        parts = []
        for part in rel.split('/'):
            actual = self.listing(folder).get(part.lower())
            if actual is None:
                return None
            parts.append(actual)
            folder = folder / actual
        return '/'.join(parts) if folder.is_file() else None

    def listing(self, folder):
        if folder not in self.listings:
            try:
                self.listings[folder] = {p.name.lower(): p.name for p in folder.iterdir()}
            except OSError:
                self.listings[folder] = {}
        return self.listings[folder]

    def read(self, rel):
        return (self.root / rel).read_bytes()


def join(base_dir, path):
    """Project-relative form of a path written relative to base_dir, or None when it
    points outside the project folder."""
    path = posixpath.normpath(posixpath.join(base_dir, path.replace('\\', '/')))
    if path in ('.', '..') or path.startswith(('../', '/')) or re.match(r'[a-z]:', path, re.I):
        return None
    return path


CHM_LINK = re.compile(r'(mk:@msitstore|ms-its|its):', re.I)


def split_ref(ref):
    """(path, anchor) of a link inside the help, or None for an external one."""
    ref = ref.strip()
    if not ref or ref.startswith('//') or re.match(r'[a-z][a-z0-9+.-]*:', ref, re.I):
        return None
    path, _, anchor = ref.partition('#')
    return unquote(path.split('?')[0]), anchor


# ---------------------------------------------------------------------------
# HTML Help project files

def read_hhp(path):
    sections = {}
    current = None
    for line in read_text(path).splitlines():
        line = line.strip()
        if not line or line.startswith(';'):
            continue
        m = re.fullmatch(r'\[(\w+)\]', line)
        if m:
            current = sections.setdefault(m.group(1).upper(), [])
        elif current is not None:
            current.append(line)
    options = {}
    for line in sections.get('OPTIONS', []):
        key, sep, value = line.partition('=')
        if sep:
            options[key.strip()] = value.strip()
    windows = {}
    for line in sections.get('WINDOWS', []):
        name, sep, value = line.partition('=')
        if sep:
            windows[name.strip()] = next(csv.reader([value]))
    return options, windows, sections.get('FILES', [])


class SitemapParser(HTMLParser):
    """Reads an .hhc/.hhk sitemap: nested <UL> lists of <OBJECT type="text/sitemap">."""

    def __init__(self):
        super().__init__()
        self.root = []
        self.stack = []
        self.params = None

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'ul':
            if not self.stack:
                items = self.root
            elif self.stack[-1]:
                items = self.stack[-1][-1].setdefault('children', [])
            else:
                items = self.stack[-1]
            self.stack.append(items)
        elif tag == 'object' and (attrs.get('type') or '').lower() == 'text/sitemap':
            self.params = []
        elif tag == 'param' and self.params is not None:
            self.params.append(((attrs.get('name') or '').lower(), attrs.get('value') or ''))

    def handle_endtag(self, tag):
        if tag == 'ul' and self.stack:
            self.stack.pop()
        elif tag == 'object' and self.params is not None:
            (self.stack[-1] if self.stack else self.root).append({'params': self.params})
            self.params = None


def read_sitemap(path):
    parser = SitemapParser()
    parser.feed(read_text(path))
    parser.close()
    return parser.root


def param_values(item, name):
    return [v for k, v in item['params'] if k == name]


# ---------------------------------------------------------------------------
# Topics

BLOCK_TAGS = {'address', 'blockquote', 'br', 'dd', 'div', 'dl', 'dt', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
              'hr', 'li', 'ol', 'p', 'pre', 'table', 'td', 'th', 'tr', 'ul'}


class TopicParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.title = []
        self.text = []
        self.refs = []
        self.ids = set()
        self.skip = 0
        self.part = None

    def handle_starttag(self, tag, attrs):
        for name, value in attrs:
            if name in ('href', 'src') and value:
                self.refs.append(value)
            elif name == 'id' or (name == 'name' and tag == 'a'):
                self.ids.add(value)
        if tag in ('script', 'style'):
            self.skip += 1
        elif tag in ('title', 'body'):
            self.part = tag
        if tag in BLOCK_TAGS:
            self.text.append(' ')

    def handle_endtag(self, tag):
        if tag in ('script', 'style'):
            self.skip = max(0, self.skip - 1)
        elif tag == 'title':
            self.part = None
        if tag in BLOCK_TAGS:
            self.text.append(' ')

    def handle_data(self, data):
        if self.skip:
            return
        if self.part == 'title':
            self.title.append(data)
        elif self.part == 'body':
            self.text.append(data)


class Topic:
    def __init__(self, rel, data):
        self.rel = rel
        self.data = data
        parser = TopicParser()
        parser.feed(decode_html(data))
        parser.close()
        self.title = ' '.join(''.join(parser.title).split())
        self.text = ' '.join(''.join(parser.text).split())
        self.refs = parser.refs
        self.ids = parser.ids


HEAD_END = re.compile(rb'</head\s*>', re.I)


def inject(data, prefix):
    """Adds the WebHelp stylesheet and scripts before </head>; prefix leads from the
    topic's folder back to the WebHelp root."""
    m = HEAD_END.search(data)
    if not m:
        return None
    nl = b'\r\n' if b'\r\n' in data else b'\n'
    assets = (prefix + ASSET_DIR + '/').encode('ascii')
    lines = (
        b'<link type="text/css" href="' + assets + b'webhelp.css" rel="stylesheet" />',
        b'<script type="text/javascript" src="' + assets + b'data.js" defer="defer"></script>',
        b'<script type="text/javascript" src="' + assets + b'webhelp.js" defer="defer"></script>',
    )
    return data[:m.start()] + b''.join(b'  ' + line + nl for line in lines) + data[m.start():]


CSS_REF = re.compile(r'url\(\s*["\']?([^"\')]+)|@import\s+["\']([^"\']+)', re.I)


# ---------------------------------------------------------------------------
# Build

def build(project, out_dir):
    project = project.resolve()
    if not project.is_file():
        raise BuildError(f'{project} not found')
    root = project.parent
    files = ProjectFiles(root)
    options, windows, file_list = read_hhp(project)
    window = windows.get(options.get('Default Window', ''), [])

    def field(i):
        return window[i].strip() if i < len(window) else ''

    print(f'Building {project.name} into {out_dir}')

    problems = {}  # message -> files it was found in

    def problem(message, where):
        problems.setdefault(message, set()).add(where)

    # [FILES]: the topics, and any other file listed there
    topics = {}     # lower-case path -> Topic
    resources = {}  # lower-case path -> path
    for entry in file_list:
        actual = files.resolve(join('', entry))
        if actual is None:
            problem(f'{entry} not found', '[FILES]')
        elif actual.lower().split('/')[0] == ASSET_DIR:
            raise BuildError(f'{actual} is in a folder named {ASSET_DIR}, which the WebHelp uses for itself')
        elif actual.lower().endswith(TOPIC_EXT):
            topics.setdefault(actual.lower(), Topic(actual, files.read(actual)))
        else:
            resources[actual.lower()] = actual
    if not topics:
        raise BuildError(f'no topics in the [FILES] section of {project.name}')

    def reference(ref, base_dir, where):
        """Resolves a link found in `where`; returns (path, anchor), or None when it
        points outside the help or to a missing file."""
        if CHM_LINK.match(ref.strip()):
            problem(f'CHM-only link {ref}', where)
            return None
        target = split_ref(ref)
        if target is None:
            return None
        path, anchor = target
        if not path:
            return where, anchor
        actual = files.resolve(join(base_dir, path))
        if actual is None:
            problem(f'{ref} not found', where)
            return None
        key = actual.lower()
        if key.endswith(TOPIC_EXT):
            if key not in topics:
                problem(f'{actual} is not in [FILES]', where)
        elif key not in resources:
            resources[key] = actual
            pending.append(actual)
        return actual, anchor

    # Links in the topics, and the files the copied stylesheets reference
    pending = [rel for rel in resources.values()]
    anchors = []
    for topic in list(topics.values()):
        for ref in topic.refs:
            target = reference(ref, posixpath.dirname(topic.rel), topic.rel)
            if target and target[1]:
                anchors.append((topic.rel, target[0].lower(), target[1]))
    while pending:
        rel = pending.pop()
        if rel.lower().endswith('.css'):
            for m in CSS_REF.finditer(read_text(root / rel)):
                reference(m.group(1) or m.group(2), posixpath.dirname(rel), rel)
    for where, key, anchor in dict.fromkeys(anchors):
        target = topics.get(key)
        if target and anchor not in target.ids:
            problem(f'#{anchor} not found in {target.rel}', where)

    def canonical(url, base_dir, where):
        """A contents/index/window URL as the on-disk path of its target, plus the anchor."""
        target = reference(url, base_dir, where)
        if target is None:
            return url.replace('\\', '/')
        return target[0] + ('#' + target[1] if target[1] else '')

    # Contents
    toc_titles = {}

    def toc_nodes(items, base_dir, where):
        nodes = []
        for item in items:
            names = param_values(item, 'name')
            local = param_values(item, 'local')
            node = {'t': names[0] if names else ''}
            if local and local[0]:
                node['u'] = canonical(local[0], base_dir, where)
                toc_titles.setdefault(node['u'].partition('#')[0].lower(), node['t'])
            if item.get('children'):
                node['c'] = toc_nodes(item['children'], base_dir, where)
            nodes.append(node)
        return nodes

    def sitemap(option, window_field, what):
        name = options.get(option) or field(window_field)
        if not name:
            return None, None
        rel = files.resolve(join('', name))
        if rel is None:
            warn(f'{what} file {name} not found')
            return None, None
        return rel, read_sitemap(root / rel)

    toc = []
    toc_rel, items = sitemap('Contents file', 1, 'contents')
    if toc_rel:
        toc = toc_nodes(items, posixpath.dirname(toc_rel), toc_rel)

    # Keyword index
    index = {}

    def index_entries(items, prefix, base_dir, where):
        for item in items:
            names = param_values(item, 'name')
            if not names:
                continue
            keyword = prefix + names[0]
            entry = index.setdefault(keyword.lower(), {'k': keyword, 'r': []})
            for i, local in enumerate(param_values(item, 'local')):
                url = canonical(local, base_dir, where)
                if all(r['u'] != url for r in entry['r']):
                    entry['r'].append({'t': names[i + 1] if i + 1 < len(names) else '', 'u': url})
            if item.get('children'):
                index_entries(item['children'], keyword + ', ', base_dir, where)

    index_rel, items = sitemap('Index file', 2, 'index')
    if index_rel:
        index_entries(items, '', posixpath.dirname(index_rel), index_rel)

    # Title, start page and the window's two jump buttons
    title = options.get('Title') or field(0) or project.stem
    default = canonical(options.get('Default topic') or field(3) or next(iter(topics.values())).rel, '', project.name)
    home = canonical(field(4), '', project.name) if field(4) else default
    links = []
    for url_field, text_field in ((5, 6), (7, 8)):
        if field(url_field) and field(text_field):
            links.append({'t': field(text_field), 'u': canonical(field(url_field), '', project.name)})

    for message, where in problems.items():
        where = sorted(where)
        more = f' and {len(where) - 3} more' if len(where) > 3 else ''
        warn(f'{message} (in {", ".join(where[:3])}{more})')

    # Output
    clean_output(out_dir, root)
    for topic in topics.values():
        data = inject(topic.data, '../' * topic.rel.count('/'))
        if data is None:
            warn(f'{topic.rel}: no </head>, copied without the WebHelp frame')
            data = topic.data
        write(out_dir / topic.rel, data)
    for rel in resources.values():
        write(out_dir / rel, files.read(rel))
    for asset in ASSETS:
        write(out_dir / ASSET_DIR / asset, (SCRIPT_DIR / asset).read_bytes())

    data = {
        'title': title,
        'home': home,
        'links': links,
        'toc': toc,
        'index': sorted(index.values(), key=lambda e: e['k'].casefold()),
    }
    docs = [{'u': t.rel, 't': toc_titles.get(t.rel.lower()) or t.title or t.rel, 'x': t.text}
            for t in sorted(topics.values(), key=lambda t: t.rel.lower())]
    write(out_dir / ASSET_DIR / 'data.js', js_assign('WEBHELP', data))
    write(out_dir / ASSET_DIR / 'search.js', js_assign('WEBHELP_SEARCH', docs))
    if 'index.html' not in topics and 'index.html' not in resources:
        write(out_dir / 'index.html', index_page(title, default))

    print(f'  {len(topics)} topics, {len(resources)} other files')


def js_assign(name, value):
    return f'window.{name} = {json.dumps(value, ensure_ascii=True, separators=(",", ":"))};\n'.encode('ascii')


def index_page(title, default):
    title = title.replace('&', '&amp;').replace('<', '&lt;')
    path, sep, anchor = default.partition('#')
    url = quote(path) + sep + anchor
    return (f'<!DOCTYPE html>\r\n<html>\r\n<head>\r\n  <meta charset="utf-8" />\r\n  <title>{title}</title>\r\n'
            f'  <meta http-equiv="refresh" content="0; url={url}" />\r\n</head>\r\n'
            f'<body>\r\n  <p><a href="{url}">{title}</a></p>\r\n</body>\r\n</html>\r\n').encode('utf-8')


def clean_output(out_dir, root):
    out_dir = out_dir.resolve()
    if out_dir == root or out_dir in root.parents:
        raise BuildError(f'output folder {out_dir} would overwrite the project')
    if out_dir.exists():
        if not out_dir.is_dir():
            raise BuildError(f'{out_dir} is not a folder')
        if any(out_dir.iterdir()) and not (out_dir / ASSET_DIR / 'data.js').is_file():
            raise BuildError(f'{out_dir} is not empty and is not a WebHelp folder made by this script')
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True)


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def main():
    # UTF-8 also when the output goes to a pipe (CHMer), where Python would use the ANSI code page
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, 'reconfigure'):
            stream.reconfigure(encoding='utf-8', errors='replace')
    parser = argparse.ArgumentParser(description='Builds a WebHelp folder from an HTML Help (CHM) project.')
    parser.add_argument('project', type=Path, help='the .hhp project file')
    parser.add_argument('output', type=Path, help='the WebHelp folder to create; a previous build there is replaced')
    args = parser.parse_args()
    try:
        build(args.project, args.output)
    except BuildError as e:
        print(f'error: {e}')
        return 1
    print(f'done, {len(warnings)} warning(s)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
