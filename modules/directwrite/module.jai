#load "windows.jai";

#import "Windows";

// NOTE(mizu): Not worth including headers that include these so I put them here manually from michaelsoft bindows docs website.

DXGI_FORMAT :: s32;

IDWriteFactory_UUID :: "B859EE5A-D838-4B5B-A2E8-1ADC7D93DB48";

COLORREF :: u32;
LPCOLORREF :: *u32;

tagLOGFONTW :: struct{
  lfHeight : s32;
  lfWidth : s32;
  lfEscapement : s32;
  lfOrientation : s32;
  lfWeight : s32;
  lfItalic : u8;
  lfUnderline : u8;
  lfStrikeOut : u8;
  lfCharSet : u8;
  lfOutPrecision : u8;
  lfClipPrecision : u8;
  lfQuality : u8;
  lfPitchAndFamily : u8;
  lfFaceName : [32]s16;
}

LOGFONTW :: tagLOGFONTW;

tagDIBSECTION :: struct 
{
	dsBm : BITMAP;
  dsBmih : BITMAPINFOHEADER;
  dsBitfields : [3]DWORD;
  dshSection : HANDLE;
  dsOffset : DWORD;
};

DIBSECTION :: tagDIBSECTION;

OBJ_BITMAP :: 7;
DC_BRUSH :: 18;
DC_PEN :: 19;

GetDCPenColor :: (hdc : HDC) -> COLORREF #foreign gdi;
SetDCPenColor :: (hdc : HDC, color : COLORREF) -> COLORREF #foreign gdi;
SetDCBrushColor :: (hdc : HDC, color : COLORREF) -> COLORREF #foreign gdi;
Rectangle :: (hdc : HDC, left : int, top : int, right : int, bottom : int) -> BOOL #foreign gdi;;
GetCurrentObject :: (hdc : HDC, type : u32) -> HGDIOBJ #foreign gdi;

#scope_file

dwrite :: #library,system "Dwrite";
gdi :: #library,system "Gdi32";