object frmEditFont: TfrmEditFont
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Enter value'
  ClientHeight = 101
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    394
    101)
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 11
    Width = 51
    Height = 13
    Caption = 'Font name'
  end
  object Label1: TLabel
    Left = 8
    Top = 38
    Width = 43
    Height = 13
    Caption = 'Font size'
  end
  object Label2: TLabel
    Left = 177
    Top = 38
    Width = 38
    Height = 13
    Caption = 'Charset'
  end
  object Label3: TLabel
    Left = 8
    Top = 63
    Width = 38
    Height = 13
    Caption = 'Preview'
  end
  object lbPreview: TLabel
    Left = 65
    Top = 63
    Width = 37
    Height = 13
    Caption = 'AaBbCc'
  end
  object cmbFontName: TComboBox
    Left = 65
    Top = 8
    Width = 321
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 32
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 230
    Top = 68
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    ExplicitTop = 46
  end
  object btnCancel: TButton
    Left = 311
    Top = 68
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    ExplicitTop = 46
  end
  object seFontSize: TSpinEdit
    Left = 65
    Top = 35
    Width = 100
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
  end
  object cmbCharset: TComboBox
    Left = 221
    Top = 35
    Width = 165
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 32
    TabOrder = 2
  end
end
