object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 123
  ClientWidth = 426
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
    426
    123)
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
    Width = 336
    Height = 21
    Filter = 'HHC.exe (hhc.exe)|hhc.exe'
    Anchors = [akLeft, akTop, akRight]
    NumGlyphs = 1
    TabOrder = 0
    Text = ''
    ExplicitWidth = 304
  end
  object chbAddContents: TCheckBox
    Left = 8
    Top = 35
    Width = 246
    Height = 17
    Caption = 'Add names from the content tree to keywords'
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 262
    Top = 90
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    ExplicitLeft = 230
    ExplicitTop = 70
  end
  object btnCancel: TButton
    Left = 343
    Top = 90
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    ExplicitLeft = 311
    ExplicitTop = 70
  end
  object chbAddIfEmpty: TCheckBox
    Left = 253
    Top = 35
    Width = 172
    Height = 17
    Caption = 'only if the keywords are empty'
    TabOrder = 2
  end
end
