(*
* Hedgewars, a free turn based strategy game
* Copyright (c) 2004-2012 Andrey Korotaev <unC0Rr@gmail.com>
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
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
*)

{$INCLUDE "options.inc"}

unit uMisc;
interface

uses SDLh, uConsts, GLunit, uTypes;

procedure movecursor(dx, dy: LongInt);
function  doSurfaceConversion(tmpsurf: PSDL_Surface): PSDL_Surface;
function  MakeScreenshot(filename: shortstring): boolean;
function  GetTeamStatString(p: PTeam): shortstring;
{$IFDEF SDL13}
function SDL_RectMake(x, y, width, height: LongInt): TSDL_Rect;
{$ELSE}
function SDL_RectMake(x, y: SmallInt; width, height: Word): TSDL_Rect;
{$ENDIF}
procedure initModule;
procedure freeModule;

implementation
uses typinfo, sysutils, uVariables, uUtils;

procedure movecursor(dx, dy: LongInt);
var x, y: LongInt;
begin
if (dx = 0) and (dy = 0) then exit;

SDL_GetMouseState(@x, @y);
Inc(x, dx);
Inc(y, dy);
SDL_WarpMouse(x, y);
end;

// captures and saves the screen. returns true on success.
function MakeScreenshot(filename: shortstring): Boolean;
var success: boolean;
    p: Pointer;
    size: QWord;
    f: file;
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
    32, 0,          // bit depth
    0, 0, 0, 0,     // compression method (uncompressed)
    0, 0, 0, 0,     // image size
    96, 0, 0, 0,    // horizontal resolution
    96, 0, 0, 0,    // vertical resolution
    0, 0, 0, 0,     // number of colors (all)
    0, 0, 0, 0      // number of important colors
    );
begin
// flash
ScreenFade:= sfFromWhite;
ScreenFadeValue:= sfMax;
ScreenFadeSpeed:= 5;

size:= toPowerOf2(cScreenWidth) * toPowerOf2(cScreenHeight) * 4;
p:= GetMem(size);

// memory could not be allocated
if p = nil then
begin
    AddFileLog('Error: Could not allocate memory for screenshot.');
    exit(false);
end;

// update header information and file name
filename:= UserPathPrefix + '/Screenshots/' + filename + '.bmp';

head[$02]:= (size + 54) and $ff;
head[$03]:= ((size + 54) shr 8) and $ff;
head[$04]:= ((size + 54) shr 16) and $ff;
head[$05]:= ((size + 54) shr 24) and $ff;
head[$12]:= cScreenWidth and $ff;
head[$13]:= (cScreenWidth shr 8) and $ff;
head[$14]:= (cScreenWidth shr 16) and $ff;
head[$15]:= (cScreenWidth shr 24) and $ff;
head[$16]:= cScreenHeight and $ff;
head[$17]:= (cScreenHeight shr 8) and $ff;
head[$18]:= (cScreenHeight shr 16) and $ff;
head[$19]:= (cScreenHeight shr 24) and $ff;
head[$22]:= size and $ff;
head[$23]:= (size shr 8) and $ff;
head[$24]:= (size shr 16) and $ff;
head[$25]:= (size shr 24) and $ff;

// read pixel from the front buffer
glReadPixels(0, 0, cScreenWidth, cScreenHeight, GL_BGRA, GL_UNSIGNED_BYTE, p);

{$IOCHECKS OFF}
Assign(f, filename);
Rewrite(f, 1);
if IOResult = 0 then
    begin
    BlockWrite(f, head, sizeof(head));
    BlockWrite(f, p^, size);
    Close(f);
    success:= true;
    end
else
    begin
    AddFileLog('Error: Could not write to ' + filename);
    success:= false;
    end;
{$IOCHECKS ON}

FreeMem(p, size);
MakeScreenshot:= success;
end;

// http://www.idevgames.com/forums/thread-5602-post-21860.html#pid21860
function doSurfaceConversion(tmpsurf: PSDL_Surface): PSDL_Surface;
var convertedSurf: PSDL_Surface;
begin
    if ((tmpsurf^.format^.bitsperpixel = 32) and (tmpsurf^.format^.rshift > tmpsurf^.format^.bshift)) or
       (tmpsurf^.format^.bitsperpixel = 24) then
        begin
        convertedSurf:= SDL_ConvertSurface(tmpsurf, conversionFormat, SDL_SWSURFACE);
        SDL_FreeSurface(tmpsurf);
        exit(convertedSurf);
        end;

    exit(tmpsurf);
end;

{$IFDEF SDL13}
function SDL_RectMake(x, y, width, height: LongInt): TSDL_Rect;
{$ELSE}
function SDL_RectMake(x, y: SmallInt; width, height: Word): TSDL_Rect;
{$ENDIF}
begin
    SDL_RectMake.x:= x;
    SDL_RectMake.y:= y;
    SDL_RectMake.w:= width;
    SDL_RectMake.h:= height;
end;

function GetTeamStatString(p: PTeam): shortstring;
var s: ansistring;
begin
    s:= p^.TeamName + ':' + IntToStr(p^.TeamHealth) + ':';
    GetTeamStatString:= s;
end;

procedure initModule;
const SDL_PIXELFORMAT_ABGR8888 = (1 shl 31) or (6 shl 24) or (7 shl 20) or (6 shl 16) or (32 shl 8) or 4;
begin
    conversionFormat:= SDL_AllocFormat(SDL_PIXELFORMAT_ABGR8888);
end;

procedure freeModule;
begin
    recordFileName:= '';
    SDL_FreeFormat(conversionFormat);
end;

end.
