object frmSelectImage: TfrmSelectImage
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Select image'
  ClientHeight = 345
  ClientWidth = 542
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    542
    345)
  PixelsPerInch = 96
  TextHeight = 13
  object lvIcons: TListView
    Left = 0
    Top = 0
    Width = 542
    Height = 302
    Align = alTop
    Columns = <>
    LargeImages = frmMain.ilHelp
    TabOrder = 0
    OnDblClick = lvIconsDblClick
  end
  object btnOK: TButton
    Left = 378
    Top = 312
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 459
    Top = 312
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
