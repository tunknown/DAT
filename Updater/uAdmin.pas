unit uAdmin;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
   Vcl.DBCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Vcl.ExtCtrls;

ResourceString
   sHelpPublish =   'Для публикации предназначены только помеченные в таблице файлы. '
                  + 'Возможна пометка одного или нескольких файлов. Сразу после запуска updater#a помечены все. '
                  + 'Справа над таблицей можно задать публикацию всех файлов или только отличающихся от предыдущего выпуска. '
                  + 'Если задана новая версия, то включается полный выпуск. '#13#10#13#10
                  + 'Сверху можно задать версию и выпуск приложения, по умолчанию они назначаются автоматически. '
                  + 'Главное требование для более новых версий и выпусков- последовательное лексикографическое возрастание, т.к. этим задаётся их последовательность. '
                  + 'Имя приложения не предназначено для изменения и берётся из первой части имени запускаемого файла updater#a. '#13#10#13#10
                  + 'Внизу слева- кнопка "Обновление" для отображения в таблице файлов, обновлённых уже после запуска updater#a. '
                  + 'Внизу справа- кнопка "Публикация", которая сохраняет файлы с клиента на сервер. '
                  + 'Если при этом установлен флаг "В архив", то после сохранения на сервере не произойдёт переключения пользователей на опубликованный выпуск. '#13#10#13#10
                  + 'Пока у опубликователя запущен updater#a все остальные не могут публиковать выпуски заданного приложения. '
                  + 'Если закрыть updater#a без публикации, то выпуск не будет сохранён и публикация другими разработчиками снова станет возможной.' ;
   sHelpMapping =   'Серверный путь начинается с имени приложения, по которому происходит фильтрация при запуске updater#a. '
                  + 'В пути для сервера можно использовать макросы (*Version*), (*Build*) и %, как последний символ. '
                  + 'Без употребления макросов сопоставление ведётся по конкретной версии и/или выпуску. '
                  + 'Серверные пути должны быть согласованы и едины для получения у конечного пользователя приложения верной установки. '#13#10#13#10
                  + 'Для опубликователя/клиента локальный путь задаётся на компьютере разработчика и должен существовать на момент публикации. '
                  + 'Для каждого опубликователя настройки локальных путей раздельны. '
                  + 'В локальном пути возможно употребление wildcard * и ?, эти настроки используются на клиенте для вызова команды DIR. '#13#10#13#10
                  + 'При заданной рекурсии также берутся файлы вложенных поддиректорий. '
                  + 'Рекурсия задаётся для всех директорий приложения по первой записи сопоставления. '
                  + 'Если в локальном пути не задана точная маска файлов, то возможно дублирование файлов. '
                  + 'Поэтому при нахождении файлов с одним именем и назначением по разным путям сопоставления нужно указать последовательность их приоритета, где 1=самый важный.' ;

type
   TButtonControlHack = class ( TWinControl )
   protected
      ClicksDisabled : Boolean ;
   end ;

  TFAdmin = class(TForm)
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TSAlive: TTabSheet;

    DSRunLog: TDataSource;
    DSPathMapping: TDataSource;
    DSLastAlive: TDataSource;

    BSave: TButton;
    BRefresh: TButton;
    PC: TPageControl;

    DBGRunLog: TDBGrid;
    DBGPathMapping: TDBGrid;
    DBGAlive: TDBGrid;

    TCIsReadOnly: TTabControl;
    EApplication: TEdit;
    EVersion: TEdit;
    EBuild: TEdit;
    CBArchive: TCheckBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    BBHelp: TBitBtn;
    BBMappingHelp: TBitBtn;

    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure BSaveClick(Sender: TObject);
    procedure BRefreshClick(Sender: TObject);
    procedure TCIsReadOnlyChange(Sender: TObject);
    procedure DBGRunLogCellClick(Column: TColumn);
    procedure DBGRunLogKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DSRunLogDataChange(Sender: TObject; Field: TField);
    procedure DSPathMappingStateChange(Sender: TObject);
    procedure BBHelpClick(Sender: TObject);
    procedure BBMappingHelpClick(Sender: TObject);
    procedure PCChange(Sender: TObject);
  private
  public
    DirName : string ;
    DirSHA : RawByteString ;
    Run , TotalSize , Counter : integer ;

    procedure SetupBuild ( Archive , Finalize : boolean ) ;
    procedure Recompare ;
    procedure ReLoadPathMapping ;
  end;

var
  FAdmin: TFAdmin;

implementation

uses System.IOUtils , System.DateUtils ,
     Uni , DBAccess ,
     uDM1;

{$R *.dfm}
////////////////////////////////////////////////////////////////////////////////////////////////////
procedure TFAdmin.FormShow(Sender: TObject);
begin
   Caption := Caption + ' ' + DM1.ServerName ;

   // *** проверяем только на первом уровне или во вложенных тоже нужно?

   DirName := DM1.AppDirForClient + '\' ;
   if not FileExists ( DirName + DM1.ApplicationExeName , false ) then
      raise EInOutError.Create ( 'В директории запуска отсутствует файл ' + DM1.ApplicationExeName + '. Создание выпуска невозможно' ) ;

   with DM1.UQVersionActual do
      try
         ParamByName ( 'sApplication' ).AsString := DM1.ApplicationName ;
         ParamByName ( 'sVersion'     ).Clear ;

         Open ;

         TCIsReadOnly.TabIndex := Integer ( IsEmpty ) ; // OnChange не вызывается, его не отключаем

         EApplication.Text := DM1.ApplicationName ;
         EVersion.Text     := FieldByName ( 'VersionName' ).AsString ;
      finally
         Close ;
      end ;

   SetupBuild ( true , false ) ;

   Recompare ;

   if     ( Counter = 0 )
      and ( Application.MessageBox ( 'Файлы не изменились- публиковать выпуск не требуется. Завершить работу?' , @DM1.FileNameUpdater[1] , MB_YESNO ) = IDYES ) then
      Close  // чтобы сработал обработчик закрытия формы
   else
      with DBGRunLog , TUniQuery ( DataSource.DataSet ) do
         try
            DisableControls ;
            Last ;
            while not BOF do
            begin
               SelectedRows.CurrentRowSelected := true ;
               Prior ;
            end ;
         finally
            EnableControls ;
            DBGRunLogCellClick ( nil ) ; // TDataSource.OnDataChange не подходит
         end ;
end ;

procedure TFAdmin.FormActivate(Sender: TObject);
begin
   PC.TabIndex := 0 ;
end;

procedure TFAdmin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   SetupBuild ( CBArchive.Checked , true ) ; // в процедуре пустой выпуск будет стёрт
end ;
////////////////////////////////////////////////////////////////////////////////////////////////////
procedure TFAdmin.PCChange(Sender: TObject);
begin
   if TSAlive.Showing then
      with TUniQuery ( DBGAlive.DataSource.DataSet ) do
      begin
         Close ;
         ParamByName ( 'sApplication' ).AsString := DM1.ApplicationName ;
         Open ;
      end ;
end ;

procedure TFAdmin.BBHelpClick(Sender: TObject);
begin
   Application.MessageBox ( @( '' + sHelpPublish )[1] , @DM1.FileNameUpdater[1] , MB_OK or MB_ICONINFORMATION ) ; // без локального +'' константу не видит
end;

procedure TFAdmin.BBMappingHelpClick(Sender: TObject);
begin
   Application.MessageBox ( @( '' + sHelpMapping )[1] , @DM1.FileNameUpdater[1] , MB_OK or MB_ICONINFORMATION ) ; // без локального +'' константу не видит
end;

procedure TFAdmin.BRefreshClick(Sender: TObject);
begin
   Recompare ;
end ;

procedure TFAdmin.BSaveClick(Sender: TObject);
var Sequence , Counter1 : integer ;
    FileNameClt , FileNameSrv , Msg : string ;
    IsDirectory : boolean ;
    PName , PValue , PDirectory : TDAParam ;
    FileDateTime : TDateTime ;
begin
   Sequence := 1 ;
   Counter1 := 0 ;
   PName      := DM1.UQSetupStream.ParamByName ( 'sName'      ) ;
   PValue     := DM1.UQSetupStream.ParamByName ( 'mValue'     ) ;
   PDirectory := DM1.UQSetupStream.ParamByName ( 'sDirectory' ) ;

   with DBGRunLog , TUniQuery ( DataSource.DataSet ) do
      try
         DisableControls ;
         First ;

         while not EOF do
         begin
            if SelectedRows.CurrentRowSelected then
            begin
               Sequence    := FieldByName ( 'Sequence' ).AsInteger ;
               FileNameClt := FieldByName ( 'FileName' ).AsString  ;
               FileNameSrv := FieldByName ( 'Value'    ).AsString  ;
               IsDirectory := DirectoryExists ( FileNameClt , false ) ;

               Msg := '' ;
               DM1.Touch ( Run , Sequence , Msg ) ;

               if not FileAge ( FileNameClt , FileDateTime , true ) then
                  Msg := 'Ошибка считывания времени модификации файла. Файл не загружен.'
               else
                  with DM1.UQSetupStream do
                     try
                        ParamByName ( 'bIsDirectory' ).AsBoolean := IsDirectory ;
                        ParamByName ( 'dtLastWrite'  ).AsString  := StringReplace ( StringReplace ( DateToISO8601 ( FileDateTime , false ) , 'T', ' ' , [rfIgnoreCase] ) , '+', ' +' , [] ) ; // приводим к текстовому представлению mssql типа datetimeoffset(7)

                        if FileNameSrv <> '' then
                        begin
                           PDirectory.Clear ;
                           PName.AsString := FileNameSrv ; // там должно быть полное серверное имя
                        end
                        else
                        begin
                           PDirectory.AsString := EApplication.Text + '\' + EVersion.Text + '\' + EBuild.Text ;
                           PName.AsString := FileNameClt ; // там клиентское имя, до серверного его нужно дополнять версией
                        end ;

                        if IsDirectory then
                           PValue.Clear
                        else
                           PValue.LoadFromFile ( FileNameClt , ftBlob ) ;

                        Open ;
                     finally
                        PValue.Clear ; // очищаем большие блобы для экономии памяти
                        Close ;
                     end ;

               DM1.Touch ( Run , Sequence , Msg ) ;
               inc ( Counter1 ) ;
            end ;

            Next ;
         end ;
      finally
         EnableControls ;
         First ;
      end ;

   SetupBuild ( CBArchive.Checked , true ) ;

   if Counter1 = Counter then
   begin
      if Application.MessageBox ( 'Выпуск опубликован на сервере обновлений. Завершить работу?' , @DM1.FileNameUpdater[1] , MB_YESNO ) = IDYES then
      begin
         Application.Terminate ;
         Halt ;
      end ;
   end
   else
   begin
      Msg := 'Не все действия выполнены на клиенте' ;
      DM1.Touch ( Run , Sequence , Msg ) ;
      Application.MessageBox ( @Msg[1] , @DM1.FileNameUpdater[1] , MB_OK or MB_ICONEXCLAMATION ) ;
   end ;
end ;

procedure TFAdmin.DBGRunLogCellClick(Column: TColumn);
begin
   with DBGRunLog do
   begin
      BSave.Caption := 'Публикация ' + IntToStr ( SelectedRows.Count ) + ' из ' + IntToStr ( DataSource.DataSet.RecordCount ) + ' файла(ов)' ;
      BSave.Enabled := ( SelectedRows.Count <> 0 ) ;
   end ;
end;

procedure TFAdmin.DBGRunLogKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   DBGRunLogCellClick ( nil ) ; // TDataSource.OnDataChange не подходит
end;

procedure TFAdmin.DSPathMappingStateChange(Sender: TObject);
begin
   if DBGPathMapping.DataSource.DataSet.State = dsBrowse then // после редактирования обрабатываем снова в надежде на изменение задействованных директорий
      ReLoadPathMapping ;
end;

procedure TFAdmin.DSRunLogDataChange(Sender: TObject; Field: TField);
begin // его одного не достаточно, он слишком рано вызывается
   DBGRunLogCellClick ( nil ) ;
end;

procedure TFAdmin.SetupBuild ( Archive , Finalize : boolean ) ;
begin
   with DM1.UQSetupVersionBuild do
      try
         ParamByName ( 'sApplication' ).AsString  := DM1.ApplicationName ;
         ParamByName ( 'sVersion'     ).AsString  := EVersion.Text ;
         ParamByName ( 'sBuild'       ).AsString  := EBuild.Text ;

         ParamByName ( 'bIsReadonly'  ).AsBoolean := ( TCIsReadOnly.TabIndex = 0 ) ;
         ParamByName ( 'bIsArchive'   ).AsBoolean := Archive ;
         ParamByName ( 'bFinalize'    ).AsBoolean := Finalize ;

         Open ;

         EVersion.Text := FieldByName ( 'Version' ).AsString ;
         EBuild.Text   := FieldByName ( 'Build'   ).AsString ;
      finally
         Close ;
      end ;
end;

procedure TFAdmin.TCIsReadOnlyChange(Sender: TObject);
begin
   Recompare ;
end;

procedure TFAdmin.Recompare ;
var SavOnStateChange : TNotifyEvent ;
begin
   with DBGPathMapping.DataSource do
      try
         SavOnStateChange := OnStateChange ;
         OnStateChange := nil ;
         ReLoadPathMapping ;
      finally
         OnStateChange := SavOnStateChange ;
      end;

   with DM1.UQDoCompareClientToServer do
      try
         ParamByName ( 'sDirFileUpdater'  ).AsString  := DM1.DirFileUpdater ;
         ParamByName ( 'sVersion'         ).AsString  := EVersion.Text ;
         ParamByName ( 'sBuild'           ).AsString  := EBuild.Text ;
         ParamByName ( 'bIsReadOnly'      ).AsBoolean := ( TCIsReadOnly.TabIndex = 0 ) ;
         ParamByName ( 'sFilesListClient' ).AsString  := DirSHA ;

         Open ;
         Run       := FieldByName ( 'Run'       ).AsInteger ;
         TotalSize := FieldByName ( 'TotalSize' ).AsLargeInt div 1000 ;
         Counter   := FieldByName ( 'Counter'   ).AsInteger ;
      finally
         Close ;
      end ;

   with TUniQuery ( DBGRunLog.DataSource.DataSet ) do
   begin
      Close ;
      ParamByName ( 'iRun' ).AsInteger := Run ;
      Open ;
   end ;
end ;

procedure TFAdmin.ReLoadPathMapping ;
var FileNameExe , FileNameCmd , DirName1 : string ;
begin
   with TUniQuery ( DBGPathMapping.DataSource.DataSet ) do
      try
         DisableControls ;

         ParamByName ( 'sApplication' ).AsString := DM1.ApplicationName ;
         Close ;
         Open ;

         if IsEmpty then
            DirName1 := AnsiQuotedStr ( DirName , '"' )
         else
            while not EOF do
            begin
               DirName1 := DirName1 + ' ' + AnsiQuotedStr ( FieldByName ( 'PathClient' ).AsString , '"' ) ; // квотируем каждую директорию
               Next ;
            end ;
      finally
         EnableControls ;
      end ;

   try
      FileNameExe := GetServerFileTemp ( 'sha1sum.exe' ) ;
      FileNameCmd := GetServerFileTemp ( 'DirSHAa.cmd' ) ;
      DirSHA := GetCmdOutput ( AnsiQuotedStr ( FileNameCmd , '"' ) + ' ' + AnsiQuotedStr ( FileNameExe , '"' ) + ' ' + DirName1 , 'c:\' ) ; // квотируем все поданные директории вместе
   finally
      DeleteFile ( FileNameCmd ) ;
      DeleteFile ( FileNameExe ) ;
   end ;
end ;

initialization
   RegisterClasses ( [TSmallintField , TWideStringField , TLabel , TPageControl , TPanel , TDBNavigator] ) ;

end.
