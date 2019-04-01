unit uEditValue;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Mask;

type
  TfrmEditValue = class(TForm)
    seInteger: TSpinEdit;
    cmbComboBox: TComboBox;
    lbCaption: TLabel;
    edEdit: TMaskEdit;
    btnOK: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TInitListCallback = procedure(aList: TStrings);
  TDestroyListCallback = procedure(aList: TStrings; ItemIndex: Integer);

function InputInteger(Title: String; var Value: Integer): Boolean;
function InputList(Title: String; var Value: String; InitListCallback: TInitListCallback; DestroyListCallback: TDestroyListCallback): Boolean;
function InputText(Title: String; var Value: String; Mask: String = ''): Boolean;

implementation

{$R *.dfm}

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

end.
