unit uSelectImage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, uMain;

type
  TfrmSelectImage = class(TForm)
    lvIcons: TListView;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure lvIconsDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GetImageIndex(ImageIndex: Integer): Integer;

implementation

{$R *.dfm}

function GetImageIndex(ImageIndex: Integer): Integer;
var
  frmSelectImage: TfrmSelectImage;
begin
  Result := -1;

  frmSelectImage := TfrmSelectImage.Create(frmMain);

  if ImageIndex > -1 then
    frmSelectImage.lvIcons.Selected := frmSelectImage.lvIcons.Items[ImageIndex];

  if frmSelectImage.ShowModal = mrOk then
    Result := frmSelectImage.lvIcons.Items.IndexOf(frmSelectImage.lvIcons.Selected);

  FreeAndNil(frmSelectImage);
end;


procedure TfrmSelectImage.FormCreate(Sender: TObject);
var
  i: Integer;
  Item: TListItem;
begin
  for i := 0 to 42 do
  begin
    Item := lvIcons.Items.Add;
    Item.Caption := IntToStr(i);
    Item.ImageIndex := i;
  end;
end;

procedure TfrmSelectImage.lvIconsDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
