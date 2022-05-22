unit uUpdater;

interface

uses
   SvcMgr , // должен стоять до Vcl.Forms, т.к. переопределяет Application
   Vcl.Controls, Winapi.Windows, System.SysUtils, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls , System.Classes, Data.DB, Vcl.ExtCtrls,
   DBAccess,
   comctrlshack;

const
  shell32 = 'shell32.dll';
  SHCNE_ASSOCCHANGED = $08000000;
  {$EXTERNALSYM SHCNE_ASSOCCHANGED}
  SHCNF_IDLIST = $0000;             // LPITEMIDLIST
  {$EXTERNALSYM SHCNF_IDLIST}

type
  TFUpdater = class(TForm)
    Panel1: TPanel;

    PB: TProgressBar;
    BStart: TButton;
    MMessage: TMemo;

    procedure FormCreate   ( Sender : TObject ) ;
    procedure FormActivate ( Sender : TObject ) ;

    procedure BStartClick  ( Sender : TObject ) ;
  private
  public
  end;

  procedure CopyFilesServerToClient ( ProgressBar : TProgressBar ; var HasError : boolean ) ;

procedure SHChangeNotify(wEventId: Integer; uFlags: UINT;
  dwItem1, dwItem2: Pointer); stdcall;
{$EXTERNALSYM SHChangeNotify}



procedure SHChangeNotify;                         external shell32 name 'SHChangeNotify';

procedure InitUpdater ;

var
  FUpdater: TFUpdater;


implementation

uses
   System.StrUtils , System.IOUtils , Vcl.Dialogs ,
   uDM1;

{$R *.dfm}

procedure InitUpdater ;
var b : boolean ;
    At : DWORD ;
    FileNameTemp , FName : string ;
    s : RawByteString ;
begin
   //*** здесь нужно получать номер заблокированной пользователем версии VersionName
   DM1.IsUpToDate := false ;

   with DM1.UQVersionActual do
      try
         ParamByName ( 'sApplication' ).AsString := DM1.ApplicationName ;
         ParamByName ( 'sVersion'     ).AsString := DM1.VersionName     ;
         Open ;

         if IsEmpty then
         begin
            Application.MessageBox ( @( 'Нет доступных версий приложения ' + DM1.ApplicationName + '. Обратитесь к администраторам' )[1] , @DM1.ApplicationName[1] , MB_OK or MB_ICONEXCLAMATION ) ;

            Application.Terminate ;
            Halt ;
         end ;

         DM1.AppDirForClient    := FieldByName ( 'PathClient'        ).AsString ; // получаем настоящие из базы заменяя полученные локально
         DM1.ActualVersion      := FieldByName ( 'Name'              ).AsString ;
         DM1.ApplicationExeName := FieldByName ( 'FileNameExeClient' ).AsString ; // предполагается, что оно не будет отличаться от полученного из ParamStr ( 0 )
         FName := FieldByName ( 'FileNameBuildClient' ).AsString ;
         At := FileGetAttr ( FName , false ) ; // FileExists проверяет атрибуты, но не даёт о них информацию

         DM1.IsUpToDate := ( At <> INVALID_FILE_ATTRIBUTES ) ;

         if DM1.IsUpToDate and ( At or FILE_ATTRIBUTE_VIRTUAL = At ) then
            with TEventLogger.Create ( FName ) do
               try
                  LogMessage ( 'Файлы Updater#u попали в профиль пользователя в директорию \AppData\Local\VirtualStore\. Их нужно убрать оттуда.' , EVENTLOG_WARNING_TYPE ) ;
               finally
                  Free ;
               end ;
      finally
         Close ;
      end ;

   try
      FileNameTemp := GetServerFileTemp ( 'GetModeRun.cmd' ) ;

      s := GetCmdOutput ( FileNameTemp , 'c:\' ) ;
   finally
      DeleteFile ( FileNameTemp ) ;
   end ;

   DM1.ModeRun := string ( s )[1] ;

   if DM1.ModeRun = 'r' then
      StartAndQuit ( DM1.ApplicationExeName , DM1.AppDirForClient ) // даже если есть более новая версия на RDP терминале не обновляем при запуске простым пользователем
   else
      if DM1.ModeRun = 's' then
         CopyFilesServerToClient ( nil , b )
      else
         if DM1.IsUpToDate then
            StartAndQuit ( DM1.ApplicationExeName , DM1.AppDirForClient )
         else
            Application.CreateForm ( TFUpdater , FUpdater ) ;
end ;
////////////////////////////////////////////////////////////////////////////////////////////////////
procedure TFUpdater.FormCreate(Sender: TObject);
begin
   with Panel1 do
   begin
      Font.Color := Color ; // скрываем Caption
      Caption := NormalizeDelimetedFileName ( DM1.FileNameUpdater ) ; // для механизма проверки запуска только одного экземпляра приложения
   end ;
end ;

procedure TFUpdater.FormActivate(Sender: TObject);
var success : boolean ;
begin
   Caption := 'Приложение "' + DM1.ApplicationName + '" обновляется до версии ' + DM1.ActualVersion + '. Пожалуйста, подождите.' ;

   BStart.Enabled := false ;
   BStart.Default := false ;

   Application.ProcessMessages ;

   success := DM1.DoWithProgressBar ( CopyFilesServerToClient , PB ) ;

   SHChangeNotify ( SHCNE_ASSOCCHANGED , SHCNF_IDLIST , nil , nil ) ;

   BStart.Enabled := success ;
   BStart.Default := success ;

   if success then
   begin
      //BStart.SetFocus ;

      Caption := 'Приложение "' + DM1.ApplicationName + '" ОБНОВЛЕНО до версии ' + DM1.ActualVersion ;

      StartAndQuit ( DM1.ApplicationExeName , DM1.AppDirForClient ) ; // вместо нажатия на кнопку BStart
   end
   else
   begin
      Application.Terminate ;
      Halt ;
   end ;
end ;

procedure TFUpdater.BStartClick(Sender: TObject);
begin
   //Close ;
   StartAndQuit ( DM1.ApplicationExeName , DM1.AppDirForClient ) ;
end;
////////////////////////////////////////////////////////////////////////////////////////////////////
procedure CopyFilesServerToClient ( ProgressBar : TProgressBar ; var HasError : boolean ) ;
var Sequence , Run , TotalSize , Counter , Counter1 : integer ;
    SubSystem , FileName , Msg : string ;
    s : RawByteString ;
    ss : ANSIString ;
    C : TComponent ;
    //ii : SHORT ;
begin
   HasError := false ;

   ProgressBarInit ( ProgressBar , 0 , 100{%} ) ;

   try
      FileName := GetServerFileTemp ( 'DirSHAu.cmd' ) ;

      s := GetCmdOutput ( AnsiQuotedStr ( FileName , '"' ) + ' ' + AnsiQuotedStr ( DM1.AppDirForClient , '"' ) , 'c:\' ) ;
   finally
      DeleteFile ( FileName ) ;
   end ;

   with DM1.UQDoCompareServerToClient do
      try
         try
            ParamByName ( 'sDirFileUpdater'  ).AsString := DM1.DirFileUpdater ;
            ParamByName ( 'sDirTemp'         ).AsString := TPath.GetTempPath ;
            ParamByName ( 'sFilesListClient' ).AsString := s ;

            Open ;
            Run       := FieldByName ( 'Run'       ).AsInteger ;
            TotalSize := FieldByName ( 'TotalSize' ).AsLargeInt div 1000 ;
            Counter   := FieldByName ( 'Counter'   ).AsInteger ;
         except
            on E : Exception do
            begin
               HasError := true ;
               Application.MessageBox ( @E.Message[1] , @DM1.ApplicationName[1] , MB_OK or MB_ICONEXCLAMATION ) ;

               Exit ;
            end ;
         end ;
      finally
         Close ;
      end ;

   if TotalSize = 0 then TotalSize := 1 ;
   ProgressBarReInit ( ProgressBar , 0 , TotalSize ) ;

   Sequence := 0 ;

   with DM1.UQFetch do
   begin
      ParamByName ( 'iRun' ).AsInteger := Run ;

      Counter1 := 0 ;
      while true do
         try
            Msg := '' ;

            Open ; // для ускорения правильнее читать из базы и писать на диск в 2 потока
            if RecordCount = 0 then break ;

            {ii := GetAsyncKeyState ( VK_LCONTROL ) ; // только для отладки
            if ii and $8000 = $8000 then
            begin
               MMessage.Visible := true ;
               Height := 200 ;
               MMessage.Lines.Add ( FileName ) ;
               Application.ProcessMessages ;
            end ;}

            Sequence  := FieldByName ( 'Sequence'  ).AsInteger ;
            FileName  := FieldByName ( 'FileName'  ).AsString  ;
            SubSystem := FieldByName ( 'Subsystem' ).AsString  ;

            DM1.Touch ( Run , Sequence , Msg ) ;

            if SubSystem = 'filesystem' then
            begin
               try
                  SaveBLOBFieldToFile ( FieldByName ( 'BLOB' ) , FileName , FieldByName ( 'FileDate' ).AsDateTime , FieldByName ( 'FileAttribute' ).AsInteger ) ; // блокирует пересоздание файла из-за антивируса? после этого поток виснет
               except
                  on E : Exception do Msg := E.Message ;
               end ;
            end
            else
               if SubSystem = 'bat' then
               begin
                  s := GetCmdOutput ( FieldByName ( 'Value' ).AsString , 'c:\' ) ;
                  SetLength ( ss , length ( s ) + 2 ) ;
                  OEMToAnsi ( @s[1] , @ss[1] ) ;
                  Msg := ss ;
                  SetLength ( ss , 0 ) ;
               end
               else
                  ; //***

            ProgressBarStep ( ProgressBar , FieldByName ( 'Size' ).AsLargeInt div 1000 ) ;

            DM1.Touch ( Run , Sequence , Msg ) ;
            inc ( Counter1 ) ;
         finally
            Close ;
         end ;
   end ;

   if Counter1 <> Counter then
      try
         DM1.Touch ( Run , Sequence , 'Не все действия выполнены на клиенте' ) ;
      except
         on E : Exception do
         begin
            Msg := E.Message ;
            C := Application.FindComponent ( 'MMessage' ) ; // костыль
            if C is TMemo then
               with TMemo ( C ) do
               begin
                  Lines.Text := Msg ;
                  Visible := true ;
               end ;
         end ;
      end ;

   ProgressBarFinish ( ProgressBar ) ; // если посчиталось до 99%
end ;

end.
