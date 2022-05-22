program Updater;

uses
  Vcl.Forms,
  Winapi.Windows,
  uUpdater in 'uUpdater.pas' {FUpdater},
  ComCtrlsHack in 'ComCtrlsHack.pas',
  uDM1 in 'uDM1.pas' {DM1: TDataModule},
  uAdmin in 'uAdmin.pas' {FAdmin};

var HLockFile : THandle ;

begin
   HLockFile := GetLockFile ;

   try
      Application.Initialize ;

      if HLockFile = INVALID_HANDLE_VALUE then
      begin
         ShowPreviousInstance ;

         Application.Terminate ;
         Application.ProcessMessages ;
         Exit ;
      end ;

      Application.MainFormOnTaskbar := True ;
      Application.CreateForm ( TDM1 , DM1 ) ;
      if DM1.ModeParam = 'a' then
         Application.CreateForm ( TFAdmin , FAdmin )
      else
         InitUpdater ;
      Application.Run ;
   finally
      if HLockFile <> 0 then CloseHandle ( HLockFile ) ;
   end ;
end.
