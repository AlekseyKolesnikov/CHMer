unit uAddNewEmpty;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Mask, Vcl.ExtCtrls, RxPlacemnt;

type
  TfrmAddNewEmpty = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    edTitle: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edFileName: TEdit;
    rgPosition: TRadioGroup;
    chbOpenEditor: TCheckBox;
    fsLayout: TFormStorage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function InputNewEmpty(var Title: String; var FileName: String; var Position: Integer; var OpenEditor: Boolean): Boolean;

implementation

{$R *.dfm}

function InputNewEmpty(var Title: String; var FileName: String; var Position: Integer; var OpenEditor: Boolean): Boolean;
var
  frmAddNewEmpty: TfrmAddNewEmpty;
begin
  frmAddNewEmpty := TfrmAddNewEmpty.Create(Application);

  Result := frmAddNewEmpty.ShowModal = mrOk;

  if Result then
  begin
    Title := frmAddNewEmpty.edTitle.Text;
    FileName := frmAddNewEmpty.edFileName.Text;
    Position := frmAddNewEmpty.rgPosition.ItemIndex;
    OpenEditor := frmAddNewEmpty.chbOpenEditor.Checked;
  end;

  frmAddNewEmpty.Free;
end;

procedure TfrmAddNewEmpty.FormCreate(Sender: TObject);
begin
  fsLayout.UseRegistry := True;
end;

end.
