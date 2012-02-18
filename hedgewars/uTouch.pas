(*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2012 Richard Deurwaarder <xeli@xelification.com>
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

unit uTouch;

interface

uses sysutils, uConsole, uVariables, SDLh, uFloat, uConsts, uIO, GLUnit, uTypes;


procedure initModule;

procedure ProcessTouch;
procedure onTouchDown(x,y: Longword; pointerId: TSDL_FingerId);
procedure onTouchMotion(x,y: Longword; dx,dy: LongInt; pointerId: TSDL_FingerId);
procedure onTouchUp(x,y: Longword; pointerId: TSDL_FingerId);
function convertToCursorX(x: LongInt): LongInt;
function convertToCursorY(y: LongInt): LongInt;
function convertToCursorDeltaX(x: LongInt): LongInt;
function convertToCursorDeltaY(y: LongInt): LongInt;
function addFinger(x,y: Longword; id: TSDL_FingerId): PTouch_Data;
function updateFinger(x,y,dx,dy: Longword; id: TSDL_FingerId): PTouch_Data;
procedure deleteFinger(id: TSDL_FingerId);
procedure onTouchClick(finger: TTouch_Data);
procedure onTouchDoubleClick(finger: TTouch_Data);

function findFinger(id: TSDL_FingerId): PTouch_Data;
procedure aim(finger: TTouch_Data);
function isOnCrosshair(finger: TTouch_Data): boolean;
function isOnCurrentHog(finger: TTouch_Data): boolean;
procedure convertToWorldCoord(var x,y: LongInt; finger: TTouch_Data);
procedure convertToFingerCoord(var x,y: LongInt; oldX, oldY: LongInt);
function fingerHasMoved(finger: TTouch_Data): boolean;
function calculateDelta(finger1, finger2: TTouch_Data): LongInt;
function getSecondFinger(finger: TTouch_Data): PTouch_Data;
function isOnRect(rect: TSDL_Rect; finger: TTouch_Data): boolean;
function isOnRect(x,y,w,h: LongInt; finger: TTouch_Data): boolean;
procedure printFinger(finger: TTouch_Data);
implementation

const
    clicktime = 200;
    nilFingerId = High(TSDL_FingerId);

var
    pointerCount : Longword;
    fingers: array of TTouch_Data;
    moveCursor : boolean;
    invertCursor : boolean;

    xTouchClick,yTouchClick : LongInt;
    timeSinceClick : Longword;

    //Pinch to zoom 
    pinchSize : LongInt;
    baseZoomValue: GLFloat;

    //aiming
    aimingCrosshair: boolean;
    aimingUp, aimingDown: boolean; 
    targetAngle: LongInt;

    buttonsDown: Longword;

procedure onTouchDown(x,y: Longword; pointerId: TSDL_FingerId);
var 
    finger: PTouch_Data;
begin
{$IFDEF USE_TOUCH_INTERFACE}
finger := addFinger(x,y,pointerId);

inc(buttonsDown);//inc buttonsDown, if we don't see a button down we'll dec it

if isOnCrosshair(finger^) then
begin
    aimingCrosshair:= true;
    aim(finger^);
    moveCursor:= false;
    exit;
end;

if isOnRect(fireButton.active, finger^) then
    begin
    spaceKey:= true;
    moveCursor:= false;
    finger^.pressedWidget:= @fireButton;
    exit;
    end;
if isOnRect(arrowLeft.active, finger^) then
    begin
    leftKey:= true;
    moveCursor:= false;
    finger^.pressedWidget:= @arrowLeft;
    exit;
    end;
if isOnRect(arrowRight.active, finger^) then
    begin
    rightKey:= true;
    moveCursor:= false;
    finger^.pressedWidget:= @arrowRight;
    exit;
    end;
if isOnRect(arrowUp.active, finger^) then
     begin
     upKey:= true;
     moveCursor:= false;
     finger^.pressedWidget:= @arrowUp;
     exit;
     end;
if isOnRect(arrowDown.active, finger^) then
     begin
     downKey:= true;
     moveCursor:= false;
     finger^.pressedWidget:= @arrowDown;
     exit;
     end;

if isOnRect(backjump.active, finger^) then
     begin
     enterKey:= true;
     moveCursor:= false;
     finger^.pressedWidget:= @backjump;
     exit;
     end;
if isOnRect(forwardjump.active, finger^) then
     begin
     backspaceKey:= true;
     moveCursor:= false;
     finger^.pressedWidget:= @forwardjump;
     exit;
     end;
if isOnRect(pauseButton.active, finger^) then
     begin
     isPaused:= not isPaused;
     moveCursor:= false;
     finger^.pressedWidget:= @pauseButton;
     exit;
     end;

dec(buttonsDown);//no buttonsDown, undo the inc() above
if buttonsDown = 0 then
    begin
    moveCursor:= true;
    if pointerCount = 2 then
        begin
        moveCursor:= false;
        pinchSize := calculateDelta(finger^, getSecondFinger(finger^)^);
        baseZoomValue := ZoomValue
    end;
end;
{$ENDIF}
end;

procedure onTouchMotion(x,y: Longword;dx,dy: LongInt; pointerId: TSDL_FingerId);
var
    finger, secondFinger: PTouch_Data;
    currentPinchDelta, zoom : single;
begin
finger:= updateFinger(x,y,dx,dy,pointerId);

if moveCursor then
    begin
        if invertCursor then
        begin
            CursorPoint.X := CursorPoint.X - finger^.dx;
            CursorPoint.Y := CursorPoint.Y + finger^.dy;
        end
    else
        begin
            CursorPoint.X := CursorPoint.X + finger^.dx;
            CursorPoint.Y := CursorPoint.Y - finger^.dy;
        end;
        exit //todo change into switch rather than ugly ifs
    end;
    
if aimingCrosshair then 
    begin
        aim(finger^);
        exit
    end;

if (buttonsDown = 0) and (pointerCount = 2) then
    begin
       secondFinger := getSecondFinger(finger^);
       currentPinchDelta := calculateDelta(finger^, secondFinger^) - pinchSize;
       zoom := currentPinchDelta/cScreenWidth;
       ZoomValue := baseZoomValue - (zoom * cMinMaxZoomLevelDelta);
       if ZoomValue < cMaxZoomLevel then
           ZoomValue := cMaxZoomLevel;
       if ZoomValue > cMinZoomLevel then
           ZoomValue := cMinZoomLevel;
    end;

end;

procedure onTouchUp(x,y: Longword; pointerId: TSDL_FingerId);
var
    finger: PTouch_Data;
    widget: POnScreenWidget;
begin
{$IFDEF USE_TOUCH_INTERFACE}
x := x;
y := y;
finger:= updateFinger(x,y,0,0,pointerId);
//Check for onTouchClick event
if ((RealTicks - finger^.timeSinceDown) < clickTime) AND not(fingerHasMoved(finger^)) then
    onTouchClick(finger^);
WriteToConsole(Format('%d', [buttonsDown]));

if aimingCrosshair then
    begin
    aimingCrosshair:= false;
    upKey:= false;
    downKey:= false;
    dec(buttonsDown);
    end;

widget:= finger^.pressedWidget;
if (buttonsDown > 0) and (widget <> nil) then
    begin
    dec(buttonsDown);
    
    if widget = @arrowLeft then
        leftKey:= false;
    
    if widget = @arrowRight then
        rightKey:= false;

    if widget = @arrowUp then
        upKey:= false;

    if widget = @arrowDown then
        downKey:= false;

    if widget = @fireButton then
        spaceKey:= false;

    if widget = @backjump then
        enterKey:= false;

    if widget = @forwardjump then
        backspaceKey:= false;
    end;
 
deleteFinger(pointerId);
{$ENDIF}
end;

procedure onTouchDoubleClick(finger: TTouch_Data);
begin
finger := finger;//avoid compiler hint
end;

procedure onTouchClick(finger: TTouch_Data);
begin
if (RealTicks - timeSinceClick < 300) and (sqrt(sqr(finger.X-xTouchClick) + sqr(finger.Y-yTouchClick)) < 30) then
    begin
    onTouchDoubleClick(finger);
    timeSinceClick:= 0;//we make an assumption there won't be an 'click' in the first 300 ticks(milliseconds) 
    exit; 
    end;

xTouchClick:= finger.x;
yTouchClick:= finger.y;
timeSinceClick:= RealTicks;

if bShowAmmoMenu then
    begin 
    if isOnRect(AmmoRect, finger) then
        begin
        CursorPoint.X:= finger.x;
        CursorPoint.Y:= finger.y;
        doPut(CursorPoint.X, CursorPoint.Y, false); 
        end
    else
        bShowAmmoMenu:= false;
    exit;
    end;


if isOnCurrentHog(finger) then
    begin
    bShowAmmoMenu := true;
    exit;
    end;
end;

function addFinger(x,y: Longword; id: TSDL_FingerId): PTouch_Data;
var 
    xCursor, yCursor, index : LongInt;
begin
    //Check array sizes
    if length(fingers) < Integer(pointerCount) then 
    begin
        setLength(fingers, length(fingers)*2);
        for index := length(fingers) div 2 to length(fingers) do
            fingers[index].id := nilFingerId;
    end;
    
    
    xCursor := convertToCursorX(x);
    yCursor := convertToCursorY(y);
    
    //on removing fingers, all fingers are moved to the left
    //with dynamic arrays being zero based, the new position of the finger is the old pointerCount
    fingers[pointerCount].id := id;
    fingers[pointerCount].historicalX := xCursor;
    fingers[pointerCount].historicalY := yCursor;
    fingers[pointerCount].x := xCursor;
    fingers[pointerCount].y := yCursor;
    fingers[pointerCount].dx := 0;
    fingers[pointerCount].dy := 0;
    fingers[pointerCount].timeSinceDown:= RealTicks;
    fingers[pointerCount].pressedWidget:= nil;
 
    addFinger:= @fingers[pointerCount];
    inc(pointerCount);
end;

function updateFinger(x,y,dx,dy: Longword; id: TSDL_FingerId): PTouch_Data;
begin
   updateFinger:= findFinger(id);

   updateFinger^.x:= convertToCursorX(x);
   updateFinger^.y:= convertToCursorY(y);
   updateFinger^.dx:= convertToCursorDeltaX(dx);
   updateFinger^.dy:= convertToCursorDeltaY(dy);
end;

procedure deleteFinger(id: TSDL_FingerId);
var
    index : Longword;
begin
    
    dec(pointerCount);
    for index := 0 to pointerCount do
    begin
        if fingers[index].id = id then
        begin
 
            //put the last finger into the spot of the finger to be removed, 
            //so that all fingers are packed to the far left
            if  pointerCount <> index then
                begin
                fingers[index].id := fingers[pointerCount].id;    
                fingers[index].x := fingers[pointerCount].x;    
                fingers[index].y := fingers[pointerCount].y;    
                fingers[index].historicalX := fingers[pointerCount].historicalX;    
                fingers[index].historicalY := fingers[pointerCount].historicalY;    
                fingers[index].timeSinceDown := fingers[pointerCount].timeSinceDown;

                fingers[pointerCount].id := nilFingerId;
            end
        else fingers[index].id := nilFingerId;
            break;
        end;
    end;

end;

procedure ProcessTouch;
var
    deltaAngle: LongInt;
begin
invertCursor := not(bShowAmmoMenu);
if aimingCrosshair then
    if CurrentHedgehog^.Gear <> nil then
        begin
        deltaAngle:= CurrentHedgehog^.Gear^.Angle - targetAngle;
        if (deltaAngle > -5) and (deltaAngle < 5) then 
            begin
                upKey:= false;
                aimingUp:= false;
                downKey:= false;
                aimingDown:= false;
            end
        else
            begin
            if (deltaAngle < 0) then
                begin
                if aimingUp then
                    begin
                    upKey:= false;
                    aimingUp:= false;
                    end;
                downKey:= true;
                aimingDown:= true;
                end
            else
                begin
                if aimingDown then
                    begin
                    downKey:= false;
                    aimingDown:= false;
                    end;
                upKey:= true;
                aimingUp:= true;
                end; 
            end;
        end
    else  
        begin
        if aimingUp then
            begin
            upKey:= false;
            aimingUp:= false;
            end;
        if aimingDown then
            begin
            upKey:= false;
            aimingDown:= false;
            end;
        end;
end;

function findFinger(id: TSDL_FingerId): PTouch_Data;
var
    index: LongWord;
begin
    for index := 0 to High(fingers) do
        if fingers[index].id = id then 
            begin
            findFinger := @fingers[index];
            break;
            end;
end;

procedure aim(finger: TTouch_Data);
var 
    hogX, hogY, touchX, touchY, deltaX, deltaY: LongInt;
begin
    if CurrentHedgehog^.Gear <> nil then
        begin
        touchX := 0;//avoid compiler hint
        touchY := 0;
        hogX := hwRound(CurrentHedgehog^.Gear^.X);
        hogY := hwRound(CurrentHedgehog^.Gear^.Y);

        convertToWorldCoord(touchX, touchY, finger);
        deltaX := abs(TouchX-HogX);
        deltaY := TouchY-HogY;
        
        targetAngle:= (Round(DeltaY / sqrt(sqr(deltaX) + sqr(deltaY)) * 2048) + 2048) div 2;
        end; //if CurrentHedgehog^.Gear <> nil
end;

// These 4 convertToCursor functions convert xy coords from the SDL coordinate system to our CursorPoint coor system:
// - the SDL coordinate system goes from 0 to 32768 on the x axis and 0 to 32768 on the y axis, (0,0) being top left;
// - the CursorPoint coordinate system goes from -cScreenWidth/2 to cScreenWidth/2 on the x axis
//   and 0 to cScreenHeight on the x axis, (-cScreenWidth, cScreenHeight) being top left.
function convertToCursorX(x: LongInt): LongInt;
begin
    convertToCursorX := round((x/32768)*cScreenWidth) - (cScreenWidth shr 1);
end;

function convertToCursorY(y: LongInt): LongInt;
begin
    convertToCursorY := cScreenHeight - round((y/32768)*cScreenHeight)
end;

function convertToCursorDeltaX(x: LongInt): LongInt;
begin
    convertToCursorDeltaX := round(x/32768*cScreenWidth)
end;

function convertToCursorDeltaY(y: LongInt): LongInt;
begin
    convertToCursorDeltaY := round(y/32768*cScreenHeight)
end;

function isOnCrosshair(finger: TTouch_Data): boolean;
var
    x,y : LongInt;
begin
    x := 0;//avoid compiler hint
    y := 0;
    convertToFingerCoord(x, y, CrosshairX, CrosshairY);
  isOnCrosshair:= sqrt(sqr(finger.x-x) + sqr(finger.y-y)) < 50;
//    isOnCrosshair:= isOnRect(x-24, y-24, 48, 48, finger);
end;

function isOnCurrentHog(finger: TTouch_Data): boolean;
var
    x,y : LongInt;
begin
    x := 0;
    y := 0;
    convertToFingerCoord(x,y, hwRound(CurrentHedgehog^.Gear^.X), hwRound(CurrentHedgehog^.Gear^.Y));
    isOnCurrentHog := sqrt(sqr(finger.X-x) + sqr(finger.Y-y)) < 50;
end;

procedure convertToFingerCoord(var x,y : LongInt; oldX, oldY: LongInt);
begin
    x := oldX + WorldDx;
    y := cScreenHeight - (oldY + WorldDy);
end;

procedure convertToWorldCoord(var x,y: LongInt; finger: TTouch_Data);
begin
//if x <> nil then 
    x := finger.x-WorldDx;
//if y <> nil then 
    y := (cScreenHeight - finger.y)-WorldDy;
end;

//Method to calculate the distance this finger has moved since the downEvent
function fingerHasMoved(finger: TTouch_Data): boolean;
begin
    fingerHasMoved := trunc(sqrt(sqr(finger.X-finger.historicalX) + sqr(finger.y-finger.historicalY))) > 330;
end;

function calculateDelta(finger1, finger2: TTouch_Data): LongInt; inline;
begin
    calculateDelta := Round(sqrt(sqr(finger2.x-finger1.x) + sqr(finger2.y-finger1.y)));
end;

// Under the premise that all pointer ids in pointerIds:TSDL_FingerId are packed to the far left.
// If the pointer to be ignored is not pointerIds[0] the second must be there
function getSecondFinger(finger: TTouch_Data): PTouch_Data;
begin
    if fingers[0].id = finger.id then
        getSecondFinger := @fingers[1]
    else
        getSecondFinger := @fingers[0];
end;

function isOnRect(rect: TSDL_Rect; finger: TTouch_Data): boolean;
begin
    isOnRect:= isOnRect(rect.x, rect.y, rect.w, rect.h, finger);
end;

function isOnRect(x,y,w,h: LongInt; finger: TTouch_Data): boolean;
begin
    isOnRect:= (finger.x > x)   and
               (finger.x < x + w) and
               (cScreenHeight - finger.y > y) and
               (cScreenHeight - finger.y < y + h);
end;

procedure printFinger(finger: TTouch_Data);
begin
    WriteToConsole(Format('id:%d, (%d,%d), (%d,%d), time: %d', [finger.id, finger.x, finger.y, finger.historicalX, finger.historicalY, finger.timeSinceDown]));
end;

procedure initModule;
var
    index: Longword;
    //uRenderCoordScaleX, uRenderCoordScaleY: Longword;
begin
    buttonsDown:= 0;

    setLength(fingers, 4);
    for index := 0 to High(fingers) do 
        fingers[index].id := nilFingerId;
end;

begin
end.
