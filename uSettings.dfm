object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 103
  ClientWidth = 394
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    394
    103)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 68
    Height = 13
    Caption = 'HHC.exe path'
  end
  object edHHC: TFilenameEdit
    Left = 82
    Top = 8
    Width = 304
    Height = 21
    Filter = 'HHC.exe (hhc.exe)|hhc.exe'
    Anchors = [akLeft, akTop, akRight]
    NumGlyphs = 1
    TabOrder = 0
    Text = ''
    ExplicitWidth = 555
  end
  object chbAddContents: TCheckBox
    Left = 8
    Top = 35
    Width = 378
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add content tree to keywords'
    TabOrder = 1
    ExplicitWidth = 629
  end
  object btnOK: TButton
    Left = 230
    Top = 70
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    ExplicitLeft = 481
    ExplicitTop = 317
  end
  object btnCancel: TButton
    Left = 311
    Top = 70
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    ExplicitLeft = 562
    ExplicitTop = 317
  end
end
