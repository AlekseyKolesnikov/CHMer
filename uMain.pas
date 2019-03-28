unit uMain;

// TODO:
// - input fields validation
// - dictionaries (select from list)
// - extend "project was modified" dialog
// - separate application and project settings

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ToolWin, ComCtrls, Grids, ImgList, OleCtrls,
  SHDocVw, SynEditHighlighter, SynHighlighterHtml, SynEdit, StdCtrls, System.ImageList, Vcl.Menus, System.Actions, Vcl.ActnList, RxPlacemnt,
  uHelpProject;

type
  TfrmMain = class(TForm)
    pnTop: TPanel;
    tbMain: TToolBar;
    pnLeft: TPanel;
    splVertical: TSplitter;
    pnRight: TPanel;
    pnProperties: TPanel;
    splHorizontalLeft: TSplitter;
    pnProjectTree: TPanel;
    pnInfo: TPanel;
    splHorizontalRight: TSplitter;
    pnData: TPanel;
    pcMainPages: TPageControl;
    tsPreview: TTabSheet;
    tsHTML: TTabSheet;
    tsKeywords: TTabSheet;
    tvProjectTree: TTreeView;
    sgProperties: TStringGrid;
    ilHelp: TImageList;
    wbBrowser: TWebBrowser;
    seHTML: TSynEdit;
    synHTMLSyn: TSynHTMLSyn;
    memKeyWords: TMemo;
    pnHTMLTop: TPanel;
    tbHTML: TToolBar;
    btnProjectCreate: TToolButton;
    btnProjectLoad: TToolButton;
    btnProjectSave: TToolButton;
    ToolButton2: TToolButton;
    btnProjectCompile: TToolButton;
    btnHTMLSave: TToolButton;
    pmProjectTree: TPopupMenu;
    miAddBefore: TMenuItem;
    miAddAfter: TMenuItem;
    miAddChild: TMenuItem;
    N1: TMenuItem;
    miDelete: TMenuItem;
    alActionList: TActionList;
    actProjectCreate: TAction;
    actProjectLoad: TAction;
    actProjectSave: TAction;
    actProjectCompile: TAction;
    actHTMLSave: TAction;
    ilNormal: TImageList;
    ilGrayed: TImageList;
    ilPopup: TImageList;
    dlgOpenProject: TOpenDialog;
    pmProperties: TPopupMenu;
    miPropertiesAdd: TMenuItem;
    miPropertiesDelete: TMenuItem;
    N2: TMenuItem;
    dlgOpenHTML: TOpenDialog;
    N3: TMenuItem;
    miMoveUp: TMenuItem;
    miMoveDown: TMenuItem;
    miLevelUp: TMenuItem;
    miLevelDown: TMenuItem;
    miLevelInside: TMenuItem;
    actAddBefore: TAction;
    actAddAfter: TAction;
    actAddChild: TAction;
    actMoveUp: TAction;
    actMoveDown: TAction;
    actLevelUp: TAction;
    actLevelDown: TAction;
    actLevelInside: TAction;
    actDelete: TAction;
    pnLeftToolbar: TPanel;
    tbLeftToolbar: TToolBar;
    btnAddBefore: TToolButton;
    btnAddAfter: TToolButton;
    btnAddChild: TToolButton;
    btnMoveUp: TToolButton;
    btnMoveDown: TToolButton;
    btnLevelUp: TToolButton;
    btnLevelDown: TToolButton;
    btnLevelInside: TToolButton;
    btnDelete: TToolButton;
    memInfo: TMemo;
    dlgOpenHHC: TOpenDialog;
    N4: TMenuItem;
    miExpandAll: TMenuItem;
    miCollapseAll: TMenuItem;
    ToolButton4: TToolButton;
    btnUpdateHTML: TToolButton;
    actUpdateHTML: TAction;
    dlgSaveProject: TSaveDialog;
    fsLayout: TFormStorage;
    btnCheckNotUsed: TToolButton;
    actCheckNotUsed: TAction;
    btnSettings: TToolButton;
    ToolButton3: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure tvProjectTreeChange(Sender: TObject; Node: TTreeNode);
    procedure actProjectLoadExecute(Sender: TObject);
    procedure actProjectSaveExecute(Sender: TObject);
    procedure actHTMLSaveExecute(Sender: TObject);
    procedure actProjectSaveUpdate(Sender: TObject);
    procedure memKeyWordsChange(Sender: TObject);
    procedure pmPropertiesPopup(Sender: TObject);
    procedure sgPropertiesDblClick(Sender: TObject);
    procedure miAddBeforeClick(Sender: TObject);
    procedure miAddAfterClick(Sender: TObject);
    procedure miAddChildClick(Sender: TObject);
    procedure miDeleteClick(Sender: TObject);
    procedure tvProjectTreeDeletion(Sender: TObject; Node: TTreeNode);
    procedure miMoveUpClick(Sender: TObject);
    procedure miMoveDownClick(Sender: TObject);
    procedure miLevelUpClick(Sender: TObject);
    procedure miLevelDownClick(Sender: TObject);
    procedure miLevelInsideClick(Sender: TObject);
    procedure actProjectCompileExecute(Sender: TObject);
    procedure miPropertiesAddClick(Sender: TObject);
    procedure miPropertiesDeleteClick(Sender: TObject);
    procedure miExpandAllClick(Sender: TObject);
    procedure miCollapseAllClick(Sender: TObject);
    procedure pmProjectTreePopup(Sender: TObject);
    procedure actUpdateHTMLExecute(Sender: TObject);
    procedure actProjectCreateExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actCheckNotUsedExecute(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
  private
    { Private declarations }
    Project: TProject;
    SelectedObjectData: TObjectData;

    function AddObject: TObjectData;
    procedure CloseProject;
    function ExecInMemo(CommandLine, Dir: string; Memo: TMemo; Show: Integer; Debug: Boolean = False): Cardinal;
    function GetAddContents: Boolean;
    function GetHHC(Request: Boolean = True): String;
    procedure InitProjectData(ProjectData: TProjectData);
    procedure LoadProject(FileName: String);
    procedure PropertiesEditDefaultTopic;
    procedure PropertiesEditImageIndex;
    procedure PropertiesEditName;
    procedure PropertiesEditRootName;
    procedure PropertiesEditURL;
    procedure SaveSettingsHHC(hhc: String);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.UITypes, StrUtils, Registry, uSelectImage, uAddProperty, uSettings, HTMLTools;

const
  eimShowStdOut = 1;
  eimShowStdErrIfErr = 2;
  eimShowStdErr = 4;

  sContent = 'Content';
  sKeyWords = 'Keywords';

  sTitle = 'CHMer';
  sVersion = ' 1.0';

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

procedure TfrmMain.actCheckNotUsedExecute(Sender: TObject);
var
  slFiles, slFilesBackup: TStringList;
  i, j: Integer;
  ObjectData: TObjectData;
begin
  if (not Assigned(Project)) or (Project.PrjDir = '') then
    Exit;

  slFiles := GetFileList(Project.PrjDir, ['*.html', '*.htm']);
  slFilesBackup := TStringList.Create;
  slFilesBackup.Text := slFiles.Text;

  memInfo.Lines.Clear;

  for i := 1 to tvProjectTree.Items.Count - 1 do
  begin
    ObjectData := TObjectData(tvProjectTree.Items[i].Data);
    if ObjectData.URL <> '' then
    begin
      j := slFiles.IndexOf(Trim(ObjectData.URL));
      if j < 0 then
      begin
        if slFilesBackup.IndexOf(Trim(ObjectData.URL)) > -1 then
          memInfo.Lines.Add('File is used twice: ' + ObjectData.URL)
        else
          memInfo.Lines.Add('File not found:     ' + ObjectData.URL);
      end
      else
        slFiles.Delete(j);
    end;
  end;

  for i := 0 to slFiles.Count - 1 do
    memInfo.Lines.Add('File not used:      ' + slFiles[i]);

  slFiles.Free;
  slFilesBackup.Free;
end;

procedure TfrmMain.actHTMLSaveExecute(Sender: TObject);
begin
  if (not Assigned(Project)) or (not Assigned(SelectedObjectData)) then
    Exit;

  seHTML.Lines.SaveToFile(Project.PrjDir + SelectedObjectData.URL);
  wbBrowser.Refresh;
  seHTML.Modified := False;
end;

procedure TfrmMain.actProjectCompileExecute(Sender: TObject);
var
  hhc, S: string;
begin
  hhc := GetHHC;

  if hhc = '' then
    Exit;

  memInfo.Lines.Clear;

  actProjectSaveExecute(nil); // forces AddContents on/off

  try
    btnProjectCompile.Down := True;
    ExecInMemo(hhc + ' ' + Project.ProjectFile, ExtractFileDir(hhc), memInfo, eimShowStdOut or eimShowStdErr);
  finally
    btnProjectCompile.Down := False;
  end;


  S := Trim(memInfo.Lines.Text);
  while Pos(#$D#$A#$D#$A, S) > 0 do
    S := StringReplace(S, #$D#$A#$D#$A, #$D#$A, [rfReplaceAll]);
  memInfo.Lines.Clear;
  memInfo.Lines.Add(S);
end;

procedure TfrmMain.actProjectCreateExecute(Sender: TObject);
begin
  CloseProject;

  Project := TProject.Create('', tvProjectTree.Items);
  tvProjectTree.Selected := tvProjectTree.Items[0];
  Project.Modified := True;
end;

procedure TfrmMain.actProjectLoadExecute(Sender: TObject);
begin
  if dlgOpenProject.Execute then
    LoadProject(dlgOpenProject.FileName);
end;

procedure TfrmMain.actProjectSaveExecute(Sender: TObject);
var
  ProjectData: TProjectData;
  AddContents: Boolean;
begin
  if not Assigned(Project) then
    Exit;

  if Project.ProjectFile = '' then
    if not dlgSaveProject.Execute then
      Exit;

  AddContents := GetAddContents;

  if Project.ProjectFile = '' then
    Project.Save(dlgSaveProject.FileName, AddContents)
  else
    Project.Save('', AddContents);

  if tvProjectTree.Selected = tvProjectTree.Items[0] then
  begin
    ProjectData := TProjectData(tvProjectTree.Selected.Data);

    sgProperties.RowCount := ProjectData.GetPropsCount + 1;
    InitProjectData(ProjectData);
  end;
end;

procedure TfrmMain.actProjectSaveUpdate(Sender: TObject);
begin
  actHTMLSave.Enabled := seHTML.Modified;
  actProjectSave.Enabled := Assigned(Project) and Project.Modified;
  actProjectCompile.Enabled := Assigned(Project);
  actUpdateHTML.Enabled := Assigned(Project);
  actCheckNotUsed.Enabled := Assigned(Project) and (Project.ProjectFile <> '');

  actAddBefore.Enabled := Assigned(Project) and Assigned(SelectedObjectData);
  actAddAfter.Enabled := actAddBefore.Enabled;
  actDelete.Enabled := actAddBefore.Enabled;

  actMoveUp.Enabled := actAddBefore.Enabled and (tvProjectTree.Selected.GetPrev <> tvProjectTree.Items[0]) and (tvProjectTree.Selected.getPrevSibling <> nil);
  actMoveDown.Enabled := actAddBefore.Enabled and (tvProjectTree.Selected.getNextSibling <> nil);
  actLevelUp.Enabled := actAddBefore.Enabled and (tvProjectTree.Selected.Parent <> tvProjectTree.Items[0]);
  actLevelDown.Enabled := actAddBefore.Enabled and (tvProjectTree.Selected.getPrevSibling <> nil);
  actLevelInside.Enabled := actMoveDown.Enabled;

  actAddChild.Enabled := Assigned(Project);
end;

procedure TfrmMain.actUpdateHTMLExecute(Sender: TObject);
var
  i: Integer;
  ObjectData: TObjectData;
  slHTML: TStringList;
  S: string;
begin
  if MessageDlg('Update HTML titles to the tree titles?', mtConfirmation, mbYesNo, 0) <> mrYes then
    Exit;

  slHTML := TStringList.Create;
  Screen.Cursor := crAppStart;
  btnUpdateHTML.Down := True;

  try
    for i := 1 to tvProjectTree.Items.Count - 1 do
    begin
      ObjectData := TObjectData(tvProjectTree.Items[i].Data);
      if FileExists(Project.PrjDir + ObjectData.URL) then
      begin
        slHTML.LoadFromFile(Project.PrjDir + ObjectData.URL);
        S := GetTagText(slHTML.Text, 'title', False);
        if S <> '' then
        begin
          slHTML.Text := StringReplace(slHTML.Text, '<title>' + S + '</title>', '<title>' + ToHTML(ObjectData.Name) + '</title>', [rfIgnoreCase]);
          slHTML.SaveToFile(Project.PrjDir + ObjectData.URL);
        end;
      end
      else
        ShowMessage('File "' + ObjectData.URL + '" not found!');
    end;
  finally
    btnUpdateHTML.Down := False;
    Screen.Cursor := crDefault;
    slHTML.Free;
  end;
end;

function TfrmMain.AddObject: TObjectData;
var
  slHTML: TStringList;
  aName: string;
begin
  Result := nil;

  if dlgOpenHTML.Execute then
  begin
    Result := TObjectData.Create;
    Result.URL := ExtractFileName(dlgOpenHTML.FileName);
    Result.ImageIndex := '11';

    slHTML := TStringList.Create;
    slHTML.LoadFromFile(dlgOpenHTML.FileName);

    aName := GetTagText(slHTML.Text, 'title');
    if aName = '' then
      aName := GetTagText(slHTML.Text, 'h1');
    if aName = '' then
      aName := GetTagText(slHTML.Text, 'h2');

    Result.Name := aName;
    slHTML.Free;
  end;
end;

procedure TfrmMain.btnSettingsClick(Sender: TObject);
var
  frmSettings: TfrmSettings;
  reg: TRegIniFile;
begin
  frmSettings := TfrmSettings.Create(Self);
  frmSettings.edHHC.FileName := GetHHC(False);
  frmSettings.chbAddContents.Checked := GetAddContents;

  if frmSettings.ShowModal = mrOk then
  begin
    reg := TRegIniFile.Create;

    reg.RootKey := HKEY_CURRENT_USER;

    if reg.OpenKey('Software\CHMer', True) then
    begin
      reg.WriteString('', 'HHC', frmSettings.edHHC.FileName);
      reg.WriteBool('', 'AddContents', frmSettings.chbAddContents.Checked);
    end;

    reg.Free;
  end;

  frmSettings.Free;
end;

procedure TfrmMain.CloseProject;
begin
  if Assigned(Project) and Project.Modified then
  begin
    if MessageDlg('Project was modified. Save?', mtConfirmation, mbYesNo, 0) = mrYes then
      Project.Save;
  end;

  SelectedObjectData := nil;
  tvProjectTree.Selected := nil;

  if Assigned(Project) then
    FreeAndNil(Project);

  tvProjectTree.Items.Clear;
  wbBrowser.Navigate('about:blank');
  seHTML.Lines.Clear;
  memKeyWords.OnChange := nil;
  memKeyWords.Lines.Clear;
  memKeyWords.OnChange := memKeyWordsChange;

  Self.Caption := sTitle + sVersion;
  Application.Title := sTitle;
end;

function TfrmMain.ExecInMemo(CommandLine, Dir: string; Memo: TMemo; Show: Integer; Debug: Boolean = False): Cardinal;
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
  Screen.Cursor := crAppStart;

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

  Screen.Cursor := crDefault;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CloseProject;
  CanClose := True;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Self.Caption := sTitle + sVersion;
  Application.Title := sTitle;
  fsLayout.UseRegistry := True;

  Project := nil;

  SelectedObjectData := nil;
end;

function TfrmMain.GetAddContents: Boolean;
var
  reg: TRegIniFile;
begin
  Result := False;

  reg := TRegIniFile.Create;

  reg.RootKey := HKEY_CURRENT_USER;

  if reg.OpenKeyReadOnly('Software\CHMer') then
    Result := reg.ReadBool('', 'AddContents', False);

  reg.Free;
end;

function TfrmMain.GetHHC(Request: Boolean = True): String;
var
  reg: TRegIniFile;
begin
  reg := TRegIniFile.Create;

  reg.RootKey := HKEY_CURRENT_USER;
  if reg.OpenKeyReadOnly('Software\CHMer') then
  begin
    Result := reg.ReadString('', 'HHC', '');
    if (Result <> '') and FileExists(Result) then
    begin
      reg.Free;
      Exit;
    end;
    reg.CloseKey;
  end;

  Result := ExtractFilePath(Application.ExeName) + 'hhc.exe';
  if FileExists(Result) then
  begin
    reg.Free;
    SaveSettingsHHC(Result);
    Exit;
  end;

  reg.RootKey := HKEY_LOCAL_MACHINE;
  if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\HTML Help Workshop') then
  begin
    Result := reg.ReadString('', 'UninstallString', '');
    if Result <> '' then
    begin
      Result := ExtractFilePath(Result) + 'hhc.exe';
      if FileExists(Result) then
      begin
        reg.Free;
        SaveSettingsHHC(Result);
        Exit;
      end;
    end;
    reg.CloseKey;
  end;

  reg.RootKey := HKEY_CURRENT_USER;
  if reg.OpenKeyReadOnly('Software\Microsoft\HTML Help Workshop') then
  begin
    Result := reg.ReadString('', 'InstallDir', '');
    if Result <> '' then
    begin
      Result := Result + '\hhc.exe';
      if FileExists(Result) then
      begin
        reg.Free;
        SaveSettingsHHC(Result);
        Exit;
      end;
    end;
    reg.CloseKey;
  end;

  reg.Free;

  if Request and dlgOpenHHC.Execute then
  begin
    Result := dlgOpenHHC.FileName;
    if FileExists(Result) then
    begin
      SaveSettingsHHC(Result);
      Exit;
    end;
  end;

  Result := '';
end;

procedure TfrmMain.InitProjectData(ProjectData: TProjectData);

  procedure AddData(slData: TStringList; Prefix: String = ''; Offset: Integer = 0);
  var
    i: Integer;
  begin
    if Prefix <> '' then
      Prefix := Prefix + ': ';

    for i := 0 to slData.Count - 1 do
    begin
      sgProperties.Cells[0, i + 1 + Offset] := Prefix + slData.Names[i];
      sgProperties.Cells[1, i + 1 + Offset] := slData.ValueFromIndex[i];
    end;
  end;

begin
  AddData(ProjectData.slProject);
  AddData(ProjectData.slContent, sContent, ProjectData.slProject.Count);
  AddData(ProjectData.slKeyWords, sKeywords, ProjectData.slProject.Count + ProjectData.slContent.Count);
end;

procedure TfrmMain.LoadProject(FileName: String);
begin
  CloseProject;

  Project := TProject.Create(FileName, tvProjectTree.Items);

  if tvProjectTree.Items.Count > 0 then
  begin
    tvProjectTree.Items[0].Expand(False);
    tvProjectTree.Selected := tvProjectTree.Items[0];
  end;

  Self.Caption := sTitle + sVersion + ': ' + ExtractFileName(FileName);
  Application.Title := sTitle + ': ' + ExtractFileName(FileName);
end;

procedure TfrmMain.memKeyWordsChange(Sender: TObject);
begin
  if Assigned(SelectedObjectData) then
  begin
    SelectedObjectData.slKeyWords.Text := memKeyWords.Lines.Text;
    Project.Modified := True;
  end;
end;

procedure TfrmMain.miAddAfterClick(Sender: TObject);
var
  DataObject: TObjectData;
  aNode: TTreeNode;
begin
  DataObject := AddObject;
  if not Assigned(DataObject) then
    Exit;

  aNode := tvProjectTree.Selected.getNextSibling;
  if Assigned(aNode) then
    aNode := tvProjectTree.Items.Insert(aNode, DataObject.Name)
  else
    aNode := tvProjectTree.Items.Add(tvProjectTree.Selected, DataObject.Name);
  aNode.Data := DataObject;
  aNode.ImageIndex := 11;
  aNode.SelectedIndex := 11;

  tvProjectTree.Selected := aNode;
  Project.Modified := True;
end;

procedure TfrmMain.miAddBeforeClick(Sender: TObject);
var
  DataObject: TObjectData;
  aNode: TTreeNode;
begin
  DataObject := AddObject;
  if not Assigned(DataObject) then
    Exit;

  aNode := tvProjectTree.Items.Insert(tvProjectTree.Selected, DataObject.Name);
  aNode.Data := DataObject;
  aNode.ImageIndex := 11;
  aNode.SelectedIndex := 11;

  tvProjectTree.Selected := aNode;
  Project.Modified := True;
end;

procedure TfrmMain.miAddChildClick(Sender: TObject);
var
  DataObject: TObjectData;
  aNode: TTreeNode;
begin
  DataObject := AddObject;
  if not Assigned(DataObject) then
    Exit;

  tvProjectTree.Selected.Expand(False);
  if (not tvProjectTree.Selected.HasChildren) and (tvProjectTree.Selected <> tvProjectTree.Items[0]) then
  begin
    TObjectData(tvProjectTree.Selected.Data).ImageIndex := '1';
    tvProjectTree.Selected.ImageIndex := 1;
    tvProjectTree.Selected.SelectedIndex := 1;
  end;

  aNode := tvProjectTree.Items.AddChild(tvProjectTree.Selected, DataObject.Name);
  aNode.Data := DataObject;
  aNode.ImageIndex := 11;
  aNode.SelectedIndex := 11;

  tvProjectTree.Selected := aNode;
  Project.Modified := True;
end;

procedure TfrmMain.miCollapseAllClick(Sender: TObject);
begin
  tvProjectTree.Items[0].Collapse(True);
end;

procedure TfrmMain.miDeleteClick(Sender: TObject);
begin
  if not Assigned(SelectedObjectData) then
    Exit;

  if MessageDlg('Remove node "' + SelectedObjectData.Name + '"' + IfThen(tvProjectTree.Selected.HasChildren, ' with all subnodes') + '?',
    mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    if tvProjectTree.Selected.HasChildren then
      tvProjectTree.Selected.DeleteChildren;
    tvProjectTree.Selected.Delete;
    Project.Modified := True;
  end;
end;

procedure TfrmMain.miExpandAllClick(Sender: TObject);
begin
  tvProjectTree.Items[0].Expand(True);
end;

procedure TfrmMain.miLevelDownClick(Sender: TObject);
var
  aNode: TTreeNode;
begin
  aNode := tvProjectTree.Selected.getPrevSibling;
  if not Assigned(aNode) then
    Exit;

  tvProjectTree.Selected.MoveTo(aNode, naAddChildFirst);
  Project.Modified := True;
end;

procedure TfrmMain.miLevelInsideClick(Sender: TObject);
var
  aNode: TTreeNode;
begin
  aNode := tvProjectTree.Selected.getNextSibling;
  if not Assigned(aNode) then
    Exit;

  tvProjectTree.Selected.MoveTo(aNode, naAddChildFirst);
  Project.Modified := True;
end;

procedure TfrmMain.miLevelUpClick(Sender: TObject);
var
  aNode: TTreeNode;
begin
  aNode := tvProjectTree.Selected.Parent;
  if (not Assigned(aNode)) or (aNode = tvProjectTree.Items[0]) then
    Exit;

  tvProjectTree.Selected.MoveTo(aNode, naInsert);
  Project.Modified := True;
end;

procedure TfrmMain.miMoveDownClick(Sender: TObject);
var
  aNode, bNode: TTreeNode;
begin
  aNode := tvProjectTree.Selected.getNextSibling;
  if not Assigned(aNode) then
    Exit;

  bNode := aNode.getNextSibling;
  if Assigned(bNode) then
    tvProjectTree.Selected.MoveTo(bNode, naInsert)
  else
    tvProjectTree.Selected.MoveTo(aNode, naAdd);

  Project.Modified := True;
end;

procedure TfrmMain.miMoveUpClick(Sender: TObject);
var
  aNode: TTreeNode;
begin
  aNode := tvProjectTree.Selected.getPrevSibling;
  if not Assigned(aNode) then
    Exit;

  tvProjectTree.Selected.MoveTo(aNode, naInsert);
  Project.Modified := True;
end;

procedure TfrmMain.miPropertiesAddClick(Sender: TObject);
var
  frmAddProperty: TfrmAddProperty;
  slList: TStringList;
  ProjectData: TProjectData;
begin
  frmAddProperty := TfrmAddProperty.Create(Self);

  if frmAddProperty.ShowModal = mrOk then
  begin
    ProjectData := TProjectData(tvProjectTree.Selected.Data);

    case frmAddProperty.rgSection.ItemIndex of
      0: slList := ProjectData.slProject;
      1: slList := ProjectData.slContent;
    else slList := ProjectData.slKeyWords;
    end;

    slList.AddPair(Trim(frmAddProperty.edName.Text), Trim(frmAddProperty.edValue.Text));
    sgProperties.RowCount := ProjectData.GetPropsCount + 1;
    InitProjectData(ProjectData);
    Project.Modified := True;
  end;

  FreeAndNil(frmAddProperty);
end;

procedure TfrmMain.miPropertiesDeleteClick(Sender: TObject);
var
  value, aName: string;
  ProjectData: TProjectData;
  slList: TStringList;
begin
  if not Assigned(Project) then
    Exit;

  aName := sgProperties.Cells[0, sgProperties.Row];

  if MessageDlg('Remove "' + aName + '"?', mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    ProjectData := TProjectData(tvProjectTree.Selected.Data);

    value := sgProperties.Cells[1, sgProperties.Row];

    if Copy(aName, 1, 8) = sContent + ':' then
    begin
      slList := ProjectData.slContent;
      Delete(aName, 1, 9);
    end
    else
    if Copy(aName, 1, 9) = sKeyWords + ':' then
    begin
      slList := ProjectData.slKeyWords;
      Delete(aName, 1, 10);
    end
    else
      slList := ProjectData.slProject;

    slList.Delete(slList.IndexOfName(aName));
    sgProperties.RowCount := ProjectData.GetPropsCount + 1;
    InitProjectData(ProjectData);
    Project.Modified := True;
  end;
end;

procedure TfrmMain.pmProjectTreePopup(Sender: TObject);
begin
  miExpandAll.Visible := Assigned(Project) and (tvProjectTree.Selected = tvProjectTree.Items[0]);
  miCollapseAll.Visible := miExpandAll.Visible;
end;

procedure TfrmMain.pmPropertiesPopup(Sender: TObject);
begin
  miPropertiesAdd.Enabled := Assigned(Project) and (tvProjectTree.Selected = tvProjectTree.Items[0]);
  miPropertiesDelete.Enabled := miPropertiesAdd.Enabled;
end;

procedure TfrmMain.PropertiesEditDefaultTopic;
var
  ProjectData: TProjectData;
begin
  dlgOpenHTML.FileName := Project.PrjDir + sgProperties.Cells[1, sgProperties.Row];
  if dlgOpenHTML.Execute then
  begin
    sgProperties.Cells[1, sgProperties.Row] := ExtractFileName(dlgOpenHTML.FileName);
    ProjectData := TProjectData(tvProjectTree.Selected.Data);
    ProjectData.slProject.Values[sgProperties.Cells[0, sgProperties.Row]] := sgProperties.Cells[1, sgProperties.Row];
    Project.Modified := True;
  end;
end;

procedure TfrmMain.PropertiesEditImageIndex;
var
  value: string;
  ImageIndex: Integer;
begin
  value := sgProperties.Cells[1, sgProperties.Row];
  try
    ImageIndex := StrToInt(value);
  except
    ImageIndex := -1;
  end;
  ImageIndex := GetImageIndex(ImageIndex);

  if ImageIndex > -1 then
  begin
    value := IntToStr(ImageIndex);
    sgProperties.Cells[1, sgProperties.Row] := value;
    SelectedObjectData.ImageIndex := value;
    tvProjectTree.Selected.ImageIndex := ImageIndex;
    tvProjectTree.Selected.SelectedIndex := ImageIndex;
    Project.Modified := True;
  end;
end;

procedure TfrmMain.PropertiesEditName;
var
  value: string;
begin
  value := sgProperties.Cells[1, sgProperties.Row];
  if InputQuery(sgProperties.Cells[0, sgProperties.Row], 'Value', value) then
  begin
    sgProperties.Cells[1, sgProperties.Row] := value;
    sgProperties.Cells[1, 0] := '[' + value + ']';
    SelectedObjectData.Name := value;
    tvProjectTree.Selected.Text := value;
    Project.Modified := True;
  end;
end;

procedure TfrmMain.PropertiesEditRootName;
var
  value, aName: string;
  ProjectData: TProjectData;
  slList: TStringList;
begin
  ProjectData := TProjectData(tvProjectTree.Selected.Data);
  aName := sgProperties.Cells[0, sgProperties.Row];
  value := sgProperties.Cells[1, sgProperties.Row];

  if Copy(aName, 1, 8) = sContent + ':' then
  begin
    slList := ProjectData.slContent;
    Delete(aName, 1, 9);
  end
  else
  if Copy(aName, 1, 9) = sKeyWords + ':' then
  begin
    slList := ProjectData.slKeyWords;
    Delete(aName, 1, 10);
  end
  else
    slList := ProjectData.slProject;

  if InputQuery(sgProperties.Cells[0, sgProperties.Row], 'Value', value) then
  begin
    sgProperties.Cells[1, sgProperties.Row] := value;
    slList.Values[aName] := value;
    Project.Modified := True;
  end;
end;

procedure TfrmMain.PropertiesEditURL;
begin
  dlgOpenHTML.FileName := Project.PrjDir + sgProperties.Cells[1, sgProperties.Row];
  if dlgOpenHTML.Execute then
  begin
    SelectedObjectData.URL := ExtractFileName(dlgOpenHTML.FileName);
    wbBrowser.Navigate(Project.PrjDir + SelectedObjectData.URL, navNoHistory or navNoReadFromCache or navNoWriteToCache);
    seHTML.Lines.LoadFromFile(Project.PrjDir + SelectedObjectData.URL);
    sgProperties.Cells[1, sgProperties.Row] := SelectedObjectData.URL;
    Project.Modified := True;
  end;
end;

procedure TfrmMain.SaveSettingsHHC(hhc: String);
var
  reg: TRegIniFile;
begin
  reg := TRegIniFile.Create;

  reg.RootKey := HKEY_CURRENT_USER;

  if reg.OpenKey('Software\CHMer', True) then
    reg.WriteString('', 'HHC', hhc);

  reg.Free;
end;

procedure TfrmMain.sgPropertiesDblClick(Sender: TObject);
begin
  if not Assigned(Project) then
    Exit;

  if Assigned(SelectedObjectData) then
  begin
    if AnsiLowerCase(sgProperties.Cells[0, sgProperties.Row]) = 'local' then
      PropertiesEditURL
    else
    if AnsiLowerCase(sgProperties.Cells[0, sgProperties.Row]) = 'imageindex' then
      PropertiesEditImageIndex
    else
    if AnsiLowerCase(sgProperties.Cells[0, sgProperties.Row]) = 'name' then
      PropertiesEditName
  end
  else
  begin
    if AnsiLowerCase(sgProperties.Cells[0, sgProperties.Row]) = 'default topic' then
      PropertiesEditDefaultTopic
    else
      PropertiesEditRootName
  end;
end;

procedure TfrmMain.tvProjectTreeChange(Sender: TObject; Node: TTreeNode);
var
  ProjectData: TProjectData;
  CHMData: TCHMData;
begin
  if not Assigned(Project) then
    Exit;

  if not Assigned(tvProjectTree.Selected) then
    Exit;

  if actHTMLSave.Enabled and Assigned(SelectedObjectData) then
  begin
    if MessageDlg('Save "' + SelectedObjectData.URL + '"?', mtConfirmation, mbYesNo, 0) = mrYes then
      actHTMLSave.Execute;
  end;

  ProjectData := nil;
  SelectedObjectData := nil;

  CHMData := TCHMData(tvProjectTree.Selected.Data);

  if CHMData is TProjectData then
    ProjectData := TProjectData(CHMData)
  else
    SelectedObjectData := TObjectData(CHMData);

  sgProperties.RowCount := CHMData.GetPropsCount + 1;

  sgProperties.Cells[0, 0] := '[properties]';
  sgProperties.Cells[1, 0] := '[' + tvProjectTree.Selected.Text + ']';

  sgProperties.FixedRows := 1;
  wbBrowser.Navigate('about:blank');

  seHTML.Lines.Clear;
  memKeyWords.OnChange := nil;
  memKeyWords.Lines.Clear;
  memKeyWords.OnChange := memKeyWordsChange;

  seHTML.Modified := False;

  if CHMData is TProjectData then
  begin
    InitProjectData(ProjectData);
  end
  else
  begin
    sgProperties.Cells[0, 1] := 'Name';
    sgProperties.Cells[1, 1] := SelectedObjectData.Name;

    sgProperties.Cells[0, 2] := 'Local';
    sgProperties.Cells[1, 2] := SelectedObjectData.URL;

    sgProperties.Cells[0, 3] := 'ImageIndex';
    sgProperties.Cells[1, 3] := SelectedObjectData.ImageIndex;

    wbBrowser.Navigate(Project.PrjDir + SelectedObjectData.URL, navNoHistory or navNoReadFromCache or navNoWriteToCache);
    seHTML.Lines.LoadFromFile(Project.PrjDir + SelectedObjectData.URL);

    memKeyWords.OnChange := nil;
    memKeyWords.Lines.Text := SelectedObjectData.slKeyWords.Text;
    memKeyWords.OnChange := memKeyWordsChange;
  end;
end;

procedure TfrmMain.tvProjectTreeDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    TCHMData(Node.Data).Free;
end;

end.

