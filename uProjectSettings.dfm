object frmProjectSettings: TfrmProjectSettings
  Left = 0
  Top = 0
  ActiveControl = chbBack
  BorderStyle = bsDialog
  Caption = 'Project settings'
  ClientHeight = 379
  ClientWidth = 452
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  DesignSize = (
    452
    379)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 288
    Top = 346
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    ExplicitTop = 318
  end
  object btnCancel: TButton
    Left = 369
    Top = 346
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    ExplicitTop = 318
  end
  object gbButtons: TGroupBox
    Left = 8
    Top = 8
    Width = 436
    Height = 150
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Buttons'
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 94
      Width = 50
      Height = 13
      Caption = 'Shortcut 1'
    end
    object Label2: TLabel
      Left = 10
      Top = 121
      Width = 50
      Height = 13
      Caption = 'Shortcut 2'
    end
    object Label3: TLabel
      Left = 10
      Top = 67
      Width = 27
      Height = 13
      Caption = 'Home'
    end
    object chbBack: TCheckBox
      Left = 10
      Top = 18
      Width = 50
      Height = 17
      Caption = 'Back'
      TabOrder = 0
    end
    object chbForward: TCheckBox
      Left = 70
      Top = 18
      Width = 68
      Height = 17
      Caption = 'Forward'
      TabOrder = 1
    end
    object chbStop: TCheckBox
      Left = 10
      Top = 41
      Width = 50
      Height = 17
      Caption = 'Stop'
      TabOrder = 4
    end
    object chbRefresh: TCheckBox
      Left = 70
      Top = 41
      Width = 68
      Height = 17
      Caption = 'Refresh'
      TabOrder = 5
    end
    object chbSync: TCheckBox
      Left = 150
      Top = 18
      Width = 126
      Height = 17
      Caption = 'Locate in tree (Sync)'
      TabOrder = 2
    end
    object chbOptions: TCheckBox
      Left = 150
      Top = 41
      Width = 64
      Height = 17
      Caption = 'Options'
      TabOrder = 6
    end
    object chbPrint: TCheckBox
      Left = 222
      Top = 41
      Width = 54
      Height = 17
      Caption = 'Print'
      TabOrder = 7
    end
    object chbHideShow: TCheckBox
      Left = 292
      Top = 18
      Width = 142
      Height = 17
      Caption = 'Hide/Show left panel'
      TabOrder = 3
    end
    object chbZoom: TCheckBox
      Left = 292
      Top = 41
      Width = 142
      Height = 17
      Caption = 'Change font size (zoom)'
      TabOrder = 8
    end
    object cmbJump1: TComboBox
      Left = 70
      Top = 91
      Width = 216
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemIndex = 0
      TabOrder = 10
      Text = #8213
      Items.Strings = (
        #8213)
    end
    object edJump1: TEdit
      Left = 292
      Top = 91
      Width = 134
      Height = 21
      Hint = 'Title'
      TabOrder = 11
    end
    object cmbJump2: TComboBox
      Left = 70
      Top = 118
      Width = 216
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemIndex = 0
      TabOrder = 12
      Text = #8213
      Items.Strings = (
        #8213)
    end
    object edJump2: TEdit
      Left = 292
      Top = 118
      Width = 134
      Height = 21
      Hint = 'Title'
      TabOrder = 13
    end
    object cmbHome: TComboBox
      Left = 70
      Top = 64
      Width = 216
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemIndex = 0
      TabOrder = 9
      Text = #8213
      Items.Strings = (
        #8213)
    end
  end
  object gbWindow: TGroupBox
    Left = 8
    Top = 164
    Width = 436
    Height = 70
    Caption = 'Window'
    TabOrder = 1
    object Label4: TLabel
      Left = 78
      Top = 20
      Width = 19
      Height = 13
      Caption = 'Left'
    end
    object Label5: TLabel
      Left = 162
      Top = 20
      Width = 18
      Height = 13
      Caption = 'Top'
    end
    object Label6: TLabel
      Left = 245
      Top = 20
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object Label7: TLabel
      Left = 338
      Top = 20
      Width = 31
      Height = 13
      Caption = 'Height'
    end
    object chbSavePosition: TCheckBox
      Left = 10
      Top = 45
      Width = 183
      Height = 17
      Caption = 'Save position after user change'
      TabOrder = 5
    end
    object edPosLeft: TSpinEdit
      Left = 102
      Top = 17
      Width = 52
      Height = 22
      MaxValue = 9999
      MinValue = 0
      TabOrder = 1
      Value = 0
      OnChange = edSpinEditChange
    end
    object edPosTop: TSpinEdit
      Left = 185
      Top = 17
      Width = 52
      Height = 22
      MaxValue = 9999
      MinValue = 0
      TabOrder = 2
      Value = 0
      OnChange = edSpinEditChange
    end
    object edPosWidth: TSpinEdit
      Left = 278
      Top = 17
      Width = 52
      Height = 22
      MaxValue = 9999
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = edSpinEditChange
    end
    object edPosHeight: TSpinEdit
      Left = 374
      Top = 17
      Width = 52
      Height = 22
      MaxValue = 9999
      MinValue = 0
      TabOrder = 4
      Value = 0
      OnChange = edSpinEditChange
    end
    object chbPosition: TCheckBox
      Left = 10
      Top = 18
      Width = 60
      Height = 17
      Hint = 'Set position'
      Caption = 'Position'
      TabOrder = 0
    end
    object chbWinOnTop: TCheckBox
      Left = 226
      Top = 45
      Width = 92
      Height = 17
      Caption = 'Always on top'
      TabOrder = 6
    end
    object chbShowMenu: TCheckBox
      Left = 355
      Top = 45
      Width = 80
      Height = 17
      Caption = 'Show menu'
      TabOrder = 7
    end
  end
  object gbNavigation: TGroupBox
    Left = 8
    Top = 240
    Width = 436
    Height = 98
    Caption = 'Navigation tree pane'
    TabOrder = 2
    object Label8: TLabel
      Left = 237
      Top = 71
      Width = 54
      Height = 13
      Caption = 'Default tab'
    end
    object Label9: TLabel
      Left = 10
      Top = 44
      Width = 156
      Height = 13
      Caption = 'Navigation pane width (0 - auto)'
    end
    object chbNaviShow: TCheckBox
      Left = 10
      Top = 18
      Width = 128
      Height = 17
      Caption = 'Show navigation tree'
      TabOrder = 0
    end
    object chbNaviAutoHide: TCheckBox
      Left = 168
      Top = 18
      Width = 104
      Height = 17
      Caption = 'Auto-hide/show'
      TabOrder = 1
    end
    object chbNaviAutoSync: TCheckBox
      Left = 297
      Top = 18
      Width = 137
      Height = 17
      Caption = 'Autosync with contents'
      TabOrder = 2
    end
    object chbShowSearch: TCheckBox
      Left = 10
      Top = 69
      Width = 87
      Height = 17
      Caption = 'Show search'
      TabOrder = 3
    end
    object chbShowFavorites: TCheckBox
      Left = 117
      Top = 69
      Width = 98
      Height = 17
      Caption = 'Show favorites'
      TabOrder = 5
    end
    object cmbDefaultTab: TComboBox
      Left = 297
      Top = 67
      Width = 129
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 6
      Text = 'Contents'
      Items.Strings = (
        'Contents'
        'Index'
        'Search'
        'Favorites')
    end
    object edLeftPaneWidth: TSpinEdit
      Left = 172
      Top = 41
      Width = 52
      Height = 22
      MaxValue = 9999
      MinValue = 0
      TabOrder = 4
      Value = 400
      OnChange = edSpinEditChange
    end
  end
end
