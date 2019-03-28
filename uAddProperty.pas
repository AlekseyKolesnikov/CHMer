unit uAddProperty;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmAddProperty = class(TForm)
    rgSection: TRadioGroup;
    edName: TEdit;
    edValue: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure edNameChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfrmAddProperty.edNameChange(Sender: TObject);
begin
  btnOK.Enabled := Trim(edName.Text) <> '';
end;

end.
