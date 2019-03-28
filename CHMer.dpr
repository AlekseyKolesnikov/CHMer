program CHMer;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain},
  uHelpProject in 'uHelpProject.pas',
  uSelectImage in 'uSelectImage.pas' {frmSelectImage},
  uAddProperty in 'uAddProperty.pas' {frmAddProperty},
  uSettings in 'uSettings.pas' {frmSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
