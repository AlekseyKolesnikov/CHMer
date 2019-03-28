object frmAddProperty: TfrmAddProperty
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Add property'
  ClientHeight = 155
  ClientWidth = 254
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
    254
    155)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 65
    Width = 27
    Height = 13
    Caption = 'Name'
  end
  object Label2: TLabel
    Left = 8
    Top = 92
    Width = 26
    Height = 13
    Caption = 'Value'
  end
  object rgSection: TRadioGroup
    Left = 8
    Top = 8
    Width = 238
    Height = 48
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Section'
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      'Project'
      'Content'
      'Keywords')
    TabOrder = 0
  end
  object edName: TEdit
    Left = 41
    Top = 62
    Width = 205
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    OnChange = edNameChange
  end
  object edValue: TEdit
    Left = 41
    Top = 89
    Width = 205
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 90
    Top = 122
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 171
    Top = 122
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
