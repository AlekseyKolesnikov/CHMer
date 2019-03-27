{ WAK Productions Presents: }
{ THyperParse    version 1.02 }
{ Copyright ©2002 - WAK Productions }
{ --------------------------------- }
{ Programmed by Winston Kotzan }
{ Email: support@wakproductions.com }
{ Website URL: http://www.wakproductions.com/ }
{
  This Delphi component gives developers an easy way to examine the contents
  of an HTML file.  Place the units HyperParse.pas and Latin1.pas in a directory
  on your project's path (don't install as a component on the IDE).  Then include
  HyperParse.pas in the uses clause of the units that will be using the parser.
}
{ }
{
  Note: Some parts of this component are based on code from HTMLParser
  v1.02 by Dennis Spreen.
}
{ }
{ To use the parser: }
{ 1. Create a THyperParse object }
{ 2. Set the FileName property to the file to be parsed }
{ 3. Run the execute method }
{ 4. The contents of the parsed file can be accessed by the }
{ 'Item' property }
{ }
{
  Each item in the 'Item' property is a THtmlInfo object. If the
  THtmlInfo.IsTag property is false, then the object contains plain
  text.  If the THtmlInfo.IsTag property is true, then the object
  contains an HTML tag. Also, the HTML tag's parameters can be viewed
  via the THtmlInfo.Params property.
}
{ }
{
  Version History
  ---------------
  2019-03-26, Alexey Kolesnikov - memory leaks fixed in THtmlInfo.Destroy

  *1.02-
  - Memory leak in THTMLInfo.Destroy() fixed.  Thank you to Saeed Sedighian
  for reporting the error.
  - In GetNextParameter() of THtmlInfo.ParseTag, the while loop on line 3, which
  read:

  if (FText[Position] <= ' ') then Inc(Position) else break;

  ... incremented Position past the end of the string, causing a Range Check
  error on the next line.  This has been fixed.

  Thank you to both Cameron Leaver and Saeed Sedighian for finding this bug!
}
unit HyperParse;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  PHtmlParameter = ^THtmlParameter;

  { Param - The complete HTML parameter as it appears in the tag. }
  { Name - Name of the HTML parameter }
  { Value - Value of the HTML parameter }
  THtmlParameter = record
    Param: string;
    Name: string;
    Value: string;
  end;

  THtmlInfo = class(TObject)
  private
    FIsTag: boolean;
    FParamList: TList;
    FTagName: string;
    FText: string;
    function CreateNewParam: PHtmlParameter;
    function GetParams(Index: integer): THtmlParameter;
    function GetParamCount: integer;
  protected
    procedure ParseTag;
    procedure SetEntities;
  public
    { Do not use this function.  Only for internal use by THyperParse. }
    constructor Create(IsTagValue: boolean);
    { Do not use this function.  Only for internal use by THyperParse. }
    destructor Destroy; override;
    { Finds the value for the given parameter in ParamName. For example, in: }
    { }
    { <A HREF="http://www.wakproductions.com/"> }
    { }
    { Passing 'HREF' as ParamName would return the URL.  If the given }
    { does not exist, it returns a blank string. }
    function FindParamValue(ParamName: string): string;
    { True if the THtmlInfo structure contains information for an HTML tag,
      false if it contains plain text. }
    property IsTag: boolean read FIsTag;
    { Used to read the parameters of an HTML tag. }
    property Params[Index: integer]: THtmlParameter read GetParams;
    { Number of parameters for an HTML tag. }
    property ParamCount: integer read GetParamCount;
    { The name of the HTML tag }
    property TagName: string read FTagName;
    { If IsTag is false, then this contains plain text (not inside an HTML
      tag).  If IsTag is true, then this contains the complete HTML tag as
      read from the file }
    property Text: string read FText write FText;
  end;

  THyperParse = class(TObject)
  private
    FileLines: TStringList;
    FFileName: string; // File to parse
    ParseList: TList;
    function GetCount: integer;
    function GetIndex(Index: integer): THtmlInfo;
  public
    { Use this to create a new instance of THyperParse }
    constructor Create;
    { Destroys an instnace of THyperParse.  Do not call this directly.
      Use the Free method instead. }
    destructor Destroy; override;
    { This method will read the file in the FileName property and place the
      parsed data in the Items property. }
    procedure Execute;
    { The number of THtmlInfo structures in the Items property }
    property Count: integer read GetCount;
    { The path of the file to be parsed. After setting this property, use the
      Execute method to run the parsing process. }
    property FileName: string read FFileName write FFileName;
    { Returns the THtmlInfo structure at Index. }
    property Item[Index: integer]: THtmlInfo read GetIndex; default;
  end;

implementation

{ *****************  THtmlInfo  ***************** }

constructor THtmlInfo.Create(IsTagValue: boolean);
begin
  inherited Create;
  FIsTag := IsTagValue;
  FParamList := TList.Create;
end;

destructor THtmlInfo.Destroy;
var
  i: Integer;
begin
  for i := 0 to FParamList.Count - 1 do
  begin
    PHtmlParameter(FParamList[i])^.Param := '';
    PHtmlParameter(FParamList[i])^.Name := '';
    PHtmlParameter(FParamList[i])^.Value := '';
    FreeMem(FParamList[i]);
  end;

  FParamList.Free;

  inherited Destroy;
end;

function THtmlInfo.GetParams(Index: integer): THtmlParameter;
begin
  Result := PHtmlParameter(FParamList[Index])^;
end;

function THtmlInfo.GetParamCount: integer;
begin
  Result := FParamList.Count;
end;

function THtmlInfo.CreateNewParam: PHtmlParameter;
var
  NewParam: PHtmlParameter;
begin
  New(NewParam);
  FParamList.Add(NewParam);
  Result := NewParam;
end;

function THtmlInfo.FindParamValue(ParamName: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to ParamCount - 1 do
    if CompareText(Params[i].Name, ParamName) = 0 then
    begin
      Result := Params[i].Value;
      break;
    end;
end;

procedure THtmlInfo.ParseTag;

{ Gets the next word or tag parameter in an Html tag }
  function GetNextParameter(var Position: integer): string;
  begin
    Result := '';
    while Position < Length(FText) do // Move to first character of next word
      if (FText[Position] = ' ') then
        Inc(Position)
      else
        break;
    while (Position <= Length(FText)) and (FText[Position] <> '=') and
      (FText[Position] <> ' ') do // Start copying the parameter name
    begin
      Result := Result + Copy(FText, Position, 1);
      Inc(Position);
    end;

    if FText[Position] = '=' then
    // This parameter has a value (some parameter's don't!)
      if FText[Position + 1] = '"' then // Parameter has quotes
      begin
        Result := Result + Copy(FText, Position, 3);
        // Copy the = , " , and first char of param.
        Position := Position + 3;
        if FText[Position - 1] <> '"' then
        // parameter was not empty   (value="")
          repeat
            Result := Result + FText[Position];
            Inc(Position);
          until (Position > Length(FText)) or (FText[Position - 1] = '"');
      end
      else
        while (Position <= Length(FText)) and (FText[Position] <> ' ') do
        // Parameter does not have quotes
        begin
          Result := Result + FText[Position];
          Inc(Position);
        end;
  end;

{ Parses the name and value of a parameter }
  procedure ParseParameter(var FullStr: string; out NameOut, ValueOut: string);

    procedure StripQuotes(var Str: string);
    var
      QuotPos: integer;
    begin
      repeat
        QuotPos := Pos('"', Str);
        if QuotPos <> 0 then
          Delete(Str, QuotPos, 1);
      until QuotPos = 0;
    end;

  var
    CurrentChar: PChar;
  begin
    FullStr := FullStr + #0;
    CurrentChar := @FullStr[1];
    NameOut := '';
    ValueOut := '';
    while (CurrentChar^ <> '=') and (CurrentChar^ <> #0) do
    begin
      NameOut := NameOut + CurrentChar^; // Param Name
      Inc(CurrentChar);
    end;
    if CurrentChar^ = '=' then
      Inc(CurrentChar); // Skip the = character
    while CurrentChar^ <> #0 do
    begin
      ValueOut := ValueOut + CurrentChar^; // Get value
      StripQuotes(ValueOut);
      Inc(CurrentChar);
    end;
    Delete(FullStr, Length(FullStr), 1); // Delete the #0
  end;

var
  i: integer;
  NextWord, NameOut, ValueOut, ParamStr: string;
  NewParam: PHtmlParameter;
begin { For Html tags, this will parse the tag's parameters }
  i := 1;
  FTagName := UpperCase(GetNextParameter(i)); // First should be the HTML tag

  if Length(FTagName) >= 3 then
    if CompareStr(Copy(FTagName, 1, 3), '!--') = 0 then
    // This is a comment - has no parameters
    begin
      i := 4;
      while (FText[i] = ' ') do
        Inc(i);
      NewParam := CreateNewParam;
      ParamStr := Copy(FText, i, Length(FText) - i);
      while (ParamStr[Length(ParamStr)] = ' ') or
        (ParamStr[Length(ParamStr)] = '-') do
        Delete(ParamStr, Length(ParamStr), 1);
      // Remove any trailing spaces and trailing '--'
      NewParam^.Param := ParamStr;
      Exit;
    end;

  // Normal tag - may have parameters
  while i <= Length(FText) do
  begin
    NextWord := GetNextParameter(i);
    if NextWord = '' then
      break // There aren't any parameters left
    else
    begin
      NewParam := CreateNewParam;
      ParseParameter(NextWord, NameOut, ValueOut);
      NewParam^.Param := NextWord;
      NewParam^.Name := NameOut;
      NewParam^.Value := ValueOut;
    end;
  end;
end;

{$I latin1.pas}

procedure THtmlInfo.SetEntities;
var
  j, i: integer;
  isEntity: boolean;
  Entity: string;
  EnLen, EnPos: integer;
  d, c: integer;
begin
  i := 1;
  isEntity := false;
  EnPos := 0;
  while (i <= Length(FText)) do
  begin
    if FText[i] = '&' then
    begin
      EnPos := i;
      isEntity := true;
      Entity := '';
    end;
    if isEntity then
      Entity := Entity + FText[i];
    if isEntity then
      if (FText[i] = ';') or (FText[i] = ' ') then
      begin
        EnLen := Length(Entity);
        // charset encoded entity
        if (EnLen > 2) and (Entity[2] = '#') then
        begin
          Delete(Entity, EnLen, 1); // delete the ;
          Delete(Entity, 1, 2); // delete the &#
          if UpperCase(Entity[1]) = 'X' then
            Entity[1] := '$'; // it's hex (but not supported!!!)
          if (Length(Entity) <= 3) then
          // we cant convert e.g. cyrillic/chinise capitals
          begin
            val(Entity, d, c);
            if c = 0 then // conversion successful
            begin
              Delete(FText, EnPos, EnLen);
              insert(Charset[d], FText, EnPos);
              i := EnPos; // set new start
            end;
          end;
        end
        else
        begin // its an entity
          j := 1;
          while j <= 100 do
          begin
            if Entity = (Entities[j, 1]) then
            begin
              Delete(FText, EnPos, EnLen);
              insert(Entities[j, 2], FText, EnPos);
              j := 102; // stop searching
            end;
            Inc(j);
          end;
          // reset FText
          if j = 103 then
            i := EnPos - 1
          else
            i := EnPos;
        end;
        isEntity := false;
      end;
    Inc(i);
  end;
end;

{ *****************  THyperParse  ***************** }

constructor THyperParse.Create;
begin
  inherited Create;
  FileLines := TStringList.Create;
  ParseList := TList.Create;
end;

destructor THyperParse.Destroy;
var
  i: integer;
begin
  FileLines.Free;

  for i := 0 to ParseList.Count - 1 do
    THtmlInfo(ParseList[i]).Free;

  ParseList.Free;
  inherited Destroy;
end;

procedure THyperParse.Execute;
var
  CurrentTag: THtmlInfo;

  procedure CloseCurrentTag;
  begin
    // Sets up the structure
    if Assigned(CurrentTag) then
    begin
      if CurrentTag.IsTag then
      begin
        CurrentTag.ParseTag;
      end
      else
        CurrentTag.SetEntities;
      CurrentTag := nil;
    end;
  end;

  procedure StartNewTag(IsTagValue: boolean);
  begin
    CloseCurrentTag;
    CurrentTag := THtmlInfo.Create(IsTagValue);
    ParseList.Add(CurrentTag);
    CurrentTag.FIsTag := IsTagValue;
  end;

var
  NextChar: PChar;
  FileSL: TStringList;
  InTag: boolean;
  i: Cardinal;
begin
  CurrentTag := nil;
  InTag := false;
  FileSL := TStringList.Create;
  FileSL.LoadFromFile(FFileName);
  NextChar := @FileSL.Text[1];
  try
    for i := 1 to Length(FileSL.Text) do
    begin
      if NextChar^ = '<' then
      begin
        if not InTag then
        // Only start a new tag if the current tag has been closed by a '>'
        begin
          StartNewTag(true);
          InTag := true;
        end;
      end
      else if NextChar^ = '>' then
      begin
        CloseCurrentTag;
        InTag := false;
      end
      else if (not Assigned(CurrentTag)) and (Ord(NextChar^) >= 21) and
        (InTag = false) then
      begin // Start a new Text structure after an HTML tag has been closed
        StartNewTag(false);
        if Ord(NextChar^) > 33 then
          CurrentTag.FText := NextChar^;
      end
      else if (Ord(NextChar^) >= 32) and (Assigned(CurrentTag)) then
        CurrentTag.FText := CurrentTag.FText + NextChar^;
      Application.ProcessMessages;
      Inc(NextChar);
    end;
    CloseCurrentTag;
  finally
    FileSL.Free;
  end;
end;

function THyperParse.GetCount: integer;
begin
  Result := ParseList.Count;
end;

function THyperParse.GetIndex(Index: integer): THtmlInfo;
begin
  Result := THtmlInfo(ParseList[Index]);
end;

end.
