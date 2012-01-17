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

unit uMobile;
interface

{$IFDEF IPHONEOS}
(*  iOS calls written in ObjcExports.m  *)
procedure clearView; cdecl; external;
procedure startLoadingIndicator; cdecl; external;
procedure stopLoadingIndicator; cdecl; external;
procedure saveFinishedSynching; cdecl; external;
procedure updateVisualsNewTurn; cdecl; external;
function  isApplePhone: Boolean; cdecl; external;
procedure AudioServicesPlaySystemSound(num: LongInt); cdecl; external;
{$ENDIF}
function  isPhone: Boolean; inline;
procedure performRumble; inline;

procedure GameLoading; inline;
procedure GameLoaded; inline;
procedure AmmoUpdate; // do not inline
procedure NewTurnBeginning; inline;
procedure SaveLoadingEnded; inline;

implementation
uses uVariables;

// this function is just to determine whether we are running on a limited screen device
function isPhone: Boolean; inline;
begin
{$IFDEF IPHONEOS}
    exit(isApplePhone());
{$ENDIF}
    exit(false);
end;

// this function should make the device vibrate in some way
procedure performRumble; inline;
const kSystemSoundID_Vibrate = $00000FFF;
begin
    // do not vibrate while synchronising a demo/save
    if not fastUntilLag then
        begin
{$IFDEF IPHONEOS}
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
{$ENDIF}
        end;
end;

procedure GameLoading; inline;
begin
{$IFDEF IPHONEOS}
    startLoadingIndicator();
{$ENDIF}
end;

procedure GameLoaded; inline;
begin
{$IFDEF IPHONEOS}
    stopLoadingIndicator();
{$ENDIF}
end;

procedure AmmoUpdate; // do not inline
begin
{$IFDEF IPHONEOS}
    if (CurrentTeam = nil) or (CurrentTeam^.ExtDriven) or (CurrentTeam^.Hedgehogs[0].BotLevel <> 0) then
        exit(); // the other way around throws a compiler error
    updateVisualsNewTurn();
{$ENDIF}
end;

procedure NewTurnBeginning; inline;
begin
{$IFDEF IPHONEOS}
    clearView();
{$ENDIF}
    AmmoUpdate();
end;

procedure SaveLoadingEnded; inline;
begin
{$IFDEF IPHONEOS}
    saveFinishedSynching();
{$ENDIF}
end;


end.
