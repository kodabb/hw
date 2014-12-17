(*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2004-2014 Andrey Korotaev <unC0Rr@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *)

{$INCLUDE "options.inc"}

unit uMisc;
interface

uses SDLh, uConsts, GLunit, uTypes;

procedure initModule;
procedure freeModule;

procedure movecursor(dx, dy: LongInt);
function  doSurfaceConversion(tmpsurf: PSDL_Surface): PSDL_Surface;
function MakeScreenshot(filename: shortstring; k: LongInt; dump: LongWord): boolean;
function  GetTeamStatString(p: PTeam): shortstring;
{$IFDEF SDL2}
function  SDL_RectMake(x, y, width, height: LongInt): TSDL_Rect; inline;
{$ELSE}
function  SDL_RectMake(x, y: SmallInt; width, height: Word): TSDL_Rect; inline;
{$ENDIF}

implementation
uses SysUtils, uVariables, uUtils
     {$IFDEF PNG_SCREENSHOTS}, PNGh, png {$ENDIF};

type PScreenshot = ^TScreenshot;
     TScreenshot = record
         buffer: PByte;
         filename: shortstring;
         width, height: LongInt;
         size: QWord;
         alpha: boolean;
         end;

var conversionFormat : PSDL_PixelFormat;

procedure movecursor(dx, dy: LongInt);
var x, y: LongInt;
begin
if (dx = 0) and (dy = 0) then exit;

SDL_GetMouseState(@x, @y);
Inc(x, dx);
Inc(y, dy);
SDL_WarpMouse(x, y);
end;

{$IFDEF PNG_SCREENSHOTS}
// this funtion will be executed in separate thread
function SaveScreenshot(screenshot: pointer): LongInt; cdecl; export;
var i: LongInt;
    png_ptr: ^png_struct;
    info_ptr: ^png_info;
    f: File;
    image: PScreenshot;
    bpp: Integer; // bytes per pixel
    ctype: Integer; // png color type
begin
image:= PScreenshot(screenshot);
if image^.alpha then
    begin
    bpp:= 4;
    ctype:= PNG_COLOR_TYPE_RGBA;
    end
else
    begin
    bpp:= 3;
    ctype:= PNG_COLOR_TYPE_RGB;
    end;

png_ptr := png_create_write_struct(png_get_libpng_ver(nil), nil, nil, nil);
if png_ptr = nil then
begin
    // AddFileLog('Error: Could not create png write struct.');
    SaveScreenshot:= 0;
    exit;
end;

info_ptr := png_create_info_struct(png_ptr);
if info_ptr = nil then
begin
    png_destroy_write_struct(@png_ptr, nil);
    // AddFileLog('Error: Could not create png info struct.');
    SaveScreenshot:= 0;
    exit;
end;

{$IOCHECKS OFF}
Assign(f, image^.filename);
Rewrite(f, 1);
if IOResult = 0 then
    begin
    png_init_pascal_io(png_ptr,@f);
    png_set_IHDR(png_ptr, info_ptr, image^.width, image^.height,
                 8, // bit depth
                 ctype, PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
    png_write_info(png_ptr, info_ptr);
    // glReadPixels and libpng number rows in different order
    for i:= image^.height-1 downto 0 do
        png_write_row(png_ptr, image^.buffer + i*bpp*image^.width);
    png_write_end(png_ptr, info_ptr);
    Close(f);
    end;
{$IOCHECKS ON}

// free everything
png_destroy_write_struct(@png_ptr, @info_ptr);
FreeMem(image^.buffer, image^.size);
Dispose(image);
SaveScreenshot:= 0;
end;

{$ELSE} // no PNG_SCREENSHOTS

// this funtion will be executed in separate thread
function SaveScreenshot(screenshot: pointer): LongInt; cdecl; export;
var f: file;
    // Windows Bitmap Header
    head: array[0..53] of Byte = (
    $42, $4D,       // identifier ("BM")
    0, 0, 0, 0,     // file size
    0, 0, 0, 0,     // reserved
    54, 0, 0, 0,    // starting offset
    40, 0, 0, 0,    // header size
    0, 0, 0, 0,     // width
    0, 0, 0, 0,     // height
    1, 0,           // color planes
    24, 0,          // bit depth
    0, 0, 0, 0,     // compression method (uncompressed)
    0, 0, 0, 0,     // image size
    96, 0, 0, 0,    // horizontal resolution
    96, 0, 0, 0,    // vertical resolution
    0, 0, 0, 0,     // number of colors (all)
    0, 0, 0, 0      // number of important colors
    );
    image: PScreenshot;
    size: QWord;
    writeResult:LongInt;
begin
image:= PScreenshot(screenshot);

size:= image^.Width*image^.Height*4;

head[$02]:= (size + 54) and $ff;
head[$03]:= ((size + 54) shr 8) and $ff;
head[$04]:= ((size + 54) shr 16) and $ff;
head[$05]:= ((size + 54) shr 24) and $ff;
head[$12]:= image^.Width and $ff;
head[$13]:= (image^.Width shr 8) and $ff;
head[$14]:= (image^.Width shr 16) and $ff;
head[$15]:= (image^.Width shr 24) and $ff;
head[$16]:= image^.Height and $ff;
head[$17]:= (image^.Height shr 8) and $ff;
head[$18]:= (image^.Height shr 16) and $ff;
head[$19]:= (image^.Height shr 24) and $ff;
head[$22]:= size and $ff;
head[$23]:= (size shr 8) and $ff;
head[$24]:= (size shr 16) and $ff;
head[$25]:= (size shr 24) and $ff;

if image^.alpha then
    head[$1C]:= 32;

{$IOCHECKS OFF}
Assign(f, image^.filename);
Rewrite(f, 1);
if IOResult = 0 then
    begin
    BlockWrite(f, head, sizeof(head), writeResult);
    BlockWrite(f, image^.buffer^, size, writeResult);
    Close(f);
    end
else
    begin
    //AddFileLog('Error: Could not write to ' + filename);
    end;
{$IOCHECKS ON}

// free everything
FreeMem(image^.buffer, image^.size);
Dispose(image);
SaveScreenshot:= 0;
end;

{$ENDIF} // no PNG_SCREENSHOTS

{$IFDEF USE_VIDEO_RECORDING}
// make image k times smaller (useful for saving thumbnails)
procedure ReduceImage(img: PByte; width, height, k: LongInt; bpp: Integer);
    var i, j, i0, j0, w, h, r, g, b, off, ksqr: LongInt;
begin
    w:= width  div k;
    h:= height div k;

    // rescale inplace
    if k <> 1 then
    begin
        ksqr:= k*k;
        for i:= 0 to h-1 do
            for j:= 0 to w-1 do
            begin
                r:= 0;
                g:= 0;
                b:= 0;
                for i0:= 0 to k-1 do
                    for j0:= 0 to k-1 do
                    begin
                        off:= bpp*(width*(i*k+i0) + j*k+j0);
                        inc(r, img[off]); inc(off);
                        inc(g, img[off]); inc(off);
                        inc(b, img[off]);
                    end;
                off:= bpp*(w*i + j);
                img[off]:= r div (ksqr); inc(off);
                img[off]:= g div (ksqr); inc(off);
                img[off]:= b div (ksqr);
                // if there's an alpha channel set opacity to max
                if bpp > 3 then
                    begin
                    inc(off);
                    img[off]:= 255;
                    end;
            end;
    end;
end;
{$ENDIF}

// captures and saves the screen. returns true on success.
// saved image will be k times smaller than original (useful for saving thumbnails).
function MakeScreenshot(filename: shortstring; k: LongInt; dump: LongWord): boolean;
var p: Pointer;
    size: QWord;
    image: PScreenshot;
    format: GLenum;
    ext: string[4];
    x,y: LongWord;
    hasA: boolean;
    bpp: Integer;
begin
hasA:= (dump > 0);

if hasA then
    bpp:= 4
else
    bpp:= 3;

{$IFDEF PNG_SCREENSHOTS}
if hasA then
    format:= GL_RGBA
else
    format:= GL_RGB;
ext:= '.png';
{$ELSE}
if hasA then
    format:= GL_BGRA
else
    format:= GL_BGR;
ext:= '.bmp';
{$ENDIF}

if dump > 0 then
     size:= LAND_WIDTH*LAND_HEIGHT*bpp
else size:= toPowerOf2(cScreenWidth) * toPowerOf2(cScreenHeight) * bpp;
p:= GetMem(size); // will be freed in SaveScreenshot()

// memory could not be allocated
if p = nil then
begin
    AddFileLog('Error: Could not allocate memory for screenshot.');
    MakeScreenshot:= false;
    exit;
end;

// read pixels from the front buffer
if dump > 0 then
    begin
    for y:= 0 to LAND_HEIGHT-1 do
        for x:= 0 to LAND_WIDTH-1 do
            if dump = 2 then
                PLongWordArray(p)^[y*LAND_WIDTH+x]:= LandPixels[LAND_HEIGHT-1-y, x]
            else
                begin
                if Land[LAND_HEIGHT-1-y, x] and lfIndestructible = lfIndestructible then
                    PLongWordArray(p)^[y*LAND_WIDTH+x]:= (AMask or RMask)
                else if Land[LAND_HEIGHT-1-y, x] and lfIce = lfIce then
                    PLongWordArray(p)^[y*LAND_WIDTH+x]:= (AMask or BMask)
                else if Land[LAND_HEIGHT-1-y, x] and lfBouncy = lfBouncy then
                    PLongWordArray(p)^[y*LAND_WIDTH+x]:= (AMask or GMask)
                else if Land[LAND_HEIGHT-1-y, x] and lfObject = lfObject then
                    PLongWordArray(p)^[y*LAND_WIDTH+x]:= $FFFFFFFF
                else if Land[LAND_HEIGHT-1-y, x] and lfBasic = lfBasic then
                    PLongWordArray(p)^[y*LAND_WIDTH+x]:= AMask
                else
                    PLongWordArray(p)^[y*LAND_WIDTH+x]:= 0
                end
    end
else
    begin
    glReadPixels(0, 0, cScreenWidth, cScreenHeight, format, GL_UNSIGNED_BYTE, p);
{$IFDEF USE_VIDEO_RECORDING}
    ReduceImage(p, cScreenWidth, cScreenHeight, k, bpp)
{$ENDIF}
    end;

// allocate and fill structure that will be passed to new thread
New(image); // will be disposed in SaveScreenshot()
if dump = 2 then
     image^.filename:= shortstring(UserPathPrefix) + filename + '_landpixels' + ext
else if dump = 1 then
     image^.filename:= shortstring(UserPathPrefix) + filename + '_land' + ext
else image^.filename:= shortstring(UserPathPrefix) + filename + ext;

if dump <> 0 then
    begin
    image^.width:= LAND_WIDTH;
    image^.height:= LAND_HEIGHT
    end
else
    begin
    image^.width:= cScreenWidth div k;
    image^.height:= cScreenHeight div k
    end;
image^.size:= size;
image^.buffer:= p;
image^.alpha:= hasA;

SDL_CreateThread(@SaveScreenshot{$IFDEF SDL2}, 'snapshot'{$ENDIF}, image);
MakeScreenshot:= true; // possibly it is not true but we will not wait for thread to terminate
end;

// http://www.idevgames.com/forums/thread-5602-post-21860.html#pid21860
function doSurfaceConversion(tmpsurf: PSDL_Surface): PSDL_Surface;
var convertedSurf: PSDL_Surface;
begin
    doSurfaceConversion:= tmpsurf;
    if ((tmpsurf^.format^.bitsperpixel = 32) and (tmpsurf^.format^.rshift > tmpsurf^.format^.bshift)) or
       (tmpsurf^.format^.bitsperpixel = 24) then
    begin
        convertedSurf:= SDL_ConvertSurface(tmpsurf, conversionFormat, SDL_SWSURFACE);
        SDL_FreeSurface(tmpsurf);
        doSurfaceConversion:= convertedSurf;
    end;
end;

{$IFDEF SDL2}
function SDL_RectMake(x, y, width, height: LongInt): TSDL_Rect; inline;
{$ELSE}
function SDL_RectMake(x, y: SmallInt; width, height: Word): TSDL_Rect; inline;
{$ENDIF}
begin
    SDL_RectMake.x:= x;
    SDL_RectMake.y:= y;
    SDL_RectMake.w:= width;
    SDL_RectMake.h:= height;
end;

function GetTeamStatString(p: PTeam): shortstring;
var s: shortstring;
begin
    s:= p^.TeamName + ':' + IntToStr(p^.TeamHealth) + ':';
    GetTeamStatString:= s;
end;

{$IFDEF SDL2}
// FIXME - pretty sure this is not handling endianness correctly like the SDL1 is
const SDL_PIXELFORMAT_ABGR8888 = (1 shl 28) or (6 shl 24) or (7 shl 20) or (6 shl 16) or (32 shl 8) or 4;
{$ELSE}
const format: TSDL_PixelFormat = (
        palette: nil; BitsPerPixel: 32; BytesPerPixel: 4;
        Rloss: 0; Gloss: 0; Bloss: 0; Aloss: 0;
        Rshift: RShift; Gshift: GShift; Bshift: BShift; Ashift: AShift;
        RMask: RMask; GMask: GMask; BMask: BMask; AMask: AMask;
        colorkey: 0; alpha: 255);
{$ENDIF}

procedure initModule;
begin
{$IFDEF SDL2}
    conversionFormat:= SDL_AllocFormat(SDL_PIXELFORMAT_ABGR8888);
{$ELSE}
    conversionFormat:= @format;
{$ENDIF}
end;

procedure freeModule;
begin
{$IFDEF SDL2}
    SDL_FreeFormat(conversionFormat);
{$ENDIF}
end;

end.
