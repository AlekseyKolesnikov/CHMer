program CHMer;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  uMain in 'uMain.pas' {frmMain},
  uHelpProject in 'uHelpProject.pas',
  uSelectImage in 'uSelectImage.pas' {frmSelectImage};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
