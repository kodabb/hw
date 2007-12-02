(*
 * Hedgewars, a worms-like game
 * Copyright (c) 2004-2007 Andrey Korotaev <unC0Rr@gmail.com>
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

unit uConsole;
interface
uses SDLh, uFloat;
{$INCLUDE options.inc}
const isDeveloperMode: boolean = true;
type TVariableType = (vtCommand, vtLongInt, vthwFloat, vtBoolean);
     TCommandHandler = procedure (var params: shortstring);

procedure DrawConsole(Surface: PSDL_Surface);
procedure WriteToConsole(s: shortstring);
procedure WriteLnToConsole(s: shortstring);
procedure KeyPressConsole(Key: Longword);
procedure ParseCommand(CmdStr: shortstring; TrustedSource: boolean);
function  GetLastConsoleLine: shortstring;

procedure doPut(putX, putY: LongInt; fromAI: boolean);

implementation
{$J+}
uses uMisc, uStore, Types, uConsts, uGears, uTeams, uIO, uKeys, uWorld, uLand,
     uRandom, uAmmos, uTriggers;
const cLineWidth: LongInt = 0;
      cLinesCount = 256;

type  PVariable = ^TVariable;
      TVariable = record
                     Next: PVariable;
                     Name: string[15];
                    VType: TVariableType;
                  Handler: pointer;
                  Trusted: boolean;
                  end;

var   ConsoleLines: array[byte] of ShortString;
      CurrLine: LongInt = 0;
      InputStr: shortstring;
      Variables: PVariable = nil;

function RegisterVariable(Name: string; VType: TVariableType; p: pointer; Trusted: boolean): PVariable;
var Result: PVariable;
begin
New(Result);
TryDo(Result <> nil, 'RegisterVariable: Result = nil', true);
FillChar(Result^, sizeof(TVariable), 0);
Result^.Name:= Name;
Result^.VType:= VType;
Result^.Handler:= p;
Result^.Trusted:= Trusted;

if Variables = nil then Variables:= Result
                   else begin
                        Result^.Next:= Variables;
                        Variables:= Result
                        end;

RegisterVariable:= Result
end;

procedure FreeVariablesList;
var t, tt: PVariable;
begin
tt:= Variables;
Variables:= nil;
while tt <> nil do
      begin
      t:= tt;
      tt:= tt^.Next;
      Dispose(t)
      end;
end;

procedure SplitBySpace(var a, b: shortstring);
var i, t: LongInt;
begin
i:= Pos(' ', a);
if i>0 then
   begin
   for t:= 1 to Pred(i) do
       if (a[t] >= 'A')and(a[t] <= 'Z') then Inc(a[t], 32);
   b:= copy(a, i + 1, Length(a) - i);
   while (b[0]<>#0) and (b[1]=#32) do Delete(b, 1, 1);
   byte(a[0]):= Pred(i)
   end else b:= '';
end;

procedure DrawConsole(Surface: PSDL_Surface);
var x, y: LongInt;
    r: TSDL_Rect;
begin
with r do
     begin
     x:= 0;
     y:= cConsoleHeight;
     w:= cScreenWidth;
     h:= 4;
     end;
SDL_FillRect(Surface, @r, cConsoleSplitterColor);
for y:= 0 to cConsoleHeight div 256 + 1 do
    for x:= 0 to cScreenWidth div 256 + 1 do
        DrawGear(sConsoleBG, x * 256, cConsoleHeight - 256 - y * 256, Surface);
for y:= 0 to cConsoleHeight div Fontz[fnt16].Height do
    DXOutText(4, cConsoleHeight - (y + 2) * (Fontz[fnt16].Height + 2), fnt16, ConsoleLines[(CurrLine - 1 - y + cLinesCount) mod cLinesCount], Surface);
DXOutText(4, cConsoleHeight - Fontz[fnt16].Height - 2, fnt16, '> '+InputStr, Surface);
end;

procedure WriteToConsole(s: shortstring);
var Len: LongInt;
begin
{$IFDEF DEBUGFILE}AddFileLog('Console write: ' + s);{$ENDIF}
Write(s);
repeat
Len:= cLineWidth - Length(ConsoleLines[CurrLine]);
ConsoleLines[CurrLine]:= ConsoleLines[CurrLine] + copy(s, 1, Len);
Delete(s, 1, Len);
if byte(ConsoleLines[CurrLine][0])=cLineWidth then
   begin
   inc(CurrLine);
   if CurrLine = cLinesCount then CurrLine:= 0;
   PLongWord(@ConsoleLines[CurrLine])^:= 0
   end;
until Length(s) = 0
end;

procedure WriteLnToConsole(s: shortstring);
begin
WriteToConsole(s);
WriteLn;
inc(CurrLine);
if CurrLine = cLinesCount then CurrLine:= 0;
PLongWord(@ConsoleLines[CurrLine])^:= 0
end;

procedure InitConsole;
var i: LongInt;
begin
cLineWidth:= cScreenWidth div 10;
if cLineWidth > 255 then cLineWidth:= 255;
for i:= 0 to Pred(cLinesCount) do PLongWord(@ConsoleLines[i])^:= 0
end;

procedure ParseCommand(CmdStr: shortstring; TrustedSource: boolean);
type PhwFloat = ^hwFloat;
var ii: LongInt;
    s: shortstring;
    t: PVariable;
    c: char;
begin
//WriteLnToConsole(CmdStr);
if CmdStr[0]=#0 then exit;
{$IFDEF DEBUGFILE}AddFileLog('ParseCommand "' + CmdStr + '"');{$ENDIF}
c:= CmdStr[1];
if c in ['/', '$'] then Delete(CmdStr, 1, 1) else c:= '/';
SplitBySpace(CmdStr, s);
t:= Variables;
while t <> nil do
      begin
      if t^.Name = CmdStr then
         begin
         if TrustedSource or t^.Trusted then
            case t^.VType of
              vtCommand: if c='/' then
                         begin
                         TCommandHandler(t^.Handler)(s);
                         end;
              vtLongInt: if c='$' then
                         if s[0]=#0 then
                            begin
                            str(PLongInt(t^.Handler)^, s);
                            WriteLnToConsole('$' + CmdStr + ' is "' + s + '"');
                            end else val(s, PLongInt(t^.Handler)^);
              vthwFloat: if c='$' then
                         if s[0]=#0 then
                            begin
                            //str(PhwFloat(t^.Handler)^:4:6, s);
                            WriteLnToConsole('$' + CmdStr + ' is "' + s + '"');
                            end else; //val(s, PhwFloat(t^.Handler)^, i);
             vtBoolean: if c='$' then
                         if s[0]=#0 then
                            begin
                            str(ord(boolean(t^.Handler^)), s);
                            WriteLnToConsole('$' + CmdStr + ' is "' + s + '"');
                            end else
                            begin
                            val(s, ii);
                            boolean(t^.Handler^):= not (ii = 0)
                            end;
              end;
         exit
         end else t:= t^.Next
      end;
case c of
     '$': WriteLnToConsole(errmsgUnknownVariable + ': "$' + CmdStr + '"')
     else WriteLnToConsole(errmsgUnknownCommand  + ': "/' + CmdStr + '"') end
end;

procedure AutoComplete;
var t: PVariable;
    c: char;
begin
if InputStr[0] = #0 then exit;
c:= InputStr[1];
if c in ['/', '$'] then Delete(InputStr, 1, 1)
                   else c:= #0;
if InputStr[byte(InputStr[0])] = #32 then dec(InputStr[0]);
t:= Variables;
while t <> nil do
      begin
      if (c=#0) or ((t^.VType =  vtCommand) and (c='/'))or
                   ((t^.VType <> vtCommand) and (c='$'))then
         if copy(t^.Name, 1, Length(InputStr)) = InputStr then
            begin
            if t^.VType = vtCommand then InputStr:= '/' + t^.Name + ' '
                                    else InputStr:= '$' + t^.Name + ' ';
            exit
            end;
      t:= t^.Next
      end
end;

procedure KeyPressConsole(Key: Longword);
const firstByteMark: array[1..4] of byte = (0, $C0, $E0, $F0);
var i, btw: integer;
    utf8: shortstring;
begin
if Key <> 0 then
  case Key of
      8: if Length(InputStr)>0 then dec(InputStr[0]);
      9: AutoComplete;
 13,271: begin
         if InputStr[1] in ['/', '$'] then
            ParseCommand(InputStr, false)
         else
            ParseCommand('/say ' + InputStr, false);
         InputStr:= ''
         end
     else
     if (Key < $80) then btw:= 1
     else if (Key < $800) then btw:= 2
     else if (Key < $10000) then btw:= 3
     else btw:= 4;
     utf8:= '';
     for i:= btw downto 2 do
         begin
         utf8:= char((Key or $80) and $BF) + utf8;
         Key:= Key shr 6
         end;
     utf8:= char(Key or firstByteMark[btw]) + utf8;
     InputStr:= InputStr + utf8
     end
end;

function GetLastConsoleLine: shortstring;
begin
if CurrLine = 0 then GetLastConsoleLine:= ConsoleLines[Pred(cLinesCount)]
                else GetLastConsoleLine:= ConsoleLines[Pred(CurrLine)]
end;

{$INCLUDE CCHandlers.inc}

initialization
InitConsole;
RegisterVariable('quit'    , vtCommand, @chQuit         , true );
RegisterVariable('proto'   , vtCommand, @chCheckProto   , true );
RegisterVariable('capture' , vtCommand, @chCapture      , true );
RegisterVariable('rotmask' , vtCommand, @chRotateMask   , true );
RegisterVariable('addteam' , vtCommand, @chAddTeam      , false);
RegisterVariable('addtrig' , vtCommand, @chAddTrigger   , false);
RegisterVariable('rdriven' , vtCommand, @chTeamLocal    , false);
RegisterVariable('map'     , vtCommand, @chSetMap       , false);
RegisterVariable('theme'   , vtCommand, @chSetTheme     , false);
RegisterVariable('seed'    , vtCommand, @chSetSeed      , false);
RegisterVariable('delay'   , vtLongInt, @cInactDelay    , false);
RegisterVariable('casefreq', vtLongInt, @cCaseFactor    , false);
RegisterVariable('landadds', vtLongInt, @cLandAdditions , false);
RegisterVariable('c_height', vtLongInt, @cConsoleHeight , false);
RegisterVariable('gmflags' , vtLongInt, @GameFlags      , false);
RegisterVariable('turntime', vtLongInt, @cHedgehogTurnTime, false);
RegisterVariable('fort'    , vtCommand, @chFort         , false);
RegisterVariable('grave'   , vtCommand, @chGrave        , false);
RegisterVariable('bind'    , vtCommand, @chBind         , true );
RegisterVariable('addhh'   , vtCommand, @chAddHH        , false);
RegisterVariable('hhcoords', vtCommand, @chSetHHCoords  , false);
RegisterVariable('ammstore', vtCommand, @chAddAmmoStore , false);
RegisterVariable('+speedup', vtCommand, @chSpeedup_p    , true );
RegisterVariable('-speedup', vtCommand, @chSpeedup_m    , true );
RegisterVariable('skip'    , vtCommand, @chSkip         , false);
RegisterVariable('say'     , vtCommand, @chSay          , true );
RegisterVariable('ammomenu', vtCommand, @chAmmoMenu     , false);
RegisterVariable('+left'   , vtCommand, @chLeft_p       , false);
RegisterVariable('-left'   , vtCommand, @chLeft_m       , false);
RegisterVariable('+right'  , vtCommand, @chRight_p      , false);
RegisterVariable('-right'  , vtCommand, @chRight_m      , false);
RegisterVariable('+up'     , vtCommand, @chUp_p         , false);
RegisterVariable('-up'     , vtCommand, @chUp_m         , false);
RegisterVariable('+down'   , vtCommand, @chDown_p       , false);
RegisterVariable('-down'   , vtCommand, @chDown_m       , false);
RegisterVariable('+attack' , vtCommand, @chAttack_p     , false);
RegisterVariable('-attack' , vtCommand, @chAttack_m     , false);
RegisterVariable('switch'  , vtCommand, @chSwitch       , false);
RegisterVariable('nextturn', vtCommand, @chNextTurn     , false);
RegisterVariable('timer'   , vtCommand, @chTimer        , false);
RegisterVariable('slot'    , vtCommand, @chSlot         , false);
RegisterVariable('put'     , vtCommand, @chPut          , false);
RegisterVariable('ljump'   , vtCommand, @chLJump        , false);
RegisterVariable('hjump'   , vtCommand, @chHJump        , false);
RegisterVariable('fullscr' , vtCommand, @chFullScr      , true );
RegisterVariable('+volup'  , vtCommand, @chVol_p        , true );
RegisterVariable('-volup'  , vtCommand, @chVol_m        , true );
RegisterVariable('+voldown', vtCommand, @chVol_m        , true );
RegisterVariable('-voldown', vtCommand, @chVol_p        , true );
RegisterVariable('findhh'  , vtCommand, @chFindhh       , true );
RegisterVariable('pause'   , vtCommand, @chPause        , true );

finalization
FreeVariablesList

end.
