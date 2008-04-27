(*
 * Hedgewars, a worms-like game
 * Copyright (c) 2004-2008 Andrey Korotaev <unC0Rr@gmail.com>
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

unit uGame;
interface
uses uFloat;
{$INCLUDE options.inc}

procedure DoGameTick(Lag: LongInt);

////////////////////
   implementation
////////////////////
uses uMisc, uConsts, uWorld, uKeys, uTeams, uIO, uAI, uGears, uConsole;

procedure DoGameTick(Lag: LongInt);
const SendEmptyPacketTicks: LongWord = 0;
var i: LongInt;
begin
if isPaused then exit;
if not CurrentTeam^.ExtDriven then
   begin
   NetGetNextCmd; // its for the case of receiving "/say" message
   isInLag:= false;
   inc(SendEmptyPacketTicks, Lag);
   if SendEmptyPacketTicks >= cSendEmptyPacketTime then
      begin
      SendIPC('+');
      SendEmptyPacketTicks:= 0
      end
   end;
if Lag > 100 then Lag:= 100
else if GameType = gmtSave then Lag:= 2500;
if (GameType = gmtDemo) and isSpeed then Lag:= Lag * 10;

i:= 1;
while (GameState <> gsExit) and (i <= Lag) do
    begin
    if not CurrentTeam^.ExtDriven then
       begin
       if CurrentHedgehog^.BotLevel <> 0 then ProcessBot;
       ProcessGears
       end else
       begin
       NetGetNextCmd;
       if isInLag then
          case GameType of
                gmtNet: break;
               gmtDemo: begin
                        GameState:= gsExit;
                        exit
                        end;
               gmtSave: begin
                        RestoreTeamsFromSave;
                        SetBinds(CurrentTeam^.Binds);
                        CurrentHedgehog^.Gear^.Message:= 0;
                        isSoundEnabled:= isSEBackup;
                        GameType:= gmtLocal
                        end;
               end
          else ProcessGears
       end;
    inc(i)
    end
end;

end.
