object FUpdater: TFUpdater
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = #1054#1073#1085#1086#1074#1083#1103#1077#1090#1089#1103' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1077' %s '#1076#1086' '#1074#1077#1088#1089#1080#1080' %s'
  ClientHeight = 67
  ClientWidth = 634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 634
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object PB: TProgressBar
      Left = 16
      Top = 14
      Width = 601
      Height = 25
      Align = alCustom
      DoubleBuffered = True
      ParentDoubleBuffered = False
      Smooth = True
      TabOrder = 0
    end
    object BStart: TButton
      Left = 479
      Top = 14
      Width = 138
      Height = 25
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1077
      Enabled = False
      TabOrder = 1
      Visible = False
      OnClick = BStartClick
    end
  end
  object MMessage: TMemo
    Left = 0
    Top = 48
    Width = 634
    Height = 19
    Align = alClient
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    Visible = False
  end
end
