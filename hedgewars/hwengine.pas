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

{$IFDEF WIN32}
{$R hwengine.rc}
{$ENDIF}

{$IFDEF HWLIBRARY}
unit hwengine;
interface
{$ELSE}
program hwengine;
{$ENDIF}

uses SDLh, uMisc, uConsole, uGame, uConsts, uLand, uAmmos, uVisualGears, uGears, uStore, uWorld, uKeys, uSound,
     uScript, uTeams, uStats, uIO, uLocale, uChat, uAI, uAIMisc, uRandom, uLandTexture, uCollisions,
     sysutils, uTypes, uVariables, uCommands, uUtils, uCaptions, uDebug, uCommandHandlers, uLandPainted,uTouch {$IFDEF ANDROID}, GLUnit {$ENDIF};

{$IFDEF HWLIBRARY}
procedure initEverything(complete:boolean);
procedure freeEverything(complete:boolean);
procedure Game(gameArgs: PPChar); cdecl; export;
procedure GenLandPreview(port: Longint); cdecl; export;

implementation
{$ELSE}
procedure OnDestroy; forward;
procedure initEverything(complete:boolean); forward;
procedure freeEverything(complete:boolean); forward;
{$ENDIF}

////////////////////////////////
procedure DoTimer(Lag: LongInt);
var s: shortstring;
begin
    if isPaused = false then
        inc(RealTicks, Lag);

    case GameState of
        gsLandGen: begin
                GenMap;
                ParseCommand('sendlanddigest', true);
                GameState:= gsStart;
                end;
        gsStart: begin
                if HasBorder then DisableSomeWeapons;
                AddClouds;
                AddFlakes;
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
                ScriptCall('onGameStart');
                GameState:= gsGame;
                end;
        gsConfirm,
        gsGame: begin
                DrawWorld(Lag); // never place between ProcessKbd and DoGameTick - bugs due to /put cmd and isCursorVisible
                ProcessKbd;
                if not isPaused then
                    begin
                    DoGameTick(Lag);
                    ProcessVisualGears(Lag);
                    end;
                end;
        gsChat: begin
                DrawWorld(Lag);
                if not isPaused then
                    begin
                    DoGameTick(Lag);
                    ProcessVisualGears(Lag);
                    end;
                end;
        gsExit: begin
                isTerminated:= true;
                end;
        gsSuspend: exit;
        end;

{$IFDEF SDL13}
    SDL_GL_SwapWindow(SDLwindow);
{$ELSE}
    SDL_GL_SwapBuffers();
{$ENDIF}

    if flagMakeCapture then
    begin
        flagMakeCapture:= false;
        s:= 'hw_' + FormatDateTime('YYYY-MM-DD_HH-mm-ss', Now()) + inttostr(GameTicks);
        WriteLnToConsole('Saving ' + s + '...');
        playSound(sndShutter);
        {$IFNDEF IPHONEOS}MakeScreenshot(s);{$ENDIF}
    end;
end;

////////////////////
procedure OnDestroy;
begin
    WriteLnToConsole('Freeing resources...');
    FreeActionsList();
    StoreRelease();
    ControllerClose();
    CloseIPC();
    TTF_Quit();
{$IFDEF SDL13}
    SDL_GL_DeleteContext(SDLGLcontext);
    SDL_DestroyWindow(SDLwindow);
    SDLGLcontext:= nil;
    SDLwindow:= nil;
{$ENDIF}
    SDL_Quit();
    isTerminated:= false;
end;

///////////////////
procedure MainLoop;
{$WARNINGS OFF}
// disable "Some fields weren't initialized" warning
const event: TSDL_Event = ();
{$WARNINGS ON}
var PrevTime, CurrTime: Longword;
    prevFocusState: boolean;
begin
    PrevTime:= SDL_GetTicks;
    while isTerminated = false do
    begin
{$IFDEF ANDROID}
	SDL_PumpEvents();
        while SDL_PeepEvents(@event, 1, SDL_GETEVENT, SDL_FIRSTEVENT, SDL_LASTEVENT) > 0 do
{$ELSE}
	while SDL_PollEvent(@event) <> 0 do
{$ENDIF}
        begin
            case event.type_ of
                SDL_KEYDOWN: if GameState = gsChat then
{$IFDEF SDL13}
                    // sdl on iphone supports only ashii keyboards and the unicode field is deprecated in sdl 1.3
                    KeyPressChat(event.key.keysym.sym);
                SDL_WINDOWEVENT:
                    if event.window.event = SDL_WINDOWEVENT_SHOWN then
                        begin
                        cHasFocus:= true;
                        onFocusStateChanged()
                        end;
                SDL_FINGERMOTION: onTouchMotion(event.tfinger.x, event.tfinger.y,event.tfinger.dx, event.tfinger.dy, event.tfinger.fingerId);
                SDL_FINGERDOWN: onTouchDown(event.tfinger.x, event.tfinger.y, event.tfinger.fingerId);
                SDL_FINGERUP: onTouchUp(event.tfinger.x, event.tfinger.y, event.tfinger.fingerId);
{$ELSE}
                    KeyPressChat(event.key.keysym.unicode);
                SDL_MOUSEBUTTONDOWN: if event.button.button = SDL_BUTTON_WHEELDOWN then wheelDown:= true;
                SDL_MOUSEBUTTONUP: if event.button.button = SDL_BUTTON_WHEELUP then wheelUp:= true;
                SDL_ACTIVEEVENT:
                    if (event.active.state and SDL_APPINPUTFOCUS) <> 0 then
                        begin
                        prevFocusState:= cHasFocus;
                        cHasFocus:= event.active.gain = 1;
                        if prevFocusState xor cHasFocus then
                            onFocusStateChanged()
                        end;
{$ENDIF}
                SDL_JOYAXISMOTION: ControllerAxisEvent(event.jaxis.which, event.jaxis.axis, event.jaxis.value);
                SDL_JOYHATMOTION: ControllerHatEvent(event.jhat.which, event.jhat.hat, event.jhat.value);
                SDL_JOYBUTTONDOWN: ControllerButtonEvent(event.jbutton.which, event.jbutton.button, true);
                SDL_JOYBUTTONUP: ControllerButtonEvent(event.jbutton.which, event.jbutton.button, false);
                SDL_QUITEV: isTerminated:= true
            end; //end case event.type_ of
        end; //end while SDL_PollEvent(@event) <> 0 do

        if isTerminated = false then
        begin
            CurrTime:= SDL_GetTicks;
            if PrevTime + longword(cTimerInterval) <= CurrTime then
            begin
                DoTimer(CurrTime - PrevTime);
                PrevTime:= CurrTime
            end
            else SDL_Delay(1);
            IPCCheckSock();
        end;
    end;
end;

/////////////////////////
procedure ShowMainWindow;
begin
    if cFullScreen then ParseCommand('fullscr 1', true)
    else ParseCommand('fullscr 0', true);
    SDL_ShowCursor(0)
end;

///////////////
{$IFDEF HWLIBRARY}
procedure Game(gameArgs: PPChar); cdecl; export;
{$ELSE}
procedure Game;
{$ENDIF}
var p: TPathType;
    s: shortstring;
    i: LongInt;
begin
{$IFDEF HWLIBRARY}
    cBits:= 32;
    cTimerInterval:= 8;
{$IFDEF ANDROID}
    PathPrefix:= gameArgs[11];
    cFullScreen:= true;
{$ELSE}
    PathPrefix:= 'Data';
    cFullScreen:= false;
{$ENDIF}
    UserPathPrefix:= '.';
    cShowFPS:= {$IFDEF DEBUGFILE}true{$ELSE}false{$ENDIF};
    val(gameArgs[0], ipcPort);
    val(gameArgs[1], cScreenWidth);
    val(gameArgs[2], cScreenHeight);
    val(gameArgs[3], cReducedQuality);
    cLocaleFName:= gameArgs[4];
    UserNick:= gameArgs[5];
    isSoundEnabled:= gameArgs[6] = '1';
    isMusicEnabled:= gameArgs[7] = '1';
    cAltDamage:= gameArgs[8] = '1';
    val(gameArgs[9], rotationQt);
    recordFileName:= gameArgs[10];
    cStereoMode:= smNone;
{$ENDIF}

    cLogfileBase:= 'game';
    initEverything(true);
    WriteLnToConsole('Hedgewars ' + cVersionString + ' engine (network protocol: ' + inttostr(cNetProtoVersion) + ')');
    AddFileLog('Prefix: "' + PathPrefix +'"');
    AddFileLog('UserPrefix: "' + UserPathPrefix +'"');
    for i:= 0 to ParamCount do
        AddFileLog(inttostr(i) + ': ' + ParamStr(i));

    for p:= Succ(Low(TPathType)) to High(TPathType) do
        if (p <> ptMapCurrent) and (p <> ptData) then UserPathz[p]:= UserPathPrefix + '/Data/' + Pathz[p];

    UserPathz[ptData]:= UserPathPrefix + '/Data';

    for p:= Succ(Low(TPathType)) to High(TPathType) do
        if p <> ptMapCurrent then Pathz[p]:= PathPrefix + '/' + Pathz[p];

    WriteToConsole('Init SDL... ');
    SDLTry(SDL_Init(SDL_INIT_VIDEO or SDL_INIT_NOPARACHUTE) >= 0, true);
    WriteLnToConsole(msgOK);

    SDL_EnableUNICODE(1);

    WriteToConsole('Init SDL_ttf... ');
    SDLTry(TTF_Init() <> -1, true);
    WriteLnToConsole(msgOK);

{$IFDEF WIN32}
    s:= SDL_getenv('SDL_VIDEO_CENTERED');
    SDL_putenv('SDL_VIDEO_CENTERED=1');
    ShowMainWindow();
    SDL_putenv(str2pchar('SDL_VIDEO_CENTERED=' + s));
{$ELSE}
    ShowMainWindow();
{$ENDIF}

    ControllerInit(); // has to happen before InitKbdKeyTable to map keys
    InitKbdKeyTable();
    AddProgress();

    LoadLocale(UserPathz[ptLocale] + '/en.txt');  // Do an initial load with english
    LoadLocale(Pathz[ptLocale] + '/en.txt');  // Do an initial load with english
    if (Length(cLocaleFName) > 6) then cLocale := Copy(cLocaleFName,1,5)
    else cLocale := Copy(cLocaleFName,1,2);
    if cLocaleFName <> 'en.txt' then
        begin
        // Try two letter locale first before trying specific locale overrides
        if (Length(cLocale) > 2) and (Copy(cLocale,1,2) <> 'en') then
            begin
            LoadLocale(UserPathz[ptLocale] + '/' + Copy(cLocale,1,2)+'.txt');
            LoadLocale(Pathz[ptLocale] + '/' + Copy(cLocale,1,2)+'.txt')
            end;
        LoadLocale(UserPathz[ptLocale] + '/' + cLocaleFName);
        LoadLocale(Pathz[ptLocale] + '/' + cLocaleFName)
        end
    else cLocale := 'en';

    WriteLnToConsole(msgGettingConfig);

    if recordFileName = '' then
        begin
        InitIPC;
        SendIPCAndWaitReply('C');        // ask for game config
        end
    else
        LoadRecordFromFile(recordFileName);

    ScriptOnGameInit;

    s:= 'eproto ' + inttostr(cNetProtoVersion);
    SendIPCRaw(@s[0], Length(s) + 1); // send proto version

    InitTeams();
    AssignStores();

    if isSoundEnabled then
        InitSound();

    isDeveloperMode:= false;

    TryDo(InitStepsFlags = cifAllInited, 'Some parameters not set (flags = ' + inttostr(InitStepsFlags) + ')', true);

    ParseCommand('rotmask', true);

    MainLoop();
    // clean up SDL and GL context
    OnDestroy();
    // clean up all the other memory allocated
    freeEverything(true);
    if alsoShutdownFrontend then halt;
end;

procedure initEverything (complete:boolean);
begin
    Randomize();

    // uConsts does not need initialization as they are all consts
    uUtils.initModule;
    uMisc.initModule;
    uVariables.initModule;
    uConsole.initModule;    // MUST happen after uMisc
    uCommands.initModule;
    uCommandHandlers.initModule;

    uLand.initModule;
    uLandPainted.initModule;

    uIO.initModule;

    if complete then
    begin
{$IFDEF ANDROID}
	GLUnit.init;
{$ENDIF}
        uTouch.initModule;
	uAI.initModule;
        //uAIActions does not need initialization
        //uAIAmmoTests does not need initialization
        uAIMisc.initModule;
        uAmmos.initModule;
        uChat.initModule;
        uCollisions.initModule;
        //uFloat does not need initialization
        //uGame does not need initialization
        uGears.initModule;
        uKeys.initModule;
        //uLandGraphics does not need initialization
        //uLandObjects does not need initialization
        //uLandTemplates does not need initialization
        uLandTexture.initModule;
        //uLocale does not need initialization
        uRandom.initModule;
        uScript.initModule;
        uSound.initModule;
        uStats.initModule;
        uStore.initModule;
        uTeams.initModule;
        uVisualGears.initModule;
        uWorld.initModule;
        uCaptions.initModule;
    end;
end;

procedure freeEverything (complete:boolean);
begin
    if complete then
    begin
        uCaptions.freeModule;
        uWorld.freeModule;
        uVisualGears.freeModule;
        uTeams.freeModule;
        uStore.freeModule;          //stub
        uStats.freeModule;          //stub
        uSound.freeModule;
        uScript.freeModule;
        uRandom.freeModule;         //stub
        //uLocale does not need to be freed
        //uLandTemplates does not need to be freed
        uLandTexture.freeModule;
        //uLandObjects does not need to be freed
        //uLandGraphics does not need to be freed
        uKeys.freeModule;           //stub
        uGears.freeModule;
        //uGame does not need to be freed
        //uFloat does not need to be freed
        uCollisions.freeModule;     //stub
        uChat.freeModule;
        uAmmos.freeModule;
        uAIMisc.freeModule;         //stub
        //uAIAmmoTests does not need to be freed
        //uAIActions does not need to be freed
        uAI.freeModule;             //stub
    end;

    uIO.freeModule;             //stub
    uLand.freeModule;
    uLandPainted.freeModule;

    uCommandHandlers.freeModule;
    uCommands.freeModule;
    uConsole.freeModule;
    uVariables.freeModule;
    uUtils.freeModule;
    uMisc.freeModule;           // uMisc closes the debug log.
end;

/////////////////////////
procedure GenLandPreview{$IFDEF HWLIBRARY}(port: LongInt); cdecl; export{$ENDIF};
var Preview: TPreview;
begin
    cLogfileBase:= 'preview';
    initEverything(false);
{$IFDEF HWLIBRARY}
    WriteLnToConsole('Preview connecting on port ' + inttostr(port));
    ipcPort:= port;
{$ENDIF}
    InitIPC;
    IPCWaitPongEvent;
    TryDo(InitStepsFlags = cifRandomize, 'Some parameters not set (flags = ' + inttostr(InitStepsFlags) + ')', true);

    Preview:= GenPreview();
    WriteLnToConsole('Sending preview...');
    SendIPCRaw(@Preview, sizeof(Preview));
    SendIPCRaw(@MaxHedgehogs, sizeof(byte));
    WriteLnToConsole('Preview sent, disconnect');
    CloseIPC();
    freeEverything(false);
end;

{$IFNDEF HWLIBRARY}
/////////////////////
procedure DisplayUsage;
var i: LongInt;
begin
    WriteLn('Wrong argument format: correct configurations is');
    WriteLn();
    WriteLn('  hwengine <path to user hedgewars folder> <path to global data folder> <path to replay file> [options]');
    WriteLn();
    WriteLn('where [options] must be specified either as:');
    WriteLn(' --set-video [screen width] [screen height] [color dept]');
    WriteLn(' --set-audio [volume] [enable music] [enable sounds]');
    WriteLn(' --set-other [language file] [full screen] [show FPS]');
    WriteLn(' --set-multimedia [screen width] [screen height] [color dept] [volume] [enable music] [enable sounds] [language file] [full screen]');
    WriteLn(' --set-everything [screen width] [screen height] [color dept] [volume] [enable music] [enable sounds] [language file] [full screen] [show FPS] [alternate damage] [timer value] [reduced quality]');
    WriteLn(' --stats-only');
    WriteLn();
    WriteLn('Read documentation online at http://code.google.com/p/hedgewars/wiki/CommandLineOptions for more information');
    WriteLn();
    Write('PARSED COMMAND: ');
    for i:=0 to ParamCount do
        Write(ParamStr(i) + ' ');
    WriteLn();
end;

////////////////////
{$INCLUDE "ArgParsers.inc"}

procedure GetParams;
begin
    if (ParamCount < 3) then
        GameType:= gmtSyntax
    else
        if (ParamCount = 3) and ((ParamStr(3) = '--stats-only') or (ParamStr(3) = 'landpreview')) then
            internalSetGameTypeLandPreviewFromParameters()
        else
            if (ParamCount = cDefaultParamNum) then
                internalStartGameWithParameters()
            else
                playReplayFileWithParameters();
end;

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// m a i n ////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
begin
    GetParams();

    if GameType = gmtLandPreview then GenLandPreview()
    else if GameType = gmtSyntax then DisplayUsage()
    else Game();

    if GameType = gmtSyntax then
        ExitCode:= 1
    else
        ExitCode:= 0;
{$ENDIF}
end.
