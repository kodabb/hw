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

unit uAIAmmoTests;
interface
uses SDLh, uConsts, uFloat, uTypes;
const amtest_OnTurn = $00000001;

type TAttackParams = record
        Time: Longword;
        Angle, Power: LongInt;
        ExplX, ExplY, ExplR: LongInt;
        AttackPutX, AttackPutY: LongInt;
        end;

function TestBazooka(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestSnowball(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestGrenade(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestMolotov(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestClusterBomb(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestWatermelon(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestMortar(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestShotgun(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestDesertEagle(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestBaseballBat(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestFirePunch(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestAirAttack(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestTeleport(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
function TestHammer(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;

type TAmmoTestProc = function (Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
    TAmmoTest = record
            proc: TAmmoTestProc;
            flags: Longword;
            end;

const AmmoTests: array[TAmmoType] of TAmmoTest =
            (
            (proc: nil;              flags: 0), // amNothing
            (proc: @TestGrenade;     flags: 0), // amGrenade
            (proc: @TestClusterBomb; flags: 0), // amClusterBomb
            (proc: @TestBazooka;     flags: 0), // amBazooka
            (proc: nil;              flags: 0), // amBee
            (proc: @TestShotgun;     flags: 0), // amShotgun
            (proc: nil;              flags: 0), // amPickHammer
            (proc: nil;              flags: 0), // amSkip
            (proc: nil;              flags: 0), // amRope
            (proc: nil;              flags: 0), // amMine
            (proc: @TestDesertEagle; flags: 0), // amDEagle
            (proc: nil;              flags: 0), // amDynamite
            (proc: @TestFirePunch;   flags: 0), // amFirePunch
            (proc: @TestFirePunch;   flags: 0), // amWhip
            (proc: @TestBaseballBat; flags: 0), // amBaseballBat
            (proc: nil;              flags: 0), // amParachute
            (proc: @TestAirAttack;   flags: amtest_OnTurn), // amAirAttack
            (proc: nil;              flags: 0), // amMineStrike
            (proc: nil;              flags: 0), // amBlowTorch
            (proc: nil;              flags: 0), // amGirder
            (proc: nil;              flags: 0), // amTeleport
            //(proc: @TestTeleport;    flags: amtest_OnTurn), // amTeleport
            (proc: nil;              flags: 0), // amSwitch
            (proc: @TestMortar;      flags: 0), // amMortar
            (proc: nil;              flags: 0), // amKamikaze
            (proc: nil;              flags: 0), // amCake
            (proc: nil;              flags: 0), // amSeduction
            (proc: @TestWatermelon;  flags: 0), // amWatermelon
            (proc: nil;              flags: 0), // amHellishBomb
            (proc: nil;              flags: 0), // amNapalm
            (proc: nil;              flags: 0), // amDrill
            (proc: nil;              flags: 0), // amBallgun
            (proc: nil;              flags: 0), // amRCPlane
            (proc: nil;              flags: 0), // amLowGravity
            (proc: nil;              flags: 0), // amExtraDamage
            (proc: nil;              flags: 0), // amInvulnerable
            (proc: nil;              flags: 0), // amExtraTime
            (proc: nil;              flags: 0), // amLaserSight
            (proc: nil;              flags: 0), // amVampiric
            (proc: nil;              flags: 0), // amSniperRifle
            (proc: nil;              flags: 0), // amJetpack
            (proc: @TestMolotov;     flags: 0), // amMolotov
            (proc: nil;              flags: 0), // amBirdy
            (proc: nil;              flags: 0), // amPortalGun
            (proc: nil;              flags: 0), // amPiano
            (proc: @TestGrenade;     flags: 0), // amGasBomb
            (proc: @TestShotgun;     flags: 0), // amSineGun
            (proc: nil;              flags: 0), // amFlamethrower
            (proc: @TestGrenade;     flags: 0), // amSMine
            (proc: @TestHammer;      flags: 0), // amHammer
            (proc: nil;              flags: 0), // amResurrector
            (proc: nil;              flags: 0), // amDrillStrike
            (proc: nil;              flags: 0), // amSnowball
            (proc: nil;              flags: 0), // amTardis
            (proc: nil;              flags: 0), // amStructure
            (proc: nil;              flags: 0) // amLandGun
            );

const BadTurn = Low(LongInt) div 4;

implementation
uses uAIMisc, uVariables, uUtils;

function Metric(x1, y1, x2, y2: LongInt): LongInt; inline;
begin
Metric:= abs(x1 - x2) + abs(y1 - y2)
end;

function TestBazooka(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var Vx, Vy, r, mX, mY: real;
    rTime: LongInt;
    EX, EY: LongInt;
    valueResult: LongInt;
    x, y, dX, dY: real;
    t: LongInt;
    value: LongInt;
begin
mX:= hwFloat2Float(Me^.X);
mY:= hwFloat2Float(Me^.Y);
ap.Time:= 0;
rTime:= 350;
ap.ExplR:= 0;
valueResult:= BadTurn;
repeat
    rTime:= rTime + 300 + Level * 50 + random(300);
    Vx:= - cWindSpeedf * rTime * 0.5 + (Targ.X + AIrndSign(2) - mX) / rTime;
    Vy:= cGravityf * rTime * 0.5 - (Targ.Y - mY) / rTime;
    r:= sqrt(sqr(Vx) + sqr(Vy));
    if not (r > 1) then
        begin
        x:= mX;
        y:= mY;
        dX:= Vx;
        dY:= -Vy;
        t:= rTime;
        repeat
            x:= x + dX;
            y:= y + dY;
            dX:= dX + cWindSpeedf;
            dY:= dY + cGravityf;
            dec(t)
        until TestCollExcludingMe(Me, trunc(x), trunc(y), 5) or (t <= 0);
        
        EX:= trunc(x);
        EY:= trunc(y);
        if Me^.Hedgehog^.BotLevel = 1 then
            value:= RateExplosion(Me, EX, EY, 101, 3)
        else value:= RateExplosion(Me, EX, EY, 101);
        if value = 0 then
            value:= - Metric(Targ.X, Targ.Y, EX, EY) div 64;
    if valueResult <= value then
        begin
        ap.Angle:= DxDy2AttackAngle(Vx, Vy) + AIrndSign(random((Level - 1) * 9));
        ap.Power:= trunc(r * cMaxPower) - random((Level - 1) * 17 + 1);
        ap.ExplR:= 100;
        ap.ExplX:= EX;
        ap.ExplY:= EY;
        valueResult:= value
        end;
    end
until (rTime > 4250);
TestBazooka:= valueResult
end;

function TestSnowball(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var Vx, Vy, r: hwFloat;
    rTime: LongInt;
    EX, EY: LongInt;
    valueResult: LongInt;
    x, y, dX, dY: hwFloat;
    t: LongInt;
    value: LongInt;

begin
ap.Time:= 0;
rTime:= 350;
ap.ExplR:= 0;
valueResult:= BadTurn;
repeat
    rTime:= rTime + 300 + Level * 50 + random(300);
    Vx:= - cWindSpeed * rTime * _0_5 + (int2hwFloat(Targ.X + AIrndSign(2)) - Me^.X) / int2hwFloat(rTime);
    Vy:= cGravity * rTime * _0_5 - (int2hwFloat(Targ.Y) - Me^.Y) / int2hwFloat(rTime);
    r:= Distance(Vx, Vy);
    if not (r > _1) then
        begin
        x:= Me^.X;
        y:= Me^.Y;
        dX:= Vx;
        dY:= -Vy;
        t:= rTime;
        repeat
            x:= x + dX;
            y:= y + dY;
            dX:= dX + cWindSpeed;
            dY:= dY + cGravity;
            dec(t)
        until TestCollExcludingMe(Me, hwRound(x), hwRound(y), 5) or (t <= 0);
        EX:= hwRound(x);
        EY:= hwRound(y);
        value:= RateExplosion(Me, EX, EY, 5);
        if value = 0 then
            value:= - Metric(Targ.X, Targ.Y, EX, EY) div 64;

        if valueResult <= value then
            begin
            ap.Angle:= DxDy2AttackAngle(Vx, Vy) + AIrndSign(random((Level - 1) * 9));
            ap.Power:= hwRound(r * cMaxPower) - random((Level - 1) * 17 + 1);
            ap.ExplR:= 100;
            ap.ExplX:= EX;
            ap.ExplY:= EY;
            valueResult:= value
            end;
     end
until (rTime > 4250);
TestSnowball:= valueResult
end;

function TestMolotov(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var Vx, Vy, r: hwFloat;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, dY: hwFloat;
    t: LongInt;
begin
valueResult:= BadTurn;
TestTime:= 0;
ap.ExplR:= 0;
repeat
    inc(TestTime, 300);
    Vx:= (int2hwFloat(Targ.X) - Me^.X) / int2hwFloat(TestTime);
    Vy:= cGravity * (TestTime div 2) - (int2hwFloat(Targ.Y) - Me^.Y) / int2hwFloat(TestTime);
    r:= Distance(Vx, Vy);
    if not (r > _1) then
        begin
        x:= Me^.X;
        y:= Me^.Y;
        dY:= -Vy;
        t:= TestTime;
        repeat
            x:= x + Vx;
            y:= y + dY;
            dY:= dY + cGravity;
            dec(t)
        until TestCollExcludingMe(Me, hwRound(x), hwRound(y), 7) or (t = 0);
        EX:= hwRound(x);
        EY:= hwRound(y);
        if t < 50 then
            Score:= RateExplosion(Me, EX, EY, 97)  // average of 17 attempts, most good, but some failing spectacularly
        else
            Score:= BadTurn;
                  
        if valueResult < Score then
            begin
            ap.Angle:= DxDy2AttackAngle(Vx, Vy) + AIrndSign(random(Level));
            ap.Power:= hwRound(r * cMaxPower) + AIrndSign(random(Level) * 15);
            ap.Time:= TestTime;
            ap.ExplR:= 100;
            ap.ExplX:= EX;
            ap.ExplY:= EY;
            valueResult:= Score
            end;
        end
until (TestTime > 4250);
TestMolotov:= valueResult
end;

function TestGrenade(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
const tDelta = 24;
var Vx, Vy, r: hwFloat;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, dY: hwFloat;
    t: LongInt;
begin
valueResult:= BadTurn;
TestTime:= 0;
ap.ExplR:= 0;
repeat
    inc(TestTime, 1000);
    Vx:= (int2hwFloat(Targ.X) - Me^.X) / int2hwFloat(TestTime + tDelta);
    Vy:= cGravity * ((TestTime + tDelta) div 2) - (int2hwFloat(Targ.Y) - Me^.Y) / int2hwFloat(TestTime + tDelta);
    r:= Distance(Vx, Vy);
    if not (r > _1) then
        begin
        x:= Me^.X;
        y:= Me^.Y;
        dY:= -Vy;
        t:= TestTime;
        repeat
            x:= x + Vx;
            y:= y + dY;
            dY:= dY + cGravity;
            dec(t)
        until TestCollExcludingMe(Me, hwRound(x), hwRound(y), 5) or (t = 0);
    EX:= hwRound(x);
    EY:= hwRound(y);
    if t < 50 then 
        Score:= RateExplosion(Me, EX, EY, 101)
    else 
        Score:= BadTurn;

    if valueResult < Score then
        begin
        ap.Angle:= DxDy2AttackAngle(Vx, Vy) + AIrndSign(random(Level));
        ap.Power:= hwRound(r * cMaxPower) + AIrndSign(random(Level) * 15);
        ap.Time:= TestTime;
        ap.ExplR:= 100;
        ap.ExplX:= EX;
        ap.ExplY:= EY;
        valueResult:= Score
        end;
    end
until (TestTime = 4000);
TestGrenade:= valueResult
end;

function TestClusterBomb(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
const tDelta = 24;
var Vx, Vy, r: hwFloat;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, dY: hwFloat;
    t: LongInt;
begin
valueResult:= BadTurn;
TestTime:= 0;
ap.ExplR:= 0;
repeat
    inc(TestTime, 1000);
    // Try to overshoot slightly, seems to pay slightly better dividends in terms of hitting cluster
    if Me^.X<int2hwFloat(Targ.X) then
        Vx:= (int2hwFloat(Targ.X+10) - Me^.X) / int2hwFloat(TestTime + tDelta)
    else
        Vx:= (int2hwFloat(Targ.X-10) - Me^.X) / int2hwFloat(TestTime + tDelta);
    Vy:= cGravity * ((TestTime + tDelta) div 2) - (int2hwFloat(Targ.Y-150) - Me^.Y) / int2hwFloat(TestTime + tDelta);
    r:= Distance(Vx, Vy);
    if not (r > _1) then
        begin
        x:= Me^.X;
        y:= Me^.Y;
        dY:= -Vy;
        t:= TestTime;
    repeat
        x:= x + Vx;
        y:= y + dY;
        dY:= dY + cGravity;
        dec(t)
    until TestCollExcludingMe(Me, hwRound(x), hwRound(y), 5) or (t = 0);
    EX:= hwRound(x);
    EY:= hwRound(y);
    if t < 50 then 
        Score:= RateExplosion(Me, EX, EY, 41)
    else 
        Score:= BadTurn;

     if valueResult < Score then
        begin
        ap.Angle:= DxDy2AttackAngle(Vx, Vy) + AIrndSign(random(Level));
        ap.Power:= hwRound(r * cMaxPower * _0_9) + AIrndSign(random(Level) * 15);
        ap.Time:= TestTime;
        ap.ExplR:= 90;
        ap.ExplX:= EX;
        ap.ExplY:= EY;
        valueResult:= Score
        end;
     end
until (TestTime = 4000);
TestClusterBomb:= valueResult
end;

function TestWatermelon(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
const tDelta = 24;
var Vx, Vy, r: hwFloat;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, dY: hwFloat;
    t: LongInt;
begin
valueResult:= BadTurn;
TestTime:= 0;
ap.ExplR:= 0;
repeat
    inc(TestTime, 1000);
    Vx:= (int2hwFloat(Targ.X) - Me^.X) / int2hwFloat(TestTime + tDelta);
    Vy:= cGravity * ((TestTime + tDelta) div 2) - (int2hwFloat(Targ.Y-200) - Me^.Y) / int2hwFloat(TestTime + tDelta);
    r:= Distance(Vx, Vy);
    if not (r > _1) then
        begin
        x:= Me^.X;
        y:= Me^.Y;
        dY:= -Vy;
        t:= TestTime;
    repeat
        x:= x + Vx;
        y:= y + dY;
        dY:= dY + cGravity;
        dec(t)
    until TestCollExcludingMe(Me, hwRound(x), hwRound(y), 5) or (t = 0);
    EX:= hwRound(x);
    EY:= hwRound(y);
    if t < 50 then 
        Score:= RateExplosion(Me, EX, EY, 381)
    else 
        Score:= BadTurn;
        
    if valueResult < Score then
        begin
        ap.Angle:= DxDy2AttackAngle(Vx, Vy) + AIrndSign(random(Level));
        ap.Power:= hwRound(r * cMaxPower * _0_9) + AIrndSign(random(Level) * 15);
        ap.Time:= TestTime;
        ap.ExplR:= 300;
        ap.ExplX:= EX;
        ap.ExplY:= EY;
        valueResult:= Score
        end;
    end
until (TestTime = 4000);
TestWatermelon:= valueResult
end;


    function Solve(TX, TY, MX, MY: LongInt): LongWord;
    var A, B, D, T: hwFloat;
        C: LongInt;
    begin
        A:= hwSqr(cGravity) * _0_25;
        B:= - cGravity * (TY - MY) - _1;
        C:= sqr(TY - MY) + sqr(TX - MX);
        D:= hwSqr(B) - (A * C * 4);
        if D.isNegative = false then
            begin
            D:= ( - B + hwSqrt(D)) * _0_5 / A;
            if D.isNegative = false then
                T:= hwSqrt(D)
            else
                T:= _0;
            Solve:= hwRound(T)
            end
            else
                Solve:= 0
    end;
    
function TestMortar(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
//const tDelta = 24;
var Vx, Vy: hwFloat;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, dY: hwFloat;
begin
valueResult:= BadTurn;
ap.ExplR:= 0;

if (Level > 2) then
    exit(BadTurn);

TestTime:= Solve(Targ.X, Targ.Y, hwRound(Me^.X), hwRound(Me^.Y));

if TestTime = 0 then
    exit(BadTurn);

    Vx:= (int2hwFloat(Targ.X) - Me^.X) / int2hwFloat(TestTime);
    Vy:= cGravity * (TestTime div 2) - (int2hwFloat(Targ.Y) - Me^.Y) / int2hwFloat(TestTime);

    x:= Me^.X;
    y:= Me^.Y;
    dY:= -Vy;

    repeat
        x:= x + Vx;
        y:= y + dY;
        dY:= dY + cGravity;
        EX:= hwRound(x);
        EY:= hwRound(y);
    until TestCollExcludingMe(Me, EX, EY, 5) or (EY > cWaterLine);

    if (EY < cWaterLine) and (not dY.isNegative) then
        begin
        Score:= RateExplosion(Me, EX, EY, 91);
        if (Score = 0) then
            if (dY > _0_15) then
                Score:= - abs(Targ.Y - EY) div 32
            else
                Score:= BadTurn
        else if (Score < 0) then
            Score:= BadTurn
        end
    else
        Score:= BadTurn;

    if valueResult < Score then
        begin
        ap.Angle:= DxDy2AttackAngle(Vx, Vy) + AIrndSign(random(Level));
        ap.Power:= 1;
        ap.ExplR:= 100;
        ap.ExplX:= EX;
        ap.ExplY:= EY;
        valueResult:= Score
        end;

TestMortar:= valueResult;
end;

function TestShotgun(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
const
    MIN_RANGE =  80;
    MAX_RANGE = 400;
var Vx, Vy, x, y: hwFloat;
    rx, ry, valueResult: LongInt;
    range: integer;
begin
ap.ExplR:= 0;
ap.Time:= 0;
ap.Power:= 1;
x:= Me^.X;
y:= Me^.Y;
range:= Metric(hwRound(x), hwRound(y), Targ.X, Targ.Y);
if ( range < MIN_RANGE ) or ( range > MAX_RANGE ) then
    exit(BadTurn);
Vx:= (int2hwFloat(Targ.X) - x) * _1div1024;
Vy:= (int2hwFloat(Targ.Y) - y) * _1div1024;
ap.Angle:= DxDy2AttackAngle(Vx, -Vy);
repeat
    x:= x + vX;
    y:= y + vY;
    rx:= hwRound(x);
    ry:= hwRound(y);
    if TestCollExcludingMe(Me, rx, ry, 2) then
        begin
        x:= x + vX * 8;
        y:= y + vY * 8;
        valueResult:= RateShotgun(Me, rx, ry);
     
    if valueResult = 0 then 
        valueResult:= - Metric(Targ.X, Targ.Y, rx, ry) div 64
    else 
        dec(valueResult, Level * 4000);
    exit(valueResult * 27 div 20) // 27/20 is reuse bonus
    end
until (Abs(Targ.X - hwRound(x)) + Abs(Targ.Y - hwRound(y)) < 4)
    or (x.isNegative)
    or (y.isNegative)
    or (x.Round > LongWord(LAND_WIDTH))
    or (y.Round > LongWord(LAND_HEIGHT));

TestShotgun:= BadTurn
end;

function TestDesertEagle(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var Vx, Vy, x, y, t: hwFloat;
    d: Longword;
    valueResult: LongInt;
begin
Level:= Level; // avoid compiler hint
ap.ExplR:= 0;
ap.Time:= 0;
ap.Power:= 1;
x:= Me^.X;
y:= Me^.Y;
if Abs(hwRound(Me^.X) - Targ.X) + Abs(hwRound(Me^.Y) - Targ.Y) < 80 then
   exit(BadTurn);
t:= _0_5 / Distance(int2hwFloat(Targ.X) - x, int2hwFloat(Targ.Y) - y);
Vx:= (int2hwFloat(Targ.X) - x) * t;
Vy:= (int2hwFloat(Targ.Y) - y) * t;
ap.Angle:= DxDy2AttackAngle(Vx, -Vy);
d:= 0;

repeat
    x:= x + vX;
    y:= y + vY;
    if ((hwRound(x) and LAND_WIDTH_MASK) = 0)and((hwRound(y) and LAND_HEIGHT_MASK) = 0)
    and (Land[hwRound(y), hwRound(x)] <> 0) then
        inc(d);
until (Abs(Targ.X - hwRound(x)) + Abs(Targ.Y - hwRound(y)) < 4)
    or (x.isNegative)
    or (y.isNegative)
    or (x.Round > LongWord(LAND_WIDTH))
    or (y.Round > LongWord(LAND_HEIGHT))
    or (d > 200);

if Abs(Targ.X - hwRound(x)) + Abs(Targ.Y - hwRound(y)) < 3 then
    valueResult:= Max(0, (4 - d div 50) * 7 * 1024)
else
    valueResult:= BadTurn;
TestDesertEagle:= valueResult
end;

function TestBaseballBat(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var valueResult: LongInt;
    x, y: hwFloat;
begin
Level:= Level; // avoid compiler hint
ap.ExplR:= 0;
if (Level > 2) or (Abs(hwRound(Me^.X) - Targ.X) + Abs(hwRound(Me^.Y) - Targ.Y) > 25) then
    exit(BadTurn);

ap.Time:= 0;
ap.Power:= 1;
x:= Me^.X;
y:= Me^.Y;
if (Targ.X) - hwRound(x) >= 0 then
    ap.Angle:=   cMaxAngle div 4
else
    ap.Angle:= - cMaxAngle div 4;
valueResult:= RateShove(Me, hwRound(x) + 10 * hwSign(int2hwFloat(Targ.X) - x), hwRound(y), 15, 30);
if valueResult <= 0 then
    valueResult:= BadTurn
else
    inc(valueResult);
TestBaseballBat:= valueResult;
end;

function TestFirePunch(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var i, valueResult: LongInt;
    x, y: hwFloat;
begin
Level:= Level; // avoid compiler hint
ap.ExplR:= 0;
ap.Time:= 0;
ap.Power:= 1;
ap.Angle:= 0;
x:= Me^.X;
y:= Me^.Y;
if (Abs(hwRound(x) - Targ.X) > 25)
or (Abs(hwRound(y) - 50 - Targ.Y) > 50) then
    begin
    if TestColl(hwRound(x), hwRound(y) - 16, 6)
    and (RateShove(Me, hwRound(x) + 10 * hwSign(Me^.dX), hwRound(y) - 40, 30, 30) = 0) then
        valueResult:= Succ(BadTurn)
    else
        valueResult:= BadTurn;
    exit(valueResult)
    end;

valueResult:= 0;
for i:= 0 to 4 do
    valueResult:= valueResult + RateShove(Me, hwRound(x) + 10 * hwSign(int2hwFloat(Targ.X) - x),
                                    hwRound(y) - 20 * i - 5, 10, 30);
if valueResult <= 0 then
    valueResult:= BadTurn
else
    inc(valueResult);

TestFirePunch:= valueResult;
end;

function TestHammer(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var rate: LongInt;
begin
Level:= Level; // avoid compiler hint
ap.ExplR:= 0;
ap.Time:= 0;
ap.Power:= 1;
ap.Angle:= 0;
         
if (Abs(hwRound(Me^.X) + hwSign(Me^.dX) * 10 - Targ.X) + Abs(hwRound(Me^.Y) - Targ.Y) > 20) then
    rate:= 0
else
    rate:= RateHammer(Me);
if rate = 0 then
    rate:= BadTurn;
TestHammer:= rate;
end;

function TestAirAttack(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
const cShift = 4;
var X, Y, dY: hwFloat;
    b: array[0..9] of boolean;
    dmg: array[0..9] of LongInt;
    fexit: boolean;
    i, t, valueResult: LongInt;
begin
ap.ExplR:= 0;
ap.Time:= 0;
if (Level > 3) then
    exit(BadTurn);

ap.AttackPutX:= Targ.X;
ap.AttackPutY:= Targ.Y;

X:= int2hwFloat(Targ.X - 135 - cShift); // hh center - cShift
X:= X - cBombsSpeed * hwSqrt(int2hwFloat((Targ.Y + 128) * 2) / cGravity);
Y:= -_128;
dY:= _0;

for i:= 0 to 9 do
    begin
    b[i]:= true;
    dmg[i]:= 0
    end;
valueResult:= 0;

repeat
    X:= X + cBombsSpeed;
    Y:= Y + dY;
    dY:= dY + cGravity;
    fexit:= true;

    for i:= 0 to 9 do
        if b[i] then
            begin
            fexit:= false;
            if TestColl(hwRound(X) + i * 30, hwRound(Y), 4) then
                begin
                b[i]:= false;
                dmg[i]:= RateExplosion(Me, hwRound(X) + i * 30, hwRound(Y), 58)
                // 58 (instead of 60) for better prediction (hh moves after explosion of one of the rockets)
                end
            end;
until fexit or (Y.Round > cWaterLine);

for i:= 0 to 5 do inc(valueResult, dmg[i]);
t:= valueResult;
ap.AttackPutX:= Targ.X - 60;

for i:= 0 to 3 do
    begin
    dec(t, dmg[i]);
    inc(t, dmg[i + 6]);
    if t > valueResult then
        begin
        valueResult:= t;
        ap.AttackPutX:= Targ.X - 30 - cShift + i * 30
        end
    end;

if valueResult <= 0 then
    valueResult:= BadTurn;
TestAirAttack:= valueResult;
end;


function TestTeleport(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var
    i, failNum: longword;
    maxTop: longword;
begin
    TestTeleport := BadTurn;
    Level:= Level; // avoid compiler hint
    FillBonuses(true, [gtCase]);
    if bonuses.Count = 0 then
        begin
        if Me^.Health <= 100  then
            begin
            maxTop := Targ.Y - cHHRadius * 2;
            
            while not TestColl(Targ.X, maxTop, cHHRadius) and (maxTop > topY + cHHRadius * 2 + 1) do
                dec(maxTop, cHHRadius*2);
            if not TestColl(Targ.X, maxTop + cHHRadius, cHHRadius) then
                begin
                ap.AttackPutX := Targ.X;
                ap.AttackPutY := maxTop + cHHRadius;
                TestTeleport := Targ.Y - maxTop;
                end;
            end;
        end
    else
        begin
        failNum := 0;
        repeat
            i := random(bonuses.Count);
            inc(failNum);
        until not TestColl(bonuses.ar[i].X, bonuses.ar[i].Y - cHHRadius - bonuses.ar[i].Radius, cHHRadius)
        or (failNum = bonuses.Count*2);
        
        if failNum < bonuses.Count*2 then
            begin
            ap.AttackPutX := bonuses.ar[i].X;
            ap.AttackPutY := bonuses.ar[i].Y - cHHRadius - bonuses.ar[i].Radius;
            TestTeleport := 0;
            end;
        end;
end;

end.
