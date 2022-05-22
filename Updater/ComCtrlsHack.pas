unit ComCtrlsHack ;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls;

type
   TProgressBar = class ( ComCtrls.TProgressBar )
      procedure WMPAINT ( var Msg : TMessage ) ; message WM_PAINT ;
   end ;

implementation

procedure TProgressBar.WMPAINT ( var Msg : TMessage ) ;
var
   DC    : HDC ;
   aRect : TRect ;
   hfnt  : HFONT ;
begin
   inherited ;
   DC := GetDC ( Handle ) ;
   if ( DC = 0 ) or ( Max * Position = 0 ) then Exit ;

   hFnt := CreateFont ( Trunc ( Height / 1.25 ) , 0 , 0 , 0 , FW_SEMIBOLD , 0 , 0 , 0 , DEFAULT_CHARSET , OUT_DEFAULT_PRECIS , CLIP_DEFAULT_PRECIS , NONANTIALIASED_QUALITY , DEFAULT_PITCH , nil ) ;
   try
      Windows.GetClientRect ( Handle , aRect ) ;

      SetBkMode ( DC , TRANSPARENT ) ;

      SetTextColor ( DC , clFuchsia ) ;

      SelectObject ( DC , hFnt ) ;

      DrawText ( DC , PChar ( Format ( '%d %%' , [Trunc ( 100 / Max * Position )] ) ) , -1 , aRect , DT_SINGLELINE or DT_VCENTER or DT_CENTER ) ;
   finally
      DeleteObject ( hFnt ) ;
      ReleaseDC ( Handle , DC ) ;
   end ;
end ;

end.