(*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2004-2011 Andrey Korotaev <unC0Rr@gmail.com>
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
{$IF GLunit = GL}{$DEFINE GLunit:=GL,GLext}{$ENDIF}

unit uStore;
interface
uses sysutils, uConsts, SDLh, GLunit, uTypes;

procedure initModule;
procedure freeModule;

procedure StoreLoad;
procedure StoreRelease;
procedure RenderHealth(var Hedgehog: THedgehog);
procedure AddProgress;
procedure FinishProgress;
function  LoadImage(const filename: shortstring; imageFlags: LongInt): PSDL_Surface;
procedure LoadHedgehogHat(HHGear: PGear; newHat: shortstring);
procedure SetupOpenGL;
procedure SetScale(f: GLfloat);
function  RenderHelpWindow(caption, subcaption, description, extra: ansistring; extracolor: LongInt; iconsurf: PSDL_Surface; iconrect: PSDL_Rect): PTexture;
procedure RenderWeaponTooltip(atype: TAmmoType);
procedure ShowWeaponTooltip(x, y: LongInt);
procedure FreeWeaponTooltip;
procedure MakeCrossHairs;

implementation
uses uMisc, uConsole, uMobile, uVariables, uUtils, uTextures, uRender, uRenderUtils, uCommands, uDebug;

type TGPUVendor = (gvUnknown, gvNVIDIA, gvATI, gvIntel, gvApple);

var MaxTextureSize: LongInt;
    cGPUVendor: TGPUVendor;

function WriteInRect(Surface: PSDL_Surface; X, Y: LongInt; Color: LongWord; Font: THWFont; s: ansistring): TSDL_Rect;
var w, h: LongInt;
    tmpsurf: PSDL_Surface;
    clr: TSDL_Color;
    finalRect: TSDL_Rect;
begin
w:= 0; h:= 0; // avoid compiler hints
TTF_SizeUTF8(Fontz[Font].Handle, Str2PChar(s), w, h);
finalRect.x:= X + FontBorder + 2;
finalRect.y:= Y + FontBorder;
finalRect.w:= w + FontBorder * 2 + 4;
finalRect.h:= h + FontBorder * 2;
clr.r:= Color shr 16;
clr.g:= (Color shr 8) and $FF;
clr.b:= Color and $FF;
tmpsurf:= TTF_RenderUTF8_Blended(Fontz[Font].Handle, Str2PChar(s), clr);
tmpsurf:= doSurfaceConversion(tmpsurf);
SDLTry(tmpsurf <> nil, true);
SDL_UpperBlit(tmpsurf, nil, Surface, @finalRect);
SDL_FreeSurface(tmpsurf);
finalRect.x:= X;
finalRect.y:= Y;
finalRect.w:= w + FontBorder * 2 + 4;
finalRect.h:= h + FontBorder * 2;
WriteInRect:= finalRect
end;

procedure MakeCrossHairs;
var t: LongInt;
    tmpsurf, texsurf: PSDL_Surface;
    Color, i: Longword;
    s : shortstring;
begin
s:= Pathz[ptGraphics] + '/' + cCHFileName;
tmpsurf:= LoadImage(s, ifAlpha or ifCritical);

for t:= 0 to Pred(TeamsCount) do
    with TeamsArray[t]^ do
    begin
    texsurf:= SDL_CreateRGBSurface(SDL_SWSURFACE, tmpsurf^.w, tmpsurf^.h, 32, RMask, GMask, BMask, AMask);
    TryDo(texsurf <> nil, errmsgCreateSurface, true);

    Color:= Clan^.Color;
    Color:= SDL_MapRGB(texsurf^.format, Color shr 16, Color shr 8, Color and $FF);
    SDL_FillRect(texsurf, nil, Color);

    SDL_UpperBlit(tmpsurf, nil, texsurf, nil);

    TryDo(tmpsurf^.format^.BytesPerPixel = 4, 'Ooops', true);

    if SDL_MustLock(texsurf) then
        SDLTry(SDL_LockSurface(texsurf) >= 0, true);

    // make black pixel be alpha-transparent
    for i:= 0 to texsurf^.w * texsurf^.h - 1 do
        if PLongwordArray(texsurf^.pixels)^[i] = AMask then PLongwordArray(texsurf^.pixels)^[i]:= (RMask or GMask or BMask) and Color;

    if SDL_MustLock(texsurf) then
        SDL_UnlockSurface(texsurf);

    if CrosshairTex <> nil then FreeTexture(CrosshairTex);
    CrosshairTex:= Surface2Tex(texsurf, false);
    SDL_FreeSurface(texsurf)
    end;

SDL_FreeSurface(tmpsurf)
end;

procedure StoreLoad;
var s: shortstring;

    procedure WriteNames(Font: THWFont);
    var t: LongInt;
        i: LongInt;
        r, rr: TSDL_Rect;
        drY: LongInt;
        texsurf, flagsurf, iconsurf: PSDL_Surface;
    begin
    r.x:= 0;
    r.y:= 0;
    drY:= - 4;
    for t:= 0 to Pred(TeamsCount) do
        with TeamsArray[t]^ do
        begin
        NameTagTex:= RenderStringTex(TeamName, Clan^.Color, Font);

        r.w:= cTeamHealthWidth + 5;
        r.h:= NameTagTex^.h;

        texsurf:= SDL_CreateRGBSurface(SDL_SWSURFACE, r.w, r.h, 32, RMask, GMask, BMask, AMask);
        TryDo(texsurf <> nil, errmsgCreateSurface, true);
        TryDo(SDL_SetColorKey(texsurf, SDL_SRCCOLORKEY, 0) = 0, errmsgTransparentSet, true);

        DrawRoundRect(@r, cWhiteColor, cNearBlackColorChannels.value, texsurf, true);
        rr:= r;
        inc(rr.x, 2); dec(rr.w, 4); inc(rr.y, 2); dec(rr.h, 4);
        DrawRoundRect(@rr, Clan^.Color, Clan^.Color, texsurf, false);
        HealthTex:= Surface2Tex(texsurf, false);
        SDL_FreeSurface(texsurf);

        r.x:= 0;
        r.y:= 0;
        r.w:= 32;
        r.h:= 32;
        texsurf:= SDL_CreateRGBSurface(SDL_SWSURFACE, r.w, r.h, 32, RMask, GMask, BMask, AMask);
        TryDo(texsurf <> nil, errmsgCreateSurface, true);
        TryDo(SDL_SetColorKey(texsurf, SDL_SRCCOLORKEY, 0) = 0, errmsgTransparentSet, true);

        r.w:= 26;
        r.h:= 19;

        DrawRoundRect(@r, cWhiteColor, cNearBlackColor, texsurf, true);

        // overwrite flag for cpu teams and keep players from using it
        if (Hedgehogs[0].Gear <> nil) and (Hedgehogs[0].BotLevel > 0) then
            if Flag = 'hedgewars' then Flag:= 'cpu'
        else if Flag = 'cpu' then
            Flag:= 'hedgewars';

        flagsurf:= LoadImage(Pathz[ptFlags] + '/' + Flag, ifNone);
        if flagsurf = nil then
            flagsurf:= LoadImage(Pathz[ptFlags] + '/hedgewars', ifNone);
        TryDo(flagsurf <> nil, 'Failed to load flag "' + Flag + '" as well as the default flag', true);
        copyToXY(flagsurf, texsurf, 2, 2);
        SDL_FreeSurface(flagsurf);
        flagsurf:= nil;

        // restore black border pixels inside the flag
        PLongwordArray(texsurf^.pixels)^[32 * 2 +  2]:= cNearBlackColor;
        PLongwordArray(texsurf^.pixels)^[32 * 2 + 23]:= cNearBlackColor;
        PLongwordArray(texsurf^.pixels)^[32 * 16 +  2]:= cNearBlackColor;
        PLongwordArray(texsurf^.pixels)^[32 * 16 + 23]:= cNearBlackColor;

        FlagTex:= Surface2Tex(texsurf, false);
        SDL_FreeSurface(texsurf);
        texsurf:= nil;

        AIKillsTex := RenderStringTex(inttostr(stats.AIKills), Clan^.Color, fnt16);

        dec(drY, r.h + 2);
        DrawHealthY:= drY;
        for i:= 0 to 7 do
            with Hedgehogs[i] do
                if Gear <> nil then
                    begin
                    NameTagTex:= RenderStringTex(Name, Clan^.Color, fnt16);
                    if Hat <> 'NoHat' then
                        begin
                        if (Length(Hat) > 39) and (Copy(Hat,1,8) = 'Reserved') and (Copy(Hat,9,32) = PlayerHash) then
                            LoadHedgehogHat(Gear, 'Reserved/' + Copy(Hat,9,Length(s)-8))
                        else
                            LoadHedgehogHat(Gear, Hat);
                        end
                    end;
        end;
    MissionIcons:= LoadImage(Pathz[ptGraphics] + '/missions', ifCritical);
    iconsurf:= SDL_CreateRGBSurface(SDL_SWSURFACE, 28, 28, 32, RMask, GMask, BMask, AMask);
    if iconsurf <> nil then
        begin
        r.x:= 0;
        r.y:= 0;
        r.w:= 28;
        r.h:= 28;
        DrawRoundRect(@r, cWhiteColor, cNearBlackColor, iconsurf, true);
        ropeIconTex:= Surface2Tex(iconsurf, false);
        SDL_FreeSurface(iconsurf);
        iconsurf:= nil;
        end;
    end;

    procedure InitHealth;
    var i, t: LongInt;
    begin
    for t:= 0 to Pred(TeamsCount) do
        if TeamsArray[t] <> nil then
            with TeamsArray[t]^ do
                begin
                for i:= 0 to cMaxHHIndex do
                    if Hedgehogs[i].Gear <> nil then
                        RenderHealth(Hedgehogs[i]);
                end
    end;

    procedure LoadGraves;
    var t: LongInt;
        texsurf: PSDL_Surface;
    begin
    for t:= 0 to Pred(TeamsCount) do
    if TeamsArray[t] <> nil then
        with TeamsArray[t]^ do
            begin
            if GraveName = '' then GraveName:= 'Statue';
            texsurf:= LoadImage(Pathz[ptGraves] + '/' + GraveName, ifTransparent);
            if texsurf = nil then texsurf:= LoadImage(Pathz[ptGraves] + '/Statue', ifCritical or ifTransparent);
            GraveTex:= Surface2Tex(texsurf, false);
            SDL_FreeSurface(texsurf)
            end
    end;

var ii: TSprite;
    fi: THWFont;
    ai: TAmmoType;
    tmpsurf: PSDL_Surface;
    i: LongInt;
begin

for fi:= Low(THWFont) to High(THWFont) do
    with Fontz[fi] do
        begin
        s:= Pathz[ptFonts] + '/' + Name;
        WriteToConsole(msgLoading + s + ' (' + inttostr(Height) + 'pt)... ');
        Handle:= TTF_OpenFont(Str2PChar(s), Height);
        SDLTry(Handle <> nil, true);
        TTF_SetFontStyle(Handle, style);
        WriteLnToConsole(msgOK)
        end;

WriteNames(fnt16);
MakeCrossHairs;
LoadGraves;

AddProgress;
for ii:= Low(TSprite) to High(TSprite) do
    with SpritesData[ii] do
        // FIXME - add a sprite attribute
        if ((cReducedQuality and rqNoBackground) = 0) or // FIXME: should check for both rqNoBackground and rqKillFlakes
            (not (ii in [sprSky, sprSkyL, sprSkyR, sprHorizont, sprHorizontL, sprHorizontR, sprFlake, sprSplash, sprDroplet, sprSDSplash, sprSDDroplet]) or
            (((Theme = 'Snow') or (Theme = 'Christmas')) and ((ii = sprFlake) or (ii = sprSDFlake)))) then // FIXME: hack; also should checked against rqLowRes
        begin
            if AltPath = ptNone then
                if ii in [sprHorizontL, sprHorizontR, sprSkyL, sprSkyR] then // FIXME: hack
                    tmpsurf:= LoadImage(Pathz[Path] + '/' + FileName, ifAlpha or ifTransparent)
                else
                    tmpsurf:= LoadImage(Pathz[Path] + '/' + FileName, ifAlpha or ifTransparent or ifCritical)
            else begin
                tmpsurf:= LoadImage(Pathz[Path] + '/' + FileName, ifAlpha or ifTransparent);
                if tmpsurf = nil then
                    tmpsurf:= LoadImage(Pathz[AltPath] + '/' + FileName, ifAlpha or ifCritical or ifTransparent);
                end;

            if tmpsurf <> nil then
            begin
                if getImageDimensions then
                begin
                    imageWidth:= tmpsurf^.w;
                    imageHeight:= tmpsurf^.h
                end;
                if getDimensions then
                begin
                    Width:= tmpsurf^.w;
                    Height:= tmpsurf^.h
                end;
                if (ii in [sprSky, sprSkyL, sprSkyR, sprHorizont, sprHorizontL, sprHorizontR]) then
                begin
                    Texture:= Surface2Tex(tmpsurf, true);
                    Texture^.Scale:= 2
                end
                else
                begin
                    Texture:= Surface2Tex(tmpsurf, false);
                    // HACK: We should include some sprite attribute to define the texture wrap directions
                    if ((ii = sprWater) or (ii = sprSDWater)) and ((cReducedQuality and (rq2DWater or rqClampLess)) = 0) then
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                end;
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_PRIORITY, priority);
                if saveSurf then
                    Surface:= tmpsurf else SDL_FreeSurface(tmpsurf)
                end
            else
                Surface:= nil
        end;

AddProgress;

tmpsurf:= LoadImage(Pathz[ptGraphics] + '/' + cHHFileName, ifAlpha or ifCritical or ifTransparent);
HHTexture:= Surface2Tex(tmpsurf, false);
SDL_FreeSurface(tmpsurf);

InitHealth;

PauseTexture:= RenderStringTex(trmsg[sidPaused], cYellowColor, fntBig);
ConfirmTexture:= RenderStringTex(trmsg[sidConfirm], cYellowColor, fntBig);
SyncTexture:= RenderStringTex(trmsg[sidSync], cYellowColor, fntBig);

AddProgress;

// name of weapons in ammo menu
for ai:= Low(TAmmoType) to High(TAmmoType) do
    with Ammoz[ai] do
    begin
        TryDo(trAmmo[NameId] <> '','No default text/translation found for ammo type #' + intToStr(ord(ai)) + '!',true);
        tmpsurf:= TTF_RenderUTF8_Blended(Fontz[CheckCJKFont(trAmmo[NameId],fnt16)].Handle, Str2PChar(trAmmo[NameId]), cWhiteColorChannels);
        TryDo(tmpsurf <> nil,'Name-texture creation for ammo type #' + intToStr(ord(ai)) + ' failed!',true);
        tmpsurf:= doSurfaceConversion(tmpsurf);
        if (NameTex <> nil) then
            FreeTexture(NameTex);
        NameTex:= Surface2Tex(tmpsurf, false);
        SDL_FreeSurface(tmpsurf)
    end;

// number of weapons in ammo menu
for i:= Low(CountTexz) to High(CountTexz) do
begin
    tmpsurf:= TTF_RenderUTF8_Blended(Fontz[fnt16].Handle, Str2PChar(IntToStr(i) + 'x'), cWhiteColorChannels);
    tmpsurf:= doSurfaceConversion(tmpsurf);
    if (CountTexz[i] <> nil) then
        FreeTexture(CountTexz[i]);
    CountTexz[i]:= Surface2Tex(tmpsurf, false);
    SDL_FreeSurface(tmpsurf)
end;

AddProgress;

{$IFDEF SDL_IMAGE_NEWER}
IMG_Quit();
{$ENDIF}
end;

procedure StoreRelease;
var ii: TSprite;
    ai: TAmmoType;
    i, t: LongInt;
begin
    for ii:= Low(TSprite) to High(TSprite) do
    begin
        FreeTexture(SpritesData[ii].Texture);
        SpritesData[ii].Texture:= nil;
        if SpritesData[ii].Surface <> nil then
            SDL_FreeSurface(SpritesData[ii].Surface);
        SpritesData[ii].Surface:= nil;
    end;
    SDL_FreeSurface(MissionIcons);
    FreeTexture(ropeIconTex);
    FreeTexture(HHTexture);
    FreeTexture(PauseTexture);
    FreeTexture(ConfirmTexture);
    FreeTexture(SyncTexture);
    // free all ammo name textures
    for ai:= Low(TAmmoType) to High(TAmmoType) do
    begin
        FreeTexture(Ammoz[ai].NameTex);
    end;
    // free all count textures
    for i:= Low(CountTexz) to High(CountTexz) do
    begin
        FreeTexture(CountTexz[i]);
    end;
    // free all team and hedgehog textures
    for t:= 0 to Pred(TeamsCount) do
    begin
        if TeamsArray[t] <> nil then
        begin
            FreeTexture(TeamsArray[t]^.NameTagTex);
            FreeTexture(TeamsArray[t]^.CrosshairTex);
            FreeTexture(TeamsArray[t]^.GraveTex);
            FreeTexture(TeamsArray[t]^.HealthTex);
            FreeTexture(TeamsArray[t]^.AIKillsTex);
            FreeTexture(TeamsArray[t]^.FlagTex);
            for i:= 0 to cMaxHHIndex do
            begin
                FreeTexture(TeamsArray[t]^.Hedgehogs[i].NameTagTex);
                FreeTexture(TeamsArray[t]^.Hedgehogs[i].HealthTagTex);
                FreeTexture(TeamsArray[t]^.Hedgehogs[i].HatTex);
            end;
        end;
    end;
{$IFNDEF S3D_DISABLED}
    if (cStereoMode = smHorizontal) or (cStereoMode = smVertical) or (cStereoMode = smAFR) then
    begin
        glDeleteTextures(1, @texl);
        glDeleteRenderbuffersEXT(1, @depthl);
        glDeleteFramebuffersEXT(1, @framel);
        glDeleteTextures(1, @texr);
        glDeleteRenderbuffersEXT(1, @depthr);
        glDeleteFramebuffersEXT(1, @framer)
    end
{$ENDIF}
end;


procedure RenderHealth(var Hedgehog: THedgehog);
var s: shortstring;
begin
    str(Hedgehog.Gear^.Health, s);
    if Hedgehog.HealthTagTex <> nil then
        FreeTexture(Hedgehog.HealthTagTex);
    Hedgehog.HealthTagTex:= RenderStringTex(s, Hedgehog.Team^.Clan^.Color, fnt16)
end;

function  LoadImage(const filename: shortstring; imageFlags: LongInt): PSDL_Surface;
var tmpsurf: PSDL_Surface;
    s: shortstring;
begin
    WriteToConsole(msgLoading + filename + '.png [flags: ' + inttostr(imageFlags) + '] ');

    s:= filename + '.png';
    tmpsurf:= IMG_Load(Str2PChar(s));

    if tmpsurf = nil then
    begin
        OutError(msgFailed, (imageFlags and ifCritical) <> 0);
        exit(nil)
    end;

    if ((imageFlags and ifIgnoreCaps) = 0) and ((tmpsurf^.w > MaxTextureSize) or (tmpsurf^.h > MaxTextureSize)) then
    begin
        SDL_FreeSurface(tmpsurf);
        OutError(msgFailedSize, (imageFlags and ifCritical) <> 0);
        // dummy surface to replace non-critical textures that failed to load due to their size
        exit(SDL_CreateRGBSurface(SDL_SWSURFACE, 2, 2, 32, RMask, GMask, BMask, AMask));
    end;

    tmpsurf:= doSurfaceConversion(tmpsurf);

    if (imageFlags and ifTransparent) <> 0 then
        TryDo(SDL_SetColorKey(tmpsurf, SDL_SRCCOLORKEY, 0) = 0, errmsgTransparentSet, true);

    WriteLnToConsole(msgOK + ' (' + inttostr(tmpsurf^.w) + 'x' + inttostr(tmpsurf^.h) + ')');

    LoadImage:= tmpsurf //Result
end;

procedure LoadHedgehogHat(HHGear: PGear; newHat: shortstring);
var texsurf: PSDL_Surface;
begin
    texsurf:= LoadImage(Pathz[ptHats] + '/' + newHat, ifNone);

    // only do something if the hat could be loaded
    if texsurf <> nil then
        begin
        // free the mem of any previously assigned texture
        FreeTexture(HHGear^.Hedgehog^.HatTex);

        // assign new hat to hedgehog
        HHGear^.Hedgehog^.HatTex:= Surface2Tex(texsurf, true);

        // cleanup: free temporary surface mem
        SDL_FreeSurface(texsurf)
        end;
end;

function glLoadExtension(extension : shortstring) : boolean;
begin
{$IF GLunit = gles11}
    // FreePascal doesnt come with OpenGL ES 1.1 Extension headers
    extension:= extension; // avoid hint
    glLoadExtension:= false;
    AddFileLog('OpenGL - "' + extension + '" skipped')
{$ELSE}
    glLoadExtension:= glext_LoadExtension(extension);
    if glLoadExtension then
        AddFileLog('OpenGL - "' + extension + '" loaded')
    else
        AddFileLog('OpenGL - "' + extension + '" failed to load');
{$ENDIF}
end;

procedure SetupOpenGL;
{$IFNDEF IPHONEOS}
var vendor: shortstring;
{$IFDEF DARWIN}
    one: LongInt;
{$ENDIF}
{$ENDIF}
begin

{$IFDEF IPHONEOS}
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 0); // no double buffering
    SDL_GL_SetAttribute(SDL_GL_RETAINED_BACKING, 1);
{$ELSE}
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    vendor:= LowerCase(shortstring(pchar(glGetString(GL_VENDOR))));
{$IFNDEF SDL13}
// this attribute is default in 1.3 and must be enabled in MacOSX
    if (cReducedQuality and rqDesyncVBlank) <> 0 then
        SDL_GL_SetAttribute(SDL_GL_SWAP_CONTROL, 0)
    else
        SDL_GL_SetAttribute(SDL_GL_SWAP_CONTROL, 1);
{$IFDEF DARWIN}
// fixes vsync in Snow Leopard
    one:= 1;
    CGLSetParameter(CGLGetCurrentContext(), 222, @one);
{$ENDIF}
{$ENDIF}
{$ENDIF}
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 0); // no depth buffer
    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 5);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 6);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 5);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 0); // no alpha channel required
    SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 16); // buffer has to be 16 bit only
    SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1); // try to prefer hardware rendering

    glGetIntegerv(GL_MAX_TEXTURE_SIZE, @MaxTextureSize);

    AddFileLog('OpenGL-- Renderer: ' + shortstring(pchar(glGetString(GL_RENDERER))));
    AddFileLog('  |----- Vendor: ' + shortstring(pchar(glGetString(GL_VENDOR))));
    AddFileLog('  |----- Version: ' + shortstring(pchar(glGetString(GL_VERSION))));
    AddFileLog('  \----- GL_MAX_TEXTURE_SIZE: ' + inttostr(MaxTextureSize));

    if MaxTextureSize <= 0 then
    begin
        MaxTextureSize:= 1024;
        AddFileLog('OpenGL Warning - driver didn''t provide any valid max texture size; assuming 1024');
    end;

{$IFDEF IPHONEOS}
    cGPUVendor:= gvApple;
{$ELSE}
    if StrPos(Str2PChar(vendor), Str2PChar('nvidia')) <> nil then
        cGPUVendor:= gvNVIDIA
    else if StrPos(Str2PChar(vendor), Str2PChar('intel')) <> nil then
        cGPUVendor:= gvATI
    else if StrPos(Str2PChar(vendor), Str2PChar('ati')) <> nil then
        cGPUVendor:= gvIntel;
{$ENDIF}
//SupportNPOTT:= glLoadExtension('GL_ARB_texture_non_power_of_two');
{$IFNDEF S3D_DISABLED}
    if (cStereoMode = smHorizontal) or (cStereoMode = smVertical) or (cStereoMode = smAFR) then
    begin
        // prepare left and right frame buffers and associated textures
        if glLoadExtension('GL_EXT_framebuffer_object') then
        begin
            // left
            glGenFramebuffersEXT(1, @framel);
            glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framel);
            glGenRenderbuffersEXT(1, @depthl);
            glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, depthl);
            glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT, cScreenWidth, cScreenHeight);
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, depthl);
            glGenTextures(1, @texl);
            glBindTexture(GL_TEXTURE_2D, texl);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,  cScreenWidth, cScreenHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, texl, 0);

            // right
            glGenFramebuffersEXT(1, @framer);
            glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framer);
            glGenRenderbuffersEXT(1, @depthr);
            glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, depthr);
            glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT, cScreenWidth, cScreenHeight);
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, depthr);
            glGenTextures(1, @texr);
            glBindTexture(GL_TEXTURE_2D, texr);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,  cScreenWidth, cScreenHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, texr, 0);

            // reset
            glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0)
        end
        else
            cStereoMode:= smNone;
    end;
{$ENDIF}

    if cGPUVendor = gvUnknown then
        AddFileLog('OpenGL Warning - unknown hardware vendor; please report');

    // set view port to whole window
    if (rotationQt = 0) or (rotationQt = 180) then
        glViewport(0, 0, cScreenWidth, cScreenHeight)
    else
        glViewport(0, 0, cScreenHeight, cScreenWidth);

    glMatrixMode(GL_MODELVIEW);
    // prepare default translation/scaling
    glLoadIdentity();
    glRotatef(rotationQt, 0, 0, 1);
    glScalef(2.0 / cScreenWidth, -2.0 / cScreenHeight, 1.0);
    glTranslatef(0, -cScreenHeight / 2, 0);

    // enable alpha blending
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // disable/lower perspective correction (will not need it anyway)
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    // disable dithering
    glDisable(GL_DITHER);
    // enable common states by default as they save a lot
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
end;

procedure SetScale(f: GLfloat);
begin
    // leave immediately if scale factor did not change
    if f = cScaleFactor then exit;

    if f = cDefaultZoomLevel then
        glPopMatrix         // "return" to default scaling
    else                    // other scaling
    begin
        glPushMatrix;       // save default scaling
        glLoadIdentity;
        glRotatef(rotationQt, 0, 0, 1);
        glScalef(f / cScreenWidth, -f / cScreenHeight, 1.0);
        glTranslatef(0, -cScreenHeight / 2, 0);
    end;

    cScaleFactor:= f;
end;

////////////////////////////////////////////////////////////////////////////////
procedure AddProgress;
var r: TSDL_Rect;
    texsurf: PSDL_Surface;
begin
    if Step = 0 then
    begin
        WriteToConsole(msgLoading + 'progress sprite: ');
        texsurf:= LoadImage(Pathz[ptGraphics] + '/Progress', ifCritical or ifTransparent);

        ProgrTex:= Surface2Tex(texsurf, false);

        squaresize:= texsurf^.w shr 1;
        numsquares:= texsurf^.h div squaresize;
        SDL_FreeSurface(texsurf);

        perfExt_AddProgress();
    end;

    TryDo(ProgrTex <> nil, 'Error - Progress Texure is nil!', true);

    glClear(GL_COLOR_BUFFER_BIT);
    if Step < numsquares then r.x:= 0
    else r.x:= squaresize;

    r.y:= (Step mod numsquares) * squaresize;
    r.w:= squaresize;
    r.h:= squaresize;

    DrawFromRect( -squaresize div 2, (cScreenHeight - squaresize) shr 1, @r, ProgrTex);

{$IFDEF SDL13}
    SDL_RenderPresent(SDLrender);
{$ELSE}
    SDL_GL_SwapBuffers();
{$ENDIF}
    inc(Step);

end;

procedure FinishProgress;
begin
    WriteLnToConsole('Freeing progress surface... ');
    FreeTexture(ProgrTex);
    perfExt_FinishProgress();
end;

function RenderHelpWindow(caption, subcaption, description, extra: ansistring; extracolor: LongInt; iconsurf: PSDL_Surface; iconrect: PSDL_Rect): PTexture;
var tmpsurf: PSDL_SURFACE;
    w, h, i, j: LongInt;
    font: THWFont;
    r, r2: TSDL_Rect;
    wa, ha: LongInt;
    tmpline, tmpline2, tmpdesc: ansistring;
begin
// make sure there is a caption as well as a sub caption - description is optional
if caption = '' then caption:= '???';
if subcaption = '' then subcaption:= ' ';

font:= CheckCJKFont(caption,fnt16);
font:= CheckCJKFont(subcaption,font);
font:= CheckCJKFont(description,font);
font:= CheckCJKFont(extra,font);

w:= 0;
h:= 0;
wa:= FontBorder * 2 + 4;
ha:= FontBorder * 2;

i:= 0; j:= 0; // avoid compiler hints

// TODO: Recheck height/position calculation

// get caption's dimensions
TTF_SizeUTF8(Fontz[font].Handle, Str2PChar(caption), i, j);
// width adds 36 px (image + space)
w:= i + 36 + wa;
h:= j + ha;

// get sub caption's dimensions
TTF_SizeUTF8(Fontz[font].Handle, Str2PChar(subcaption), i, j);
// width adds 36 px (image + space)
if w < (i + 36 + wa) then w:= i + 36 + wa;
inc(h, j + ha);

// get description's dimensions
tmpdesc:= description;
while tmpdesc <> '' do
    begin
    tmpline:= tmpdesc;
    SplitByChar(tmpline, tmpdesc, '|');
    if tmpline <> '' then
        begin
        TTF_SizeUTF8(Fontz[font].Handle, Str2PChar(tmpline), i, j);
        if w < (i + wa) then w:= i + wa;
        inc(h, j + ha)
        end
    end;

if extra <> '' then
    begin
    // get extra label's dimensions
    TTF_SizeUTF8(Fontz[font].Handle, Str2PChar(extra), i, j);
    if w < (i + wa) then w:= i + wa;
    inc(h, j + ha);
    end;

// add borders space
inc(w, wa);
inc(h, ha + 8);

tmpsurf:= SDL_CreateRGBSurface(SDL_SWSURFACE, w, h, 32, RMask, GMask, BMask, AMask);
TryDo(tmpsurf <> nil, 'RenderHelpWindow: fail to create surface', true);

// render border and background
r.x:= 0;
r.y:= 0;
r.w:= w;
r.h:= h;
DrawRoundRect(@r, cWhiteColor, cNearBlackColor, tmpsurf, true);

// render caption
r:= WriteInRect(tmpsurf, 36 + FontBorder + 2, ha, $ffffffff, font, caption);
// render sub caption
r:= WriteInRect(tmpsurf, 36 + FontBorder + 2, r.y + r.h, $ffc7c7c7, font, subcaption);

// render all description lines
tmpdesc:= description;
while tmpdesc <> '' do
    begin
    tmpline:= tmpdesc;
    SplitByChar(tmpline, tmpdesc, '|');
    r2:= r;
    if tmpline <> '' then
        begin
        r:= WriteInRect(tmpsurf, FontBorder + 2, r.y + r.h, $ff707070, font, tmpline);

        // render highlighted caption (if there's a ':')
        tmpline2:= '';
        SplitByChar(tmpline, tmpline2, ':');
        if tmpline2 <> '' then
            WriteInRect(tmpsurf, FontBorder + 2, r2.y + r2.h, $ffc7c7c7, font, tmpline + ':');
        end
    end;

if extra <> '' then
    r:= WriteInRect(tmpsurf, FontBorder + 2, r.y + r.h, extracolor, font, extra);

r.x:= FontBorder + 6;
r.y:= FontBorder + 4;
r.w:= 32;
r.h:= 32;
SDL_FillRect(tmpsurf, @r, $ffffffff);
SDL_UpperBlit(iconsurf, iconrect, tmpsurf, @r);

RenderHelpWindow:=  Surface2Tex(tmpsurf, true);
SDL_FreeSurface(tmpsurf)
end;

procedure RenderWeaponTooltip(atype: TAmmoType);
var r: TSDL_Rect;
    i: LongInt;
    extra: ansistring;
    extracolor: LongInt;
begin
    // don't do anything if the window shouldn't be shown
    if (cReducedQuality and rqTooltipsOff) <> 0 then
    begin
        WeaponTooltipTex:= nil;
        exit
    end;

// free old texture
FreeWeaponTooltip;

// image region
i:= LongInt(atype) - 1;
r.x:= (i shr 4) * 32;
r.y:= (i mod 16) * 32;
r.w:= 32;
r.h:= 32;

// default (no extra text)
extra:= '';
extracolor:= 0;

if (CurrentTeam <> nil) and (Ammoz[atype].SkipTurns >= CurrentTeam^.Clan^.TurnNumber) then // weapon or utility is not yet available
    begin
    extra:= trmsg[sidNotYetAvailable];
    extracolor:= LongInt($ffc77070);
    end
else if (Ammoz[atype].Ammo.Propz and ammoprop_NoRoundEnd) <> 0 then // weapon or utility won't end your turn
    begin
    extra:= trmsg[sidNoEndTurn];
    extracolor:= LongInt($ff70c770);
    end
else
    begin
    extra:= '';
    extracolor:= 0;
    end;

// render window and return the texture
WeaponTooltipTex:= RenderHelpWindow(trammo[Ammoz[atype].NameId], trammoc[Ammoz[atype].NameId], trammod[Ammoz[atype].NameId], extra, extracolor, SpritesData[sprAMAmmos].Surface, @r)
end;

procedure ShowWeaponTooltip(x, y: LongInt);
begin
// draw the texture if it exists
if WeaponTooltipTex <> nil then
    DrawTexture(x, y, WeaponTooltipTex)
end;

procedure FreeWeaponTooltip;
begin
// free the existing texture (if there is any)
if WeaponTooltipTex = nil then
    exit;
FreeTexture(WeaponTooltipTex);
WeaponTooltipTex:= nil
end;

procedure chFullScr(var s: shortstring);
var flags: Longword = 0;
    ico: PSDL_Surface;
    buf: array[byte] of char;
    {$IFDEF SDL13}x, y: LongInt;{$ENDIF}
begin
    s:= s; // avoid compiler hint
    if Length(s) = 0 then cFullScreen:= not cFullScreen
    else cFullScreen:= s = '1';

    buf[0]:= char(0); // avoid compiler hint
    AddFileLog('Prepare to change video parameters...');

    flags:= SDL_OPENGL;// or SDL_RESIZABLE;

    if cFullScreen then
        flags:= flags or SDL_FULLSCREEN;

{$IFDEF SDL_IMAGE_NEWER}
    WriteToConsole('Init SDL_image... ');
    SDLTry(IMG_Init(IMG_INIT_PNG) <> 0, true);
    WriteLnToConsole(msgOK);
{$ENDIF}
    // load engine icon
{$IFDEF DARWIN}
    ico:= LoadImage(Pathz[ptGraphics] + '/hwengine_mac', ifIgnoreCaps);
{$ELSE}
    ico:= LoadImage(Pathz[ptGraphics] + '/hwengine', ifIgnoreCaps);
{$ENDIF}
    if ico <> nil then
    begin
        SDL_WM_SetIcon(ico, 0);
        SDL_FreeSurface(ico)
    end;

    // set window caption
    SDL_WM_SetCaption('Hedgewars', nil);

    if SDLPrimSurface <> nil then
    begin
        AddFileLog('Freeing old primary surface...');
        SDL_FreeSurface(SDLPrimSurface);
        SDLPrimSurface:= nil;
    end;

{$IFDEF SDL13}
    if SDLwindow = nil then
    begin
        // the values in x and y make the window appear in the center
        // on ios, make the sdl window appear on the second monitor when present
        x:= (SDL_WINDOWPOS_CENTERED_MASK or {$IFDEF IPHONEOS}(SDL_GetNumVideoDisplays() - 1){$ELSE}0{$ENDIF});
        y:= (SDL_WINDOWPOS_CENTERED_MASK or {$IFDEF IPHONEOS}(SDL_GetNumVideoDisplays() - 1){$ELSE}0{$ENDIF});
        SDLwindow:= SDL_CreateWindow('Hedgewars', x, y, cScreenWidth, cScreenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_SHOWN
                          {$IFDEF IPHONEOS} or SDL_WINDOW_BORDERLESS {$ENDIF});  // do not set SDL_WINDOW_RESIZABLE on iOS
        SDLrender:= SDL_CreateRenderer(SDLwindow, -1, SDL_RENDERER_ACCELERATED or SDL_RENDERER_PRESENTVSYNC);
    end;

    SDL_SetRenderDrawColor(SDLrender, 0, 0, 0, 255);
    SDL_RenderClear(SDLrender);
    SDL_RenderPresent(SDLrender);

    // we need to reset the gl context from the one created by SDL as we have our own drawing system
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
{$ELSE}
    if not cOnlyStats then
        begin
        SDLPrimSurface:= SDL_SetVideoMode(cScreenWidth, cScreenHeight, cBits, flags);
        SDLTry(SDLPrimSurface <> nil, true);
        end;
{$ENDIF}

    AddFileLog('Setting up OpenGL (using driver: ' + shortstring(SDL_VideoDriverName(buf, sizeof(buf))) + ')');
    SetupOpenGL();
end;

procedure initModule;
var ai: TAmmoType;
    i: LongInt;
begin
    RegisterVariable('fullscr', vtCommand, @chFullScr, true);

    SDLPrimSurface:= nil;

{$IFNDEF IPHONEOS}
    rotationQt:= 0;
    cGPUVendor:= gvUnknown;
{$ENDIF}

    cScaleFactor:= 2.0;
    SupportNPOTT:= false;
    Step:= 0;
    ProgrTex:= nil;

    // init all ammo name texture pointers
    for ai:= Low(TAmmoType) to High(TAmmoType) do
    begin
        Ammoz[ai].NameTex := nil;
    end;
    // init all count texture pointers
    for i:= Low(CountTexz) to High(CountTexz) do
    begin
        CountTexz[i] := nil;
    end;
end;

procedure freeModule;
begin
end;

end.
