unit SystemUtils;

interface

uses
  Classes, Vcl.StdCtrls;

const
  eimShowStdOut = 1;
  eimShowStdErrIfErr = 2;
  eimShowStdErr = 4;

function ExecInMemo(CommandLine, Dir: string; Memo: TMemo; Show: Integer; Debug: Boolean = False): Cardinal;
function GetFileList(Path: String; Masks: array of String): TStringList;
function GetLocaleName(Code, CodeType: Cardinal): String;
function IntegerToHex(Value: Integer): string;


implementation

uses
  SysUtils, Windows, Vcl.Forms;

function ExecInMemo(CommandLine, Dir: string; Memo: TMemo; Show: Integer; Debug: Boolean = False): Cardinal;
const
  BufSize = 4096;
var
  SA: TSecurityAttributes;
  PI: TProcessInformation;
  SI: TStartupInfo;
  hReadOut, hWriteOut, hReadErr, hWriteErr: NativeUInt;
  dwAvailOut, dwAvailErr: Cardinal;
  hsBuffOut, hsBuffErr: THandleStream;
  TempBuf: TStringList;
  StrOut, StrErr: TStringList;
  resMsg: Cardinal;
begin
  //Init
  SA.nLength := SizeOf(SECURITY_ATTRIBUTES);
  SA.bInheritHandle := True;
  SA.lpSecurityDescriptor := nil;

  if not CreatePipe(hReadOut, hWriteOut, @SA, 0) then
  begin
    Result := 5;
    Memo.Lines.Add('ERROR: can''t create output pipe!');
    Exit;
  end;

  if not CreatePipe(hReadErr, hWriteErr, @SA, 0) then
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
    hsBuffOut := THandleStream.Create(hReadOut);
    hsBuffErr := THandleStream.Create(hReadErr);
    TempBuf := TStringList.Create;

    //Waiting...
    //WaitForSingleObject(PI.hProcess, INFINITE);
    //MsgWaitForMultipleObjects(1, PI.hProcess, False, INFINITE, QS_ALLINPUT);
    repeat
      TempBuf.Clear();
      if hsBuffOut.Size > 0 then
        TempBuf.LoadFromStream(hsBuffOut); //moving block to the buffer
      StrOut.AddStrings(TempBuf);

      TempBuf.Clear();
      if hsBuffErr.Size > 0 then
        TempBuf.LoadFromStream(hsBuffErr); //moving block to the buffer
      StrErr.AddStrings(TempBuf);

      //Waiting...
      //WaitForSingleObject(PI.hProcess, INFINITE);
      resMsg := MsgWaitForMultipleObjects(1, PI.hProcess, False, INFINITE, QS_ALLINPUT);
      //Is pipe empty ?
      PeekNamedPipe(hReadOut, nil, 0, nil, @dwAvailOut, nil);
      PeekNamedPipe(hReadErr, nil, 0, nil, @dwAvailErr, nil);
      Application.ProcessMessages;
    until (dwAvailOut = 0) and (dwAvailErr = 0) and (resMsg <> WAIT_OBJECT_0 + 1);

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

    FreeAndNil(hsBuffOut);
    FreeAndNil(hsBuffErr);
    FreeAndNil(TempBuf);
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

end.

