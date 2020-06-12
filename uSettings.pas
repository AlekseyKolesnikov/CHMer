unit uSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask, RxToolEdit, Vcl.StdCtrls;

type
  TfrmSettings = class(TForm)
    Label1: TLabel;
    edHHC: TFilenameEdit;
    chbAddContents: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    chbAddIfEmpty: TCheckBox;
    edEditor: TFilenameEdit;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
