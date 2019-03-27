unit HTMLTools;

interface

function GetTagText(html, tag: String): String;
function FromHTML(html: String): String;
function ToHTML(S: String): String;

implementation

uses
  System.SysUtils;

const
  codes = 235;

  HTML_codes: array [1..codes] of Integer = (
    34, 38, 47, 60, 62, 130, 132, 134, 135, 137, 139, 145, 146, 147, 148, 153, 155, 160, 161, 162, 163, 164, 165, 166,
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
    '&quot;', '&amp;', '&frasl;', '&lt;', '&gt;', '&sbquo;', '&bdquo;', '&dagger;', '&Dagger;', '&permil;', '&lsaquo;',
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

function GetTagText(html, tag: String): String;
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

  Result := FromHTML(html);
end;

function FromHTML(html: String): String;
var
  i: Integer;
begin
  Result := html;
  if Pos('&', Result) > 0 then
    for i := 1 to codes do
      Result := StringReplace(Result, HTML_signs[i], Char(HTML_codes[i]), [rfReplaceAll]);
end;

function ToHTML(S: String): String;
var
  i: Integer;
begin
  Result := S;
  for i := 1 to codes do
    Result := StringReplace(Result, Char(HTML_codes[i]), HTML_signs[i], [rfReplaceAll]);
end;

end.

