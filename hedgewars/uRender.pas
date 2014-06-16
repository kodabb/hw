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
{$IF GLunit = GL}{$DEFINE GLunit:=GL,GLext}{$ENDIF}

unit uRender;

interface

uses SDLh, uTypes, GLunit;

procedure initModule;
procedure freeModule;

procedure DrawSprite            (Sprite: TSprite; X, Y, Frame: LongInt);
procedure DrawSprite            (Sprite: TSprite; X, Y, FrameX, FrameY: LongInt);
procedure DrawSpriteFromRect    (Sprite: TSprite; r: TSDL_Rect; X, Y, Height, Position: LongInt); inline;
procedure DrawSpriteClipped     (Sprite: TSprite; X, Y, TopY, RightX, BottomY, LeftX: LongInt);
procedure DrawSpriteRotated     (Sprite: TSprite; X, Y, Dir: LongInt; Angle: real);
procedure DrawSpriteRotatedF    (Sprite: TSprite; X, Y, Frame, Dir: LongInt; Angle: real);

procedure DrawTexture           (X, Y: LongInt; Texture: PTexture); inline;
procedure DrawTexture           (X, Y: LongInt; Texture: PTexture; Scale: GLfloat);
procedure DrawTexture2          (X, Y: LongInt; Texture: PTexture; Scale, Overlap: GLfloat);
procedure DrawTextureFromRect   (X, Y: LongInt; r: PSDL_Rect; SourceTexture: PTexture); inline;
procedure DrawTextureFromRect   (X, Y, W, H: LongInt; r: PSDL_Rect; SourceTexture: PTexture); inline;
procedure DrawTextureFromRectDir(X, Y, W, H: LongInt; r: PSDL_Rect; SourceTexture: PTexture; Dir: LongInt);
procedure DrawTextureCentered   (X, Top: LongInt; Source: PTexture);
procedure DrawTextureF          (Texture: PTexture; Scale: GLfloat; X, Y, Frame, Dir, w, h: LongInt);
procedure DrawTextureRotated    (Texture: PTexture; hw, hh, X, Y, Dir: LongInt; Angle: real);
procedure DrawTextureRotatedF   (Texture: PTexture; Scale, OffsetX, OffsetY: GLfloat; X, Y, Frame, Dir, w, h: LongInt; Angle: real);

procedure DrawCircle            (X, Y, Radius, Width: LongInt);
procedure DrawCircle            (X, Y, Radius, Width: LongInt; r, g, b, a: Byte);

procedure DrawLine              (X0, Y0, X1, Y1, Width: Single; color: LongWord); inline;
procedure DrawLine              (X0, Y0, X1, Y1, Width: Single; r, g, b, a: Byte);
procedure DrawRect              (rect: TSDL_Rect; r, g, b, a: Byte; Fill: boolean);
procedure DrawHedgehog          (X, Y: LongInt; Dir: LongInt; Pos, Step: LongWord; Angle: real);
procedure DrawScreenWidget      (widget: POnScreenWidget);
procedure DrawWaterBody         (pVertexBuffer: Pointer);

procedure RenderClear           ();
procedure RenderSetClearColor      (r, g, b, a: real);
procedure Tint                  (r, g, b, a: Byte); inline;
procedure Tint                  (c: Longword); inline;
procedure untint(); inline;
procedure setTintAdd            (f: boolean); inline;

function isAreaOffscreen(X, Y, Width, Height: LongInt): boolean; inline;

// 0 => not offscreen, <0 => left/top of screen >0 => right/below of screen
function isDxAreaOffscreen(X, Width: LongInt): LongInt; inline;
function isDyAreaOffscreen(Y, Height: LongInt): LongInt; inline;

procedure SetScale(f: GLfloat);
procedure UpdateViewLimits();

procedure RenderSetup();

// TODO everything below this should not need a public interface

procedure CreateFramebuffer(var frame, depth, tex: GLuint);
procedure DeleteFramebuffer(var frame, depth, tex: GLuint);

procedure EnableTexture(enable:Boolean);

procedure SetTexCoordPointer(p: Pointer;n: Integer);
procedure SetVertexPointer(p: Pointer;n: Integer);
procedure SetColorPointer(p: Pointer;n: Integer);

procedure UpdateModelviewProjection(); inline;

procedure openglLoadIdentity    (); inline;
procedure openglTranslProjMatrix(X, Y, Z: GLFloat); inline;
procedure openglPushMatrix      (); inline;
procedure openglPopMatrix       (); inline;
procedure openglTranslatef      (X, Y, Z: GLfloat); inline;
procedure openglScalef          (ScaleX, ScaleY, ScaleZ: GLfloat); inline;
procedure openglRotatef         (RotX, RotY, RotZ: GLfloat; dir: LongInt); inline;
procedure openglTint            (r, g, b, a: Byte); inline;


implementation
uses {$IFNDEF PAS2C} StrUtils, {$ENDIF}SysUtils, uVariables, uUtils, uConsts
     {$IFDEF GL2}, uMatrix, uConsole{$ENDIF}
     {$IF NOT DEFINED(SDL2) AND DEFINED(USE_VIDEO_RECORDING)}, glut {$ENDIF};

{$IFDEF USE_TOUCH_INTERFACE}
const
    FADE_ANIM_TIME = 500;
    MOVE_ANIM_TIME = 500;
{$ENDIF}

{$IFDEF GL2}
var
    shaderMain: GLuint;
    shaderWater: GLuint;
{$ENDIF}

var LastTint: LongWord = 0;

function isAreaOffscreen(X, Y, Width, Height: LongInt): boolean; inline;
begin
    isAreaOffscreen:= (isDxAreaOffscreen(X, Width) <> 0) or (isDyAreaOffscreen(Y, Height) <> 0);
end;

function isDxAreaOffscreen(X, Width: LongInt): LongInt; inline;
begin
    if X > ViewRightX then exit(1);
    if X + Width < ViewLeftX then exit(-1);
    isDxAreaOffscreen:= 0;
end;

function isDyAreaOffscreen(Y, Height: LongInt): LongInt; inline;
begin
    if Y > ViewBottomY then exit(1);
    if Y + Height < ViewTopY then exit(-1);
    isDyAreaOffscreen:= 0;
end;

procedure RenderClear();
begin
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;

procedure RenderSetClearColor(r, g, b, a: real);
begin
    glClearColor(r, g, b, a);
end;

{$IFDEF GL2}
function CompileShader(shaderFile: string; shaderType: GLenum): GLuint;
var
    shader: GLuint;
    f: Textfile;
    source, line: AnsiString;
    sourceA: Pchar;
    lengthA: GLint;
    compileResult: GLint;
    logLength: GLint;
    log: PChar;
begin
    Assign(f, PathPrefix + cPathz[ptShaders] + '/' + shaderFile);
    filemode:= 0; // readonly
    Reset(f);
    if IOResult <> 0 then
    begin
        AddFileLog('Unable to load ' + shaderFile);
        halt(HaltStartupError);
    end;

    source:='';
    while not eof(f) do
    begin
        ReadLn(f, line);
        source:= source + line + #10;
    end;

    Close(f);

    WriteLnToConsole('Compiling shader: ' + PathPrefix + cPathz[ptShaders] + '/' + shaderFile);

    sourceA:=PChar(source);
    lengthA:=Length(source);

    shader:=glCreateShader(shaderType);
    glShaderSource(shader, 1, @sourceA, @lengthA);
    glCompileShader(shader);
    glGetShaderiv(shader, GL_COMPILE_STATUS, @compileResult);
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, @logLength);

    if logLength > 1 then
    begin
        log := GetMem(logLength);
        glGetShaderInfoLog(shader, logLength, nil, log);
        WriteLnToConsole('========== Compiler log  ==========');
        WriteLnToConsole(shortstring(log));
        WriteLnToConsole('===================================');
        FreeMem(log, logLength);
    end;

    if compileResult <> GL_TRUE then
    begin
        WriteLnToConsole('Shader compilation failed, halting');
        halt(HaltStartupError);
    end;

    CompileShader:= shader;
end;

function CompileProgram(shaderName: string): GLuint;
var
    program_: GLuint;
    vs, fs: GLuint;
    linkResult: GLint;
    logLength: GLint;
    log: PChar;
begin
    program_:= glCreateProgram();
    vs:= CompileShader(shaderName + '.vs', GL_VERTEX_SHADER);
    fs:= CompileShader(shaderName + '.fs', GL_FRAGMENT_SHADER);
    glAttachShader(program_, vs);
    glAttachShader(program_, fs);

    glBindAttribLocation(program_, aVertex, PChar('vertex'));
    glBindAttribLocation(program_, aTexCoord, PChar('texcoord'));
    glBindAttribLocation(program_, aColor, PChar('color'));

    glLinkProgram(program_);
    glDeleteShader(vs);
    glDeleteShader(fs);

    glGetProgramiv(program_, GL_LINK_STATUS, @linkResult);
    glGetProgramiv(program_, GL_INFO_LOG_LENGTH, @logLength);

    if logLength > 1 then
    begin
        log := GetMem(logLength);
        glGetProgramInfoLog(program_, logLength, nil, log);
        WriteLnToConsole('========== Compiler log  ==========');
        WriteLnToConsole(shortstring(log));
        WriteLnToConsole('===================================');
        FreeMem(log, logLength);
    end;

    if linkResult <> GL_TRUE then
    begin
        WriteLnToConsole('Linking program failed, halting');
        halt(HaltStartupError);
    end;

    CompileProgram:= program_;
end;
{$ENDIF}

function glLoadExtension(extension : shortstring) : boolean;
begin
//TODO: pas2c does not handle {$IF (GLunit = gles11) OR DEFINED(PAS2C)}
{$IFNDEF PAS2C}
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

{$ELSE} // pas2c part
    glLoadExtension:= false;
{$ENDIF}
end;

{$IF DEFINED(USE_S3D_RENDERING) OR DEFINED(USE_VIDEO_RECORDING)}
procedure CreateFramebuffer(var frame, depth, tex: GLuint);
begin
    glGenFramebuffersEXT(1, @frame);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, frame);
    glGenRenderbuffersEXT(1, @depth);
    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, depth);
    glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT, cScreenWidth, cScreenHeight);
    glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, depth);
    glGenTextures(1, @tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,  cScreenWidth, cScreenHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, tex, 0);
end;

procedure DeleteFramebuffer(var frame, depth, tex: GLuint);
begin
    glDeleteTextures(1, @tex);
    glDeleteRenderbuffersEXT(1, @depth);
    glDeleteFramebuffersEXT(1, @frame);
end;

{$ENDIF}
procedure RenderSetup();
var AuxBufNum: LongInt = 0;
    tmpstr: ansistring;
    tmpint: LongInt;
    tmpn: LongInt;
begin
    // suppress hint/warning
    AuxBufNum:= AuxBufNum;

    // get the max (h and v) size for textures that the gpu can support
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, @MaxTextureSize);
    if MaxTextureSize <= 0 then
        begin
        MaxTextureSize:= 1024;
        AddFileLog('OpenGL Warning - driver didn''t provide any valid max texture size; assuming 1024');
        end
    else if (MaxTextureSize < 1024) and (MaxTextureSize >= 512) then
        begin
        cReducedQuality := cReducedQuality or rqNoBackground;
        AddFileLog('Texture size too small for backgrounds, disabling.');
        end;
    // everyone loves debugging
    // find out which gpu we are using (for extension compatibility maybe?)
    AddFileLog('OpenGL-- Renderer: ' + shortstring(pchar(glGetString(GL_RENDERER))));
    AddFileLog('  |----- Vendor: ' + shortstring(pchar(glGetString(GL_VENDOR))));
    AddFileLog('  |----- Version: ' + shortstring(pchar(glGetString(GL_VERSION))));
    AddFileLog('  |----- Texture Size: ' + inttostr(MaxTextureSize));
{$IFDEF USE_VIDEO_RECORDING}
    glGetIntegerv(GL_AUX_BUFFERS, @AuxBufNum);
    AddFileLog('  |----- Number of auxiliary buffers: ' + inttostr(AuxBufNum));
{$ENDIF}
{$IFNDEF PAS2C}
    AddFileLog('  \----- Extensions: ');

    // fetch extentions and store them in string
    tmpstr := StrPas(PChar(glGetString(GL_EXTENSIONS)));
    tmpn := WordCount(tmpstr, [' ']);
    tmpint := 1;

    repeat
    begin
        // print up to 3 extentions per row
        // ExtractWord will return empty string if index out of range
        AddFileLog(TrimRight(
            ExtractWord(tmpint, tmpstr, [' ']) + ' ' +
            ExtractWord(tmpint+1, tmpstr, [' ']) + ' ' +
            ExtractWord(tmpint+2, tmpstr, [' '])
        ));
        tmpint := tmpint + 3;
    end;
    until (tmpint > tmpn);
{$ENDIF}
    AddFileLog('');

    defaultFrame:= 0;

{$IFDEF USE_VIDEO_RECORDING}
    if GameType = gmtRecord then
    begin
        if glLoadExtension('GL_EXT_framebuffer_object') then
        begin
            CreateFramebuffer(defaultFrame, depthv, texv);
            glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, defaultFrame);
            AddFileLog('Using framebuffer for video recording.');
        end
        else if AuxBufNum > 0 then
        begin
            glDrawBuffer(GL_AUX0);
            glReadBuffer(GL_AUX0);
            AddFileLog('Using auxiliary buffer for video recording.');
        end
        else
        begin
            glDrawBuffer(GL_BACK);
            glReadBuffer(GL_BACK);
            AddFileLog('Warning: off-screen rendering is not supported; using back buffer but it may not work.');
        end;
    end;
{$ENDIF}

{$IFDEF GL2}

{$IFDEF PAS2C}
    err := glewInit();
    if err <> GLEW_OK then
    begin
        WriteLnToConsole('Failed to initialize GLEW.');
        halt(HaltStartupError);
    end;
{$ENDIF}

{$IFNDEF PAS2C}
    if not Load_GL_VERSION_2_0 then
        halt;
{$ENDIF}

    shaderWater:= CompileProgram('water');
    glUseProgram(shaderWater);
    glUniform1i(glGetUniformLocation(shaderWater, pchar('tex0')), 0);
    uWaterMVPLocation:= glGetUniformLocation(shaderWater, pchar('mvp'));

    shaderMain:= CompileProgram('default');
    glUseProgram(shaderMain);
    glUniform1i(glGetUniformLocation(shaderMain, pchar('tex0')), 0);
    uMainMVPLocation:= glGetUniformLocation(shaderMain, pchar('mvp'));
    uMainTintLocation:= glGetUniformLocation(shaderMain, pchar('tint'));

    uCurrentMVPLocation:= uMainMVPLocation;

    Tint(255, 255, 255, 255);
    UpdateModelviewProjection;
{$ENDIF}

{$IFNDEF USE_S3D_RENDERING}
    if (cStereoMode = smHorizontal) or (cStereoMode = smVertical) or (cStereoMode = smAFR) then
    begin
        // prepare left and right frame buffers and associated textures
        if glLoadExtension('GL_EXT_framebuffer_object') then
            begin
            CreateFramebuffer(framel, depthl, texl);
            CreateFramebuffer(framer, depthr, texr);

            // reset
            glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, defaultFrame)
            end
        else
            cStereoMode:= smNone;
    end;
{$ENDIF}

// set view port to whole window
glViewport(0, 0, cScreenWidth, cScreenHeight);

{$IFDEF GL2}
    uMatrix.initModule;
    hglMatrixMode(MATRIX_MODELVIEW);
    // prepare default translation/scaling
    hglLoadIdentity();
    hglScalef(2.0 / cScreenWidth, -2.0 / cScreenHeight, 1.0);
    hglTranslatef(0, -cScreenHeight / 2, 0);

    EnableTexture(True);

    glEnableVertexAttribArray(aVertex);
    glEnableVertexAttribArray(aTexCoord);
    glGenBuffers(1, @vBuffer);
    glGenBuffers(1, @tBuffer);
    glGenBuffers(1, @cBuffer);
{$ELSE}
    glMatrixMode(GL_MODELVIEW);
    // prepare default translation/scaling
    glLoadIdentity();
    glScalef(2.0 / cScreenWidth, -2.0 / cScreenHeight, 1.0);
    glTranslatef(0, -cScreenHeight / 2, 0);

    // disable/lower perspective correction (will not need it anyway)
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    // disable dithering
    glDisable(GL_DITHER);
    // enable common states by default as they save a lot
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
{$ENDIF}

    // enable alpha blending
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // disable/lower perspective correction (will not need it anyway)
end;

procedure openglLoadIdentity(); inline;
begin
{$IFDEF GL2}
    hglLoadIdentity();
{$ELSE}
    glLoadIdentity();
{$ENDIF}
end;

procedure openglTranslProjMatrix(X, Y, Z: GLfloat); inline;
begin
{$IFDEF GL2}
    hglMatrixMode(MATRIX_PROJECTION);
    hglTranslatef(X, Y, Z);
    hglMatrixMode(MATRIX_MODELVIEW);
{$ELSE}
    glMatrixMode(GL_PROJECTION);
    glTranslatef(X, Y, Z);
    glMatrixMode(GL_MODELVIEW);
{$ENDIF}
end;

procedure openglPushMatrix(); inline;
begin
{$IFDEF GL2}
    hglPushMatrix();
{$ELSE}
    glPushMatrix();
{$ENDIF}
end;

procedure openglPopMatrix(); inline;
begin
{$IFDEF GL2}
    hglPopMatrix();
{$ELSE}
    glPopMatrix();
{$ENDIF}
end;

procedure openglTranslatef(X, Y, Z: GLfloat); inline;
begin
{$IFDEF GL2}
    hglTranslatef(X, Y, Z);
{$ELSE}
    glTranslatef(X, Y, Z);
{$ENDIF}
end;

procedure openglScalef(ScaleX, ScaleY, ScaleZ: GLfloat); inline;
begin
{$IFDEF GL2}
    hglScalef(ScaleX, ScaleY, ScaleZ);
{$ELSE}
    glScalef(ScaleX, ScaleY, ScaleZ);
{$ENDIF}
end;

procedure openglRotatef(RotX, RotY, RotZ: GLfloat; dir: LongInt); inline;
begin
{$IFDEF GL2}
    hglRotatef(RotX, RotY, RotZ, dir);
{$ELSE}
    glRotatef(RotX, RotY, RotZ, dir);
{$ENDIF}
end;

procedure openglUseColorOnly(b :boolean); inline;
begin
    if b then
        begin
        {$IFDEF GL2}
        glDisableVertexAttribArray(aTexCoord);
        glEnableVertexAttribArray(aColor);
        {$ELSE}
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        {$ENDIF}
        end
    else
        begin
        {$IFDEF GL2}
        glDisableVertexAttribArray(aColor);
        glEnableVertexAttribArray(aTexCoord);
        {$ELSE}
        glDisableClientState(GL_COLOR_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        {$ENDIF}
        end;
end;

procedure UpdateModelviewProjection(); inline;
{$IFDEF GL2}
var
    mvp: TMatrix4x4f;
{$ENDIF}
begin
{$IFDEF GL2}
    //MatrixMultiply(mvp, mProjection, mModelview);
{$HINTS OFF}
    hglMVP(mvp);
{$HINTS ON}
    glUniformMatrix4fv(uCurrentMVPLocation, 1, GL_FALSE, @mvp[0, 0]);
{$ENDIF}
end;

procedure SetTexCoordPointer(p: Pointer; n: Integer);
begin
{$IFDEF GL2}
    glBindBuffer(GL_ARRAY_BUFFER, tBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * n * 2, p, GL_STATIC_DRAW);
    glEnableVertexAttribArray(aTexCoord);
    glVertexAttribPointer(aTexCoord, 2, GL_FLOAT, GL_FALSE, 0, pointer(0));
{$ELSE}
    n:= n;
    glTexCoordPointer(2, GL_FLOAT, 0, p);
{$ENDIF}
end;

procedure SetVertexPointer(p: Pointer; n: Integer);
begin
{$IFDEF GL2}
    glBindBuffer(GL_ARRAY_BUFFER, vBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * n * 2, p, GL_STATIC_DRAW);
    glEnableVertexAttribArray(aVertex);
    glVertexAttribPointer(aVertex, 2, GL_FLOAT, GL_FALSE, 0, pointer(0));
{$ELSE}
    n:= n;
    glVertexPointer(2, GL_FLOAT, 0, p);
{$ENDIF}
end;

procedure SetColorPointer(p: Pointer; n: Integer);
begin
{$IFDEF GL2}
    glBindBuffer(GL_ARRAY_BUFFER, cBuffer);
    glBufferData(GL_ARRAY_BUFFER, n * 4, p, GL_STATIC_DRAW);
    glEnableVertexAttribArray(aColor);
    glVertexAttribPointer(aColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, pointer(0));
{$ELSE}
    n:= n;
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, p);
{$ENDIF}
end;

procedure EnableTexture(enable:Boolean);
begin
    {$IFDEF GL2}
    if enable then
        glUniform1i(glGetUniformLocation(shaderMain, pchar('enableTexture')), 1)
    else
        glUniform1i(glGetUniformLocation(shaderMain, pchar('enableTexture')), 0);
    {$ELSE}
    if enable then
        glEnable(GL_TEXTURE_2D)
    else
        glDisable(GL_TEXTURE_2D);
    {$ENDIF}
end;

procedure UpdateViewLimits();
var tmp: real;
begin
    // cScaleFactor is 2.0 on "no zoom"
    tmp:= cScreenWidth / cScaleFactor;
    ViewRightX:= 1 + round(tmp);
    ViewLeftX:= round(-tmp);
    tmp:= cScreenHeight / cScaleFactor;
    ViewBottomY:= 1 + round(tmp) + cScreenHeight div 2;
    ViewTopY:= round(-tmp) + cScreenHeight div 2;

    // visual debugging fun :D
    if cViewLimitsDebug then
        begin
        // some margin on each side
        tmp:= min(cScreenWidth, cScreenHeight) div 2 / cScaleFactor;
        ViewLeftX  := ViewLeftX   + trunc(tmp);
        ViewRightX := ViewRightX  - trunc(tmp);
        ViewBottomY:= ViewBottomY - trunc(tmp);
        ViewTopY   := ViewTopY    + trunc(tmp);
        end;

    ViewWidth := ViewRightX  - ViewLeftX + 1;
    ViewHeight:= ViewBottomY - ViewTopY  + 1;
end;

procedure SetScale(f: GLfloat);
begin
    // leave immediately if scale factor did not change
    if f = cScaleFactor then
        exit;

    // for going back to default scaling just pop matrix
    if f = cDefaultZoomLevel then
        begin
        openglPopMatrix;
        end
    else
        begin
        openglPushMatrix; // save default scaling in matrix
        openglLoadIdentity();
        openglScalef(f / cScreenWidth, -f / cScreenHeight, 1.0);
        openglTranslatef(0, -cScreenHeight div 2, 0);
        end;

    cScaleFactor:= f;
    updateViewLimits();

    UpdateModelviewProjection;
end;

procedure DrawSpriteFromRect(Sprite: TSprite; r: TSDL_Rect; X, Y, Height, Position: LongInt); inline;
begin
r.y:= r.y + Height * Position;
r.h:= Height;
DrawTextureFromRect(X, Y, @r, SpritesData[Sprite].Texture)
end;

procedure DrawTextureFromRect(X, Y: LongInt; r: PSDL_Rect; SourceTexture: PTexture); inline;
begin
DrawTextureFromRectDir(X, Y, r^.w, r^.h, r, SourceTexture, 1)
end;

procedure DrawTextureFromRect(X, Y, W, H: LongInt; r: PSDL_Rect; SourceTexture: PTexture); inline;
begin
DrawTextureFromRectDir(X, Y, W, H, r, SourceTexture, 1)
end;

procedure DrawTextureFromRectDir(X, Y, W, H: LongInt; r: PSDL_Rect; SourceTexture: PTexture; Dir: LongInt);
var rr: TSDL_Rect;
    _l, _r, _t, _b: real;
    VertexBuffer, TextureBuffer: array [0..3] of TVertex2f;
begin
if (SourceTexture^.h = 0) or (SourceTexture^.w = 0) then
    exit;

{if isDxAreaOffscreen(X, W) <> 0 then
    exit;
if isDyAreaOffscreen(Y, H) <> 0 then
    exit;}

// do not draw anything outside the visible screen space (first check fixes some sprite drawing, e.g. hedgehogs)
if (abs(X) > W) and ((abs(X + W / 2) - W / 2) * 2 > ViewWidth) then
    exit;
if (abs(Y) > H) and ((abs(Y + H / 2 - (0.5 * cScreenHeight)) - H / 2) * 2 > ViewHeight) then
    exit;

rr.x:= X;
rr.y:= Y;
rr.w:= W;
rr.h:= H;

_l:= r^.x / SourceTexture^.w * SourceTexture^.rx;
_r:= (r^.x + r^.w) / SourceTexture^.w * SourceTexture^.rx;
_t:= r^.y / SourceTexture^.h * SourceTexture^.ry;
_b:= (r^.y + r^.h) / SourceTexture^.h * SourceTexture^.ry;

glBindTexture(GL_TEXTURE_2D, SourceTexture^.id);

if Dir < 0 then
    begin
    VertexBuffer[0].X:= X + rr.w div 2;
    VertexBuffer[0].Y:= Y;
    VertexBuffer[1].X:= X - rr.w div 2;
    VertexBuffer[1].Y:= Y;
    VertexBuffer[2].X:= X - rr.w div 2;
    VertexBuffer[2].Y:= rr.h + Y;
    VertexBuffer[3].X:= X + rr.w div 2;
    VertexBuffer[3].Y:= rr.h + Y;
    end
else
    begin
    VertexBuffer[0].X:= X;
    VertexBuffer[0].Y:= Y;
    VertexBuffer[1].X:= rr.w + X;
    VertexBuffer[1].Y:= Y;
    VertexBuffer[2].X:= rr.w + X;
    VertexBuffer[2].Y:= rr.h + Y;
    VertexBuffer[3].X:= X;
    VertexBuffer[3].Y:= rr.h + Y;
    end;

TextureBuffer[0].X:= _l;
TextureBuffer[0].Y:= _t;
TextureBuffer[1].X:= _r;
TextureBuffer[1].Y:= _t;
TextureBuffer[2].X:= _r;
TextureBuffer[2].Y:= _b;
TextureBuffer[3].X:= _l;
TextureBuffer[3].Y:= _b;

glVertexPointer(2, GL_FLOAT, 0, @VertexBuffer[0]);
glTexCoordPointer(2, GL_FLOAT, 0, @TextureBuffer[0]);
glDrawArrays(GL_TRIANGLE_FAN, 0, High(VertexBuffer) - Low(VertexBuffer) + 1);
end;

procedure DrawTexture(X, Y: LongInt; Texture: PTexture); inline;
begin
    DrawTexture(X, Y, Texture, 1.0);
end;

procedure DrawTexture(X, Y: LongInt; Texture: PTexture; Scale: GLfloat);
begin

openglPushMatrix;
openglTranslatef(X, Y, 0);

if Scale <> 1.0 then
    openglScalef(Scale, Scale, 1);

glBindTexture(GL_TEXTURE_2D, Texture^.id);

SetVertexPointer(@Texture^.vb, Length(Texture^.vb));
SetTexCoordPointer(@Texture^.tb, Length(Texture^.vb));

UpdateModelviewProjection;

glDrawArrays(GL_TRIANGLE_FAN, 0, Length(Texture^.vb));
openglPopMatrix;

end;

{ this contains tweaks in order to avoid land tile borders in blurry land mode }
procedure DrawTexture2(X, Y: LongInt; Texture: PTexture; Scale, Overlap: GLfloat);
var
    TextureBuffer: array [0..3] of TVertex2f;
begin
openglPushMatrix;
openglTranslatef(X, Y, 0);
openglScalef(Scale, Scale, 1);

glBindTexture(GL_TEXTURE_2D, Texture^.id);

TextureBuffer[0].X:= Texture^.tb[0].X + Overlap;
TextureBuffer[0].Y:= Texture^.tb[0].Y + Overlap;
TextureBuffer[1].X:= Texture^.tb[1].X - Overlap;
TextureBuffer[1].Y:= Texture^.tb[1].Y + Overlap;
TextureBuffer[2].X:= Texture^.tb[2].X - Overlap;
TextureBuffer[2].Y:= Texture^.tb[2].Y - Overlap;
TextureBuffer[3].X:= Texture^.tb[3].X + Overlap;
TextureBuffer[3].Y:= Texture^.tb[3].Y - Overlap;

SetVertexPointer(@Texture^.vb, Length(Texture^.vb));
SetTexCoordPointer(@TextureBuffer, Length(Texture^.vb));

UpdateModelviewProjection;

glDrawArrays(GL_TRIANGLE_FAN, 0, Length(Texture^.vb));
openglPopMatrix;
end;

procedure DrawTextureF(Texture: PTexture; Scale: GLfloat; X, Y, Frame, Dir, w, h: LongInt);
begin
    DrawTextureRotatedF(Texture, Scale, 0, 0, X, Y, Frame, Dir, w, h, 0)
end;

procedure DrawTextureRotatedF(Texture: PTexture; Scale, OffsetX, OffsetY: GLfloat; X, Y, Frame, Dir, w, h: LongInt; Angle: real);
var ft, fb, fl, fr: GLfloat;
    hw, hh, nx, ny: LongInt;
    VertexBuffer, TextureBuffer: array [0..3] of TVertex2f;
begin

// note: not taking scale into account
if isAreaOffscreen(X, Y, w, h) then
    exit;

{
// do not draw anything outside the visible screen space (first check fixes some sprite drawing, e.g. hedgehogs)
if (abs(X) > W) and ((abs(X + dir * OffsetX) - W / 2) * 2 > ViewWidth) then
    exit;
if (abs(Y) > H) and ((abs(Y + OffsetY - (cScreenHeight / 2)) - W / 2) * 2 > ViewHeight) then
    exit;
}

openglPushMatrix;

openglTranslatef(X, Y, 0);

if Dir = 0 then Dir:= 1;

if Angle <> 0 then
    openglRotatef(Angle, 0, 0, Dir);

if (OffsetX <> 0) or (OffsetY <> 0) then
    openglTranslatef(Dir*OffsetX, OffsetY, 0);

if Scale <> 1.0 then
    openglScalef(Scale, Scale, 1);

// Any reason for this call? And why only in t direction, not s?
//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

if Dir > 0 then
    hw:=  w div 2
else
    hw:= -w div 2;

hh:= h div 2;

nx:= Texture^.w div w; // number of horizontal frames
if nx = 0 then nx:= 1; // one frame is minimum
ny:= Texture^.h div h; // number of vertical frames
if ny = 0 then ny:= 1;

ft:= (Frame mod ny) * Texture^.ry / ny;
fb:= ((Frame mod ny) + 1) * Texture^.ry / ny;
fl:= (Frame div ny) * Texture^.rx / nx;
fr:= ((Frame div ny) + 1) * Texture^.rx / nx;

glBindTexture(GL_TEXTURE_2D, Texture^.id);

VertexBuffer[0].X:= -hw;
VertexBuffer[0].Y:= -hh;
VertexBuffer[1].X:=  hw;
VertexBuffer[1].Y:= -hh;
VertexBuffer[2].X:=  hw;
VertexBuffer[2].Y:=  hh;
VertexBuffer[3].X:= -hw;
VertexBuffer[3].Y:=  hh;

TextureBuffer[0].X:= fl;
TextureBuffer[0].Y:= ft;
TextureBuffer[1].X:= fr;
TextureBuffer[1].Y:= ft;
TextureBuffer[2].X:= fr;
TextureBuffer[2].Y:= fb;
TextureBuffer[3].X:= fl;
TextureBuffer[3].Y:= fb;

SetVertexPointer(@VertexBuffer[0], Length(VertexBuffer));
SetTexCoordPointer(@TextureBuffer[0], Length(VertexBuffer));

UpdateModelviewProjection;

glDrawArrays(GL_TRIANGLE_FAN, 0, Length(VertexBuffer));

openglPopMatrix;

end;

procedure DrawSpriteRotated(Sprite: TSprite; X, Y, Dir: LongInt; Angle: real);
begin
    DrawTextureRotated(SpritesData[Sprite].Texture,
        SpritesData[Sprite].Width,
        SpritesData[Sprite].Height,
        X, Y, Dir, Angle)
end;

procedure DrawSpriteRotatedF(Sprite: TSprite; X, Y, Frame, Dir: LongInt; Angle: real);
begin

if Angle <> 0  then
    begin
    // sized doubled because the sprite might occupy up to 1.4 * of it's
    // original size in each dimension, because it is rotated
    if isDxAreaOffscreen(X - SpritesData[Sprite].Width, 2 * SpritesData[Sprite].Width) <> 0 then
        exit;
    if isDYAreaOffscreen(Y - SpritesData[Sprite].Height, 2 * SpritesData[Sprite].Height) <> 0 then
        exit;
    end
else
    begin
    if isDxAreaOffscreen(X - SpritesData[Sprite].Width div 2, SpritesData[Sprite].Width) <> 0 then
        exit;
    if isDYAreaOffscreen(Y - SpritesData[Sprite].Height div 2 , SpritesData[Sprite].Height) <> 0 then
        exit;
    end;


openglPushMatrix;
openglTranslatef(X, Y, 0);

// mirror
if Dir < 0 then
    openglScalef(-1.0, 1.0, 1.0);

// apply angle after (conditional) mirroring
if Angle <> 0  then
    openglRotatef(Angle, 0, 0, 1);

DrawSprite(Sprite, -SpritesData[Sprite].Width div 2, -SpritesData[Sprite].Height div 2, Frame);

openglPopMatrix;

end;

procedure DrawTextureRotated(Texture: PTexture; hw, hh, X, Y, Dir: LongInt; Angle: real);
var VertexBuffer: array [0..3] of TVertex2f;
begin

if isDxAreaOffscreen(X, 2 * hw) <> 0 then
    exit;
if isDyAreaOffscreen(Y, 2 * hh) <> 0 then
    exit;

// do not draw anything outside the visible screen space (first check fixes some sprite drawing, e.g. hedgehogs)
{if (abs(X) > 2 * hw) and ((abs(X) - hw) > cScreenWidth / cScaleFactor) then
    exit;
if (abs(Y) > 2 * hh) and ((abs(Y - 0.5 * cScreenHeight) - hh) > cScreenHeight / cScaleFactor) then
    exit;}

openglPushMatrix;
openglTranslatef(X, Y, 0);

if Dir < 0 then
    begin
    hw:= - hw;
    openglRotatef(Angle, 0, 0, -1);
    end
else
    openglRotatef(Angle, 0, 0, 1);

glBindTexture(GL_TEXTURE_2D, Texture^.id);

VertexBuffer[0].X:= -hw;
VertexBuffer[0].Y:= -hh;
VertexBuffer[1].X:= hw;
VertexBuffer[1].Y:= -hh;
VertexBuffer[2].X:= hw;
VertexBuffer[2].Y:= hh;
VertexBuffer[3].X:= -hw;
VertexBuffer[3].Y:= hh;

SetVertexPointer(@VertexBuffer[0], Length(VertexBuffer));
SetTexCoordPointer(@Texture^.tb, Length(VertexBuffer));

UpdateModelviewProjection;

glDrawArrays(GL_TRIANGLE_FAN, 0, Length(VertexBuffer));

openglPopMatrix;

end;

procedure DrawSprite(Sprite: TSprite; X, Y, Frame: LongInt);
var row, col, numFramesFirstCol: LongInt;
begin
    if SpritesData[Sprite].imageHeight = 0 then
        exit;
    numFramesFirstCol:= SpritesData[Sprite].imageHeight div SpritesData[Sprite].Height;
    row:= Frame mod numFramesFirstCol;
    col:= Frame div numFramesFirstCol;
    DrawSprite(Sprite, X, Y, col, row);
end;

procedure DrawSprite(Sprite: TSprite; X, Y, FrameX, FrameY: LongInt);
var r: TSDL_Rect;
begin
    r.x:= FrameX * SpritesData[Sprite].Width;
    r.w:= SpritesData[Sprite].Width;
    r.y:= FrameY * SpritesData[Sprite].Height;
    r.h:= SpritesData[Sprite].Height;
    DrawTextureFromRect(X, Y, @r, SpritesData[Sprite].Texture)
end;

procedure DrawSpriteClipped(Sprite: TSprite; X, Y, TopY, RightX, BottomY, LeftX: LongInt);
var r: TSDL_Rect;
begin
r.x:= 0;
r.y:= 0;
r.w:= SpritesData[Sprite].Width;
r.h:= SpritesData[Sprite].Height;

if (X < LeftX) then
    r.x:= LeftX - X;
if (Y < TopY) then
    r.y:= TopY - Y;

if (Y + SpritesData[Sprite].Height > BottomY) then
    r.h:= BottomY - Y + 1;
if (X + SpritesData[Sprite].Width > RightX) then
    r.w:= RightX - X + 1;

if (r.h < r.y) or (r.w < r.x) then
    exit;

dec(r.h, r.y);
dec(r.w, r.x);

DrawTextureFromRect(X + r.x, Y + r.y, @r, SpritesData[Sprite].Texture)
end;

procedure DrawTextureCentered(X, Top: LongInt; Source: PTexture);
var scale: GLfloat;
    left : LongInt;
begin
    // scale down if larger than screen
    if (Source^.w + 20) > cScreenWidth then
        begin
        scale:= cScreenWidth / (Source^.w + 20);
        DrawTexture(X - round(Source^.w * scale) div 2, Top, Source, scale);
        end
    else
        begin
        left:= X - Source^.w div 2;
        if (not isAreaOffscreen(left, Top, Source^.w, Source^.h)) then
            DrawTexture(left, Top, Source);
        end;
end;

procedure DrawLine(X0, Y0, X1, Y1, Width: Single; color: LongWord); inline;
begin
DrawLine(X0, Y0, X1, Y1, Width, (color shr 24) and $FF, (color shr 16) and $FF, (color shr 8) and $FF, color and $FF)
end;

procedure DrawLine(X0, Y0, X1, Y1, Width: Single; r, g, b, a: Byte);
var VertexBuffer: array [0..1] of TVertex2f;
begin
    glEnable(GL_LINE_SMOOTH);

    EnableTexture(False);

    openglPushMatrix;
    openglTranslatef(WorldDx, WorldDy, 0);
    glLineWidth(Width);

    UpdateModelviewProjection;

    Tint(r, g, b, a);
    VertexBuffer[0].X:= X0;
    VertexBuffer[0].Y:= Y0;
    VertexBuffer[1].X:= X1;
    VertexBuffer[1].Y:= Y1;

    SetVertexPointer(@VertexBuffer[0], Length(VertexBuffer));
    glDrawArrays(GL_LINES, 0, Length(VertexBuffer));
    untint;

    openglPopMatrix;

    EnableTexture(True);

    glDisable(GL_LINE_SMOOTH);
end;

procedure DrawRect(rect: TSDL_Rect; r, g, b, a: Byte; Fill: boolean);
var VertexBuffer: array [0..3] of TVertex2f;
begin
// do not draw anything outside the visible screen space (first check fixes some sprite drawing, e.g. hedgehogs)
if (abs(rect.x) > rect.w) and ((abs(rect.x + rect.w / 2) - rect.w / 2) * 2 > ViewWidth) then
    exit;
if (abs(rect.y) > rect.h) and ((abs(rect.y + rect.h / 2 - (cScreenHeight / 2)) - rect.h / 2) * 2 > ViewHeight) then
    exit;

EnableTexture(False);

Tint(r, g, b, a);

with rect do
begin
    VertexBuffer[0].X:= x;
    VertexBuffer[0].Y:= y;
    VertexBuffer[1].X:= x + w;
    VertexBuffer[1].Y:= y;
    VertexBuffer[2].X:= x + w;
    VertexBuffer[2].Y:= y + h;
    VertexBuffer[3].X:= x;
    VertexBuffer[3].Y:= y + h;
end;

SetVertexPointer(@VertexBuffer[0], Length(VertexBuffer));
if Fill then
    glDrawArrays(GL_TRIANGLE_FAN, 0, Length(VertexBuffer))
else
    glDrawArrays(GL_LINE_LOOP, 0, Length(VertexBuffer));

untint;

EnableTexture(True);

end;

procedure DrawCircle(X, Y, Radius, Width: LongInt; r, g, b, a: Byte);
begin
    Tint(r, g, b, a);
    DrawCircle(X, Y, Radius, Width);
    untint;
end;

procedure DrawCircle(X, Y, Radius, Width: LongInt);
var
    i: LongInt;
    CircleVertex: array [0..59] of TVertex2f;
begin
    for i := 0 to 59 do begin
        CircleVertex[i].X := X + Radius*cos(i*pi/30);
        CircleVertex[i].Y := Y + Radius*sin(i*pi/30);
    end;

    EnableTexture(False);
    glEnable(GL_LINE_SMOOTH);
    openglPushMatrix;
    glLineWidth(Width);
    SetVertexPointer(@CircleVertex[0], 60);
    glDrawArrays(GL_LINE_LOOP, 0, 60);
    openglPopMatrix;
    EnableTexture(True);
    glDisable(GL_LINE_SMOOTH);
end;


procedure DrawHedgehog(X, Y: LongInt; Dir: LongInt; Pos, Step: LongWord; Angle: real);
const VertexBuffer: array [0..3] of TVertex2f = (
        (X: -16; Y: -16),
        (X:  16; Y: -16),
        (X:  16; Y:  16),
        (X: -16; Y:  16));
var l, r, t, b: real;
    TextureBuffer: array [0..3] of TVertex2f;
begin
    // do not draw anything outside the visible screen space (first check fixes some sprite drawing, e.g. hedgehogs)
    if (abs(X) > 32) and ((abs(X) - 16) * 2 > ViewWidth) then
        exit;
    if (abs(Y) > 32) and ((abs(Y - cScreenHeight / 2) - 16) * 2 > ViewHeight) then
        exit;

    t:= Pos * 32 / HHTexture^.h;
    b:= (Pos + 1) * 32 / HHTexture^.h;

    if Dir = -1 then
        begin
        l:= (Step + 1) * 32 / HHTexture^.w;
        r:= Step * 32 / HHTexture^.w
        end
    else
        begin
        l:= Step * 32 / HHTexture^.w;
        r:= (Step + 1) * 32 / HHTexture^.w
    end;

    openglPushMatrix();
    openglTranslatef(X, Y, 0);
    openglRotatef(Angle, 0, 0, 1);

    glBindTexture(GL_TEXTURE_2D, HHTexture^.id);

    TextureBuffer[0].X:= l;
    TextureBuffer[0].Y:= t;
    TextureBuffer[1].X:= r;
    TextureBuffer[1].Y:= t;
    TextureBuffer[2].X:= r;
    TextureBuffer[2].Y:= b;
    TextureBuffer[3].X:= l;
    TextureBuffer[3].Y:= b;

    SetVertexPointer(@VertexBuffer[0], Length(VertexBuffer));
    SetTexCoordPointer(@TextureBuffer[0], Length(VertexBuffer));

    UpdateModelviewProjection;

    glDrawArrays(GL_TRIANGLE_FAN, 0, Length(VertexBuffer));

    openglPopMatrix;
end;

procedure DrawScreenWidget(widget: POnScreenWidget);
{$IFDEF USE_TOUCH_INTERFACE}
var alpha: byte = $FF;
begin
with widget^ do
    begin
    if (fadeAnimStart <> 0) then
        begin
        if RealTicks > (fadeAnimStart + FADE_ANIM_TIME) then
            fadeAnimStart:= 0
        else
            if show then
                alpha:= Byte(trunc((RealTicks - fadeAnimStart)/FADE_ANIM_TIME * $FF))
            else
                alpha:= Byte($FF - trunc((RealTicks - fadeAnimStart)/FADE_ANIM_TIME * $FF));
        end;

    with moveAnim do
        if animate then
            if RealTicks > (startTime + MOVE_ANIM_TIME) then
                begin
                startTime:= 0;
                animate:= false;
                frame.x:= target.x;
                frame.y:= target.y;
                active.x:= active.x + (target.x - source.x);
                active.y:= active.y + (target.y - source.y);
                end
            else
                begin
                frame.x:= source.x + Round((target.x - source.x) * ((RealTicks - startTime) / MOVE_ANIM_TIME));
                frame.y:= source.y + Round((target.y - source.y) * ((RealTicks - startTime) / MOVE_ANIM_TIME));
                end;

    if show or (fadeAnimStart <> 0) then
        begin
        Tint($FF, $FF, $FF, alpha);
        DrawTexture(frame.x, frame.y, spritesData[sprite].Texture, buttonScale);
        untint;
        end;
    end;
{$ELSE}
begin
widget:= widget; // avoid hint
{$ENDIF}
end;

procedure BeginWater;
begin
{$IFDEF GL2}
    glUseProgram(shaderWater);
    uCurrentMVPLocation:=uWaterMVPLocation;
    UpdateModelviewProjection;
    glDisableVertexAttribArray(aTexCoord);
    glEnableVertexAttribArray(aColor);
{$ENDIF}

    openglUseColorOnly(true);
end;

procedure EndWater;
begin
{$IFDEF GL2}
    glUseProgram(shaderMain);
    uCurrentMVPLocation:=uMainMVPLocation;
    UpdateModelviewProjection;
    glDisableVertexAttribArray(aColor);
    glEnableVertexAttribArray(aTexCoord);
{$ENDIF}

    openglUseColorOnly(false);
end;

procedure DrawWaterBody(pVertexBuffer: Pointer);
begin
        UpdateModelviewProjection;

        BeginWater;

        if SuddenDeathDmg then
            SetColorPointer(@SDWaterColorArray[0], 4)
        else
            SetColorPointer(@WaterColorArray[0], 4);

        SetVertexPointer(pVertexBuffer, 4);

        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

        EndWater;
end;

procedure openglTint(r, g, b, a: Byte); inline;
{$IFDEF GL2}
const
    scale:Real = 1.0/255.0;
{$ENDIF}
begin
    {$IFDEF GL2}
    glUniform4f(uMainTintLocation, r*scale, g*scale, b*scale, a*scale);
    {$ELSE}
    glColor4ub(r, g, b, a);
    {$ENDIF}
end;

procedure Tint(r, g, b, a: Byte); inline;
var
    nc, tw: Longword;
begin
    nc:= (r shl 24) or (g shl 16) or (b shl 8) or a;

    if nc = lastTint then
        exit;

    if GrayScale then
        begin
        tw:= round(r * RGB_LUMINANCE_RED + g * RGB_LUMINANCE_GREEN + b * RGB_LUMINANCE_BLUE);
        if tw > 255 then
            tw:= 255;
        r:= tw;
        g:= tw;
        b:= tw
        end;

    openglTint(r, g, b, a);
    lastTint:= nc;
end;

procedure Tint(c: Longword); inline;
begin
    if c = lastTint then exit;
    Tint(((c shr 24) and $FF), ((c shr 16) and $FF), (c shr 8) and $FF, (c and $FF))
end;

procedure untint(); inline;
begin
    if cWhiteColor = lastTint then exit;
    openglTint($FF, $FF, $FF, $FF);
    lastTint:= cWhiteColor;
end;

procedure setTintAdd(f: boolean); inline;
begin
    if f then
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_ADD)
    else
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
end;

procedure initModule;
begin
end;

procedure freeModule;
begin
{$IFDEF GL2}
    glDeleteProgram(shaderMain);
    glDeleteProgram(shaderWater);
    glDeleteBuffers(1, @vBuffer);
    glDeleteBuffers(1, @tBuffer);
    glDeleteBuffers(1, @cBuffer);
{$ENDIF}
end;
end.
