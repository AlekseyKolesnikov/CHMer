object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 145
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
    145)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 68
    Height = 13
    Caption = 'HHC.exe path'
  end
  object Label2: TLabel
    Left = 8
    Top = 38
    Width = 53
    Height = 13
    Caption = 'Editor path'
  end
  object Label3: TLabel
    Left = 8
    Top = 88
    Width = 39
    Height = 13
    Caption = 'Tab size'
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
  end
  object chbAddContents: TCheckBox
    Left = 8
    Top = 62
    Width = 246
    Height = 17
    Caption = 'Add names from the content tree to keywords'
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 262
    Top = 112
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
    ExplicitTop = 90
  end
  object btnCancel: TButton
    Left = 343
    Top = 112
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
    ExplicitTop = 90
  end
  object chbAddIfEmpty: TCheckBox
    Left = 253
    Top = 62
    Width = 172
    Height = 17
    Caption = 'only if the keywords are empty'
    TabOrder = 3
  end
  object edEditor: TFilenameEdit
    Left = 82
    Top = 35
    Width = 336
    Height = 21
    Filter = 'Executables (*.exe)|*.exe'
    Anchors = [akLeft, akTop, akRight]
    NumGlyphs = 1
    TabOrder = 1
    Text = ''
  end
  object edTabSize: TSpinEdit
    Left = 82
    Top = 85
    Width = 63
    Height = 22
    MaxValue = 10
    MinValue = 1
    TabOrder = 4
    Value = 2
  end
end
