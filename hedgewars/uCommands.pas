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

unit uCommands;

interface

var isDeveloperMode: boolean;
type TVariableType = (vtCommand, vtLongInt, vtBoolean);
    TCommandHandler = procedure (var params: shortstring);

procedure initModule;
procedure freeModule;
procedure RegisterVariable(Name: shortstring; VType: TVariableType; p: pointer; Trusted: boolean);
procedure ParseCommand(CmdStr: shortstring; TrustedSource: boolean);
procedure StopMessages(Message: Longword);

implementation
uses Types, uConsts, uVariables, uConsole, uUtils, uDebug;

type  PVariable = ^TVariable;
    TVariable = record
        Next: PVariable;
        Name: string[15];
        VType: TVariableType;
        Handler: pointer;
        Trusted: boolean;
        end;

var
    Variables: PVariable;

procedure RegisterVariable(Name: shortstring; VType: TVariableType; p: pointer; Trusted: boolean);
var
    value: PVariable;
begin
New(value);
TryDo(value <> nil, 'RegisterVariable: value = nil', true);
FillChar(value^, sizeof(TVariable), 0);
value^.Name:= Name;
value^.VType:= VType;
value^.Handler:= p;
value^.Trusted:= Trusted;

if Variables = nil then
    Variables:= value
else
    begin
    value^.Next:= Variables;
    Variables:= value
    end;
end;


procedure ParseCommand(CmdStr: shortstring; TrustedSource: boolean);
var ii: LongInt;
    s: shortstring;
    t: PVariable;
    c: char;
begin
//WriteLnToConsole(CmdStr);
if CmdStr[0]=#0 then
    exit;
c:= CmdStr[1];
if (c = '/') or (c = '$') then
    Delete(CmdStr, 1, 1)
else
    c:= '/';
s:= '';
SplitBySpace(CmdStr, s);
AddFileLog('[Cmd] ' + c + CmdStr + ' (' + inttostr(length(s)) + ')');
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
                        end
                    else
                        val(s, PLongInt(t^.Handler)^);
                vtBoolean: if c='$' then
                    if s[0]=#0 then
                        begin
                        str(ord(boolean(t^.Handler^)), s);
                        WriteLnToConsole('$' + CmdStr + ' is "' + s + '"');
                        end
                    else
                        begin
                        val(s, ii);
                        boolean(t^.Handler^):= not (ii = 0)
                        end;
                end;
            exit
            end
        else
            t:= t^.Next
        end;
case c of
    '$': WriteLnToConsole(errmsgUnknownVariable + ': "$' + CmdStr + '"')
    else
        WriteLnToConsole(errmsgUnknownCommand  + ': "/' + CmdStr + '"') end
end;


procedure StopMessages(Message: Longword);
begin
if (Message and gmLeft) <> 0 then
    ParseCommand('/-left', true)
else if (Message and gmRight) <> 0 then
    ParseCommand('/-right', true) 
else if (Message and gmUp) <> 0 then
    ParseCommand('/-up', true)
else if (Message and gmDown) <> 0 then
    ParseCommand('/-down', true)
else if (Message and gmAttack) <> 0 then
    ParseCommand('/-attack', true)
end;

procedure initModule;
begin
    Variables:= nil;
    isDeveloperMode:= true;
end;

procedure freeModule;
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

end.
