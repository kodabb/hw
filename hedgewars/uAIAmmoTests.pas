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
function TestWhip(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
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
            (proc: @TestWhip;        flags: 0), // amWhip
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
            (proc: @TestSnowball;    flags: 0), // amSnowball
            (proc: nil;              flags: 0), // amTardis
            (proc: nil;              flags: 0), // amStructure
            (proc: nil;              flags: 0), // amLandGun
            (proc: nil;              flags: 0)  // amIceGun
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
    r:= sqr(Vx) + sqr(Vy);
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
            ap.Angle:= DxDy2AttackAnglef(Vx, Vy) + AIrndSign(random((Level - 1) * 9));
            ap.Power:= trunc(sqrt(r) * cMaxPower) - random((Level - 1) * 17 + 1);
            ap.ExplR:= 100;
            ap.ExplX:= EX;
            ap.ExplY:= EY;
            valueResult:= value
            end;
        end
//until (value > 204800) or (rTime > 4250); not so useful since adding score to the drowning
until rTime > 4250;
TestBazooka:= valueResult
end;

function TestSnowball(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var Vx, Vy, r: real;
    rTime: LongInt;
    EX, EY: LongInt;
    valueResult: LongInt;
    x, y, dX, dY, meX, meY: real;
    t: LongInt;
    value: LongInt;

begin
meX:= hwFloat2Float(Me^.X);
meY:= hwFloat2Float(Me^.Y);
ap.Time:= 0;
rTime:= 350;
ap.ExplR:= 0;
valueResult:= BadTurn;
repeat
    rTime:= rTime + 300 + Level * 50 + random(1000);
    Vx:= - cWindSpeedf * rTime * 0.5 + ((Targ.X + AIrndSign(2)) - meX) / rTime;
    Vy:= cGravityf * rTime * 0.5 - (Targ.Y - meY) / rTime;
    r:= sqr(Vx) + sqr(Vy);
    if not (r > 1) then
        begin
        x:= meX;
        y:= meY;
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

        value:= RateShove(Me, trunc(x), trunc(y), 5, 1, trunc((abs(dX)+abs(dY))*20), -dX, -dY, 1);
        if value = 0 then
            value:= - Metric(Targ.X, Targ.Y, EX, EY) div 64;

        if valueResult <= value then
            begin
            ap.Angle:= DxDy2AttackAnglef(Vx, Vy) + AIrndSign(random((Level - 1) * 9));
            ap.Power:= trunc(sqrt(r) * cMaxPower) - random((Level - 1) * 17 + 1);
            ap.ExplR:= 0;
            ap.ExplX:= EX;
            ap.ExplY:= EY;
            valueResult:= value
            end;
     end
until (rTime > 4250);
TestSnowball:= valueResult
end;

function TestMolotov(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var Vx, Vy, r: real;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, dY, meX, meY: real;
    t: LongInt;
begin
meX:= hwFloat2Float(Me^.X);
meY:= hwFloat2Float(Me^.Y);
valueResult:= BadTurn;
TestTime:= 0;
ap.ExplR:= 0;
repeat
    inc(TestTime, 300);
    Vx:= (Targ.X - meX) / TestTime;
    Vy:= cGravityf * (TestTime div 2) - Targ.Y - meY / TestTime;
    r:= sqr(Vx) + sqr(Vy);
    if not (r > 1) then
        begin
        x:= meX;
        y:= meY;
        dY:= -Vy;
        t:= TestTime;
        repeat
            x:= x + Vx;
            y:= y + dY;
            dY:= dY + cGravityf;
            dec(t)
        until TestCollExcludingMe(Me, trunc(x), trunc(y), 7) or (t = 0);
        EX:= trunc(x);
        EY:= trunc(y);
        if t < 50 then
            Score:= RateExplosion(Me, EX, EY, 97)  // average of 17 attempts, most good, but some failing spectacularly
        else
            Score:= BadTurn;
                  
        if valueResult < Score then
            begin
            ap.Angle:= DxDy2AttackAnglef(Vx, Vy) + AIrndSign(random(Level));
            ap.Power:= trunc(sqrt(r) * cMaxPower) + AIrndSign(random(Level) * 15);
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
var Vx, Vy, r: real;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, meX, meY, dY: real;
    t: LongInt;
begin
valueResult:= BadTurn;
TestTime:= 0;
ap.ExplR:= 0;
meX:= hwFloat2Float(Me^.X);
meY:= hwFloat2Float(Me^.Y);
repeat
    inc(TestTime, 1000);
    Vx:= (Targ.X - meX) / (TestTime + tDelta);
    Vy:= cGravityf * ((TestTime + tDelta) div 2) - (Targ.Y - meY) / (TestTime + tDelta);
    r:= sqr(Vx) + sqr(Vy);
    if not (r > 1) then
        begin
        x:= meX;
        y:= meY; 
        dY:= -Vy;
        t:= TestTime;
        repeat
            x:= x + Vx;
            y:= y + dY;
            dY:= dY + cGravityf;
            dec(t)
        until TestCollExcludingMe(Me, trunc(x), trunc(y), 5) or (t = 0);
    EX:= trunc(x);
    EY:= trunc(y);
    if t < 50 then 
        if Me^.Hedgehog^.BotLevel = 1 then
            Score:= RateExplosion(Me, EX, EY, 101, 3)
        else Score:= RateExplosion(Me, EX, EY, 101)
    else 
        Score:= BadTurn;

    if valueResult < Score then
        begin
        ap.Angle:= DxDy2AttackAnglef(Vx, Vy) + AIrndSign(random(Level));
        ap.Power:= trunc(sqrt(r) * cMaxPower) + AIrndSign(random(Level) * 15);
        ap.Time:= TestTime;
        ap.ExplR:= 100;
        ap.ExplX:= EX;
        ap.ExplY:= EY;
        valueResult:= Score
        end;
    end
//until (Score > 204800) or (TestTime > 4000);
until TestTime > 4000;
TestGrenade:= valueResult
end;

function TestClusterBomb(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
const tDelta = 24;
var Vx, Vy, r: real;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, dY, meX, meY: real;
    t: LongInt;
begin
valueResult:= BadTurn;
TestTime:= 0;
ap.ExplR:= 0;
meX:= hwFloat2Float(Me^.X);
meY:= hwFloat2Float(Me^.Y);
repeat
    inc(TestTime, 1000);
    // Try to overshoot slightly, seems to pay slightly better dividends in terms of hitting cluster
    if meX<Targ.X then
        Vx:= ((Targ.X+10) - meX) / (TestTime + tDelta)
    else
        Vx:= ((Targ.X-10) - meX) / (TestTime + tDelta);
    Vy:= cGravityf * ((TestTime + tDelta) div 2) - ((Targ.Y-150) - meY) / (TestTime + tDelta);
    r:= sqr(Vx)+sqr(Vy);
    if not (r > 1) then
        begin
        x:= meX;
        y:= meY;
        dY:= -Vy;
        t:= TestTime;
    repeat
        x:= x + Vx;
        y:= y + dY;
        dY:= dY + cGravityf;
        dec(t)
    until TestCollExcludingMe(Me, trunc(x), trunc(y), 5) or (t = 0);
    EX:= trunc(x);
    EY:= trunc(y);
    if t < 50 then 
        Score:= RateExplosion(Me, EX, EY, 41)
    else 
        Score:= BadTurn;

     if valueResult < Score then
        begin
        ap.Angle:= DxDy2AttackAnglef(Vx, Vy) + AIrndSign(random(Level));
        ap.Power:= trunc(sqrt(r) * cMaxPower * 0.9) + AIrndSign(random(Level) * 15);
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
var Vx, Vy, r: real;
    Score, EX, EY, valueResult: LongInt;
    TestTime: Longword;
    x, y, dY, meX, meY: real;
    t: LongInt;
begin
valueResult:= BadTurn;
TestTime:= 0;
ap.ExplR:= 0;
meX:= hwFloat2Float(Me^.X);
meY:= hwFloat2Float(Me^.Y);
repeat
    inc(TestTime, 1000);
    Vx:= (Targ.X - meX) / (TestTime + tDelta);
    Vy:= cGravityf * ((TestTime + tDelta) div 2) - ((Targ.Y-200) - meY) / (TestTime + tDelta);
    r:= sqr(Vx)+sqr(Vy);
    if not (r > 1) then
        begin
        x:= meX;
        y:= meY;
        dY:= -Vy;
        t:= TestTime;
    repeat
        x:= x + Vx;
        y:= y + dY;
        dY:= dY + cGravityf;
        dec(t)
    until TestCollExcludingMe(Me, trunc(x), trunc(y), 5) or (t = 0);
    EX:= trunc(x);
    EY:= trunc(y);
    if t < 50 then 
        Score:= RateExplosion(Me, EX, EY, 381)
    else 
        Score:= BadTurn;
        
    if valueResult < Score then
        begin
        ap.Angle:= DxDy2AttackAnglef(Vx, Vy) + AIrndSign(random(Level));
        ap.Power:= trunc(sqrt(r) * cMaxPower * 0.9) + AIrndSign(random(Level) * 15);
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
    var A, B, D, T: real;
        C: LongInt;
    begin
        A:= sqr(cGravityf) * 0.25;
        B:= - cGravityf * (TY - MY) - 1;
        C:= sqr(TY - MY) + sqr(TX - MX);
        D:= sqr(B) - (A * C * 4);
        if D >= 0 then
            begin
            D:= ( - B + sqrt(D)) * 0.5 / A;
            if D >= 0 then
                T:= sqrt(D)
            else
                T:= 0;
            Solve:= trunc(T)
            end
            else
                Solve:= 0
    end;
    
function TestMortar(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
//const tDelta = 24;
var Vx, Vy: real;
    Score, EX, EY: LongInt;
    TestTime: Longword;
    x, y, dY, meX, meY: real;
begin
    TestMortar:= BadTurn;
    ap.ExplR:= 0;
    meX:= hwFloat2Float(Me^.X);
    meY:= hwFloat2Float(Me^.Y);

    if (Level > 2) then
        exit(BadTurn);

    TestTime:= Solve(Targ.X, Targ.Y, trunc(meX), trunc(meY));

    if TestTime = 0 then
        exit(BadTurn);

    Vx:= (Targ.X - meX) / TestTime;
    Vy:= cGravityf * (TestTime div 2) - (Targ.Y - meY) / TestTime;

    x:= meX;
    y:= meY;
    dY:= -Vy;

    repeat
        x:= x + Vx;
        y:= y + dY;
        dY:= dY + cGravityf;
        EX:= trunc(x);
        EY:= trunc(y);
    until TestCollExcludingMe(Me, EX, EY, 5) or (EY > cWaterLine);

    if (EY < cWaterLine) and (dY >= 0) then
        begin
        Score:= RateExplosion(Me, EX, EY, 91);
        if (Score = 0) then
            if (dY > 0.15) then
                Score:= - abs(Targ.Y - EY) div 32
            else
                Score:= BadTurn
        else if (Score < 0) then
            Score:= BadTurn
        end
    else
        Score:= BadTurn;

    if BadTurn < Score then
        begin
        ap.Angle:= DxDy2AttackAnglef(Vx, Vy) + AIrndSign(random(Level));
        ap.Power:= 1;
        ap.ExplR:= 100;
        ap.ExplX:= EX;
        ap.ExplY:= EY;
        TestMortar:= Score
        end;
end;

function TestShotgun(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
const
    MIN_RANGE =  80;
    MAX_RANGE = 400;
var Vx, Vy, x, y: real;
    rx, ry, valueResult: LongInt;
    range: integer;
begin
TestShotgun:= BadTurn;
ap.ExplR:= 0;
ap.Time:= 0;
ap.Power:= 1;
x:= hwFloat2Float(Me^.X);
y:= hwFloat2Float(Me^.Y);
range:= Metric(trunc(x), trunc(y), Targ.X, Targ.Y);
if ( range < MIN_RANGE ) or ( range > MAX_RANGE ) then
    exit(BadTurn);

Vx:= (Targ.X - x) * 1 / 1024;
Vy:= (Targ.Y - y) * 1 / 1024;
ap.Angle:= DxDy2AttackAnglef(Vx, -Vy);
repeat
    x:= x + vX;
    y:= y + vY;
    rx:= trunc(x);
    ry:= trunc(y);
    if TestCollExcludingMe(Me, rx, ry, 2) then
    begin
        x:= x + vX * 8;
        y:= y + vY * 8;
        valueResult:= RateShotgun(Me, vX, vY, rx, ry);
     
        if valueResult = 0 then 
            valueResult:= - Metric(Targ.X, Targ.Y, rx, ry) div 64
        else 
            dec(valueResult, Level * 4000);
        // 27/20 is reuse bonus
        exit(valueResult * 27 div 20)
    end
until (Abs(Targ.X - trunc(x)) + Abs(Targ.Y - trunc(y)) < 4)
    or (x < 0)
    or (y < 0)
    or (trunc(x) > LAND_WIDTH)
    or (trunc(y) > LAND_HEIGHT);

TestShotgun:= BadTurn
end;

function TestDesertEagle(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var Vx, Vy, x, y, t, dmgMod: real;
    d: Longword;
    fallDmg, valueResult: LongInt;
begin
dmgMod:= 0.01 * hwFloat2Float(cDamageModifier) * cDamagePercent;
Level:= Level; // avoid compiler hint
ap.ExplR:= 0;
ap.Time:= 0;
ap.Power:= 1;
x:= hwFloat2Float(Me^.X);
y:= hwFloat2Float(Me^.Y);
if Abs(trunc(x) - Targ.X) + Abs(trunc(y) - Targ.Y) < 40 then
    begin
    TestDesertEagle:= BadTurn;
    exit(BadTurn);
    end;
t:= 0.5 / sqrt(sqr(Targ.X - x)+sqr(Targ.Y-y));
Vx:= (Targ.X - x) * t;
Vy:= (Targ.Y - y) * t;
ap.Angle:= DxDy2AttackAnglef(Vx, -Vy);
d:= 0;

repeat
    x:= x + vX;
    y:= y + vY;
    if ((trunc(x) and LAND_WIDTH_MASK) = 0)and((trunc(y) and LAND_HEIGHT_MASK) = 0)
    and (Land[trunc(y), trunc(x)] <> 0) then
        inc(d);
until (Abs(Targ.X - trunc(x)) + Abs(Targ.Y - trunc(y)) < 4)
    or (x < 0)
    or (y < 0)
    or (trunc(x) > LAND_WIDTH)
    or (trunc(y) > LAND_HEIGHT)
    or (d > 200);

if Abs(Targ.X - trunc(x)) + Abs(Targ.Y - trunc(y)) < 3 then
    begin
    fallDmg:= TraceShoveFall(Me, Targ.X, Targ.Y, vX * 0.005 * 20, vY * 0.005 * 20);
    if fallDmg < 0 then
        valueResult:= 204800
    else valueResult:= Max(0, (4 - d div 50) * trunc((7+fallDmg)*dmgMod) * 1024)
    end
else
    valueResult:= BadTurn;
TestDesertEagle:= valueResult
end;

function TestBaseballBat(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var valueResult: LongInt;
    x, y: real;
begin
Level:= Level; // avoid compiler hint
TestBaseballBat:= BadTurn;
ap.ExplR:= 0;
x:= hwFloat2Float(Me^.X);
y:= hwFloat2Float(Me^.Y);
if (Level > 2) or (Abs(trunc(x) - Targ.X) + Abs(trunc(y) - Targ.Y) > 25) then
    exit(BadTurn);

ap.Time:= 0;
ap.Power:= 1;
if (Targ.X) - trunc(x) >= 0 then
    ap.Angle:=   cMaxAngle div 4
else
    ap.Angle:= - cMaxAngle div 4;

valueResult:= RateShove(Me, trunc(x) + LongWord(10*hwSignf(Targ.X - x)), trunc(y), 15, 30, 115, hwSign(Me^.dX)*0.353, -0.353, 1);
if valueResult <= 0 then
    valueResult:= BadTurn
else
    inc(valueResult);
TestBaseballBat:= valueResult;
end;

function TestFirePunch(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var val1: LongInt;
    x, y: real;
begin
Level:= Level; // avoid compiler hint
ap.ExplR:= 0;
ap.Time:= 0;
ap.Power:= 1;
ap.Angle:= hwSign(Me^.dX);
x:= hwFloat2Float(Me^.X);
y:= hwFloat2Float(Me^.Y);
if (Abs(trunc(x) - Targ.X) > 25)
or (Abs(trunc(y) - 50 - Targ.Y) > 50) then
    begin
// TODO - find out WTH this works.
    if TestColl(trunc(x), trunc(y) - 16, 6) and 
       (RateShove(Me, trunc(x) + LongWord(10 * hwSign(Me^.dX)), 
                      trunc(y) - 40, 30, 30, 40, hwSign(Me^.dX)*0.45, -0.9,  1) = 0) then
        val1:= Succ(BadTurn)
    else
        val1:= BadTurn;
    exit(val1);
    end;
(*
For some silly reason, having this enabled w/ the AI 
val1:= 0;
for i:= 0 to 4 do
    begin
    t:= RateShove(Me, trunc(x) + 10 * hwSign(Targ.X - x), trunc(y) - 20 * i - 5, 10, 30, 40, hwSign(Me^.dX)*0.45, -0.9, 1);
    if (val1 < 0) or (t < 0) then val1:= BadTurn
    else if t > 0 then val1:= t;
    end;

val2:= 0;
for i:= 0 to 4 do
    begin
    t:= RateShove(Me, trunc(x) + 10 * hwSign(Targ.X - x), trunc(y) - 20 * i - 5, 10, 30, 40, -hwSign(Me^.dX)*0.45, -0.9, 1);
    if (val2 < 0) or (t < 0) then val2:= BadTurn
    else if t > 0 then val2:= t;
    end;
if (val1 > val2) and (val1 > 0) then 
    TestFirePunch:= val1
else if (val2 > val1) and (val2 > 0) then
    begin
    ap.Angle:= -hwSign(Me^.dX);
    TestFirePunch:= val2
    end
else TestFirePunch:= BadTurn;*)
end;

function TestWhip(Me: PGear; Targ: TPoint; Level: LongInt; var ap: TAttackParams): LongInt;
var i, valueResult: LongInt;
    x, y: real;
begin
Level:= Level; // avoid compiler hint
ap.ExplR:= 0;
ap.Time:= 0;
ap.Power:= 1;
ap.Angle:= 0;
x:= hwFloat2Float(Me^.X);
y:= hwFloat2Float(Me^.Y);
if (Abs(trunc(x) - Targ.X) > 25)
or (Abs(trunc(y) - 50 - Targ.Y) > 50) then
    begin
    if TestColl(trunc(x), trunc(y) - 16, 6)
    and (RateShove(Me, trunc(x) + LongWord(10 * hwSign(Me^.dX)), trunc(y) - 40, 30, 30, 40, hwSign(Me^.dX), -0.8,  1) = 0) then
        valueResult:= Succ(BadTurn)
    else
        valueResult:= BadTurn;
    exit(valueResult);
    end;

valueResult:= 0;
for i:= 0 to 4 do
    valueResult:= valueResult + RateShove(Me, trunc(x) + LongWord(10 * hwSignf(Targ.X - x)),
                                    trunc(y) - LongWord(20 * i) - 5, 10, 30, 40, hwSign(Me^.dX), -0.8, 1);
if valueResult <= 0 then
    valueResult:= BadTurn
else
    inc(valueResult);

TestWhip:= valueResult;
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
var bombsSpeed, X, Y, dY: real;
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

bombsSpeed:= hwFloat2Float(cBombsSpeed);
X:= Targ.X - 135 - cShift; // hh center - cShift
X:= X - bombsSpeed * sqrt(((Targ.Y + 128) * 2) / cGravityf);
Y:= -128;
dY:= 0;

for i:= 0 to 9 do
    begin
    b[i]:= true;
    dmg[i]:= 0
    end;
valueResult:= 0;

repeat
    X:= X + bombsSpeed;
    Y:= Y + dY;
    dY:= dY + cGravityf;
    fexit:= true;

    for i:= 0 to 9 do
        if b[i] then
            begin
            fexit:= false;
            if TestColl(trunc(X) + LongWord(i * 30), trunc(Y), 4) then
                begin
                b[i]:= false;
                dmg[i]:= RateExplosion(Me, trunc(X) + LongWord(i * 30), trunc(Y), 58)
                // 58 (instead of 60) for better prediction (hh moves after explosion of one of the rockets)
                end
            end;
until fexit or (Y > cWaterLine);

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
    exit(BadTurn);
    Level:= Level; // avoid compiler hint
    //FillBonuses(true, [gtCase]);
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
