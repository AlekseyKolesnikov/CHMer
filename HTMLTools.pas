unit HTMLTools;

interface

uses
  System.Classes;

function GetTagText(html, tag: String; Convert: Boolean = True): String;
function FromHTML(html: String): String;
function ToHTML(S: String; WithoutFrasl: Boolean = False): String;

// The links of CSS text: url() and @import
procedure ExtractCSSRefs(const Text: String; Refs: TStrings);
// The links of HTML text: src, href, background, data and poster attributes, url() in style attributes and elements;
// Ids gets the anchors the text defines: id attributes and names of <a>
procedure ExtractHTMLRefs(const Text: String; Refs: TStrings; Ids: TStrings = nil);
// A link into a CHM file (ms-its:, its:, mk:@MSITStore:), which works only in the CHM viewer
function IsCHMLink(const Ref: String): Boolean;
// Path and anchor of a link inside the help; False for an external one (with a scheme or //).
// The path is %-decoded; its slashes are kept as they are
function SplitRef(const Ref: String; out Path, Anchor: String): Boolean;

implementation

uses
  System.SysUtils, System.StrUtils, System.RegularExpressions, SystemUtils;

const
  codes = 234;

  HTML_codes: array [1..codes] of Integer = (
    34, 47, 60, 62, 130, 132, 134, 135, 137, 139, 145, 146, 147, 148, 153, 155, 160, 161, 162, 163, 164, 165, 166,
    167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189,
    190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212,
    213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235,
    236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 402, 913, 914,
    915, 916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 926, 927, 928, 929, 931, 932, 933, 934, 935, 936, 937, 945,
    946, 947, 948, 949, 950, 951, 952, 953, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964, 965, 966, 967, 968,
    969, 977, 978, 982, 8226, 8230, 8242, 8243, 8254, 8465, 8472, 8476, 8501, 8592, 8593, 8594, 8595, 8596, 8629, 8656,
    8657, 8658, 8659, 8660, 8704, 8706, 8707, 8709, 8711, 8712, 8713, 8715, 8719, 8721, 8722, 8727, 8730, 8733, 8734,
    8736, 8743, 8744, 8745, 8746, 8747, 8756, 8764, 8773, 8776, 8800, 8801, 8804, 8805, 8834, 8835, 8836, 8838, 8839,
    8853, 8855, 8869, 8901, 8968, 8969, 8970, 8971, 9001, 9002, 9674, 9824, 9827, 9829, 9830
  );

  HTML_signs: array [1..codes] of String = (
    '&quot;', '&frasl;', '&lt;', '&gt;', '&sbquo;', '&bdquo;', '&dagger;', '&Dagger;', '&permil;', '&lsaquo;',
    '&lsquo;', '&rsquo;', '&ldquo;', '&rdquo;', '&trade;', '&rsaquo;', '&nbsp;', '&iexcl;', '&cent;', '&pound;', '&curren;',
    '&yen;', '&brvbar;', '&sect;', '&uml;', '&copy;', '&ordf;', '&laquo;', '&not;', '&shy;', '&reg;', '&macr;', '&deg;',
    '&plusmn;', '&sup2;', '&sup3;', '&acute;', '&micro;', '&para;', '&middot;', '&cedil;', '&sup1;', '&ordm;', '&raquo;',
    '&frac14;', '&frac12;', '&frac34;', '&iquest;', '&Agrave;', '&Aacute;', '&Acirc;', '&Atilde;', '&Auml;', '&Aring;',
    '&AElig;', '&Ccedil;', '&Egrave;', '&Eacute;', '&Ecirc;', '&Euml;', '&Igrave;', '&Iacute;', '&Icirc;', '&Iuml;',
    '&ETH;', '&Ntilde;', '&Ograve;', '&Oacute;', '&Ocirc;', '&Otilde;', '&Ouml;', '&times;', '&Oslash;', '&Ugrave;',
    '&Uacute;', '&Ucirc;', '&Uuml;', '&Yacute;', '&THORN;', '&szlig;', '&agrave;', '&aacute;', '&acirc;', '&atilde;',
    '&auml;', '&aring;', '&aelig;', '&ccedil;', '&egrave;', '&eacute;', '&ecirc;', '&euml;', '&igrave;', '&iacute;',
    '&icirc;', '&iuml;', '&eth;', '&ntilde;', '&ograve;', '&oacute;', '&ocirc;', '&otilde;', '&ouml;', '&divide;',
    '&oslash;', '&ugrave;', '&uacute;', '&ucirc;', '&uuml;', '&yacute;', '&thorn;', '&yuml;', '&fnof;', '&Alpha;',
    '&Beta;', '&Gamma;', '&Delta;', '&Epsilon;', '&Zeta;', '&Eta;', '&Theta;', '&Iota;', '&Kappa;', '&Lambda;', '&Mu;',
    '&Nu;', '&Xi;', '&Omicron;', '&Pi;', '&Rho;', '&Sigma;', '&Tau;', '&Upsilon;', '&Phi;', '&Chi;', '&Psi;', '&Omega;',
    '&alpha;', '&beta;', '&gamma;', '&delta;', '&epsilon;', '&zeta;', '&eta;', '&theta;', '&iota;', '&kappa;', '&lambda;',
    '&mu;', '&nu;', '&xi;', '&omicron;', '&pi;', '&rho;', '&sigmaf;', '&sigma;', '&tau;', '&upsilon;', '&phi;', '&chi;',
    '&psi;', '&omega;', '&thetasym;', '&upsih;', '&piv;', '&bull;', '&hellip;', '&prime;', '&Prime;', '&oline;', '&image;',
    '&weierp;', '&real;', '&alefsym;', '&larr;', '&uarr;', '&rarr;', '&darr;', '&harr;', '&crarr;', '&lArr;', '&uArr;',
    '&rArr;', '&dArr;', '&hArr;', '&forall;', '&part;', '&exist;', '&empty;', '&nabla;', '&isin;', '&notin;', '&ni;',
    '&prod;', '&sum;', '&minus;', '&lowast;', '&radic;', '&prop;', '&infin;', '&ang;', '&and;', '&or;', '&cap;', '&cup;',
    '&int;', '&there4;', '&sim;', '&cong;', '&asymp;', '&ne;', '&equiv;', '&le;', '&ge;', '&sub;', '&sup;', '&nsub;',
    '&sube;', '&supe;', '&oplus;', '&otimes;', '&perp;', '&sdot;', '&lceil;', '&rceil;', '&lfloor;', '&rfloor;', '&lang;',
    '&rang;', '&loz;', '&spades;', '&clubs;', '&hearts;', '&diams;'
  );

function GetTagText(html, tag: String; Convert: Boolean = True): String;
var
  i: Integer;
  LowerHTML: String;
begin
  Result := '';

  tag := AnsiLowerCase(tag);
  LowerHTML := AnsiLowerCase(html);

  i := Pos('</' + tag + '>', LowerHTML);
  if i < 1 then
    Exit;

  SetLength(html, i - 1);
  SetLength(LowerHTML, i - 1);

  i := Pos('<' + tag + '>', LowerHTML);
  if i < 1 then
    Exit;

  Delete(html, 1, i + Length(tag) + 1);

  if Convert then
    html := FromHTML(html);

  Result := html;
end;

function FromHTML(html: String): String;
var
  i: Integer;
begin
  Result := html;

  if Pos('&', Result) > 0 then
  begin
    for i := 1 to codes do
      Result := StringReplace(Result, HTML_signs[i], Char(HTML_codes[i]), [rfReplaceAll]);
    Result := StringReplace(Result, '&amp;', Char(38), [rfReplaceAll]);
  end;
end;

function ToHTML(S: String; WithoutFrasl: Boolean = False): String;
var
  i: Integer;
begin
  Result := S;

  Result := StringReplace(Result, Char(38), '&amp;', [rfReplaceAll]);
  for i := 1 to codes do
    Result := StringReplace(Result, Char(HTML_codes[i]), HTML_signs[i], [rfReplaceAll]);

  if WithoutFrasl then
    Result := StringReplace(Result, '&frasl;', '/', [rfReplaceAll]);
end;

// %XX sequences as UTF-8 bytes; unlike TNetEncoding.URL.Decode it keeps '+', which is valid in a file name
function DecodePercent(const S: String): String;
const
  HexDigits = ['0'..'9', 'a'..'f', 'A'..'F'];
var
  Src, Dst: TBytes;
  i, n: Integer;
begin
  if Pos('%', S) = 0 then
    Exit(S);

  Src := TEncoding.UTF8.GetBytes(S);
  SetLength(Dst, Length(Src));
  i := 0;
  n := 0;

  while i < Length(Src) do
  begin
    if (Src[i] = Ord('%')) and (i + 2 < Length(Src)) and CharInSet(Char(Src[i + 1]), HexDigits) and
      CharInSet(Char(Src[i + 2]), HexDigits) then
    begin
      Dst[n] := StrToInt('$' + Char(Src[i + 1]) + Char(Src[i + 2]));
      Inc(i, 3);
    end
    else
    begin
      Dst[n] := Src[i];
      Inc(i);
    end;

    Inc(n);
  end;

  Result := DecodeText(Dst, 0, n);
end;

procedure ExtractCSSRefs(const Text: String; Refs: TStrings);
const
  sRef = 'url\(\s*["'']?([^"'')]+)|@import\s+["'']([^"'']+)';
var
  Ref: TMatch;
  i: Integer;
begin
  for Ref in TRegEx.Matches(TRegEx.Replace(Text, '/\*.*?\*/', '', [roSingleLine]), sRef, [roIgnoreCase]) do
    for i := 1 to Ref.Groups.Count - 1 do
      if Ref.Groups[i].Success and (Trim(Ref.Groups[i].Value) <> '') then
        Refs.Add(Trim(Ref.Groups[i].Value));
end;

// The non-empty groups of the matches of Pattern, with the HTML entities decoded
procedure AddValues(const Text, Pattern: String; Values: TStrings);
var
  Value: TMatch;
  i: Integer;
begin
  for Value in TRegEx.Matches(Text, Pattern, [roIgnoreCase]) do
    for i := 1 to Value.Groups.Count - 1 do
      if Value.Groups[i].Success and (Value.Groups[i].Value <> '') then
        Values.Add(FromHTML(Value.Groups[i].Value));
end;

procedure ExtractHTMLRefs(const Text: String; Refs: TStrings; Ids: TStrings = nil);
const
  // A comment, a script or style element, or another start tag
  sTag = '<!--.*?-->|<script\b[^>]*>.*?</script\s*>|<style\b[^>]*>.*?</style\s*>|<[a-z][^>]*>';
  sValue = '\s*=\s*(?:"([^"]*)"|''([^'']*)''|([^\s"''>]+))';
  // The whitespace before the name keeps out data-src and the like
  sAttr = '\s(?:src|href|background|data|poster)' + sValue;
  sId = '\sid' + sValue;
  sName = '\sname' + sValue;
var
  Tag: TMatch;
  S: String;
begin
  for Tag in TRegEx.Matches(Text, sTag, [roIgnoreCase, roSingleLine]) do
  begin
    S := Tag.Value;

    if StartsText('<!--', S) then
      Continue;

    if StartsText('<style', S) then
    begin
      ExtractCSSRefs(S, Refs);
      Continue;
    end;

    if StartsText('<script', S) then
      SetLength(S, Pos('>', S)); // the start tag only: the code may contain anything

    AddValues(S, sAttr, Refs);
    ExtractCSSRefs(S, Refs); // url() in a style attribute

    if Assigned(Ids) then
    begin
      AddValues(S, sId, Ids);

      if TRegEx.IsMatch(S, '^<a\s', [roIgnoreCase]) then // name of <param>, <input>... is not an anchor
        AddValues(S, sName, Ids);
    end;
  end;
end;

function IsCHMLink(const Ref: String): Boolean;
begin
  Result := TRegEx.IsMatch(Trim(Ref), '^(mk:@msitstore|ms-its|its):', [roIgnoreCase]);
end;

function SplitRef(const Ref: String; out Path, Anchor: String): Boolean;
var
  k: Integer;
begin
  Path := Trim(Ref);
  Anchor := '';

  // Two letters at least before the colon: C:\file is a (broken) local file, not a scheme
  Result := (Path <> '') and not StartsText('//', Path) and not TRegEx.IsMatch(Path, '^[a-z][a-z0-9+.-]+:', [roIgnoreCase]);

  if not Result then
    Exit;

  k := Pos('#', Path);

  if k > 0 then
  begin
    Anchor := Copy(Path, k + 1, MaxInt);
    SetLength(Path, k - 1);
  end;

  k := Pos('?', Path);

  if k > 0 then
    SetLength(Path, k - 1);

  Path := DecodePercent(Path);
end;

end.

