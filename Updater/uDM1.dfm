object DM1: TDM1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 362
  Width = 880
  object UP1: TSQLServerUniProvider
    Left = 4
  end
  object UC1: TUniConnection
    ProviderName = 'SQL Server'
    Database = 'Updater'
    SpecificOptions.Strings = (
      'SQL Server.ConnectionTimeout=5')
    Options.KeepDesignConnected = False
    Username = 'sa'
    Server = '.\sqlexpress'
    Connected = True
    LoginPrompt = False
    Left = 60
    EncryptedPassword = '8EFF'
  end
  object UQDoCompareServerToClient: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'declare'#9'@iRun'#9#9'integer'
      'exec'#9'dbo.DoCompareServerToClient'
      #9#9'@iRun='#9#9#9'@iRun'#9#9'output'
      #9#9',@sDirFileUpdater='#9':sDirFileUpdater'
      #9#9',@sDirTemp='#9#9':sDirTemp'
      #9#9',@sFilesListClient='#9':sFilesListClient'
      'select'
      #9'Error='#9#9'@@Error'
      #9',Run='#9#9'@iRun'
      
        #9',TotalSize='#9'sum ( isnull ( s.cached_file_size,'#9'datalength ( rl.' +
        'Value ) ) )'
      #9',Counter='#9'count ( * )'
      'from'
      #9'dbo.RunLog'#9'rl'
      #9'left'#9'join'#9'dbo.Stream'#9's'#9'on'
      #9#9's.stream_id='#9'rl.stream_id'
      'where'
      #9'Run='#9#9'@iRun')
    FetchRows = 1
    ReadOnly = True
    Left = 120
    Top = 28
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'sDirFileUpdater'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'sDirTemp'
        Value = nil
      end
      item
        DataType = ftMemo
        Name = 'sFilesListClient'
        ParamType = ptInput
        Value = ''
      end>
  end
  object UQFetch: TUniQuery
    Connection = UC1
    SQL.Strings = (
      
        'if'#9'cursor_status ( '#39'global'#39','#9#39'Comparer_59DB27D0285F4CFC9086A9FE8' +
        '90DED4D'#39' )='#9'-3'
      'begin'
      #9'declare'#9'Comparer_59DB27D0285F4CFC9086A9FE890DED4D'
      #9'cursor'#9'global'#9'forward_only'#9'read_only'#9'keyset'#9'for'
      #9#9'select'
      
        #9#9#9'al.Run'#9#9#9#9'-- '#1074#1099#1076#1072#1105#1084' '#1085#1072#1088#1091#1078#1091', '#1082#1083#1080#1077#1085#1090' '#1087#1086' '#1085#1080#1084' '#1073#1091#1076#1077#1090' '#1080#1079#1084#1077#1085#1103#1090#1100'/'#1076#1086#1073#1072 +
        #1074#1083#1103#1090#1100' '#1079#1072#1087#1080#1089#1080
      
        #9#9#9',al.Sequence'#9#9#9'-- '#1074#1099#1076#1072#1105#1084' '#1085#1072#1088#1091#1078#1091', '#1082#1083#1080#1077#1085#1090' '#1087#1086' '#1085#1080#1084' '#1073#1091#1076#1077#1090' '#1080#1079#1084#1077#1085#1103#1090#1100 +
        ' '#1079#1072#1087#1080#1089#1080
      #9#9#9',al.Subsystem'
      #9#9#9',al.FileName'
      #9#9#9',al.FileDate'
      #9#9#9',al.FileAttribute'
      
        #9#9#9',BLOB='#9'isnull ( s.file_stream,'#9#9'al.Value )'#9'-- '#1076#1083#1103' '#1087#1086#1076#1076#1077#1088#1078#1082#1080' '#1092 +
        #1072#1081#1083#1086#1074' '#1088#1091#1095#1085#1086#1081' '#1075#1077#1085#1077#1088#1072#1094#1080#1080
      #9#9#9',Value='#9'convert ( nvarchar ( max ),'#9'al.Value )'
      #9#9#9',Size='#9'isnull ( s.cached_file_size,'#9'datalength ( al.Value ) )'
      #9#9'from'
      #9#9#9'dbo.RunLog'#9'al'
      #9#9#9'left'#9'join'#9'dbo.Stream'#9's'#9'on'
      #9#9#9#9's.stream_id='#9'al.stream_id'
      #9#9'where'
      #9#9#9#9'al.Run='#9#9':iRun'
      #9#9'order'#9'by'
      #9#9#9'al.Sequence'
      '----------'
      #9'open'#9'global'#9'Comparer_59DB27D0285F4CFC9086A9FE890DED4D'
      'end'
      '----------'
      'fetch'#9'next'#9'from'#9'Comparer_59DB27D0285F4CFC9086A9FE890DED4D'
      '----------'
      'if'#9'@@fetch_status<>'#9'0'
      #9'deallocate'#9'Comparer_59DB27D0285F4CFC9086A9FE890DED4D')
    FetchRows = 1
    ReadOnly = True
    Left = 192
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'iRun'
        Value = nil
      end>
  end
  object UQTouch: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'set'#9'nocount'#9'on'
      'declare'#9'@iError'#9#9'integer'
      #9',@iRowCount'#9'integer'
      '----------'
      'update'
      #9'dbo.RunLog'
      'set'
      #9'Start='#9'isnull ( Start,'#9'getdate() )'
      #9',Finish=case'
      #9#9#9'when'#9'Start'#9'is'#9'null'#9'then'#9'null'
      #9#9#9'else'#9#9#9#9#9'isnull ( Finish,'#9'getdate() )'
      #9#9'end'
      #9',Note='#9#9'isnull ( Note,'#9#39#39' )'
      #9#9'+'#9'case'
      
        #9#9#9#9'when'#9'isnull ( Note,'#9#39#39' )<>'#9#39#39#9'and'#9'isnull ( :sNote,'#9#39#39' )<>'#9#39#39 +
        #9'then'#9#39'; '#39
      #9#9#9'end'
      #9#9'+'#9'isnull ( :sNote,'#9#39#39' )'
      'where'
      #9#9'Run='#9#9':iRun'
      #9'and'#9'Sequence='#9':iSequence'
      'select'#9'@iError='#9'@@Error'
      #9',@iRowCount='#9'@@RowCount'
      '----------'
      'select'#9'Error='#9'case'
      #9#9#9'when'#9'@iError='#9'0'#9'and'#9'@iRowCount='#9'1'#9'then'#9'0'
      #9#9#9'else'#9#9#9#9#9#9#9#9#9'-1'
      #9#9'end')
    FetchRows = 1
    ReadOnly = True
    Left = 256
    Top = 28
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'sNote'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'iRun'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'iSequence'
        Value = nil
      end>
  end
  object UQVersionActual: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'select'
      #9'VersionName'
      #9',BuildName'
      #9',Name='#9#9'VersionName+'#9#39' ('#39'+'#9'BuildName+'#9#39')'#39
      #9',FileNameBuildClient'
      #9',PathClient'
      #9',FileNameExeClient'
      'from'
      
        #9'dbo.GetBuildActual ( nullif ( :sApplication,'#9#39#39' ),'#9'nullif ( :sV' +
        'ersion,'#9#39#39' ) )'#9't')
    FetchRows = 1
    ReadOnly = True
    Left = 316
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'sApplication'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'sVersion'
        Value = nil
      end>
  end
  object UQCheckAdmin: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'declare'#9'@bIsAdmin'#9'bit'
      'set'#9'@bIsAdmin='#9'is_member ( '#39'UpdaterAdmin'#39' )'
      'if'#9'@bIsAdmin'#9'is'#9'null'
      #9'raiserror ( '#39#1054#1096#1080#1073#1082#1072' '#1074#1099#1073#1086#1088#1072' '#1041#1044#39','#9'18,'#9'1 )'
      'select'#9'IsAdmin='#9'@bIsAdmin')
    FetchRows = 1
    ReadOnly = True
    Left = 440
  end
  object UQSaveFile: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'select'
      #9'Value='#9'convert ( varchar ( max ),'#9'file_stream )'
      'from'
      #9'dbo.Stream'
      'where'
      #9#9'parent_path_locator'#9'is'#9'null'
      #9'and'#9'name='#9':sFileName')
    FetchRows = 1
    ReadOnly = True
    Left = 376
    Top = 28
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'sFileName'
        Value = nil
      end>
  end
  object UQDoCompareClientToServer: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'declare'#9'@iRun'#9#9'integer'
      'exec'#9'dbo.DoCompareClientToServer'
      #9#9'@iRun='#9#9#9'@iRun'#9#9'output'
      #9#9',@sDirFileUpdater='#9':sDirFileUpdater'
      #9#9',@sVersion='#9#9':sVersion'
      #9#9',@sBuild='#9#9':sBuild'
      #9#9',@bIsReadOnly='#9#9':bIsReadOnly'
      #9#9',@sFilesListClient='#9':sFilesListClient'
      'select'
      #9'Error='#9#9'@@Error'
      #9',Run='#9#9'@iRun'
      
        #9',TotalSize='#9'sum ( isnull ( s.cached_file_size,'#9'datalength ( rl.' +
        'Value ) ) )'
      #9',Counter='#9'count ( * )'
      'from'
      #9'dbo.RunLog'#9'rl'
      #9'left'#9'join'#9'dbo.Stream'#9's'#9'on'
      #9#9's.stream_id='#9'rl.stream_id'
      'where'
      #9'Run='#9#9'@iRun')
    FetchRows = 1
    ReadOnly = True
    Left = 120
    Top = 96
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'sDirFileUpdater'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'sVersion'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'sBuild'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'bIsReadOnly'
        Value = nil
      end
      item
        DataType = ftMemo
        Name = 'sFilesListClient'
        ParamType = ptInput
        Value = ''
      end>
  end
  object UQSetupVersionBuild: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'declare'#9'@hBuild'#9#9'hierarchyid'
      #9',@sVersion'#9'nvarchar ( 255 )'
      #9',@sBuild'#9'nvarchar ( 255 )'
      'select'#9'@sVersion='#9':sVersion'
      #9',@sBuild='#9':sBuild'
      'exec'#9'dbo.SetupVersionBuild'
      #9#9'@hBuild='#9'@hBuild'#9#9'output'
      #9#9',@sApplication='#9':sApplication'
      #9#9',@sVersion='#9'@sVersion'#9'output'
      #9#9',@sBuild='#9'@sBuild'#9#9'output'
      #9#9',@bIsReadonly='#9':bIsReadonly'
      #9#9',@bIsArchive='#9':bIsArchive'
      #9#9',@bFinalize='#9':bFinalize'
      'select'#9'BuildId='#9'@hBuild'
      #9',Version='#9'@sVersion'
      #9',Build='#9#9'@sBuild')
    FetchRows = 1
    ReadOnly = True
    Left = 256
    Top = 96
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'sVersion'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'sBuild'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'sApplication'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'bIsReadonly'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'bIsArchive'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'bFinalize'
        Value = nil
      end>
  end
  object UQRunLog: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'select'
      #9'Sequence'
      #9',FileName'
      #9',Value='#9'convert ( nvarchar ( 4000 ),'#9'case'
      #9#9#9#9#9#9#9'when'#9'Value'#9'is'#9'null'#9'then'#9'FileName'
      #9#9#9#9#9#9#9'else'#9#9#9#9#9'Value'
      #9#9#9#9#9#9'end )'
      #9',LastWrite='#9'Finish'
      #9',Note'
      'from'
      #9'dbo.RunLog'
      'where'
      #9'Run='#9':iRun'
      'order'#9'by'
      
        #9'Finish'#9'desc'#9'--'#1087#1086' Sequence '#1074#1080#1076#1085#1072' '#1089#1090#1088#1091#1082#1090#1091#1088#1072' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1081', '#1085#1086' '#1079#1072#1093#1086#1090#1077 +
        #1083#1080' '#1090#1072#1082)
    ReadOnly = True
    Left = 192
    Top = 56
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'iRun'
        Value = nil
      end>
    object TSmallintField
      DisplayLabel = #8470
      FieldName = 'Sequence'
      Required = True
      Visible = False
    end
    object TWideStringField
      DisplayLabel = #1055#1091#1090#1100' '#1085#1072' '#1086#1087#1091#1073#1083#1080#1082#1086#1074#1072#1090#1077#1083#1077' ('#1083#1086#1082#1072#1083#1100#1085#1099#1081' '#1082#1086#1084#1087#1100#1102#1090#1077#1088')'
      DisplayWidth = 46
      FieldName = 'FileName'
      Size = 260
    end
    object TWideStringField
      DisplayLabel = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1077
      DisplayWidth = 41
      FieldName = 'Note'
      Size = 4000
    end
    object TWideStringField
      DisplayLabel = #1055#1091#1090#1100' '#1085#1072' '#1089#1077#1088#1074#1077#1088#1077' ('#1076#1083#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081')'
      DisplayWidth = 87
      FieldName = 'Value'
      ReadOnly = True
      Size = 4000
    end
    object UQRunLogLastWrite: TDateTimeField
      DisplayLabel = ' '#1044#1072#1090#1072' '#1080#1079#1084#1077#1085#1077#1085#1080#1103
      DisplayWidth = 12
      FieldName = 'LastWrite'
    end
  end
  object UQSetupStream: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'exec'#9'dbo.SetupStream'
      #9#9'@sName='#9#9':sName'
      #9#9',@dtLastWrite='#9':dtLastWrite'
      #9#9',@sDirectory='#9':sDirectory'
      #9#9',@bIsDirectory='#9':bIsDirectory'
      #9#9',@mValue='#9':mValue'
      'select'#9'Error='#9'@@Error')
    FetchRows = 1
    ReadOnly = True
    Left = 316
    Top = 76
    ParamData = <
      item
        DataType = ftString
        Name = 'sName'
        Value = nil
      end
      item
        DataType = ftDateTime
        Name = 'dtLastWrite'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'sDirectory'
        Value = nil
      end
      item
        DataType = ftBoolean
        Name = 'bIsDirectory'
        Value = nil
      end
      item
        DataType = ftBlob
        Name = 'mValue'
        Value = ''
      end>
  end
  object TPB: TTimer
    Enabled = False
    Interval = 50
    OnTimer = TPBTimer
    Left = 32
    Top = 28
  end
  object UQPathMapping: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'select'
      #9'pm.PathServer'
      #9',pm.PathClient'
      #9',pm.IsRecursive'
      #9',pm.Sequence'
      'from'
      #9'dbo.ShowPathMapping'#9'pm'
      #9'left'#9'join'#9'dbo.Stream'#9's'#9'on'
      #9#9'pm.PathServer'#9'like'#9's.name+'#9#39'\%'#39
      #9'and'#9's.parent_path_locator'#9'is'#9'null'
      #9'and'#9's.is_directory='#9'1'
      'where'
      #9#9'pm.PathServer'#9'like'#9':sApplication+'#9#39'\%'#39
      
        #9'or'#9's.name'#9'is'#9'null'#9#9'-- '#1087#1086#1082#1072#1079#1099#1074#1072#1077#1084' '#1080' '#1076#1083#1103' ('#1091#1078#1077')'#1085#1077#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1080#1093' '#1087#1088#1080#1083 +
        #1086#1078#1077#1085#1080#1081
      'order'#9'by'
      #9'pm.PathServer'
      #9',pm.Sequence'
      #9',pm.PathClient')
    Left = 192
    Top = 140
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'sApplication'
        Value = nil
      end>
    object UQPathMappingPathServer: TWideStringField
      DisplayWidth = 50
      FieldName = 'PathServer'
      Size = 4000
    end
    object UQPathMappingPathClient: TWideStringField
      DisplayWidth = 50
      FieldName = 'PathClient'
      Required = True
      Size = 4000
    end
    object UQPathMappingIsRecursive: TBooleanField
      FieldName = 'IsRecursive'
      Required = True
    end
    object UQPathMappingSequence: TByteField
      DisplayWidth = 3
      FieldName = 'Sequence'
      Required = True
    end
  end
  object UQLastAlive: TUniQuery
    Connection = UC1
    SQL.Strings = (
      'select'
      #9'*'
      'from'
      #9'dbo.ListStationAlive ( :sApplication )'
      'order'#9'by'
      #9'Sequence')
    ReadOnly = True
    Left = 256
    Top = 156
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'sApplication'
        Value = Null
      end>
    object UQLastAliveOwner: TWideStringField
      DisplayLabel = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
      DisplayWidth = 15
      FieldName = 'Owner'
      ReadOnly = True
      Required = True
      Size = 128
    end
    object UQLastAliveStation: TWideStringField
      DisplayLabel = #1050#1086#1084#1087#1100#1102#1090#1077#1088
      DisplayWidth = 20
      FieldName = 'Station'
      ReadOnly = True
      Required = True
      Size = 128
    end
    object UQLastAliveIsUpload: TBooleanField
      DisplayLabel = #1055#1091#1073#1083#1080#1082#1086#1074#1072#1090#1077#1083#1100
      FieldName = 'IsUpload'
      ReadOnly = True
    end
    object UQLastAliveCounter: TIntegerField
      DisplayLabel = #1047#1072#1087#1091#1089#1082#1086#1074
      FieldName = 'Counter'
      ReadOnly = True
    end
    object UQLastAliveMomentAlive: TDateTimeField
      DisplayLabel = #1040#1082#1090#1080#1074#1085#1086#1089#1090#1100
      FieldName = 'MomentAlive'
      ReadOnly = True
      Required = True
    end
    object UQLastAliveSequence: TLargeintField
      FieldName = 'Sequence'
      ReadOnly = True
      Visible = False
    end
  end
end
