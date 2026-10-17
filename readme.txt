CHMer 1.2.3
Copyright (C) 2019-2026 by Alexey Kolesnikov.
Email: ak@blu-disc.net
Website: https://github.com/AlekseyKolesnikov/CHMer


A simple CHM and WebHelp creation tool.

Requires:
  * Microsoft HTML Help Workshop (https://blu-disc.net/download/htmlhelp.exe) - for CHM
  * build_webhelp.exe next to CHMer.exe (included) - for WebHelp, Python is not needed

Uses:
  * SynEdit (https://github.com/SynEdit/SynEdit)
  * Rx Library (http://www.micrel.cz/RxLib/dfiles.htm)
  * HyperParse by Winston Kotzan (included)
  * PyInstaller (https://pyinstaller.org) - to build build_webhelp.exe

Features:
  * Update HTML titles with tree titles - scans all used htmls and replaces <title>...</title> with the corresponding names of the content tree nodes.
  * Validate project - follows the links from the contents pages, the default topic and the Home/Jump buttons through all the pages and stylesheets they reference (src, href, background, data, poster, url() and @import), and reports:
    Missed file - a link to a file that doesn't exist; Missed anchor - a #anchor not found in its page (ids and <a name>, case-sensitive as in browsers; #top is always valid);
    Outside project - a link to a file outside the project folder; CHM-only link - ms-its:, its: or mk:@MSITStore: links, which work only in the CHM viewer;
    File not found / File is used twice - contents items; Not in contents - a page that is linked but not in the contents, so it is missing from the WebHelp;
    File not used / Image not used - HTMLs and images in the project folder and its subfolders that nothing links to (the WebHelp output folder is skipped, the tab icon and dark images of used ones count as used); No regular image - a dark image without a regular one.
    A problem found in several places is reported once with up to three of them. The project must be saved first, as files are found relative to its folder.
  * Ctrl+Space in the HTML editor opens the context menu for inserting a tag/symbol.
  * Compile WebHelp (Ctrl+F9) - an HTML version of the help with contents, index and search that works from a local folder or a web server. The output folder is set in Project settings (relative to the project folder); when it is empty, the build asks for it, and Shift+click the button selects another one. The folder must be empty or contain a previous WebHelp: it is replaced on every build. The tab icon (.ico, .png, .svg or .gif, also set in Project settings) is shown by browsers in the page tab, like a site's favicon; topics that link their own icon keep it.
  * WebHelp dark theme - the help opens in the light theme; the button at the top right switches between light and dark, and the choice is remembered. TOPIC.htm?theme=dark (or ?theme=light, also index.html?theme=dark) opens the help in that theme, so an application can open it in its own theme; the reader can still switch. Note that opening a local file with ShellExecute drops ?theme=... and #anchor: start the browser with the file:/// URL, or open a temporary .html that goes there with location.replace("file:///...").
    Dark images: FOLDER\dark\NAME (the same file name) is the dark version of the image FOLDER\NAME. It is shown in the dark theme, the regular image otherwise; the CHM doesn't include it. A dark image without a regular one is reported, as it is most likely misnamed.
    Colors set by the topics' own stylesheet are changed for the dark theme with html[data-wh-theme="dark"] rules, e.g. html[data-wh-theme="dark"] .code { background-color: #2D333B; } - the CHM ignores them. Inline colors (style="color: black") can't be changed this way, use classes instead.
  * CHMer settings, like the WebHelp output folder, are stored in the .hhp as comment lines after "; [CHMer]", so HTML Help Workshop ignores them.

Building build_webhelp.exe:
  The WebHelp is built by WebHelp\build_webhelp.py. WebHelp\build_webhelp_exe.bat compiles it into build_webhelp.exe, so users don't need Python.
  Requires:
    * Python 3.8 or later (https://www.python.org/downloads/windows/). The exe runs on the Windows versions this Python supports (Python 3.8 is the last one for Windows 7) and is 64-bit when this Python is 64-bit.
    * Internet access on the first run: PyInstaller is downloaded into a private virtual environment in %TEMP%\CHMer_build_webhelp, the system Python is not changed.
  Run WebHelp\build_webhelp_exe.bat - it copies build_webhelp.exe to bin and bin64, next to CHMer.exe.
  Run it again after changing build_webhelp.py, webhelp.js or webhelp.css: they are packed into the exe.
