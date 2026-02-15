unit uHelpProject;

interface

uses
  Classes, ComCtrls;

  {Buttons
  HHWIN_BUTTON_EXPAND  = $000002; // Expand/contract button (Hide/Show navigation tree)
  HHWIN_BUTTON_BACK    = $000004; // Back button
  HHWIN_BUTTON_FORWARD = $000008; // Forward button
  HHWIN_BUTTON_STOP    = $000010; // Stop button
  HHWIN_BUTTON_REFRESH = $000020; // Refresh button
  HHWIN_BUTTON_HOME    = $000040; // Home button
  HHWIN_BUTTON_SYNC    = $000800; // Sync button
  HHWIN_BUTTON_OPTIONS = $001000; // Options button
  HHWIN_BUTTON_PRINT   = $002000; // Print button
  HHWIN_BUTTON_JUMP1   = $040000;
  HHWIN_BUTTON_JUMP2   = $080000;
  HHWIN_BUTTON_ZOOM    = $100000; // Font size

  Navigation
  HHWIN_PROP_TAB_AUTOHIDESHOW = $00000001; // Automatically hide/show navigation tree
  HHWIN_PROP_TRI_PANE         = $00000020; // Show navigation tree
  HHWIN_PROP_AUTO_SYNC        = $00000100; // Automatically sync between nav tree and main contents
  HHWIN_PROP_TAB_SEARCH       = $00000400; // include search tab in navigation pane
  HHWIN_PROP_TAB_FAVORITES    = $00001000; // include favorites tab in navigation pane
  HHWIN_PROP_TAB_ADVSEARCH    = $00020000; // Advanced FTS UI (Advanced search).

  Window
  HHWIN_PROP_ONTOP            = $00000002; // Top-most window
  HHWIN_PROP_MENU             = $00010000; // Menu
  HHWIN_PROP_USER_POS         = $00040000; // After initial creation, user controls window size/position (save window position)}

type
  THHCType = (hhcProperties, hhcObject, hhcEndObject, hhcUL, hhcEndUL, hhcParameter, hhcUnknown);

  TProject = class
  private
    FileHHC, FileHHK: String;
    ProjectItems: TTreeNodes;

    procedure LoadHHC(FileName: String);
    procedure LoadHHK(FileName: String);
    function LoadHHP(FileName: String): Boolean;
    procedure InitProjectProperties;
  public
    PrjDir, ProjectFile, Home, Jump1File, Jump1Name, Jump2File, Jump2Name: String;
    Buttons, WindowNav, DefaultTab, LeftPaneWidth, Top, Left, Width, Height: Integer;
    Modified: Boolean;

    constructor Create(FileName: String; ProjectTree: TTreeNodes);
    destructor Destroy; override;
    procedure CreateEmptyProject;
    procedure Save(FileName: String = ''; AddContents: Boolean = False; AddIfEmpty: Boolean = False);
  end;

  TCHMData = class abstract
    function GetPropsCount: Integer; virtual; abstract;
  end;

  TProjectData = class(TCHMData)
    slProject, slContent, slKeyWords: TStringList;

    constructor Create;
    destructor Destroy; override;
    function GetPropsCount: Integer; override;
  end;

  TObjectData = class(TCHMData)
    Name, URL, ImageIndex: String;
    slKeyWords: TStringList;

    constructor Create;
    destructor Destroy; override;
    function GetPropsCount: Integer; override;
  end;


implementation

uses
  SysUtils, Winapi.Windows, StrUtils, XMLDoc, Dialogs, IniFiles, HyperParse, HTMLTools;

function GetTypeHHC(info: THtmlInfo): THHCType;
var
  S, TagName: string;
  i: Integer;
begin
  Result := hhcUnknown;
  TagName := AnsiUpperCase(info.TagName);

  if (TagName = 'PARAM') then
    Result := hhcParameter
  else
  if (TagName = '/OBJECT') then
    Result := hhcEndObject
  else
  if (TagName = 'UL') then
    Result := hhcUL
  else
  if (TagName = '/UL') then
    Result := hhcEndUL
  else
  if (TagName = 'OBJECT') and (info.ParamCount > 0) then
  begin
    for i := 0 to info.ParamCount - 1 do
      if AnsiLowerCase(info.Params[i].Name) = 'type' then
      begin
        S := AnsiLowerCase(info.Params[i].Value);

        if Pos('text/site properties', S) > 0 then
          Result := hhcProperties
        else
        if Pos('text/sitemap', S) > 0 then
          Result := hhcObject;

        Break;
      end;
  end;
end;

function NumStr2Int(S: String): Integer;
begin
  Result := 0;

  if S = '' then
    Exit;

  S := StringReplace(AnsiLowerCase(S), '0x', '$', []);

  try
    Result := StrToInt(S);
  except
  end;
end;


{ TProject }

constructor TProject.Create(FileName: String; ProjectTree: TTreeNodes);
begin
  inherited Create();

  ProjectItems := ProjectTree;
  ProjectFile := FileName;
  InitProjectProperties;

  if FileName = '' then
  begin
    PrjDir := '';
    CreateEmptyProject;
  end
  else
  begin
    PrjDir := ExtractFilePath(FileName);

    if LoadHHP(FileName) then
    begin
      LoadHHC(PrjDir + FileHHC);
      LoadHHK(PrjDir + FileHHK);
    end;
  end;

  Modified := False;
end;

procedure TProject.CreateEmptyProject;
var
  RootNode: TTreeNode;
  Data: TProjectData;
begin
  RootNode := ProjectItems.AddChild(nil, 'Project');
  RootNode.ImageIndex := 43;
  RootNode.SelectedIndex := 43;

  Data := TProjectData.Create;
  RootNode.Data := Data;

  Data.slProject.AddPair('Compiled file', '');
  Data.slProject.AddPair('Contents file', '');
  Data.slProject.AddPair('Index file', '');
  Data.slProject.AddPair('Default topic', '');
  Data.slProject.AddPair('Title', '');
  Data.slProject.AddPair('Compatibility', '1.1 or later');
  Data.slProject.AddPair('Default Font', 'Calibri,9,0');
  Data.slProject.AddPair('Default Window', 'Main');
  Data.slProject.AddPair('Full-text search', 'Yes');
  Data.slProject.AddPair('Language', '0x409 English (United States)');

  Data.slContent.AddPair('Font', 'Calibri,9,0');

  Data.slKeyWords.AddPair('Font', 'Calibri,9,0');
end;

destructor TProject.Destroy;
var
  i: Integer;
begin
  if Assigned(ProjectItems) then
  begin
    for i := 0 to ProjectItems.Count - 1 do
      if Assigned(ProjectItems[i].Data) then
      begin
        TObject(ProjectItems[i].Data).Free;
        ProjectItems[i].Data := nil;
      end;
  end;

  inherited;
end;

procedure TProject.InitProjectProperties;
begin
  Buttons := HHWIN_BUTTON_EXPAND or HHWIN_BUTTON_BACK or HHWIN_BUTTON_OPTIONS or HHWIN_BUTTON_PRINT;
  WindowNav := HHWIN_PROP_TRI_PANE or HHWIN_PROP_AUTO_SYNC or HHWIN_PROP_TAB_SEARCH or HHWIN_PROP_TAB_ADVSEARCH or HHWIN_PROP_USER_POS;
  DefaultTab := 0;
  Top := -1;
  Left := -1;
  Width := 0;
  Height := 0;
  Home := '';
  Jump1File := '';
  Jump1Name := '';
  Jump2File := '';
  Jump2Name := '';
end;

procedure TProject.LoadHHC(FileName: String);

  function AddObject(RootNode: TTreeNode): TTreeNode;
  var
    Data: TObjectData;
  begin
    Result := ProjectItems.AddChild(RootNode, '-');

    Result.ImageIndex := 0;
    Result.SelectedIndex := 0;

    Data := TObjectData.Create;
    Result.Data := Data;
  end;

  procedure AddParameter(LastNode: TTreeNode; info: THtmlInfo);
  var
    i: Integer;
    sName, sValue: string;
  begin
    if not Assigned(LastNode) then
      Exit;

    sName := '';
    sValue := '';

    for i := 0 to info.ParamCount - 1 do
    begin
      if AnsiLowerCase(info.Params[i].Name) = 'name' then
        sName := info.Params[i].Value;
      if AnsiLowerCase(info.Params[i].Name) = 'value' then
        sValue := FromHTML(info.Params[i].Value);
    end;

    if sName <> '' then
    begin
      if LastNode = ProjectItems[0] then
      begin
        TProjectData(LastNode.Data).slContent.Add(sName + '=' + sValue);
      end
      else
      begin
        if AnsiLowerCase(sName) = 'name' then
        begin
          TObjectData(LastNode.Data).Name := sValue;
          LastNode.Text := sValue;
        end
        else
        if AnsiLowerCase(sName) = 'local' then
        begin
          TObjectData(LastNode.Data).URL := sValue
        end
        else
        if AnsiLowerCase(sName) = 'imagenumber' then
        try
          TObjectData(LastNode.Data).ImageIndex := sValue;
          LastNode.ImageIndex := StrToInt(sValue);
          LastNode.SelectedIndex := LastNode.ImageIndex;
        except
        end;
      end;
    end;
  end;

var
  DomTree: THyperParse;
  i: Integer;
  hhcType: THHCType;
  CurrentNode, RootNode: TTreeNode;
begin
  // ProjectItems[0] should exists - creates by LoadHHP

  CurrentNode := nil;
  RootNode := ProjectItems[0];

  DomTree := THyperParse.Create;
  DomTree.FileName := FileName;
  DomTree.Execute;

  for i := 0 to DomTree.Count - 1 do
  begin
    hhcType := GetTypeHHC(DomTree.Item[i]);

    case hhcType of
      hhcUL: RootNode := CurrentNode;
      hhcEndUL: if Assigned(CurrentNode) then RootNode := RootNode.Parent;
      hhcProperties: CurrentNode := ProjectItems[0];
      hhcObject: CurrentNode := AddObject(RootNode);
      hhcParameter: AddParameter(CurrentNode, DomTree.Item[i]);
    end;
  end;

  FreeAndNil(DomTree);
end;

procedure TProject.LoadHHK(FileName: String);
var
  CurrentNode: TTreeNode;
  slParameters: TStringList;

  procedure AddParameter(info: THtmlInfo);
  var
    i: Integer;
    sName, sValue: string;
  begin
    sName := '';
    sValue := '';

    for i := 0 to info.ParamCount - 1 do
    begin
      if AnsiLowerCase(info.Params[i].Name) = 'name' then
        sName := info.Params[i].Value;
      if AnsiLowerCase(info.Params[i].Name) = 'value' then
        sValue := FromHTML(info.Params[i].Value);
    end;

    if CurrentNode = ProjectItems[0] then
    begin
      TProjectData(ProjectItems[0].Data).slKeyWords.Add(sName + '=' + sValue);
      Exit;
    end;

    if AnsiLowerCase(sName) = 'local' then
    begin
      for i := 1 to ProjectItems.Count - 1 do
        if AnsiLowerCase(Trim(TObjectData(ProjectItems[i].Data).URL)) = AnsiLowerCase(Trim(sValue)) then
        begin
          CurrentNode := ProjectItems[i];
          Break;
        end;

      if not Assigned(CurrentNode) then
        ShowMessage('Node not found for ' + sValue);
    end
    else
      slParameters.Add(sValue);
  end;

var
  DomTree: THyperParse;
  i, j: Integer;
  hhcType: THHCType;
begin
  DomTree := THyperParse.Create;
  DomTree.FileName := FileName;
  DomTree.Execute;

  slParameters := TStringList.Create;
  CurrentNode := nil;

  for i := 0 to DomTree.Count - 1 do
  begin
    hhcType := GetTypeHHC(DomTree.Item[i]);

    case hhcType of
      hhcProperties: CurrentNode := ProjectItems[0];
      hhcObject: CurrentNode := nil;
      hhcEndObject: if Assigned(CurrentNode) and (CurrentNode <> ProjectItems[0]) then
        begin
          for j := 0 to slParameters.Count - 1 do
            if slParameters[j] <> TObjectData(CurrentNode.Data).Name then
              TObjectData(CurrentNode.Data).slKeyWords.Add(slParameters[j]);

          slParameters.Clear;
        end;
      hhcParameter: AddParameter(DomTree.Item[i]);
    end;

  end;

  DomTree.Free;
  slParameters.Free;
end;

function TProject.LoadHHP(FileName: String): Boolean;
var
  ini: TMemIniFile;
  RootNode: TTreeNode;
  Data: TProjectData;
  slWindow: TStringList;
  WindowParams: string;
begin
  Result := False;
  ini := TMemIniFile.Create(FileName);
  FileHHC := ini.ReadString('OPTIONS', 'Contents file', ExtractFileName(ChangeFileExt(FileName, '.hhc')));

  if not FileExists(PrjDir + FileHHC) then
  begin
    FileHHC := '';
    PrjDir := '';
    FreeAndNil(ini);
    Exit;
  end;

  FileHHK := ini.ReadString('OPTIONS', 'Index file', ExtractFileName(ChangeFileExt(FileName, '.hhk')));

  RootNode := ProjectItems.AddChild(nil, 'Project');
  RootNode.ImageIndex := 43;
  RootNode.SelectedIndex := 43;

  Data := TProjectData.Create;
  RootNode.Data := Data;

  ini.ReadSectionValues('OPTIONS', Data.slProject);

  Data.slProject.Values['Contents file'] := FileHHC;
  Data.slProject.Values['Index file'] := FileHHK;

  if ini.SectionExists('WINDOWS') then
  begin
    WindowParams := ini.ReadString('WINDOWS', Data.slProject.Values['Default Window'], '');
    slWindow := TStringList.Create;

    if WindowParams <> '' then
    try
      WindowParams := StringReplace(WindowParams, '[', '"', []);
      WindowParams := StringReplace(WindowParams, ']', '"', []);
      slWindow.CommaText := WindowParams;
      Home := slWindow[4];
      Jump1File := slWindow[5];
      Jump1Name := slWindow[6];
      Jump2File := slWindow[7];
      Jump2Name := slWindow[8];
      WindowNav := NumStr2Int(slWindow[9]);
      LeftPaneWidth := NumStr2Int(slWindow[10]);
      Buttons := NumStr2Int(slWindow[11]);
      DefaultTab := NumStr2Int(slWindow[17]);
      // 19 = 0
      slWindow.CommaText := slWindow[12];
      if slWindow.Count > 3 then
      begin
        Left := NumStr2Int(slWindow[0]);
        Top := NumStr2Int(slWindow[1]);
        Width := NumStr2Int(slWindow[2]) - Left;
        Height := NumStr2Int(slWindow[3]) - Top;
      end;
    except
    end;

    slWindow.Free;
  end;

  FreeAndNil(ini);
  Result := True;
end;

procedure TProject.Save(FileName: String = ''; AddContents: Boolean = False; AddIfEmpty: Boolean = False);
var
  slHHP, slHHC, slHHK: TStringList;

  procedure SaveNode(aNode: TTreeNode);
  var
    i: Integer;
    ObjectData: TObjectData;
  begin
    if aNode <> ProjectItems[0] then
    begin
      ObjectData := TObjectData(aNode.Data);

      if ObjectData.URL <> '' then
        slHHP.Add(ObjectData.URL);

      slHHC.Add('<LI><OBJECT type="text/sitemap">');
      slHHC.Add('  <param name="Name" value="' + ToHTML(ObjectData.Name, True) + '">');

      if ObjectData.URL <> '' then
        slHHC.Add('  <param name="Local" value="' + ToHTML(ObjectData.URL, True) + '">');

      if ObjectData.ImageIndex <> '' then
        slHHC.Add('  <param name="ImageNumber" value="' + ObjectData.ImageIndex + '">');

      slHHC.Add('</OBJECT>');

      if ObjectData.URL <> '' then
      begin
        for i := 0 to ObjectData.slKeyWords.Count - 1 do
        begin
          slHHK.Add('<LI><OBJECT type="text/sitemap">');
          slHHK.Add('  <param name="Name" value="' + ToHTML(ObjectData.slKeyWords[i], True) + IfThen(ObjectData.slKeyWords[i] = ObjectData.Name, ' ') + '">');
          slHHK.Add('  <param name="Name" value="' + ToHTML(ObjectData.Name, True) + '">');
          slHHK.Add('  <param name="Local" value="' + ToHTML(ObjectData.URL, True) + '">');
          slHHK.Add('</OBJECT>');
        end;

        if AddContents and ((not AddIfEmpty) or (ObjectData.slKeyWords.Count = 0)) then
        begin
          slHHK.Add('<LI><OBJECT type="text/sitemap">');
          slHHK.Add('  <param name="Name" value="' + ToHTML(ObjectData.Name, True) + '">');
          slHHK.Add('  <param name="Name" value="' + ToHTML(ObjectData.Name, True) + '">');
          slHHK.Add('  <param name="Local" value="' + ToHTML(ObjectData.URL, True) + '">');
          slHHK.Add('</OBJECT>');
        end;
      end;
    end;

    if aNode.Count > 0 then
    begin
      slHHC.Add('<UL>');
      for i := 0 to aNode.Count - 1 do
        SaveNode(aNode.Item[i]);
      slHHC.Add('</UL>');
    end;
  end;

var
  ProjectData: TProjectData;
  i: Integer;
  DefWindow: string;
begin
  if FileName <> '' then
  begin
    ProjectFile := FileName;
    PrjDir := ExtractFilePath(ProjectFile);
  end;

  if ProjectFile = '' then
    Exit;

  ProjectData := TProjectData(ProjectItems[0].Data);

  FileHHC := ProjectData.slProject.Values['Contents file'];
  if FileHHC = '' then
  begin
    FileHHC := ChangeFileExt(ExtractFileName(FileName), '.hhc');
    ProjectData.slProject.Values['Contents file'] := FileHHC;
  end;

  FileHHK := ProjectData.slProject.Values['Index file'];
  if FileHHK = '' then
  begin
    FileHHK := ChangeFileExt(ExtractFileName(FileName), '.hhk');
    ProjectData.slProject.Values['Index file'] := FileHHK;
  end;

  if FileName <> '' then
  begin
    if ProjectData.slProject.Values['Compiled file'] = '' then
      ProjectData.slProject.Values['Compiled file'] := ChangeFileExt(ExtractFileName(FileName), '.chm');
    if ProjectData.slProject.Values['Title'] = '' then
      ProjectData.slProject.Values['Title'] := ChangeFileExt(ExtractFileName(FileName), '');
  end;

  SysUtils.RenameFile(ProjectFile, ProjectFile + '.bak');
  SysUtils.DeleteFile(ProjectFile);

  slHHP := TStringList.Create;
  slHHC := TStringList.Create;
  slHHK := TStringList.Create;


  DefWindow := Trim(ProjectData.slProject.Values['Default Window']);
  if DefWindow = '' then
    DefWindow := 'Main';
  ProjectData.slProject.Values['Default Window'] := DefWindow;


  slHHP.Add('[OPTIONS]');
  for i := 0 to ProjectData.slProject.Count - 1 do
    slHHP.Add(ProjectData.slProject.Names[i] + '=' + ProjectData.slProject.ValueFromIndex[i]);
  slHHP.Add('');


  slHHP.Add('[WINDOWS]');
  // Name="Title","TOC_File","Index_File","Default_Topic","Home_Topic","Jump1page","Jump1title","Jump2page","Jump2title",
  //   WinNavStyles,Left_Pane_Width,Buttons,Window_Pos,Window_Styles,Extended_Styles,?,-,Default_Tab,,0
  slHHP.Add(DefWindow +
    '="'  + ProjectData.slProject.Values['Title'] + '"' +
    ',"'  + ProjectData.slProject.Values['Contents file'] + '"' +
    ',"'  + ProjectData.slProject.Values['Index file'] + '"' +
    ',"'  + ProjectData.slProject.Values['Default topic'] + '"' +
    ','   + IfThen(Home <> '', '"' + Home + '"') +
    ','   + IfThen(Jump1File <> '', '"' + Jump1File + '"') +
    ','   + IfThen(Jump1Name <> '', '"' + Jump1Name + '"') +
    ','   + IfThen(Jump2File <> '', '"' + Jump2File + '"') +
    ','   + IfThen(Jump2Name <> '', '"' + Jump2Name + '"') +
    ',0x' + IntToHex(WindowNav) +
    ','   + IfThen(LeftPaneWidth > 0, IntToStr(LeftPaneWidth)) +
    ',0x' + IntToHex(Buttons) +
    ','   + IfThen(Left >= 0, '[' + IntToStr(Left) + ',' + IntToStr(Top) + ',' + IntToStr(Left + Width) + ',' + IntToStr(Top + Height) + ']') +
    ',,,,,' + IntToStr(DefaultTab) + ',,0'
  );
  slHHP.Add('');


  slHHC.Add('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">');
  slHHC.Add('<HTML>');
  slHHC.Add('<HEAD>');
  slHHC.Add('<meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1">');
  slHHC.Add('<!-- Sitemap 1.0 -->');
  slHHC.Add('</HEAD>');
  slHHC.Add('<BODY>');
  slHHC.Add('<OBJECT type="text/site properties">');

  for i := 0 to ProjectData.slContent.Count - 1 do
    slHHC.Add('  <param name="' + ProjectData.slContent.Names[i] + '" value="' + ToHTML(ProjectData.slContent.ValueFromIndex[i], True) + '">');

  slHHC.Add('</OBJECT>');


  slHHK.Add('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">');
  slHHK.Add('<HTML>');
  slHHK.Add('<HEAD>');
  slHHK.Add('<meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1">');
  slHHK.Add('<!-- Sitemap 1.0 -->');
  slHHK.Add('</HEAD>');
  slHHK.Add('<BODY>');
  slHHK.Add('<OBJECT type="text/site properties">');

  for i := 0 to ProjectData.slKeyWords.Count - 1 do
    slHHK.Add('  <param name="' + ProjectData.slKeyWords.Names[i] + '" value="' + ToHTML(ProjectData.slKeyWords.ValueFromIndex[i], True) + '">');

  slHHK.Add('</OBJECT>');


  slHHP.Add('[FILES]');

  slHHK.Add('<UL>');
  SaveNode(ProjectItems.GetFirstNode);
  slHHK.Add('</UL>');


  slHHC.Add('</BODY>');
  slHHC.Add('</HTML>');

  slHHK.Add('</BODY>');
  slHHK.Add('</HTML>');


  slHHP.SaveToFile(ProjectFile);
  slHHC.SaveToFile(PrjDir + FileHHC);
  slHHK.SaveToFile(PrjDir + FileHHK);


  FreeAndNil(slHHC);
  FreeAndNil(slHHK);
  FreeAndNil(slHHP);

  Modified := False;
end;


{ TProjectData }

constructor TProjectData.Create;
begin
  inherited;

  slProject := TStringList.Create;
  slContent := TStringList.Create;
  slKeyWords := TStringList.Create;
end;

destructor TProjectData.Destroy;
begin
  FreeAndNil(slProject);
  FreeAndNil(slContent);
  FreeAndNil(slKeyWords);

  inherited;
end;

function TProjectData.GetPropsCount: Integer;
begin
  Result := slProject.Count + slContent.Count + slKeyWords.Count;
end;


{ TObjectData }

constructor TObjectData.Create;
begin
  inherited;

  Name := '';
  URL := '';
  ImageIndex := '';

  slKeyWords := TStringList.Create;
end;

destructor TObjectData.Destroy;
begin
  FreeAndNil(slKeyWords);

  inherited;
end;

function TObjectData.GetPropsCount: Integer;
begin
  Result := 3;
end;

end.

