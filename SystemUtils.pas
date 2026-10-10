unit SystemUtils;

interface

uses
  Classes, SysUtils, Vcl.StdCtrls;

const
  eimShowStdOut = 1;
  eimShowStdErrIfErr = 2;
  eimShowStdErr = 4;

// Encoding is the encoding of the program's output; nil means the ANSI code page (or the one of a BOM)
function ExecInMemo(CommandLine, Dir: string; Memo: TMemo; Show: Integer; Debug: Boolean = False;
  Encoding: TEncoding = nil): Cardinal;
// A relative Path is resolved against BaseDir (\path against its drive), one with a drive or UNC is only normalized
function ExpandPath(const BaseDir, Path: String): String;
function GetFileList(Path: String; Masks: array of String): TStringList;
function GetLocaleName(Code, CodeType: Cardinal): String;
function IntegerToHex(Value: Integer): string;
// Path relative to BaseDir; it stays absolute on another drive
function RelativePath(const BaseDir, Path: String): String;


implementation

uses
  Windows, Vcl.Forms;

function ExecInMemo(CommandLine, Dir: string; Memo: TMemo; Show: Integer; Debug: Boolean = False;
  Encoding: TEncoding = nil): Cardinal;
const
  // The pipes are read without blocking, so they are polled: a program that fills a pipe waits until it is read
  PipeSize = 65536;
  PollTime = 10;
var
  SA: TSecurityAttributes;
  PI: TProcessInformation;
  SI: TStartupInfo;
  hReadOut, hWriteOut, hReadErr, hWriteErr: NativeUInt;
  dwAvailOut, dwAvailErr: Cardinal;
  BuffOut, BuffErr: TMemoryStream;
  StrOut, StrErr: TStringList;
  resMsg: Cardinal;

  // Keeps the raw bytes: they are decoded at the end, so a character split between two reads stays intact
  procedure ReadPipe(hRead: NativeUInt; Buff: TMemoryStream);
  var
    dwAvail, dwRead: Cardinal;
    Chunk: TBytes;
  begin
    while PeekNamedPipe(hRead, nil, 0, nil, @dwAvail, nil) and (dwAvail > 0) do
    begin
      SetLength(Chunk, dwAvail);
      if not ReadFile(hRead, Chunk[0], dwAvail, dwRead, nil) or (dwRead = 0) then
        Break;
      Buff.WriteBuffer(Chunk[0], dwRead);
    end;
  end;

begin
  //Init
  SA.nLength := SizeOf(SECURITY_ATTRIBUTES);
  SA.bInheritHandle := True;
  SA.lpSecurityDescriptor := nil;

  if not CreatePipe(hReadOut, hWriteOut, @SA, PipeSize) then
  begin
    Result := 5;
    Memo.Lines.Add('ERROR: can''t create output pipe!');
    Exit;
  end;

  if not CreatePipe(hReadErr, hWriteErr, @SA, PipeSize) then
  begin
    Result := 6;
    Memo.Lines.Add('ERROR: can''t create error pipe!');
    CloseHandle(hReadOut);
    CloseHandle(hWriteOut);
    Exit;
  end;

  ZeroMemory(@SI, SizeOf(TStartupInfo));
  SI.cb := SizeOf(TStartupInfo);
  SI.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  if Debug then
    SI.wShowWindow := SW_NORMAL
  else
    SI.wShowWindow := SW_HIDE;
  SI.hStdOutput := hWriteOut;
  SI.hStdError := hWriteErr;
  SI.hStdInput := GetStdHandle(STD_INPUT_HANDLE);

  StrOut := TStringList.Create;
  StrErr := TStringList.Create;

  //Starting up...
  if CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, PChar(Dir), SI, PI) then
  begin
    BuffOut := TMemoryStream.Create;
    BuffErr := TMemoryStream.Create;

    repeat
      ReadPipe(hReadOut, BuffOut);
      ReadPipe(hReadErr, BuffErr);

      //Waiting...
      resMsg := MsgWaitForMultipleObjects(1, PI.hProcess, False, PollTime, QS_ALLINPUT);
      //Is pipe empty ?
      PeekNamedPipe(hReadOut, nil, 0, nil, @dwAvailOut, nil);
      PeekNamedPipe(hReadErr, nil, 0, nil, @dwAvailErr, nil);
      Application.ProcessMessages;
    until (dwAvailOut = 0) and (dwAvailErr = 0) and (resMsg <> WAIT_OBJECT_0 + 1) and (resMsg <> WAIT_TIMEOUT);

    BuffOut.Position := 0;
    StrOut.LoadFromStream(BuffOut, Encoding);
    BuffErr.Position := 0;
    StrErr.LoadFromStream(BuffErr, Encoding);

    GetExitCodeProcess(PI.hProcess, Result);

    if (Show and eimShowStdOut) > 0 then
    begin
      Memo.Lines.AddStrings(StrOut);
      Memo.Lines.Add('');
      Memo.SelStart := Length(Memo.Text);
    end;
    if ((Show and eimShowStdErr) > 0) or
      (((Show and eimShowStdErrIfErr) > 0) and (Result <> 0)) then
    begin
      Memo.Lines.AddStrings(StrErr);
      Memo.Lines.Add('');
      Memo.SelStart := Length(Memo.Text);
    end;

    CloseHandle(PI.hProcess);
    CloseHandle(PI.hThread);

    FreeAndNil(BuffOut);
    FreeAndNil(BuffErr);
  end
  else
  begin
    Result := 7;
    Memo.Lines.Add('ERROR: can''t start application!');
  end;

  FreeAndNil(StrOut);
  FreeAndNil(StrErr);

  CloseHandle(hReadOut);
  CloseHandle(hWriteOut);
  CloseHandle(hReadErr);
  CloseHandle(hWriteErr);
end;

function ExpandPath(const BaseDir, Path: String): String;
begin
  if (BaseDir = '') or (ExtractFileDrive(Path) <> '') then
    Result := Path
  else if (Path <> '') and (Path[1] = PathDelim) then
    Result := ExtractFileDrive(BaseDir) + Path // the root of the BaseDir drive, not of the current one
  else
    Result := IncludeTrailingPathDelimiter(BaseDir) + Path;

  Result := ExpandFileName(Result); // removes ..\ and .\
end;

function GetFileList(Path: String; Masks: array of String): TStringList;
var
  i, iFind: Integer;
  FindRec: TSearchRec;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;

  for i := 0 to Length(Masks) - 1 do
  begin
    iFind := FindFirst(Path + Masks[i], faAnyFile, FindRec);

    if iFind <> 0 then
    begin
      SysUtils.FindClose(FindRec);
      Continue;
    end;

    repeat
      if (FindRec.Attr <> faDirectory) then
        Result.Add(FindRec.Name);
    until FindNext(FindRec) <> 0;

    SysUtils.FindClose(FindRec);
  end;

  Result.Sort;
end;

function GetLocaleName(Code, CodeType: Cardinal): String;
var
  Size: Integer;
begin
  Result := '';
  Size := GetLocaleInfo(Code, CodeType, nil, 0);

  if Size < 1 then
    Exit;

  SetLength(Result, Size);

  GetLocaleInfo(Code, CodeType, @Result[1], Size);

  Result := Trim(Result);
end;

function IntegerToHex(Value: Integer): string;
var
  len: Integer;
  i: Integer;
begin
  Result := IntToHex(Value, 1);

  len := Length(Result);

  for i := 1 to len do
    if Result[i] <> '0' then
    begin
      Delete(Result, 1, i - 1);
      Break;
    end;

  Result := '0x' + Result;
end;

function RelativePath(const BaseDir, Path: String): String;
begin
  if BaseDir = '' then
    Result := Path
  else
    Result := ExtractRelativePath(IncludeTrailingPathDelimiter(BaseDir), Path); // without the delimiter BaseDir is taken as a file name
end;

end.

