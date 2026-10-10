unit uEditValue;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Mask, RxToolEdit;

type
  TfrmEditValue = class(TForm)
    seInteger: TSpinEdit;
    cmbComboBox: TComboBox;
    lbCaption: TLabel;
    edEdit: TMaskEdit;
    feFileName: TFilenameEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure feFileNameBeforeDialog(Sender: TObject; var AName: string; var Action: Boolean);
  private
    { Private declarations }
    BaseDir: String; // relative paths are relative to it
  public
    { Public declarations }
  end;

  TInitListCallback = procedure(aList: TStrings);
  TDestroyListCallback = procedure(aList: TStrings; ItemIndex: Integer);

// Value is a path relative to BaseDir, or an absolute one; the dialogs return it relative when possible
function BrowseFolder(Title, BaseDir: String; var Value: String): Boolean;
function InputFileName(Title, BaseDir: String; var Value: String; Filter: String = ''; DefaultExt: String = ''): Boolean;
function InputInteger(Title: String; var Value: Integer): Boolean;
function InputList(Title: String; var Value: String; InitListCallback: TInitListCallback; DestroyListCallback: TDestroyListCallback): Boolean;
function InputText(Title: String; var Value: String; Mask: String = ''): Boolean;

implementation

{$R *.dfm}

uses
  SystemUtils;

function Dequote(const S: String): String;
begin
  Result := AnsiDequotedStr(Trim(S), '"');
end;

function BrowseFolder(Title, BaseDir: String; var Value: String): Boolean;
var
  dlgFolder: TFileOpenDialog;
  Dir: String;
begin
  Dir := ExpandPath(BaseDir, Dequote(Value));

  if not DirectoryExists(Dir) then
    Dir := BaseDir;

  dlgFolder := TFileOpenDialog.Create(nil);
  try
    dlgFolder.Title := Title;
    dlgFolder.Options := [fdoPickFolders, fdoForceFileSystem, fdoPathMustExist];
    dlgFolder.DefaultFolder := Dir;

    Result := dlgFolder.Execute;

    if Result then
      Value := RelativePath(BaseDir, dlgFolder.FileName);
  finally
    dlgFolder.Free;
  end;
end;

function InputFileName(Title, BaseDir: String; var Value: String; Filter: String = ''; DefaultExt: String = ''): Boolean;
var
  frmEditValue: TfrmEditValue;
begin
  frmEditValue := TfrmEditValue.Create(Application);
  frmEditValue.Caption := Title;
  frmEditValue.BaseDir := BaseDir;
  frmEditValue.feFileName.Visible := True;
  frmEditValue.feFileName.DialogTitle := Title;
  frmEditValue.feFileName.Text := Value;

  if Filter <> '' then
    frmEditValue.feFileName.Filter := Filter;

  frmEditValue.feFileName.DefaultExt := DefaultExt;

  Result := frmEditValue.ShowModal = mrOk;

  if Result then
    Value := Dequote(frmEditValue.feFileName.Text);

  frmEditValue.Free;
end;

function InputInteger(Title: String; var Value: Integer): Boolean;
var
  frmEditValue: TfrmEditValue;
begin
  frmEditValue := TfrmEditValue.Create(Application);
  frmEditValue.Caption := Title;
  frmEditValue.seInteger.Visible := True;
  frmEditValue.seInteger.Value := Value;

  Result := frmEditValue.ShowModal = mrOk;

  if Result then
    Value := frmEditValue.seInteger.Value;

  frmEditValue.Free;
end;

function InputList(Title: String; var Value: String; InitListCallback: TInitListCallback; DestroyListCallback: TDestroyListCallback): Boolean;
var
  frmEditValue: TfrmEditValue;
begin
  frmEditValue := TfrmEditValue.Create(Application);
  frmEditValue.Caption := Title;
  frmEditValue.cmbComboBox.Visible := True;
  InitListCallback(frmEditValue.cmbComboBox.Items);
  frmEditValue.cmbComboBox.ItemIndex := frmEditValue.cmbComboBox.Items.IndexOf(Value);

  Result := frmEditValue.ShowModal = mrOk;

  if Result then
    Value := frmEditValue.cmbComboBox.Text;

  if Assigned(DestroyListCallback) then
    DestroyListCallback(frmEditValue.cmbComboBox.Items, frmEditValue.cmbComboBox.ItemIndex);

  frmEditValue.Free;
end;

function InputText(Title: String; var Value: String; Mask: String = ''): Boolean;
var
  frmEditValue: TfrmEditValue;
begin
  frmEditValue := TfrmEditValue.Create(Application);
  frmEditValue.Caption := Title;
  frmEditValue.edEdit.Visible := True;
  frmEditValue.edEdit.EditMask := Mask;
  frmEditValue.edEdit.Text := Value;

  Result := frmEditValue.ShowModal = mrOk;

  if Result then
    Value := frmEditValue.edEdit.Text;

  frmEditValue.Free;
end;

{ TfrmEditValue }

// The dialog is shown here instead of by RxLib, which passes AName cut at the first space (it parses the text
// as a command line), resolves a relative name against the current folder and quotes a selected name with spaces
procedure TfrmEditValue.feFileNameBeforeDialog(Sender: TObject; var AName: string; var Action: Boolean);
var
  FileName: String;
begin
  Action := False;
  FileName := ExpandPath(BaseDir, Dequote(feFileName.Text));

  if DirectoryExists(ExtractFileDir(FileName)) then
    feFileName.Dialog.InitialDir := ExtractFileDir(FileName)
  else
    feFileName.Dialog.InitialDir := BaseDir;

  feFileName.Dialog.FileName := ExtractFileName(FileName);

  if feFileName.Dialog.Execute then
    feFileName.Text := RelativePath(BaseDir, feFileName.Dialog.FileName);
end;

end.
