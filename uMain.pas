unit uMain;

// TODO:
// - input fields validation
// - separate application and project settings

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ToolWin, ComCtrls, Grids, ImgList, OleCtrls,
  SHDocVw, SynEditHighlighter, SynHighlighterHtml, SynEdit, StdCtrls, System.ImageList, Vcl.Menus, System.Actions, Vcl.ActnList, RxPlacemnt,
  uHelpProject;

type
  TAddFile = function (const FileName: String): TTreeNode of object;

  TfrmMain = class(TForm)
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
    tvProjectTree: TTreeView;
    sgProperties: TStringGrid;
    ilHelp: TImageList;
    wbBrowser: TWebBrowser;
    seHTML: TSynEdit;
    synHTMLSyn: TSynHTMLSyn;
    pnHTMLTop: TPanel;
    tbHTML: TToolBar;
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
    actUpdateHTML: TAction;
    dlgSaveProject: TSaveDialog;
    fsLayout: TFormStorage;
    actCheckNotUsed: TAction;
    pnTop: TPanel;
    tbMain: TToolBar;
    btnProjectCreate: TToolButton;
    btnProjectLoad: TToolButton;
    btnProjectSave: TToolButton;
    ToolButton4: TToolButton;
    btnSettings: TToolButton;
    ToolButton3: TToolButton;
    btnUpdateHTML: TToolButton;
    btnCheckNotUsed: TToolButton;
    ToolButton2: TToolButton;
    btnProjectCompile: TToolButton;
    ilPopupDisabled: TImageList;
    memKeyWords: TMemo;
    splVerticalRight: TSplitter;
    lbKeywords: TLabel;
    btnEdit: TToolButton;
    actEditHTML: TAction;
    btnNewEmpty: TToolButton;
    actNewEmpty: TAction;
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
    procedure FormShow(Sender: TObject);
    procedure splVerticalRightMoved(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actEditHTMLExecute(Sender: TObject);
    procedure actNewEmptyExecute(Sender: TObject);
  private
    { Private declarations }
    Project: TProject;
    SelectedObjectData: TObjectData;

    function AddAfter(const FileName: string): TTreeNode;
    function AddBefore(const FileName: string): TTreeNode;
    function AddChild(const FileName: string): TTreeNode;
    procedure AddFiles(AddFile: TAddFile);
    function AddObject(const FileName: string): TObjectData;
    function CloseProject: Boolean;
    function GetAddContents: Boolean;
    function GetAddIfEmpty: Boolean;
    function GetEditor: String;
    function GetHHC(Request: Boolean = True): String;
    function GetProjectDataList(var aName: string): TStringList;
    procedure InitProjectData(ProjectData: TProjectData);
    procedure LoadProject(const FileName: String);
    procedure PropertiesEditBoolean;
    procedure PropertiesEditDefaultTopic;
    procedure PropertiesEditFont;
    procedure PropertiesEditHex;
    procedure PropertiesEditImageIndex;
    procedure PropertiesEditLanguage;
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
  System.UITypes, StrUtils, Registry, ShellAPI, HTMLTools, SystemUtils, uSelectImage, uAddProperty, uEditValue, uEditFont, uSettings,
  uAddNewEmpty;

const
  sContent = 'Content';
  sKeyWords = 'Keywords';

  sTitle = 'CHMer';
  sVersion = ' 1.0.6';

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

procedure TfrmMain.actEditHTMLExecute(Sender: TObject);
var
  editor: string;
begin
  editor := GetEditor;

  if editor = '' then
  begin
    ShowMessage('Editor not specified');
    btnSettings.Click;

    editor := GetEditor;
    if editor = '' then
      Exit;
  end;

  ShellExecute(0, nil, PWideChar(editor), PWideChar(Project.PrjDir + SelectedObjectData.URL), PWideChar(Project.PrjDir), SW_SHOWNORMAL);
end;

procedure TfrmMain.actHTMLSaveExecute(Sender: TObject);
begin
  if (not Assigned(Project)) or (not Assigned(SelectedObjectData)) then
    Exit;

  seHTML.Lines.SaveToFile(Project.PrjDir + SelectedObjectData.URL);
  wbBrowser.Refresh;
  seHTML.Modified := False;
end;

procedure TfrmMain.actNewEmptyExecute(Sender: TObject);
var
  Title, FileName, Ext: String;
  Position: Integer;
  OpenEditor: Boolean;
  slHTML: TStringList;
  aNode: TTreeNode;
begin
  if InputNewEmpty(Title, FileName, Position, OpenEditor) then
  begin
    FileName := Trim(FileName);
    if FileName = '' then
    begin
      ShowMessage('You should specify the file name.');
      Exit;
    end;

    Ext := AnsiLowerCase(ExtractFileExt(FileName));
    if (Ext <> '.html') and (Ext <> '.htm') then
      Ext := '.html';
    FileName := ChangeFileExt(FileName, Ext);

    slHTML := TStringList.Create;

    slHTML.Add('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
    slHTML.Add('<html xmlns="http://www.w3.org/1999/xhtml">');
    slHTML.Add('  <head>');
    slHTML.Add('    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
    slHTML.Add('    <title>' + ToHTML(Title) + '</title>');
    slHTML.Add('  </head>');
    slHTML.Add('');
    slHTML.Add('  <body>');
    slHTML.Add('  </body>');
    slHTML.Add('</html>');

    try
      slHTML.SaveToFile(Project.PrjDir + FileName, TEncoding.UTF8);
    except
      ShowMessage('Error saving file');
      slHTML.Free;
      Exit;
    end;

    slHTML.Free;

    if (Position = 0) and actAddBefore.Enabled then
      aNode := AddBefore(Project.PrjDir + FileName)
    else
    if (Position = 1) and actAddAfter.Enabled then
      aNode := AddAfter(Project.PrjDir + FileName)
    else
      aNode := AddChild(Project.PrjDir + FileName);

    if OpenEditor and Assigned(aNode) then
    begin
      tvProjectTree.Selected := aNode;
      Project.Modified := True;
      actEditHTMLExecute(Sender);
    end;
  end;
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
    Screen.Cursor := crAppStart;
    ExecInMemo(hhc + ' ' + Project.ProjectFile, ExtractFileDir(hhc), memInfo, eimShowStdOut or eimShowStdErr);
  finally
    Screen.Cursor := crDefault;
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
  if not CloseProject then
    Exit;

  Project := TProject.Create('', tvProjectTree.Items);

  actProjectSaveExecute(nil);

  if Project.ProjectFile = '' then
  begin
    Project.Modified := False;
    CloseProject;
    Exit;
  end;

  tvProjectTree.Selected := tvProjectTree.Items[0];

  Self.Caption := sTitle + sVersion + ': ' + ExtractFileName(Project.ProjectFile);
  Application.Title := sTitle + ': ' + ExtractFileName(Project.ProjectFile);
end;

procedure TfrmMain.actProjectLoadExecute(Sender: TObject);
begin
  if dlgOpenProject.Execute then
    LoadProject(dlgOpenProject.FileName);
end;

procedure TfrmMain.actProjectSaveExecute(Sender: TObject);
var
  ProjectData: TProjectData;
  AddContents, AddIfEmpty: Boolean;
begin
  if not Assigned(Project) then
    Exit;

  if Project.ProjectFile = '' then
    if not dlgSaveProject.Execute then
      Exit;

  AddContents := GetAddContents;
  AddIfEmpty := GetAddIfEmpty;

  if Project.ProjectFile = '' then
    Project.Save(dlgSaveProject.FileName, AddContents, AddIfEmpty)
  else
    Project.Save('', AddContents, AddIfEmpty);

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
  actEditHTML.Enabled := actAddBefore.Enabled;

  actMoveUp.Enabled := actAddBefore.Enabled and (tvProjectTree.Selected.GetPrev <> tvProjectTree.Items[0]) and (tvProjectTree.Selected.getPrevSibling <> nil);
  actMoveDown.Enabled := actAddBefore.Enabled and (tvProjectTree.Selected.getNextSibling <> nil);
  actLevelUp.Enabled := actAddBefore.Enabled and (tvProjectTree.Selected.Parent <> tvProjectTree.Items[0]);
  actLevelDown.Enabled := actAddBefore.Enabled and (tvProjectTree.Selected.getPrevSibling <> nil);
  actLevelInside.Enabled := actMoveDown.Enabled;

  actAddChild.Enabled := Assigned(Project);
  actNewEmpty.Enabled := actAddChild.Enabled;
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
          slHTML.Text := StringReplace(slHTML.Text, '<title>' + S + '</title>', '<title>' + ToHTML(ObjectData.Name, True) + '</title>', [rfIgnoreCase]);
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

function TfrmMain.AddAfter(const FileName: string): TTreeNode;
var
  DataObject: TObjectData;
begin
  DataObject := AddObject(FileName);

  Result := tvProjectTree.Selected.getNextSibling;

  if Assigned(Result) then
    Result := tvProjectTree.Items.Insert(Result, DataObject.Name)
  else
    Result := tvProjectTree.Items.Add(tvProjectTree.Selected, DataObject.Name);

  Result.Data := DataObject;
  Result.ImageIndex := 11;
  Result.SelectedIndex := 11;
end;

function TfrmMain.AddBefore(const FileName: string): TTreeNode;
var
  DataObject: TObjectData;
begin
  DataObject := AddObject(FileName);

  Result := tvProjectTree.Items.Insert(tvProjectTree.Selected, DataObject.Name);

  Result.Data := DataObject;
  Result.ImageIndex := 11;
  Result.SelectedIndex := 11;
end;

function TfrmMain.AddChild(const FileName: string): TTreeNode;
var
  DataObject: TObjectData;
begin
  DataObject := AddObject(FileName);

  if (not tvProjectTree.Selected.HasChildren) and (tvProjectTree.Selected <> tvProjectTree.Items[0]) then
  begin
    TObjectData(tvProjectTree.Selected.Data).ImageIndex := '1';
    tvProjectTree.Selected.ImageIndex := 1;
    tvProjectTree.Selected.SelectedIndex := 1;
  end;

  Result := tvProjectTree.Items.AddChild(tvProjectTree.Selected, DataObject.Name);
  Result.Data := DataObject;
  Result.ImageIndex := 11;
  Result.SelectedIndex := 11;
end;

procedure TfrmMain.AddFiles(AddFile: TAddFile);
var
  aNode: TTreeNode;
  i: Integer;
begin
  try
    dlgOpenHTML.Options := dlgOpenHTML.Options + [ofAllowMultiSelect];

    if dlgOpenHTML.Execute then
    begin
      aNode := tvProjectTree.Selected;

      for i := 0 to dlgOpenHTML.Files.Count - 1 do
        aNode := AddFile(dlgOpenHTML.Files[i]);

      tvProjectTree.Selected := aNode;
      Project.Modified := True;
    end;
  finally
    dlgOpenHTML.Options := dlgOpenHTML.Options + [ofAllowMultiSelect];
  end;
end;

function TfrmMain.AddObject(const FileName: string): TObjectData;
var
  slHTML: TStringList;
  aName: string;
begin
  slHTML := TStringList.Create;

  Result := TObjectData.Create;
  Result.URL := ExtractFileName(FileName);
  Result.ImageIndex := '11';

  slHTML.LoadFromFile(FileName);

  aName := GetTagText(slHTML.Text, 'title');
  if aName = '' then
    aName := GetTagText(slHTML.Text, 'h1');
  if aName = '' then
    aName := GetTagText(slHTML.Text, 'h2');

  Result.Name := aName;

  slHTML.Free;
end;

procedure TfrmMain.btnSettingsClick(Sender: TObject);
var
  frmSettings: TfrmSettings;
  reg: TRegIniFile;
begin
  frmSettings := TfrmSettings.Create(Self);
  frmSettings.edHHC.FileName := GetHHC(False);
  frmSettings.edEditor.FileName := GetEditor;
  frmSettings.chbAddContents.Checked := GetAddContents;
  frmSettings.chbAddIfEmpty.Checked := GetAddIfEmpty;

  if frmSettings.ShowModal = mrOk then
  begin
    reg := TRegIniFile.Create;

    reg.RootKey := HKEY_CURRENT_USER;

    if reg.OpenKey('Software\CHMer', True) then
    begin
      reg.WriteString('', 'HHC', frmSettings.edHHC.FileName);
      reg.WriteString('', 'Editor', frmSettings.edEditor.FileName);
      reg.WriteBool('', 'AddContents', frmSettings.chbAddContents.Checked);
      reg.WriteBool('', 'AddIfEmpty', frmSettings.chbAddIfEmpty.Checked);
    end;

    reg.Free;
  end;

  frmSettings.Free;
end;

function TfrmMain.CloseProject: Boolean;
var
  i: Integer;
begin
  Result := False;

  if Assigned(Project) and Project.Modified then
  begin
    i := MessageDlg('Project was modified. Save?', mtConfirmation, mbYesNoCancel, 0);

    if i = mrCancel then
      Exit;

    if i = mrYes then
      Project.Save;
  end;

  SelectedObjectData := nil;
  tvProjectTree.Selected := nil;
  Result := True;

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

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CloseProject;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Self.Caption := sTitle + sVersion;
  Application.Title := sTitle;
  fsLayout.UseRegistry := True;

  Project := nil;

  SelectedObjectData := nil;

  sgProperties.Cells[0, 0] := '[properties]';
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  splVerticalRightMoved(Sender);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  Self.OnShow := nil;
  if (ParamCount > 0) and (FileExists(ParamStr(1))) then
    LoadProject(ParamStr(1));
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

function TfrmMain.GetAddIfEmpty: Boolean;
var
  reg: TRegIniFile;
begin
  Result := False;

  reg := TRegIniFile.Create;

  reg.RootKey := HKEY_CURRENT_USER;

  if reg.OpenKeyReadOnly('Software\CHMer') then
    Result := reg.ReadBool('', 'AddIfEmpty', False);

  reg.Free;
end;

function TfrmMain.GetEditor: String;
var
  reg: TRegIniFile;
begin
  Result := '';
  reg := TRegIniFile.Create;

  reg.RootKey := HKEY_CURRENT_USER;
  if reg.OpenKeyReadOnly('Software\CHMer') then
  begin
    Result := reg.ReadString('', 'Editor', '');
    if (Result <> '') and FileExists(Result) then
    begin
      reg.Free;
      Exit;
    end;
    reg.CloseKey;
  end;
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

function TfrmMain.GetProjectDataList(var aName: string): TStringList;
var
  ProjectData: TProjectData;
begin
  ProjectData := TProjectData(tvProjectTree.Selected.Data);

  if Copy(aName, 1, 8) = sContent + ':' then
  begin
    Result := ProjectData.slContent;
    Delete(aName, 1, 9);
  end
  else if Copy(aName, 1, 9) = sKeyWords + ':' then
  begin
    Result := ProjectData.slKeyWords;
    Delete(aName, 1, 10);
  end
  else
    Result := ProjectData.slProject;
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

procedure TfrmMain.LoadProject(const FileName: String);
begin
  if not CloseProject then
    Exit;

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
begin
  AddFiles(AddAfter);
end;

procedure TfrmMain.miAddBeforeClick(Sender: TObject);
begin
  AddFiles(AddBefore);
end;

procedure TfrmMain.miAddChildClick(Sender: TObject);
begin
  tvProjectTree.Selected.Expand(False);
  AddFiles(AddChild);
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
  HasChildren: Boolean;
begin
  aNode := tvProjectTree.Selected.getPrevSibling;
  if not Assigned(aNode) then
    Exit;

  HasChildren := aNode.HasChildren;

  tvProjectTree.Selected.MoveTo(aNode, naAddChildFirst);

  if not HasChildren then
  begin
    aNode.ImageIndex := 1;
    aNode.SelectedIndex := 1;
  end;

  Project.Modified := True;
end;

procedure TfrmMain.miLevelInsideClick(Sender: TObject);
var
  aNode: TTreeNode;
  HasChildren: Boolean;
begin
  aNode := tvProjectTree.Selected.getNextSibling;
  if not Assigned(aNode) then
    Exit;

  HasChildren := aNode.HasChildren;

  tvProjectTree.Selected.MoveTo(aNode, naAddChildFirst);

  if not HasChildren then
  begin
    aNode.ImageIndex := 1;
    aNode.SelectedIndex := 1;
  end;

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

  if (not aNode.HasChildren) and (not tvProjectTree.Selected.HasChildren) then
  begin
    aNode.ImageIndex := tvProjectTree.Selected.ImageIndex;
    aNode.SelectedIndex := tvProjectTree.Selected.SelectedIndex;
  end;

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

    slList := GetProjectDataList(aName);

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

procedure InitListBoolean(aList: TStrings);
begin
  aList.Add('Yes');
  aList.Add('No');
end;

procedure TfrmMain.PropertiesEditBoolean;
var
  value, aName: string;
  slList: TStringList;
begin
  value := sgProperties.Cells[1, sgProperties.Row];

  if InputList(sgProperties.Cells[0, sgProperties.Row], value, InitListBoolean, nil) then
  begin
    sgProperties.Cells[1, sgProperties.Row] := value;

    aName := sgProperties.Cells[0, sgProperties.Row];
    slList := GetProjectDataList(aName);
    slList.Values[aName] := value;

    Project.Modified := True;
  end;
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

procedure TfrmMain.PropertiesEditFont;
var
  FontName, aName, value: string;
  FontSize, Charset, i: Integer;
  slList: TStringList;
begin
  FontName := '';
  FontSize := 8;
  Charset := 0;

  value := sgProperties.Cells[1, sgProperties.Row];
  i := Pos(',', value);
  if i > 0 then
  begin
    FontName := Copy(value, 1, i - 1);
    Delete(value, 1, i);
  end;
  i := Pos(',', value);
  if i > 0 then
  try
    FontSize := StrToInt(Trim(Copy(value, 1, i - 1)));
    Delete(value, 1, i);
    Charset := StrToInt(Trim(value));
  except
  end;

  if InputFont('Fonts', FontName, FontSize, Charset) then
  begin
    value := FontName + ',' + IntToStr(FontSize) + ',' + IntToStr(Charset);
    sgProperties.Cells[1, sgProperties.Row] := value;

    aName := sgProperties.Cells[0, sgProperties.Row];
    slList := GetProjectDataList(aName);
    slList.Values[aName] := value;

    Project.Modified := True;
  end;
end;

procedure TfrmMain.PropertiesEditHex;
var
  value, aName: string;
  intValue: Integer;
  slList: TStringList;
begin
  value := StringReplace(sgProperties.Cells[1, sgProperties.Row], '0x', '$', [rfIgnoreCase]);
  try
    intValue := StrToInt(value);
  except
    intValue := 0;
  end;

  if InputInteger(sgProperties.Cells[0, sgProperties.Row], intValue) then
  begin
    value := IntegerToHex(intValue);
    sgProperties.Cells[1, sgProperties.Row] := value;

    aName := sgProperties.Cells[0, sgProperties.Row];
    slList := GetProjectDataList(aName);
    slList.Values[aName] := value;

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

procedure InitListLanguage(aList: TStrings);
var
  i: Integer;
  S: string;
  stringList: TStringList;
begin
  for i := $401 to 65536 do
  begin
    S := GetLocaleName(i, LOCALE_SLOCALIZEDDISPLAYNAME);
    if (S <> '') and (aList.IndexOf(S) < 0) then
      aList.AddObject(S, Pointer(i));
  end;

  stringList := TStringList.Create;
  try
     stringList.Assign(aList);
     stringList.Sort;
     aList.Assign(stringList);
  finally
     stringList.Free;
  end;
end;

var
  iSelectedLangCode: Integer;

procedure DestroyListLanguage(aList: TStrings; ItemIndex: Integer);
begin
  if ItemIndex > -1 then
    iSelectedLangCode := Integer(Pointer(aList.Objects[ItemIndex]));
end;

procedure TfrmMain.PropertiesEditLanguage;
var
  value, aName: string;
  i: Integer;
  slList: TStringList;
begin
  value := Trim(sgProperties.Cells[1, sgProperties.Row]);

  i := Pos(' ', value);
  if i > 0 then
  begin
    Delete(value, 1, i);
    value := Trim(value);
  end;
  iSelectedLangCode := 0;

  if InputList(sgProperties.Cells[0, sgProperties.Row], value, InitListLanguage, DestroyListLanguage) then
  begin
    sgProperties.Cells[1, sgProperties.Row] := IntegerToHex(iSelectedLangCode) + ' ' + value;

    aName := sgProperties.Cells[0, sgProperties.Row];
    slList := GetProjectDataList(aName);
    slList.Values[aName] := sgProperties.Cells[1, sgProperties.Row];

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
  slList: TStringList;
begin
  value := sgProperties.Cells[1, sgProperties.Row];

  if InputQuery(sgProperties.Cells[0, sgProperties.Row], 'Value', value) then
  begin
    sgProperties.Cells[1, sgProperties.Row] := value;

    aName := sgProperties.Cells[0, sgProperties.Row];
    slList := GetProjectDataList(aName);
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
var
  propertyName: string;
begin
  if not Assigned(Project) then
    Exit;

  propertyName := AnsiLowerCase(sgProperties.Cells[0, sgProperties.Row]);
  if Assigned(SelectedObjectData) then
  begin
    if propertyName = 'local' then
      PropertiesEditURL
    else
    if propertyName = 'imageindex' then
      PropertiesEditImageIndex
    else
    if propertyName = 'name' then
      PropertiesEditName
  end
  else
  begin
    if propertyName = 'default topic' then
      PropertiesEditDefaultTopic
    else
    if (propertyName = 'default font') or (Pos(': font', propertyName) > 0) then
      PropertiesEditFont
    else
    if (Pos('window styles', propertyName) > 0) or (Pos('exwindow styles', propertyName) > 0) then
      PropertiesEditHex
    else
    if (propertyName = 'display compile progress') or (propertyName = 'full-text search') then
      PropertiesEditBoolean
    else
    if propertyName = 'language' then
      PropertiesEditLanguage
    else
      PropertiesEditRootName
  end;
end;

procedure TfrmMain.splVerticalRightMoved(Sender: TObject);
begin
  lbKeywords.Left := splVerticalRight.Left + 5;
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

