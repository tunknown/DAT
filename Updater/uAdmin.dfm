object FAdmin: TFAdmin
  Left = 0
  Top = 0
  Caption = #1055#1091#1073#1083#1080#1082#1072#1094#1080#1103' '#1092#1072#1081#1083#1086#1074' '#1089' '#1082#1083#1080#1077#1085#1090#1072' '#1085#1072' '#1089#1077#1088#1074#1077#1088
  ClientHeight = 685
  ClientWidth = 944
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PC: TPageControl
    Left = 0
    Top = 0
    Width = 944
    Height = 685
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    OnChange = PCChange
    object TabSheet1: TTabSheet
      Caption = #1055#1091#1073#1083#1080#1082#1072#1094#1080#1103
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 936
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          936
          41)
        object TLabel
          Left = 4
          Top = 0
          Width = 63
          Height = 13
          Caption = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1077
        end
        object TLabel
          Left = 296
          Top = 0
          Width = 35
          Height = 13
          Caption = #1042#1077#1088#1089#1080#1103
        end
        object TLabel
          Left = 528
          Top = 0
          Width = 37
          Height = 13
          Caption = #1042#1099#1087#1091#1089#1082
        end
        object EApplication: TEdit
          Left = 4
          Top = 16
          Width = 286
          Height = 19
          Ctl3D = False
          ParentCtl3D = False
          ReadOnly = True
          TabOrder = 2
        end
        object EVersion: TEdit
          Left = 296
          Top = 16
          Width = 226
          Height = 19
          Ctl3D = False
          ParentCtl3D = False
          TabOrder = 0
        end
        object EBuild: TEdit
          Left = 528
          Top = 16
          Width = 401
          Height = 19
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = False
          ParentCtl3D = False
          TabOrder = 1
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 616
        Width = 936
        Height = 41
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          936
          41)
        object BSave: TButton
          Left = 744
          Top = 8
          Width = 185
          Height = 25
          Anchors = [akTop, akRight]
          Caption = #1055#1091#1073#1083#1080#1082#1072#1094#1080#1103
          Default = True
          TabOrder = 0
          OnClick = BSaveClick
        end
        object BRefresh: TButton
          Left = 4
          Top = 8
          Width = 185
          Height = 25
          Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1089#1087#1080#1089#1082#1072' '#1092#1072#1081#1083#1086#1074
          TabOrder = 1
          OnClick = BRefreshClick
        end
        object CBArchive: TCheckBox
          Left = 673
          Top = 12
          Width = 65
          Height = 17
          Anchors = [akTop, akRight]
          Caption = #1042' '#1072#1088#1093#1080#1074
          Ctl3D = False
          ParentCtl3D = False
          TabOrder = 2
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 41
        Width = 936
        Height = 575
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 936
          Height = 21
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          DesignSize = (
            936
            21)
          object TLabel
            Left = 4
            Top = 4
            Width = 185
            Height = 13
            Caption = #1055#1086#1084#1077#1095#1077#1085#1085#1099#1077' '#1076#1083#1103' '#1087#1091#1073#1083#1080#1082#1072#1094#1080#1080' '#1092#1072#1081#1083#1099
          end
          object TCIsReadOnly: TTabControl
            Left = 810
            Top = 0
            Width = 126
            Height = 21
            Align = alRight
            Style = tsButtons
            TabOrder = 0
            Tabs.Strings = (
              #1048#1079#1084#1077#1085#1105#1085#1085#1099#1077
              #1042#1089#1077)
            TabIndex = 0
            OnChange = TCIsReadOnlyChange
          end
          object BBHelp: TBitBtn
            Left = 751
            Top = -1
            Width = 37
            Height = 23
            Anchors = [akTop, akRight]
            Caption = ' '
            Kind = bkHelp
            NumGlyphs = 2
            TabOrder = 1
            OnClick = BBHelpClick
          end
        end
        object DBGRunLog: TDBGrid
          Left = 0
          Top = 21
          Width = 936
          Height = 554
          Align = alClient
          Ctl3D = False
          DataSource = DSRunLog
          DrawingStyle = gdsClassic
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick]
          ParentCtl3D = False
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
          OnCellClick = DBGRunLogCellClick
          OnKeyUp = DBGRunLogKeyUp
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      ImageIndex = 1
      object DBGPathMapping: TDBGrid
        Left = 0
        Top = 24
        Width = 936
        Height = 633
        Align = alClient
        Ctl3D = False
        DataSource = DSPathMapping
        DrawingStyle = gdsClassic
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick]
        ParentCtl3D = False
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object TPanel
        Left = 0
        Top = 0
        Width = 936
        Height = 24
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          936
          24)
        object TLabel
          Left = 0
          Top = 5
          Width = 372
          Height = 13
          Caption = 
            #1057#1086#1087#1086#1089#1090#1072#1074#1083#1077#1085#1080#1077' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1081' '#1085#1072' '#1086#1087#1091#1073#1083#1080#1082#1086#1074#1072#1090#1077#1083#1077' '#1080' '#1089#1077#1088#1074#1077#1088#1077'/'#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083 +
            #1077
        end
        object TDBNavigator
          Left = 696
          Top = 0
          Width = 240
          Height = 24
          DataSource = DSPathMapping
          Align = alRight
          Flat = True
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
        end
        object BBMappingHelp: TBitBtn
          Left = 653
          Top = 0
          Width = 37
          Height = 23
          Anchors = [akTop, akRight]
          Caption = ' '
          Kind = bkHelp
          NumGlyphs = 2
          TabOrder = 1
          OnClick = BBMappingHelpClick
        end
      end
    end
    object TSAlive: TTabSheet
      Caption = #1040#1082#1090#1080#1074#1085#1086#1089#1090#1100
      ImageIndex = 2
      object TPanel
        Left = 0
        Top = 0
        Width = 936
        Height = 24
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object TLabel
          Left = 0
          Top = 5
          Width = 306
          Height = 13
          Caption = #1055#1086#1089#1083#1077#1076#1085#1080#1077' '#1079#1072#1075#1088#1091#1079#1082#1080' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1081' '#1087#1086#1089#1083#1077' '#1087#1086#1089#1083#1077#1076#1085#1077#1075#1086' '#1074#1099#1087#1091#1089#1082#1072
        end
        object TDBNavigator
          Left = 812
          Top = 0
          Width = 124
          Height = 24
          DataSource = DSLastAlive
          VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbRefresh]
          Align = alRight
          Flat = True
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
        end
      end
      object DBGAlive: TDBGrid
        Left = 0
        Top = 24
        Width = 936
        Height = 633
        Align = alClient
        Ctl3D = False
        DataSource = DSLastAlive
        DrawingStyle = gdsClassic
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick]
        ParentCtl3D = False
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
  object DSRunLog: TDataSource
    AutoEdit = False
    DataSet = DM1.UQRunLog
    OnDataChange = DSRunLogDataChange
    Left = 36
    Top = 4
  end
  object DSPathMapping: TDataSource
    AutoEdit = False
    DataSet = DM1.UQPathMapping
    OnStateChange = DSPathMappingStateChange
    Left = 144
    Top = 4
  end
  object DSLastAlive: TDataSource
    AutoEdit = False
    DataSet = DM1.UQLastAlive
    Left = 256
    Top = 4
  end
end
