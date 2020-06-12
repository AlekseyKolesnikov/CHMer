object frmAddNewEmpty: TfrmAddNewEmpty
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Create new empty HTML'
  ClientHeight = 155
  ClientWidth = 294
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
    294
    155)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 20
    Height = 13
    Caption = 'Title'
  end
  object Label2: TLabel
    Left = 8
    Top = 38
    Width = 45
    Height = 13
    Caption = 'File name'
  end
  object btnOK: TButton
    Left = 130
    Top = 122
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 211
    Top = 122
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object edTitle: TEdit
    Left = 59
    Top = 8
    Width = 227
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object edFileName: TEdit
    Left = 59
    Top = 35
    Width = 227
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object rgPosition: TRadioGroup
    Left = 8
    Top = 62
    Width = 278
    Height = 51
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add'
    Columns = 3
    ItemIndex = 1
    Items.Strings = (
      'Before'
      'After'
      'Child')
    TabOrder = 2
  end
  object chbOpenEditor: TCheckBox
    Left = 8
    Top = 126
    Width = 97
    Height = 17
    Caption = 'Open in editor'
    TabOrder = 3
  end
  object fsLayout: TFormStorage
    IniFileName = 'SOFTWARE'
    IniSection = 'CHMer'
    Options = []
    StoredProps.Strings = (
      'rgPosition.ItemIndex'
      'chbOpenEditor.Checked')
    StoredValues = <>
    Left = 250
    Top = 71
  end
end
