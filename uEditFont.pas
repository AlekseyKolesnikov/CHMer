unit uEditFont;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Mask;

type
  TfrmEditFont = class(TForm)
    cmbFontName: TComboBox;
    Label4: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    seFontSize: TSpinEdit;
    Label1: TLabel;
    cmbCharset: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    lbPreview: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OnFontChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function InputFont(Title: String; var FontName: String; var FontSize: Integer; var Charset: Integer): Boolean;

implementation

{$R *.dfm}

function InputFont(Title: String; var FontName: String; var FontSize: Integer; var Charset: Integer): Boolean;
var
  frmEditFont: TfrmEditFont;
begin
  frmEditFont := TfrmEditFont.Create(Application);

  frmEditFont.cmbFontName.ItemIndex := frmEditFont.cmbFontName.Items.IndexOf(FontName);
  if frmEditFont.cmbFontName.ItemIndex < 0 then
    frmEditFont.cmbFontName.Text := FontName;

  frmEditFont.seFontSize.Value := FontSize;
  frmEditFont.cmbCharset.ItemIndex := frmEditFont.cmbCharset.Items.IndexOfObject(Pointer(Charset));

  Result := frmEditFont.ShowModal = mrOk;

  if Result then
  begin
    FontName := frmEditFont.cmbFontName.Text;
    FontSize := frmEditFont.seFontSize.Value;
    Charset := Integer(Pointer(frmEditFont.cmbCharset.Items.Objects[frmEditFont.cmbCharset.ItemIndex]));
  end;

  frmEditFont.Free;
end;

procedure TfrmEditFont.FormCreate(Sender: TObject);
begin
  cmbFontName.Items.AddStrings(Screen.Fonts);

  cmbCharset.Items.AddObject('ANSI_CHARSET', Pointer($00));
  cmbCharset.Items.AddObject('ARABIC_CHARSET', Pointer($B2));
  cmbCharset.Items.AddObject('BALTIC_CHARSET', Pointer($BA));
  cmbCharset.Items.AddObject('CHINESEBIG5_CHARSET', Pointer($88));
  cmbCharset.Items.AddObject('DEFAULT_CHARSET', Pointer($01));
  cmbCharset.Items.AddObject('EASTEUROPE_CHARSET', Pointer($EE));
  cmbCharset.Items.AddObject('GB2312_CHARSET', Pointer($86));
  cmbCharset.Items.AddObject('GREEK_CHARSET', Pointer($A1));
  cmbCharset.Items.AddObject('HANGUL_CHARSET', Pointer($81));
  cmbCharset.Items.AddObject('HEBREW_CHARSET', Pointer($B1));
  cmbCharset.Items.AddObject('JOHAB_CHARSET', Pointer($82));
  cmbCharset.Items.AddObject('MAC_CHARSET', Pointer($4D));
  cmbCharset.Items.AddObject('OEM_CHARSET', Pointer($FF));
  cmbCharset.Items.AddObject('RUSSIAN_CHARSET', Pointer($CC));
  cmbCharset.Items.AddObject('SHIFTJIS_CHARSET', Pointer($80));
  cmbCharset.Items.AddObject('SYMBOL_CHARSET', Pointer($02));
  cmbCharset.Items.AddObject('THAI_CHARSET', Pointer($DE));
  cmbCharset.Items.AddObject('TURKISH_CHARSET', Pointer($A2));
  cmbCharset.Items.AddObject('VIETNAMESE_CHARSET', Pointer($A3));

  cmbCharset.ItemIndex := 0;

  cmbFontName.OnChange := OnFontChange;
  seFontSize.OnChange := OnFontChange;
  cmbCharset.OnChange := OnFontChange;
end;

procedure TfrmEditFont.OnFontChange(Sender: TObject);
begin
  lbPreview.Font.Name := cmbFontName.Text;
  lbPreview.Font.Size := seFontSize.Value;
  if cmbCharset.ItemIndex > -1 then
    lbPreview.Font.Charset := TFontCharset(Pointer(cmbCharset.Items.Objects[cmbCharset.ItemIndex]));
end;

end.
