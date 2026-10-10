unit uProjectSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.Samples.Spin, Vcl.Mask, RxToolEdit;

type
  TfrmProjectSettings = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    gbButtons: TGroupBox;
    chbBack: TCheckBox;
    chbForward: TCheckBox;
    chbStop: TCheckBox;
    chbRefresh: TCheckBox;
    chbSync: TCheckBox;
    chbOptions: TCheckBox;
    chbPrint: TCheckBox;
    chbHideShow: TCheckBox;
    chbZoom: TCheckBox;
    cmbJump1: TComboBox;
    edJump1: TEdit;
    Label1: TLabel;
    cmbJump2: TComboBox;
    edJump2: TEdit;
    Label2: TLabel;
    cmbHome: TComboBox;
    Label3: TLabel;
    gbWindow: TGroupBox;
    chbSavePosition: TCheckBox;
    Label4: TLabel;
    edPosLeft: TSpinEdit;
    edPosTop: TSpinEdit;
    Label5: TLabel;
    edPosWidth: TSpinEdit;
    Label6: TLabel;
    edPosHeight: TSpinEdit;
    Label7: TLabel;
    gbNavigation: TGroupBox;
    chbNaviShow: TCheckBox;
    chbNaviAutoHide: TCheckBox;
    chbNaviAutoSync: TCheckBox;
    chbPosition: TCheckBox;
    chbWinOnTop: TCheckBox;
    chbShowMenu: TCheckBox;
    chbShowSearch: TCheckBox;
    chbShowFavorites: TCheckBox;
    cmbDefaultTab: TComboBox;
    Label8: TLabel;
    Label9: TLabel;
    edLeftPaneWidth: TSpinEdit;
    gbWebHelp: TGroupBox;
    Label10: TLabel;
    deWebHelpOutput: TDirectoryEdit;
    procedure edSpinEditChange(Sender: TObject);
    procedure deWebHelpOutputBeforeDialog(Sender: TObject; var AName: string; var Action: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    BaseDir: String; // the project folder: deWebHelpOutput is relative to it
  end;

implementation

{$R *.dfm}

uses
  uEditValue;

// RxLib's folder dialogs are the Windows 3.1 style one and a SHBrowseForFolder wrapper that is not 64-bit safe
procedure TfrmProjectSettings.deWebHelpOutputBeforeDialog(Sender: TObject; var AName: string; var Action: Boolean);
var
  Dir: String;
begin
  Action := False;
  Dir := deWebHelpOutput.Text;

  if BrowseFolder('WebHelp output folder (replaced on every build)', BaseDir, Dir) then
    deWebHelpOutput.Text := Dir;
end;

procedure TfrmProjectSettings.edSpinEditChange(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then
    TSpinEdit(Sender).Value := 0;
end;

end.
