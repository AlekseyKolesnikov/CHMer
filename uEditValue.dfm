object frmEditValue: TfrmEditValue
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Enter value'
  ClientHeight = 79
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    394
    79)
  PixelsPerInch = 96
  TextHeight = 13
  object lbCaption: TLabel
    Left = 8
    Top = 11
    Width = 55
    Height = 13
    Caption = 'Enter value'
  end
  object edEdit: TMaskEdit
    Left = 72
    Top = 8
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = ''
    Visible = False
  end
  object seInteger: TSpinEdit
    Left = 72
    Top = 8
    Width = 100
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
    Visible = False
  end
  object cmbComboBox: TComboBox
    Left = 72
    Top = 8
    Width = 314
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 32
    TabOrder = 2
    Visible = False
  end
  object btnOK: TButton
    Left = 230
    Top = 46
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 311
    Top = 46
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
