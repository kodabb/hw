 (*
 * Hedgewars, a free turn based strategy game
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

{$IFNDEF FPC}
WriteLn('Only Freepascal supported');
{$ENDIF}

// Add all your Pascal units to the "uses" clause below to add them to the program.

// Mark all Pascal procedures/functions that you wish to call from C/C++/Objective-C code using
// "cdecl; export;" (see the fpclogo.pas unit for an example), and then add C-declarations for
// these procedures/functions to the PascalImports.h file (also in the "Pascal Sources" group)
// to make these functions available in the C/C++/Objective-C source files
// (add "#include PascalImports.h" near the top of these files if it's not there yet)
//Library PascalLibrary;
program hwengine;
uses
	SDLh in 'SDLh.pas',
{$IFDEF IPHONE}
	gles11,
{$ELSE}
	GL,
{$ENDIF}
	uConsts in 'uConsts.pas',
	uGame in 'uGame.pas',
	uMisc in 'uMisc.pas',
	uStore in 'uStore.pas',
	uWorld in 'uWorld.pas',
	uIO in 'uIO.pas',
	uGears in 'uGears.pas',
	uVisualGears in 'uVisualGears.pas',
	uConsole in 'uConsole.pas',
	uKeys in 'uKeys.pas',
	uTeams in 'uTeams.pas',
	uSound in 'uSound.pas',
	uRandom in 'uRandom.pas',
	uAI in 'uAI.pas',
	uAIMisc in 'uAIMisc.pas',
	uAIAmmoTests in 'uAIAmmoTests.pas',
	uAIActions in 'uAIActions.pas',
	uCollisions in 'uCollisions.pas',
	uLand in 'uLand.pas',
	uLandTemplates in 'uLandTemplates.pas',
	uLandObjects in 'uLandObjects.pas',
	uLandGraphics in 'uLandGraphics.pas',
	uLocale in 'uLocale.pas',
	uAmmos in 'uAmmos.pas',
	uSHA in 'uSHA.pas',
	uFloat in 'uFloat.pas',
	uStats in 'uStats.pas',
	uChat in 'uChat.pas',
	uLandTexture;

{$INCLUDE options.inc}

// also: GSHandlers.inc
//       CCHandlers.inc
//       HHHandlers.inc
//       SinTable.inc
//       proto.inc

var recordFileName : shortstring = '';

procedure OnDestroy; forward;

////////////////////////////////
procedure DoTimer(Lag: LongInt);
var s: string;
begin
inc(RealTicks, Lag);

case GameState of
	gsLandGen: begin
			GenMap;
			GameState:= gsStart;
			end;
	gsStart: begin
			if HasBorder then DisableSomeWeapons;
			AddClouds;
			AssignHHCoords;
			AddMiscGears;
			StoreLoad;
            InitWorld;
			ResetKbd;
			SoundLoad;
			if GameType = gmtSave then
				begin
				isSEBackup:= isSoundEnabled;
				isSoundEnabled:= false
				end;
			FinishProgress;
			PlayMusic;
			GameState:= gsGame
			end;
	gsConfirm,
	gsGame: begin
			DrawWorld(Lag); // never place between ProcessKbd and DoGameTick - bugs due to /put cmd and isCursorVisible
			ProcessKbd;
			DoGameTick(Lag);
			ProcessVisualGears(Lag);
			end;
	gsChat: begin
			DrawWorld(Lag);
			DoGameTick(Lag);
			ProcessVisualGears(Lag);
			end;
	gsExit: begin
			OnDestroy;
			end;
	end;

SDL_GL_SwapBuffers();
if flagMakeCapture then
	begin
	flagMakeCapture:= false;
	s:= 'hw_' + cSeed + '_' + inttostr(GameTicks) + '.tga';
	WriteLnToConsole('Saving ' + s);
	MakeScreenshot(s);
//	SDL_SaveBMP_RW(SDLPrimSurface, SDL_RWFromFile(Str2PChar(s), 'wb'), 1)
	end;
end;

////////////////////
procedure OnDestroy;
begin
{$IFDEF DEBUGFILE}AddFileLog('Freeing resources...');{$ENDIF}
if isSoundEnabled then ReleaseSound;
StoreRelease;
FreeLand;
SendKB;
CloseIPC;
TTF_Quit;
SDL_Quit;
halt
end;

////////////////////////////////
procedure Resize(w, h: LongInt);
begin
cScreenWidth:= w;
cScreenHeight:= h;
if cFullScreen then
	ParseCommand('/fullscr 1', true)
else
	ParseCommand('/fullscr 0', true);
end;

///////////////////
procedure MainLoop;
var PrevTime,
    CurrTime: Longword;
    event: TSDL_Event;
begin
PrevTime:= SDL_GetTicks;
repeat
while SDL_PollEvent(@event) <> 0 do
	case event.type_ of
		SDL_KEYDOWN: if GameState = gsChat then KeyPressChat(event.key.keysym.unicode);
		SDL_ACTIVEEVENT: if (event.active.state and SDL_APPINPUTFOCUS) <> 0 then
				cHasFocus:= event.active.gain = 1;
		//SDL_VIDEORESIZE: Resize(max(event.resize.w, 600), max(event.resize.h, 450));
		SDL_QUITEV: isTerminated:= true
		end;
CurrTime:= SDL_GetTicks;
if PrevTime + cTimerInterval <= CurrTime then
   begin
   DoTimer(CurrTime - PrevTime);
   PrevTime:= CurrTime
   end else SDL_Delay(1);
IPCCheckSock
until isTerminated
end;

////////////////////
procedure GetParams;
var
{$IFDEF DEBUGFILE}
    i: LongInt;
{$ENDIF}
    p: TPathType;
begin
{$IFDEF DEBUGFILE}
AddFileLog('Prefix: "' + PathPrefix +'"');
for i:= 0 to ParamCount do
    AddFileLog(inttostr(i) + ': ' + ParamStr(i));
{$ENDIF}

case ParamCount of
 16: begin
     val(ParamStr(2), cScreenWidth);
     val(ParamStr(3), cScreenHeight);
     cInitWidth:= cScreenWidth;
     cInitHeight:= cScreenHeight;
     cBitsStr:= ParamStr(4);
     val(cBitsStr, cBits);
     val(ParamStr(5), ipcPort);
     cFullScreen:= ParamStr(6) = '1';
     isSoundEnabled:= ParamStr(7) = '1';
     cLocaleFName:= ParamStr(8);
     val(ParamStr(9), cInitVolume);
     val(ParamStr(10), cTimerInterval);
     PathPrefix:= ParamStr(11);
     cShowFPS:= ParamStr(12) = '1';
     cAltDamage:= ParamStr(13) = '1';
     UserNick:= DecodeBase64(ParamStr(14));
     isMusicEnabled:= ParamStr(15) = '1';
     cReducedQuality:= ParamStr(16) = '1';
     for p:= Succ(Low(TPathType)) to High(TPathType) do
         if p <> ptMapCurrent then Pathz[p]:= PathPrefix + '/' + Pathz[p]
     end;
  3: begin
     val(ParamStr(2), ipcPort);
     GameType:= gmtLandPreview;
     if ParamStr(3) <> 'landpreview' then OutError(errmsgShouldntRun, true);
     end;
 14: begin
     PathPrefix:= ParamStr(1);
     recordFileName:= ParamStr(2);
     val(ParamStr(3), cScreenWidth);
     val(ParamStr(4), cScreenHeight);
     cInitWidth:= cScreenWidth;
     cInitHeight:= cScreenHeight;
     cBitsStr:= ParamStr(5);
     val(cBitsStr, cBits);
     cFullScreen:= ParamStr(6) = '1';
     isSoundEnabled:= ParamStr(7) = '1';
     cLocaleFName:= ParamStr(8);
     val(ParamStr(9), cInitVolume);
     val(ParamStr(10), cTimerInterval);
     cShowFPS:= ParamStr(11) = '1';
     cAltDamage:= ParamStr(12) = '1';
     isMusicEnabled:= ParamStr(13) = '1';
     cReducedQuality:= ParamStr(14) = '1';
     for p:= Succ(Low(TPathType)) to High(TPathType) do
         if p <> ptMapCurrent then Pathz[p]:= PathPrefix + '/' + Pathz[p]
     end;
   else
   OutError(errmsgShouldntRun, true)
   end
end;

procedure ShowMainWindow;
begin
if cFullScreen then ParseCommand('fullscr 1', true)
               else ParseCommand('fullscr 0', true);
SDL_ShowCursor(0)
end;

///////////////
procedure Game;
var s: shortstring;
begin
WriteToConsole('Init SDL... ');
SDLTry(SDL_Init(SDL_INIT_VIDEO) >= 0, true);
WriteLnToConsole(msgOK);

SDL_EnableUNICODE(1);

WriteToConsole('Init SDL_ttf... ');
SDLTry(TTF_Init <> -1, true);
WriteLnToConsole(msgOK);

ShowMainWindow;

InitKbdKeyTable;

if recordFileName = '' then InitIPC;
WriteLnToConsole(msgGettingConfig);

LoadLocale(Pathz[ptLocale] + '/' + cLocaleFName);

if recordFileName = '' then
	SendIPCAndWaitReply('C')        // ask for game config
else
	LoadRecordFromFile(recordFileName);

s:= 'eproto ' + inttostr(cNetProtoVersion);
SendIPCRaw(@s[0], Length(s) + 1); // send proto version

InitTeams;
AssignStores;

if isSoundEnabled then InitSound;

StoreInit;

isDeveloperMode:= false;

TryDo(InitStepsFlags = cifAllInited,
      'Some parameters not set (flags = ' + inttostr(InitStepsFlags) + ')',
      true);

MainLoop
end;

/////////////////////////
procedure GenLandPreview;
var Preview: TPreview;
	h: byte;
begin
InitIPC;
IPCWaitPongEvent;
TryDo(InitStepsFlags = cifRandomize,
      'Some parameters not set (flags = ' + inttostr(InitStepsFlags) + ')',
      true);

Preview:= GenPreview;
WriteLnToConsole('Sending preview...');
SendIPCRaw(@Preview, sizeof(Preview));
h:= MaxHedgehogs;
SendIPCRaw(@h, sizeof(h));
WriteLnToConsole('Preview sent, disconnect');
CloseIPC
end;

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// m a i n ////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

begin
WriteLnToConsole('-= Hedgewars ' + cVersionString + ' =-');
WriteLnToConsole('   -= by unC0Rr =-   ');
GetParams;
Randomize;
{ /home/nemo/games/bin/hwengine /home/nemo/games/hedgewars/Data ~/.hedgewars/Saves/2009-03-22_19-54.hws_24 480 320 32 0 1 en.txt 128 33 0 1 1 0}
if GameType = gmtLandPreview then GenLandPreview
                             else Game
end.
