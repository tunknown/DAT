unit uDM1;

interface

uses
   SvcMgr , // ������ ������ �� Vcl.Forms, �.�. �������������� Application
   Vcl.Forms, System.Classes, Winapi.Windows, System.SysUtils, Data.DB, Vcl.ComCtrls, Vcl.ExtCtrls,
   MemDS, DBAccess, Uni, UniProvider, SQLServerUniProvider,
   comctrlshack ;

ResourceString
   sCMDGetModeRun =   '@echo off'#13#10
                    + 'if not defined sessionname echo s'#13#10
                    + 'if "%sessionname%"=="Console" ('#13#10
                    + '   echo c'#13#10
                    + ') else ('#13#10
                    + '   set a=%sessionname:#=%'#13#10
                    + '   if not "%a%"=="%sessionname%" echo r'#13#10
                    + ')' ;

type
   TFileStreamHack = class ( THandleStream )
   end ;

  TProc1 = procedure ( ProgressBar : TProgressBar ; var HasError : boolean ) ;

  TProcedureFinished = ( ppProcessing , ppError , ppSuccess ) ;

  TThreadMy = class(TThread)
  private
    FProc: TProc1;
  protected
    procedure Execute; override;
  public
    HasError : boolean ;

    constructor Create(const AProc: TProc1);
  end ;

  TDM1 = class(TDataModule)
    UP1: TSQLServerUniProvider;
    UC1: TUniConnection;
    UQDoCompareServerToClient: TUniQuery;
    UQFetch: TUniQuery;
    UQTouch: TUniQuery;
    UQVersionActual: TUniQuery;
    UQCheckAdmin: TUniQuery;
    UQSaveFile: TUniQuery;
    UQDoCompareClientToServer: TUniQuery;
    UQSetupVersionBuild: TUniQuery;
    UQRunLog: TUniQuery;
    UQSetupStream: TUniQuery;
    TPB: TTimer;
    UQPathMapping: TUniQuery;
    UQPathMappingPathServer: TWideStringField;
    UQPathMappingPathClient: TWideStringField;
    UQPathMappingIsRecursive: TBooleanField;
    UQPathMappingSequence: TByteField;
    UQLastAlive: TUniQuery;
    UQLastAliveMomentAlive: TDateTimeField;
    UQLastAliveOwner: TWideStringField;
    UQLastAliveStation: TWideStringField;
    UQLastAliveIsUpload: TBooleanField;
    UQLastAliveCounter: TIntegerField;
    UQLastAliveSequence: TLargeintField;
    UQRunLogLastWrite: TDateTimeField;

    procedure DataModuleCreate(Sender: TObject);
    procedure TPBTimer(Sender: TObject);
  private
    ProgressBar : TProgressBar ;
  public
    ApplicationName
    ,ApplicationExeName
    ,ActualVersion
    ,AppDirForClient
    ,DirFileUpdater
    ,FileNameUpdater
    ,VersionName
    ,ServerName
    ,SQLLogin : string ;

    ModeParam         // u=User/Updater, a=Admin/Anti-updater
    ,ModeRun : char ; // s=task scheduler, r=Terminal RDP, c=console

    IsUpToDate : boolean ;

    procedure Touch ( Run , Sequence : integer ; Msg : string ) ;
    function DoWithProgressBar ( Proc : TProc1 ; PB : TProgressBar ) : boolean ;
  end;

  procedure SaveBLOBFieldToFile ( F : TField ; FileName : string ; dt : TDateTime ; Attributes : Longint ) ;
  function GetServerFileTemp ( FileNameServer : string ) : string ;
  procedure GetServerFile ( FileNameServer , FileNameClient : string ) ;
  function GetCmdOutput ( CommandLine , WorkDir : string ) : RawByteString ;
  function StartAndQuit ( CommandLine : string ; WorkDir : string ) : RawByteString ;

  procedure SetProcessedSuccess ;
  procedure SetProcessedError ;

  function ProgressBarGetChunk ( ProgressBar : TProgressBar ) : integer ;
  procedure ProgressBarInit    ( ProgressBar : TProgressBar ; Min , Max : Integer ) ;
  procedure ProgressBarReInit  ( ProgressBar : TProgressBar ; Min1 , Max1 : Integer ) ;
  procedure ProgressBarStep    ( ProgressBar : TProgressBar ; Increment : integer ) ;
  procedure ProgressBarFinish  ( ProgressBar : TProgressBar ) ;

  function GetLockFile : THandle ;
  function ShowPreviousInstance : boolean ;
  function NormalizeDelimetedFileName ( FileName : string ) : string ;

  function GetParametersFromCommandLine ( ParamStr : string ; var DirFileUpdater , FileNameUpdater , AppDirForClient , ApplicationExeName , ApplicationName , ServerName , SQLLogin : string ; var RunMode : char ) : boolean ;

var
   DM1: TDM1;
   Processed : TProcedureFinished ;
   PBPrev : integer ;

implementation

uses
   System.StrUtils , System.IOUtils , Vcl.Dialogs, Vcl.Controls , System.Types ,
   uUpdater ;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
procedure TDM1.DataModuleCreate(Sender: TObject);
var FileNameTemp , FileNameTemp2 , Msg : string ;
    s : RawByteString ;
begin
   if not GetParametersFromCommandLine ( ParamStr ( 0 ) , DirFileUpdater , FileNameUpdater , AppDirForClient , ApplicationExeName , ApplicationName , ServerName , SQLLogin , ModeParam ) then
      {Error};

   Application.Title := ApplicationName ;

   with UC1 do
      try
         Server := ServerName ;
         if SQLLogin <> '' then
         begin
            Username := SQLLogin ;
            Password := SQLLogin + '1' ; // ������������ �� �����
         end ;
         //else
            //SpecificOptions.Add ( 'Authentication=auWindows' ) ;
         Connected := true ;
      except
         on E : Exception do
         begin
            Msg := E.Message ;

            with TEventLogger.Create ( FileNameUpdater ) do
               try
                  LogMessage ( '������ ���������� Updater# ����������. �������� � ����� ���������� ������� ����������.'#13#10'������:'#13#10 + Msg , EVENTLOG_WARNING_TYPE ) ;
               finally
                  Free ;
               end ;

            with TStringList.Create do
               try
                  FileNameTemp2 := TPath.GetTempFileName ;
                  FileNameTemp := FileNameTemp2 + '.cmd' ;
                  RenameFile ( FileNameTemp2 , FileNameTemp ) ;

                  Text := sCMDGetModeRun ; // ���������� �������������� �������, �.�. sql ������ ����������
                  SaveToFile ( FileNameTemp ) ;

                  s := GetCmdOutput ( FileNameTemp , 'c:\' ) ;

                  ModeRun := string ( s )[1] ;
               finally
                  Free ;
                  DeleteFile ( FileNameTemp ) ;
               end ;

            if ModeRun = 's' then
            begin
               Application.Terminate ;     // ���������� ������ ������
               Halt ;
            end
            else
               if ModeParam = 'a' then     // ��������������� ���������� ������
               begin
                  Application.MessageBox ( @( '������ ���������� Updater# ����������'#13#10 + Msg )[1] , @DM1.FileNameUpdater[1] , MB_OK or MB_ICONEXCLAMATION ) ;
                  Application.Terminate ;
                  Halt ;
               end
               else                        // ������������� ������� �� ����������
                  StartAndQuit ( ApplicationExeName , AppDirForClient ) ;
         end ;
      end ;

   with UQCheckAdmin do
      try
         Open ;
         if ( ModeParam = 'a' ) and not FieldByName ( 'IsAdmin' ).AsBoolean then raise EInOutError.Create ( '�������� ������ ����������������� � ����� ������������ ����� �������� ������ ��� ���������������' ) ;
      finally
         Close ;
      end ;
end ;

function GetParametersFromCommandLine ( ParamStr : string ; var DirFileUpdater , FileNameUpdater , AppDirForClient , ApplicationExeName , ApplicationName , ServerName , SQLLogin : string ; var RunMode : char ) : boolean ;
var p1 , p2 : integer ;
    FileNameUpdater1 , s : string ;
begin
   DirFileUpdater := ParamStr ;

   try
      FileNameUpdater := ExtractFileName ( DirFileUpdater ) ;
      AppDirForClient := ExtractFileDir ( DirFileUpdater ) ;

      FileNameUpdater1 := FileNameUpdater ;

      p2 := LastDelimiter ( '.' , FileNameUpdater1 ) ;
      if p2 <> 0 then FileNameUpdater1 := LeftStr ( FileNameUpdater1 , p2 - 1 ) ;

      FileNameUpdater1 := StringReplace ( StringReplace ( StringReplace ( FileNameUpdater1 , '�' , '.' , [rfReplaceAll] ) , '�' , '#' , [rfReplaceAll] ) , '�' , '$' , [rfReplaceAll] ) ; // ��� ��������� ������� � delphi � ����������� ����� ��� �������
      FileNameUpdater1 := StringReplace ( FileNameUpdater1 , '$' , '\' , [rfReplaceAll] ) ;

      p1 := PosEx ( '#' , FileNameUpdater1 , 1 ) - 1 ;
      if p1 = 0 then raise EInOutError.Create ( '������ ��������� ���������� �� ����� ������������ �����' ) ;
      ApplicationExeName := LeftStr ( FileNameUpdater1 , p1 ) ;

      p2 := LastDelimiter ( '.' , ApplicationExeName ) ;
      if p2 = 0 then ApplicationName := ApplicationExeName else ApplicationName := LeftStr ( ApplicationExeName , p2 - 1 ) ;

      p2 := PosEx ( '#' , FileNameUpdater1 , p1 + 2 ) ;
      if p2 = 0 then raise EInOutError.Create ( '������ ��������� ������� ���������� �� ����� ������������ �����' ) ;
      ServerName := MidStr ( FileNameUpdater1 , p1 + 2 , p2 - p1 - 2 ) ;

      p1 := p2 ;
      p2 := PosEx ( '#' , FileNameUpdater1 , p2 + 2 ) ;
      if p2 = 0 then
         RunMode := 'u'
      else
      begin
         s := MidStr ( FileNameUpdater1 , p1 + 1 , p2 - p1 - 1 ) ;
         RunMode := LowerCase ( s )[1] ;

         SQLLogin := MidStr ( FileNameUpdater1 , p2 + 1 , 33000 ) ;
      end ;
      Result := true ;
   except
      Result := false ;
   end ;
end ;

procedure SaveBLOBFieldToFile ( F : TField ; FileName : string ; dt : TDateTime ; Attributes : Longint ) ;
var Stream : TFileStream ;
    BlobStream : TStream ;
    FH : THandle ;
    Attr : DWORD ;
    FileNameTemp : string ;
begin // ������ TBLOBField ( F ).SaveToFile ( FileName ) ;

   Attr := GetFileAttributes ( @FileName[1] ) ;

   // �������� �������� ���� �� GetLockFile, ��� ���� ���� ����� ������� ������ � ������������ ����������
   // ���� � ������������� ����� ������ hidden ��� system � �� �� �������, �� ����� Access denied
   FH := CreateFile ( @FileName[1] , GENERIC_WRITE , FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE , nil , OPEN_ALWAYS , Attributes , 0 ) ;

   FileNameTemp := TPath.GetTempFileName ;                             // ������������, ��� ��������� ���� �������� � ����������� ����������

   Stream := TFileStream.Create ( FileNameTemp , fmCreate ) ;          // ������������, ��� ����� ������ FHandle ��� ����� �����
   try
      CloseHandle ( TFileStreamHack ( Stream ).FHandle ) ;             // ������������� ��������� ���� �� ����������

      TFileStreamHack ( Stream ).FHandle := FH ;                       // ��������� �� ���, �.�. ������������� ��������� ���� �������� � ������������ ��������� ����������

      BlobStream := F.DataSet.CreateBlobStream ( F , bmRead ) ;
      try
         Stream.CopyFrom ( BlobStream , 0 ) ;
      finally
         BlobStream.Free ;
      end ;
   finally
      DeleteFile ( FileNameTemp ) ;
      Stream.Free ;                                                    // ��� ������� CloseHandle ( FH ) ;
   end ;

   if dt   <> 0          then FileSetDate ( FileName , DateTimeToFileDate ( dt ) ) ;
   if Attr <> Attributes then SetFileAttributes ( @FileName[1] , Attributes ) ;
end ;
////////////////////////////////////////////////////////////////////////////////////////////////////
function GetCmdOutput ( CommandLine , WorkDir : string ) : RawByteString ;
var
   SA : TSecurityAttributes ;
   SI : TStartupInfo ;
   PI : TProcessInformation ;
   StdOutPipeRead , StdOutPipeWrite : THandle ;
   bRead , bSuccess : Boolean ;
   Buffer : array[0..255] of AnsiChar ;
   BytesRead : Cardinal ;
begin
   Result := '' ;

   SA.nLength := SizeOf ( SA ) ;
   SA.bInheritHandle := True ;
   SA.lpSecurityDescriptor := nil ;

   CreatePipe ( StdOutPipeRead , StdOutPipeWrite , @SA , 0 ) ;
   try
      with SI do
      begin
         FillChar ( SI , SizeOf ( SI ) , 0 ) ;
         cb := SizeOf ( SI ) ;
         dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES ;
         wShowWindow := SW_HIDE ;

         hStdInput  := GetStdHandle ( STD_INPUT_HANDLE ) ; // �� ���������������� stdinput
         hStdOutput := StdOutPipeWrite ;
         hStdError  := StdOutPipeWrite ;
      end ;

      if ( CommandLine[1] = '"' ) and ( CommandLine[length ( CommandLine )] = '"' ) then CommandLine := '"' + CommandLine + '"' ; // https://ss64.com/nt/cmd.html   AnsiQuotedStr �� �������, �.�. ��������� � ���������� �������

      bSuccess := CreateProcess ( nil , PChar ( 'cmd.exe /C ' + CommandLine ) , nil , nil , True , 0 , nil , @WorkDir[1] , SI , PI ) ;
      CloseHandle ( StdOutPipeWrite ) ;
      if bSuccess then
         try
            repeat
               bRead := ReadFile ( StdOutPipeRead , Buffer , 255 , BytesRead , nil ) ;
               if BytesRead > 0 then
               begin
                  Buffer[BytesRead] := #0 ;
                  Result := Result + Buffer ;
               end ;
            until not bRead or ( BytesRead = 0 ) ;
            WaitForSingleObject ( PI.hProcess , INFINITE ) ;
         finally
            CloseHandle ( PI.hThread ) ;
            CloseHandle ( PI.hProcess ) ;
         end ;
   finally
     CloseHandle ( StdOutPipeRead ) ;
   end ;
end ;

function StartAndQuit ( CommandLine : string ; WorkDir : string ) : RawByteString ;
var
   SI : TStartupInfo ;
   PI : TProcessInformation ;
   bSuccess : Boolean ;
begin
   Result := '' ;

   FillChar ( SI , SizeOf ( SI ) , 0 ) ;

   SI.cb := SizeOf ( SI ) ;
   SI.dwFlags := STARTF_FORCEOFFFEEDBACK ;
   SI.wShowWindow := SW_SHOWDEFAULT ;

   FillChar ( PI , SizeOf ( PI ) , 0 ) ;

   try
      bSuccess := CreateProcess ( nil , @CommandLine[1] , nil , nil , True , 0 , nil , @WorkDir[1] , SI , PI ) ; // @...[1] ����� ������� ����� �������� ���������� string writeable ��� CreateProcessW
   finally
      if PI.hThread  <> 0 then CloseHandle ( PI.hThread  ) ;
      if PI.hProcess <> 0 then CloseHandle ( PI.hProcess ) ;
   end;

   if not bSuccess then //raise EInOutError.Create ( '������ ������� ����������' ) ;
      Application.MessageBox ( '������ ������� ����������- ����������� ���� �������� ��� �����������' , @DM1.ApplicationName[1] , MB_OK or MB_ICONEXCLAMATION ) ;

   Application.Terminate ;
   Halt ;
end ;

function GetServerFileTemp ( FileNameServer : string ) : string ;
var s : string ;
begin
   s := '' ;
   try
      s := TPath.GetTempFileName ; // ��� ��������� ���������� �����- ���� ��������. ������� GetTempFileName ������������ �� ����� 65536 ����� ������ �� ��������� ����������
      Result := s + '.' + ExtractFileName ( FileNameServer ) ;
   finally
      if s <> '' then RenameFile ( s , Result ) ;
   end ;

   GetServerFile ( FileNameServer , Result ) ;
end ;

procedure GetServerFile ( FileNameServer , FileNameClient : string ) ;
var Message : string ;
begin
   with DM1.UQSaveFile do
      try
         ParamByName ( 'sFileName' ).AsString := FileNameServer ;
         Open ;
         if RecordCount = 1 then
            SaveBLOBFieldToFile ( FieldByName ( 'Value' ) , FileNameClient , 0 , 0 )
         else
         begin
            Message := '���� ' + FileNameServer + ' �� ������. ���������� � ��������������.' ;
            Application.MessageBox ( @Message[1] , @DM1.ApplicationName[1] , MB_OK ) ;

            Application.Terminate ;
            Halt ;
         end ;
      finally
         Close ;
      end ;
end ;

procedure TDM1.Touch ( Run , Sequence : integer ; Msg : string ) ;
begin
   with UQTouch do
      try
         ParamByName ( 'iRun'      ).AsInteger := Run ;
         ParamByName ( 'iSequence' ).AsInteger := Sequence ;
         ParamByName ( 'sNote'     ).AsString  := Msg ;
         Open ;
      finally
         Close ;
      end ;
end ;
////////////////////////////////////////////////////////////////////////////////////////////////////
constructor TThreadMy.Create ( const AProc : TProc1 ) ;
begin
   inherited Create ( True ) ;
   FreeOnTerminate := false ;
   FProc := AProc ;
end ;

procedure TThreadMy.Execute ;
var IsError : boolean ;
begin
   FProc ( DM1.ProgressBar , IsError ) ;

   HasError := IsError ;

   if IsError then
      Synchronize ( SetProcessedError )
   else
      Synchronize ( SetProcessedSuccess ) ;

   Terminate ;
end ;
////////////////////////////////////////////////////////////////////////////////////////////////////
procedure SetProcessedSuccess ;
begin
   Processed := ppSuccess ;
end ;

procedure SetProcessedError ;
begin
   Processed := ppError ;
end ;
////////////////////////////////////////////////////////////////////////////////////////////////////
function ProgressBarGetChunk ( ProgressBar : TProgressBar ) : integer ;
begin
   with ProgressBar do
      if Orientation = pbHorizontal then
         Result := ( Max - Min ) div ClientWidth // ���������� ������� ������� � ���� �������
      else
         Result := ( Max - Min ) div ClientHeight ;
end ;

procedure TDM1.TPBTimer(Sender: TObject);
begin
   // ������� ������� � ���� ������� �� �������� �������. ��� �������� �������� ���������� �������� �������� ��������

   ProgressBarStep ( ProgressBar , ProgressBarGetChunk ( ProgressBar ) ) ; // ��������� ������� ������� � ���� �������

   if TPB.Interval = 1 then TPB.Interval := 100 ;
end;

function TDM1.DoWithProgressBar ( Proc : TProc1 ; PB : TProgressBar ) : boolean ;
var TMy : TThreadMy ;
begin
   ProgressBar := PB ;

   TPB.Interval := 1 ; // ������ ������ ��� ����� �������
   TPB.Enabled  := true ;

   TMy := TThreadMy.Create ( Proc ) ;
   try
      while TPB.Interval = 1 do
         Application.ProcessMessages ;

      Processed := ppProcessing ;

      TMy.Start ;

      while Processed = ppProcessing do
         Application.ProcessMessages ;

      Result := not TMy.HasError ;
   finally
      TMy.Free ;

      TPB.Enabled := false ;
   end ;
end ;

procedure ProgressBarInit ( ProgressBar : TProgressBar ; Min , Max : Integer ) ;
begin
   if not assigned ( ProgressBar ) then Exit ;

   ProgressBar.Min := Min ;
   ProgressBar.Max := Max ;
end ;

procedure ProgressBarReInit ( ProgressBar : TProgressBar ; Min1 , Max1 : Integer ) ;
var Percent : extended ;
begin
   if not assigned ( ProgressBar ) then Exit ;

   with ProgressBar do
   begin
      Percent := Position / ( Max - Min ) ;
      Min := Min1 ;
      Max := Max1 ;
      Position := Integer ( Trunc ( ( Max1 - Min1 ) * Percent ) ) ;
   end ;
end ;

procedure ProgressBarStep ( ProgressBar : TProgressBar ; Increment : integer ) ;
var Chunk : integer ;
begin
   if not assigned ( ProgressBar ) then Exit ;

   Chunk := ProgressBarGetChunk ( ProgressBar ) ;

   if PBPrev + Increment < ProgressBar.Max - Chunk then
      ProgressBar.Position := PBPrev + Increment ; // �������� �� ������ ������������ �����, ���� �������� ����������� ���� ���������������

   PBPrev := ProgressBar.Position ;
end ;

procedure ProgressBarFinish ( ProgressBar : TProgressBar ) ;
begin
   if not assigned ( ProgressBar ) then Exit ;

   with ProgressBar do
      Position := Max ;
end ;

function GetCurrentUser : String ;
var
   B : pointer ;
   S : Cardinal ;
begin
  S := 255 ;
  GetMem ( B , S ) ;
  GetUserName ( B , S ) ;
  Result := PChar ( B ) ;
  FreeMem ( B ) ;
end;

function GetComputerName : string ;
var
   Buf : array[0..MAX_COMPUTERNAME_LENGTH] of char ;
   Len : cardinal ;
begin
   Len := MAX_COMPUTERNAME_LENGTH + 1 ;
   if Winapi.Windows.GetComputerName ( @Buf , Len ) then SetString ( Result , Buf , Len ) else Result := '' ;
end;

function TempPath : string ;
var S : string ;
begin
   SetLength ( S , MAX_PATH ) ;
   GetTempPath ( MAX_PATH , @S[1] ) ;
   SetLength ( S , StrLen ( PChar ( S ) ) ) ;
   Result := IncludeTrailingPathDelimiter ( S ) ;
end ;

function GetLockFileName : string ;
begin
   Result := TempPath         // � ���������� ��������� ������, ���� ������ �� ������ ������ ����. ������ �� ���������, ���� ��������� ���������� ������� ����� ���������
           + GetComputerName  // ���� ����� ������� ������ ��� ���������� �����������
           + '$'{'\'}         // �����������
           + GetCurrentUser   // ������� Windows ������������, ��������, ��� RDP ���������
           + '#'              // �����������
           + ExtractFileName ( ParamStr ( 0 ) ) // ����� ��������� �������, ���� Computer �/��� User �������� $/#, � ���� ���������� ����� �� ����� ������� �������
           + '.lock' ;        // ��� ��������������� ����� ���� ����� �������, ��� ��� �� ����
end ;

function GetLockFile : THandle ;
var a : TStringDynArray ;
    i : integer ;
    s , ss : string ;
begin
   s := GetLockFileName ;
   try
      SetLength ( a , Length ( s ) - Length ( StringReplace ( s , '\' , '' , [rfReplaceAll] ) ) + 1 ) ;
      a := SplitString ( s , '\' ) ;        // CreateFile ������ ���� ������ � ��� ������������ ����������
      ss := a[0] ;

      for i := 1 to Length ( a ) - 2 do     // ��������� ��� �����, ��������� ����� �����
      begin
         ss := ss + '\' + a[i] ;
         CreateDirectory ( @ss[1] , nil ) ; // ��������� ���������� ����� ���� ������ � %TMP%, �� �� ������������. ������ �� ���������, ��� ������������ �������������, ������������� �������
      end ;
   finally
      a := nil ;
   end ;

   Result := CreateFile ( @s[1] , GENERIC_WRITE , 0{FILE_SHARE_READ or FILE_SHARE_DELETE} , nil , OPEN_ALWAYS , FILE_ATTRIBUTE_TEMPORARY{�� ����������� �� ����} or FILE_FLAG_DELETE_ON_CLOSE{��� ��������� ��� �������� ����������} or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM , 0 ) ; // FILE_ATTRIBUTE_READONLY �� ��������� � ����� ����������
end ;

function EnumWindowsProc ( h : HWND ; lParam : LPARAM ) : boolean ; stdcall ;
var
   Handle : HWnd ;
   s : string ;
begin
   Result := true ;                                // ���������� ������

   if h <> 0 then
   begin
      SetLength ( s , 301 ) ;                      // ��. TFormStyleHook.TMainMenuBarStyleHook.GetIcon
      GetClassName ( h , @s[1] , Length ( s ) ) ;
      SetLength ( s , StrLen ( PChar ( S ) ) ) ;
      if s = TFUpdater.ClassName then              // ClassName ���� ���������� ����� � ������ �������������� ������� ����� ����������
      begin
         s := NormalizeDelimetedFileName ( ExtractFileName ( ParamStr ( 0 ) ) ) ;
         Handle := FindWindowEx ( h , 0 , 'TPanel' , @s[1] ) ; // ��������������, ��� TPanel ����, ����� � Caption ��������� ��������
         Result := ( Handle <> 0 ) ;
         if Result then PNativeUInt ( lParam )^ := h ;
      end ;
   end ;
end ;

function ShowPreviousInstance : boolean ;
var PreviousInstance : HWND ;
    //b : BOOL ;
begin
   Result := false ;
   {b := }EnumWindows ( @EnumWindowsProc , LPARAM ( @PreviousInstance ) ) ; // �� ���������� ������������ ��������?
   //if not b then ShowMessage ( IntToStr ( GetLastError ) ) ;

   if PreviousInstance <> 0 then
      if IsIconic ( PreviousInstance ) then
         Result := ShowWindow ( PreviousInstance , SW_RESTORE )
      else
         Result := SetForegroundWindow ( PreviousInstance ) ;

   if not Result then ShowMessage ( '���������� ��� ��������. ���� ��� ����������, ���������� � ���������������.' ) ; // Application.MessageBox �� ������ ������������� ���������� �� ��������
end ;

function NormalizeDelimetedFileName ( FileName : string ) : string ;
begin
   Result := StringReplace ( StringReplace ( StringReplace ( FileName , '.' , '�' , [rfReplaceAll] ) , '#' , '�' , [rfReplaceAll] ) , '$' , '�' , [rfReplaceAll] ) ; // ��� ��������� �������� ������� ������ ������ ���������� ����������
end ;

end.
