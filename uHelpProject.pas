unit uHelpProject;

interface

uses
  Classes, ComCtrls;

type
  THHCType = (hhcProperties, hhcObject, hhcParameter, hhcWTF);

  TProject = class
  private
    FileHHC, FileHHK: String;
    ProjectItems: TTreeNodes;

    procedure LoadHHC(FileName: String);
    procedure LoadHHK(FileName: String);
    function LoadHHP(FileName: String): Boolean;
  public
    PrjDir, ProjectFile: String;
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
  SysUtils, StrUtils, XMLDoc, Dialogs, IniFiles, HyperParse, HTMLTools;

function GetTypeHHC(info: THtmlInfo): THHCType;
var
  S: string;
  i: Integer;
begin
  Result := hhcWTF;

  if (AnsiLowerCase(info.TagName) = 'param') then
    Result := hhcParameter;

  if (AnsiUpperCase(info.TagName) <> 'OBJECT') or (info.ParamCount < 1) then
    Exit;

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


{ TProject }

constructor TProject.Create(FileName: String; ProjectTree: TTreeNodes);
begin
  inherited Create();

  ProjectItems := ProjectTree;
  ProjectFile := FileName;

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
  RootNode := ProjectItems.AddChild(nil, 'Project properties');
  RootNode.ImageIndex := 43;
  RootNode.SelectedIndex := 43;

  Data := TProjectData.Create;
  RootNode.Data := Data;

  Data.slProject.AddPair('Compatibility', '1.1 or later');
  Data.slProject.AddPair('Compiled file', '');
  Data.slProject.AddPair('Contents file', '');
  Data.slProject.AddPair('Default font', ',8,0');
  Data.slProject.AddPair('Default topic', '');
  Data.slProject.AddPair('Full-text search', 'Yes');
  Data.slProject.AddPair('Index file', '');
  Data.slProject.AddPair('Language', '0x409 English (United States)');
  Data.slProject.AddPair('Title', '');

  Data.slContent.AddPair('FrameName', 'right');
  Data.slContent.AddPair('Font', ',8,0');
  Data.slContent.AddPair('ImageType', 'Book');
  Data.slContent.AddPair('Window Styles', '0x27');
  Data.slContent.AddPair('ExWindow Styles', '0x0');

  Data.slKeyWords.AddPair('Font', ',8,0');
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
        if sName = 'Name' then
        begin
          TObjectData(LastNode.Data).Name := sValue;
          LastNode.Text := sValue;
        end
        else
        if sName = 'Local' then
        begin
          TObjectData(LastNode.Data).URL := sValue
        end
        else
        if sName = 'ImageNumber' then
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
  LastNode, RootNode: TTreeNode;
begin
  // ProjectItems[0] should exists - creates by LoadHHP

  LastNode := nil;
  RootNode := ProjectItems[0];

  DomTree := THyperParse.Create;
  DomTree.FileName := FileName;
  DomTree.Execute;

  for i := 0 to DomTree.Count - 1 do
  begin
    if AnsiUpperCase(DomTree.Item[i].TagName) = 'UL' then
    begin
      RootNode := LastNode;
      Continue;
    end;

    if (AnsiUpperCase(DomTree.Item[i].TagName) = '/UL') and Assigned(LastNode) then
    begin
      RootNode := RootNode.Parent;
      Continue;
    end;

    hhcType := GetTypeHHC(DomTree.Item[i]);

    case hhcType of
      hhcProperties: LastNode := ProjectItems[0];
      hhcObject: LastNode := AddObject(RootNode);
      hhcParameter: AddParameter(LastNode, DomTree.Item[i]);
    end;
  end;

  FreeAndNil(DomTree);
end;

procedure TProject.LoadHHK(FileName: String);
var
  LastNode: TTreeNode;
  slParameters: TStringList;
  j: Integer;

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
        sName := AnsiLowerCase(info.Params[i].Value);
      if AnsiLowerCase(info.Params[i].Name) = 'value' then
        sValue := FromHTML(info.Params[i].Value);
    end;

    if LastNode = ProjectItems[0] then
    begin
      TProjectData(ProjectItems[0].Data).slKeyWords.Add(sName + '=' + sValue);
      Exit;
    end;

    if sName = 'local' then
    begin
      for i := 1 to ProjectItems.Count - 1 do
        if AnsiLowerCase(Trim(TObjectData(ProjectItems[i].Data).URL)) = AnsiLowerCase(Trim(sValue)) then
        begin
          LastNode := ProjectItems[i];
          Break;
        end;

      if not Assigned(LastNode) then
        ShowMessage('Node not found for ' + sValue);
    end
    else
      slParameters.Add(sValue);
  end;

var
  DomTree: THyperParse;
  i: Integer;
  hhcType: THHCType;
begin
  DomTree := THyperParse.Create;
  DomTree.FileName := FileName;
  DomTree.Execute;

  slParameters := TStringList.Create;
  LastNode := nil;

  for i := 0 to DomTree.Count - 1 do
  begin
    hhcType := GetTypeHHC(DomTree.Item[i]);

    if (AnsiUpperCase(DomTree.Item[i].TagName) = '/OBJECT') and Assigned(LastNode) and (LastNode <> ProjectItems[0]) then
    begin
      for j := 0 to slParameters.Count - 1 do
        if slParameters[j] <> TObjectData(LastNode.Data).Name then
          TObjectData(LastNode.Data).slKeyWords.Add(slParameters[j]);

      slParameters.Clear;
      Continue;
    end;

    case hhcType of
      hhcProperties: LastNode := ProjectItems[0];
      hhcObject: LastNode := nil;
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

  RootNode := ProjectItems.AddChild(nil, 'Project properties');
  RootNode.ImageIndex := 43;
  RootNode.SelectedIndex := 43;

  Data := TProjectData.Create;
  RootNode.Data := Data;

  ini.ReadSectionValues('OPTIONS', Data.slProject);

  Data.slProject.Values['Contents file'] := FileHHC;
  Data.slProject.Values['Index file'] := FileHHK;

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

      slHHP.Add(ObjectData.URL);

      slHHC.Add('<LI><OBJECT type="text/sitemap">');
      slHHC.Add('  <param name="Name" value="' + ToHTML(ObjectData.Name, True) + '">');
      slHHC.Add('  <param name="Local" value="' + ToHTML(ObjectData.URL, True) + '">');
      if ObjectData.ImageIndex <> '' then
        slHHC.Add('  <param name="ImageNumber" value="' + ObjectData.ImageIndex + '">');
      slHHC.Add('</OBJECT>');

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

  DeleteFile(ProjectFile);

  slHHP := TStringList.Create;
  slHHC := TStringList.Create;
  slHHK := TStringList.Create;


  slHHP.Add('[OPTIONS]');
  for i := 0 to ProjectData.slProject.Count - 1 do
    slHHP.Add(ProjectData.slProject.Names[i] + '=' + ProjectData.slProject.ValueFromIndex[i]);


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


  slHHP.Add('');
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

