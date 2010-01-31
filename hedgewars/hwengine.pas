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

{$INCLUDE "options.inc"}

{$IFDEF IPHONEOS}
unit hwengine;
interface
{$ELSE}
program hwengine;
{$ENDIF}
uses	SDLh in 'SDLh.pas',
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
	uTriggers in 'uTriggers.pas',
	uLandTexture in 'uLandTexture.pas'
	{$IFDEF IPHONEOS}
	, PascalExports in 'PascalExports.pas'
	{$ELSE}
	, sysutils
	{$ENDIF}
	;

// also: GSHandlers.inc
//       CCHandlers.inc
//       HHHandlers.inc
//       SinTable.inc
//       proto.inc

{$IFDEF IPHONEOS}
type arrayofpchar = array[0..6] of PChar;
procedure DoTimer(Lag: LongInt);
procedure OnDestroy;
procedure MainLoop;
procedure ShowMainWindow;
procedure Game(gameArgs: arrayofpchar); cdecl; export;
procedure initEverything;
procedure freeEverything;

implementation

{$ELSE}
procedure OnDestroy; forward;
procedure freeEverything; forward;
{$ENDIF}

////////////////////////////////
procedure DoTimer(Lag: LongInt);
{$IFNDEF IPHONEOS}
var s: string;
{$ENDIF}
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
				SetScale(zoom);
				GameState:= gsGame;
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
				isTerminated:= true;
				end;
		end;

	SDL_GL_SwapBuffers();
{$IFDEF SDL13}
	SDL_RenderPresent();
{$ENDIF}
{$IFNDEF IPHONEOS}
	// not going to make captures on the iPhone
	if flagMakeCapture then
	begin
		flagMakeCapture:= false;
		s:= 'hw_' + FormatDateTime('YYYY-MM-DD_HH-mm-ss', Now()) + inttostr(GameTicks);
		WriteLnToConsole('Saving ' + s + '...');
		MakeScreenshot(s);
		//SDL_SaveBMP_RW(SDLPrimSurface, SDL_RWFromFile(Str2PChar(s), 'wb'), 1)
	end;
{$ENDIF}
end;

////////////////////
procedure OnDestroy;
begin
	WriteLnToConsole('Freeing resources...');
	if isSoundEnabled then ReleaseSound();
	StoreRelease();
	FreeLand();
	ControllerClose();
	SendKB();
	CloseIPC();
	TTF_Quit();
	{$IFDEF SDL13}SDL_VideoQuit();{$ENDIF}
	SDL_Quit();
	freeEverything();
	exit();
end;

///////////////////
procedure MainLoop; 
var PrevTime, CurrTime: Longword;
    {$IFNDEF IPHONEOS}event: TSDL_Event;{$ENDIF}
begin
	PrevTime:= SDL_GetTicks;
	repeat
{$IFNDEF IPHONEOS}
// have to remove this cycle because otherwise it segfaults at exit
		while SDL_PollEvent(@event) <> 0 do
		begin
			case event.type_ of
				SDL_KEYDOWN: if GameState = gsChat then KeyPressChat(event.key.keysym.unicode);
{$IFDEF SDL13}
				SDL_WINDOWEVENT:
{$ELSE}
				SDL_ACTIVEEVENT:
{$ENDIF}
					if (event.active.state and SDL_APPINPUTFOCUS) <> 0 then
						cHasFocus:= event.active.gain = 1;
				//SDL_VIDEORESIZE: Resize(max(event.resize.w, 600), max(event.resize.h, 450));
				SDL_MOUSEBUTTONDOWN: if event.button.button = SDL_BUTTON_WHEELDOWN then uKeys.wheelDown:= true;
				SDL_MOUSEBUTTONUP: if event.button.button = SDL_BUTTON_WHEELUP then uKeys.wheelUp:= true;
				SDL_JOYAXISMOTION: ControllerAxisEvent(event.jaxis.which, event.jaxis.axis, event.jaxis.value);
				SDL_JOYHATMOTION: ControllerHatEvent(event.jhat.which, event.jhat.hat, event.jhat.value);
				SDL_JOYBUTTONDOWN: ControllerButtonEvent(event.jbutton.which, event.jbutton.button, true);
				SDL_JOYBUTTONUP: ControllerButtonEvent(event.jbutton.which, event.jbutton.button, false);
				SDL_QUITEV: isTerminated:= true
			end; // end case event.type_ of
		end; // end while SDL_PollEvent(@event) <> 0 do
{$ENDIF}
		CurrTime:= SDL_GetTicks;
		if PrevTime + cTimerInterval <= CurrTime then
		begin
			DoTimer(CurrTime - PrevTime);
			PrevTime:= CurrTime
		end else SDL_Delay(1);
		if isTerminated = false then IPCCheckSock();
	until isTerminated;

	exit();
end;

/////////////////////////
procedure ShowMainWindow;
begin
	if cFullScreen then ParseCommand('fullscr 1', true)
	else ParseCommand('fullscr 0', true);
	SDL_ShowCursor(0)
end;

///////////////
{$IFDEF IPHONEOS}
procedure Game(gameArgs: arrayofpchar); cdecl; export;
{$ELSE}
procedure Game;cdecl; export;
{$ENDIF}
var	p: TPathType;
	s: shortstring;
begin
{$IFDEF IPHONEOS}
	initEverything();
	Randomize();

	val('480', cScreenWidth);
	val('320', cScreenHeight);
	cInitWidth:= cScreenWidth;
	cInitHeight:= cScreenHeight;
	cBitsStr:= '32';
	val(cBitsStr, cBits);
	cFullScreen:= false;
	cVSyncInUse:= true;
	val('8', cTimerInterval);
	PathPrefix:= 'Data';
	cReducedQuality:= false;
	cShowFPS:= true;

	UserNick:= gameArgs[0];
	val(gameArgs[1], ipcPort);
	isSoundEnabled:= gameArgs[2] = '1';
	isMusicEnabled:= gameArgs[3] = '1';
	cLocaleFName:= gameArgs[4];
	val(gameArgs[5], cInitVolume);
	cAltDamage:= gameArgs[6] = '1';
{$ENDIF}

	for p:= Succ(Low(TPathType)) to High(TPathType) do
		if p <> ptMapCurrent then Pathz[p]:= PathPrefix + '/' + Pathz[p];
		
	WriteToConsole('Init SDL... ');
	SDLTry(SDL_Init(SDL_INIT_VIDEO) >= 0, true);
	WriteLnToConsole(msgOK);

	SDL_EnableUNICODE(1);

	WriteToConsole('Init SDL_ttf... ');
	SDLTry(TTF_Init() <> -1, true);
	WriteLnToConsole(msgOK);

	ShowMainWindow();

	AddProgress();

	ControllerInit(); // has to happen before InitKbdKeyTable to map keys
	InitKbdKeyTable();

	if recordFileName = '' then
		InitIPC;
	WriteLnToConsole(msgGettingConfig);

	LoadLocale(Pathz[ptLocale] + '/en.txt');  // Do an initial load with english
	if cLocaleFName <> 'en.txt' then
        begin
        // Try two letter locale first before trying specific locale overrides
        if (Length(cLocaleFName) > 6) and (Copy(cLocaleFName,1,2)+'.txt' <> 'en.txt') then 
            LoadLocale(Pathz[ptLocale] + '/' + Copy(cLocaleFName,1,2)+'.txt');
	    LoadLocale(Pathz[ptLocale] + '/' + cLocaleFName);
        end;

	if recordFileName = '' then
		SendIPCAndWaitReply('C')        // ask for game config
	else
		LoadRecordFromFile(recordFileName);

	s:= 'eproto ' + inttostr(cNetProtoVersion);
	SendIPCRaw(@s[0], Length(s) + 1); // send proto version

	InitTeams();
	AssignStores();

	if isSoundEnabled then
		InitSound();

	isDeveloperMode:= false;

	TryDo(InitStepsFlags = cifAllInited, 'Some parameters not set (flags = ' + inttostr(InitStepsFlags) + ')', true);

	MainLoop();
	OnDestroy();
	exit();
end;

procedure initEverything;
begin
	init_uConsts();
	init_uMisc();
	init_uConsole();	// MUST happen after uMisc
	
	init_uAI();
	//uAIActions does not need initialization
	//uAIAmmoTests does not need initialization
	init_uAIMisc();
	init_uAmmos();
	init_uChat();
	init_uCollisions();
	//uFloat does not need initialization
	//uGame does not need initialization
	init_uGears();
	init_uIO();
	init_uKeys();
	init_uLand();
	//uLandGraphics does not need initialization
	//uLandObjects does not need initialization
	//uLandTemplates does not need initialization
	//uLandTexture does not need initialization
	//uLocale does not need initialization
	init_uRandom();	
	//uSHA does not need initialization
	init_uSound();
	init_uStats();
	init_uStore();
	init_uTeams();
	init_uTriggers();
	init_uVisualGears();
	init_uWorld();
end;

procedure freeEverything;
begin
	free_uWorld();
	free_uVisualGears();	//stub
	free_uTriggers();	//stub
	free_uTeams();
	free_uStore();
	free_uStats();		//stub
	free_uSound();		//stub
	//uSHA does not need to be freed
	free_uRandom();		//stub
	//uLocale does not need to be freed
	//uLandTemplates does not need to be freed
	//uLandTexture does not need to be freed
	//uLandObjects does not need to be freed
	//uLandGraphics does not need to be freed
	free_uLand();
	free_uKeys();		//stub
	free_uIO();
	free_uGears();
	//uGame does not need to be freed
	//uFloat does not need to be freed
	free_uCollisions();
	free_uChat();
	free_uAmmos();
	free_uAIMisc();		//stub
	//uAIAmmoTests does not need to be freed
	//uAIActions does not need to be freed
	free_uAI();		//stub

	free_uConsole();
	free_uMisc();
	free_uConsts();		//stub

end;
{$IFNDEF IPHONEOS}
/////////////////////////
procedure GenLandPreview;
var Preview: TPreview;
    h: byte;
begin
	InitIPC;
	IPCWaitPongEvent;
	TryDo(InitStepsFlags = cifRandomize, 'Some parameters not set (flags = ' + inttostr(InitStepsFlags) + ')', true);

	Preview:= GenPreview;
	WriteLnToConsole('Sending preview...');
	SendIPCRaw(@Preview, sizeof(Preview));
	h:= MaxHedgehogs;
	SendIPCRaw(@h, sizeof(h));
	WriteLnToConsole('Preview sent, disconnect');
	CloseIPC();
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

/////////////////////
procedure DisplayUsage;
var i: LongInt;
begin
	WriteLn('Wrong argument format: correct configurations is');
	WriteLn();
	WriteLn('  hwengine <path to data folder> <path to replay file> [option]');
	WriteLn();
	WriteLn('where [option] must be specified either as');
	WriteLn(' --set-video [screen width] [screen height] [color dept]');
	WriteLn(' --set-audio [volume] [enable music] [enable sounds]');
	WriteLn(' --set-other [language file] [full screen] [show FPS]');
	WriteLn(' --set-multimedia [screen height] [screen width] [color dept] [volume] [enable music] [enable sounds] [language file] [full screen]');
	WriteLn(' --set-everything [screen height] [screen width] [color dept] [volume] [enable music] [enable sounds] [language file] [full screen] [show FPS] [alternate damage] [timer value] [reduced quality]');
	WriteLn();
	WriteLn('Read documentation online at http://www.hedgewars.org/node/1465 for more information');
	Write('parsed command: ');
	for i:=0 to ParamCount do
		Write(ParamStr(i) + ' ');
	WriteLn();
	halt(1);
end;

////////////////////
procedure GetParams;
{$IFDEF DEBUGFILE}
var i: LongInt;
{$ENDIF}
begin

	case ParamCount of
		17: begin
			val(ParamStr(2), cScreenWidth);
			val(ParamStr(3), cScreenHeight);
			cInitWidth:= cScreenWidth;
			cInitHeight:= cScreenHeight;
			cBitsStr:= ParamStr(4);
			val(cBitsStr, cBits);
			val(ParamStr(5), ipcPort);
			cFullScreen:= ParamStr(6) = '1';
			isSoundEnabled:= ParamStr(7) = '1';
			cVSyncInUse:= ParamStr(8) = '1';
			cLocaleFName:= ParamStr(9);
			val(ParamStr(10), cInitVolume);
			val(ParamStr(11), cTimerInterval);
			PathPrefix:= ParamStr(12);
			cShowFPS:= ParamStr(13) = '1';
			cAltDamage:= ParamStr(14) = '1';
			UserNick:= DecodeBase64(ParamStr(15));
			isMusicEnabled:= ParamStr(16) = '1';
			cReducedQuality:= ParamStr(17) = '1';
		end;
		3: begin
			val(ParamStr(2), ipcPort);
			GameType:= gmtLandPreview;
			if ParamStr(3) <> 'landpreview' then 
				OutError(errmsgShouldntRun, true);
		end;
		2: begin
			PathPrefix:= ParamStr(1);
			recordFileName:= ParamStr(2);
		end;
		6: begin
			PathPrefix:= ParamStr(1);
			recordFileName:= ParamStr(2);

			if ParamStr(3) = '--set-video'	then
			begin
				val(ParamStr(4), cScreenWidth);
				val(ParamStr(5), cScreenHeight);
				cInitWidth:= cScreenWidth;
				cInitHeight:= cScreenHeight;
				cBitsStr:= ParamStr(6);
				val(cBitsStr, cBits);
			end
			else
			begin
				if ParamStr(3) = '--set-audio' then
				begin
					val(ParamStr(4), cInitVolume);
					isMusicEnabled:= ParamStr(5) = '1';
					isSoundEnabled:= ParamStr(6) = '1';
				end
				else
				begin
					if ParamStr(3) = '--set-other' then
					begin
						cLocaleFName:= ParamStr(4);
						cFullScreen:= ParamStr(5) = '1';
						cShowFPS:= ParamStr(6) = '1';
					end
					else DisplayUsage;
				end
			end;
		end;
		11: begin
			PathPrefix:= ParamStr(1);
			recordFileName:= ParamStr(2);

			if ParamStr(3) = '--set-multimedia' then
			begin
				val(ParamStr(4), cScreenWidth);
				val(ParamStr(5), cScreenHeight);
				cInitWidth:= cScreenWidth;
				cInitHeight:= cScreenHeight;
				cBitsStr:= ParamStr(6);
				val(cBitsStr, cBits);
				val(ParamStr(7), cInitVolume);
				isMusicEnabled:= ParamStr(8) = '1';
				isSoundEnabled:= ParamStr(9) = '1';
				cLocaleFName:= ParamStr(10);
				cFullScreen:= ParamStr(11) = '1';
			end
			else DisplayUsage;
		end;
		15: begin
			PathPrefix:= ParamStr(1);
			recordFileName:= ParamStr(2);
			if ParamStr(3) = '--set-everything' then
			begin
				val(ParamStr(4), cScreenWidth);
				val(ParamStr(5), cScreenHeight);
				cInitWidth:= cScreenWidth;
				cInitHeight:= cScreenHeight;
				cBitsStr:= ParamStr(6);
				val(cBitsStr, cBits);
				val(ParamStr(7), cInitVolume);
				isMusicEnabled:= ParamStr(8) = '1';
				isSoundEnabled:= ParamStr(9) = '1';
				cLocaleFName:= ParamStr(10);
				cFullScreen:= ParamStr(11) = '1';
				cAltDamage:= ParamStr(12) = '1';
				cShowFPS:= ParamStr(13) = '1';
				val(ParamStr(14), cTimerInterval);
				cReducedQuality:= ParamStr(15) = '1';
			end
			else DisplayUsage;
		end;
		else DisplayUsage;
	end;

{$IFDEF DEBUGFILE}
	AddFileLog('Prefix: "' + PathPrefix +'"');
	for i:= 0 to ParamCount do
		AddFileLog(inttostr(i) + ': ' + ParamStr(i));
{$IFDEF IPHONEOS}
	WriteLnToConsole('Saving debug file at: ' + IPH_getDocumentsPath());
{$ENDIF}
{$ENDIF}
end;
////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// m a i n ////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

begin
	initEverything();
	WriteLnToConsole('Hedgewars ' + cVersionString + ' engine (network protocol: ' + inttostr(cNetProtoVersion) + ')');
	
	GetParams();
	Randomize();

	if GameType = gmtLandPreview then GenLandPreview()
	else Game();
	ExitCode:= 0;
{$ENDIF}
end.
