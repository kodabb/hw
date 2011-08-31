------------------------------------
-- TUMBLER
-- v.0.7
------------------------------------

loadfile(GetDataPath() .. "Scripts/Locale.lua")()
loadfile(GetDataPath() .. "Scripts/Tracker.lua")()

local fMod = 1000000 -- use this for dev and .16+ games

local leftOn = false
local rightOn = false
local upOn = false
local downOn = false
local preciseOn = false

local wep = {}
local wepAmmo = {}
local wepCol = {}
local wepIndex = 0
local wepCount = 0
local fGears = 0

local mineSpawn
local barrelSpawn

local roundKills = 0
local barrelsEaten = 0
local minesEaten = 0

local moveTimer = 0
local fireTimer = 0
local TimeLeftCounter = 0
local TimeLeft = 0
local stopMovement = false
local tumbleStarted = false

local vTag = {}

------------------------
-- version 0.4
------------------------

-- removed some old code/comments
-- removed both shell and mortar as the primary and secondary weapons
-- the primary weapon is now an explosive(barrel)

-- added support for picking up barrels scattered about the map (backspace)
-- added support for dragging around mines (enter toggles on/off)
-- added support for primary fire being onAttackUp
-- added a trail to indicate when the player has 5s or less left to tumble
-- updated showmission to reflect changed controls and options

------------------------
-- version 0.5
------------------------

-- changed some of the user feedback
-- i can't remember??
-- substituted onAttackUp for onPrecise()
-- brought in line with new velocity changes

------------------------
-- version 0.6
------------------------

-- reduced starting "ammo"
-- randomly spawn new barrels/mines on new turn
-- updated user feedback
-- better locs and coloured addcaptions
-- added tag for turntime
-- removed tractor beam
-- added two new weapons and changed ammo handling
-- health crates now give tumbler time, and wep/utility give flamer ammo
-- explosives AND mines can be picked up to increase their relative ammo
-- replaced "no weapon" selected message that hw serves
-- modified crate frequencies a bit
-- added some simple kill-based achievements, i think

------------------------
-- version 0.7
------------------------

-- a few code optimisations/performance tweaks
-- removed some deprecated code
-- fix a potential spawn bug

-- improved HUD (now shows ammo counts)
-- improved user feedback (less generic messages)
-- colour-coded addcaptions to match hud :)

-- base tumbling time now equals scheme turntime
-- tumbling time extension is now based on the amount of health contained in crate
-- new mines per turn based on minesnum
-- new barrels per turn based on explosives

-- added 2 more achievements: barrel eater and mine eater (like kills, don't do anything atm)
-- slightly increased grab distance for explosives/mines
-- slightly increased flamer velocity
-- slightly decreased flamer volume
-- added a flame vaporiser (based on number of flame gears?)
-- give tumblers an extra 47 health on the start of their tumble to counter the grenade (exp)
-- refocus camera on tumbler on newturn (not on crates, barrels etc)
-- increase delay: yes, yes, eat your hearts out

-- commit log
-- Better HUD
-- Allow more user customization
-- Bugfix for new gear spawns
-- Performance tweaks
-- Variety of small gameplay changes

---------------------------
-- some other ideas/things
---------------------------
--[[
-- add better gameflag handling
-- fix flamer "shots remaining" message on start or choose a standard versus %
-- add more sounds
-- better barrel/minespawn effects
-- separate grab distance for mines/barrels
-- [probably not] make barrels always explode?
-- [probably not] persistent ammo?
-- [probably not] dont hurt tumblers and restore their health at turn end?
]]


----------------------------------------------------------------
----------------------------------------------------------------

local flames = {}
local fGearValues = {}

function runOnflames(func)
    for k, gear in ipairs(flames) do
        func(gear)
    end
end

function trackFGear(gear)
    table.insert(flames, gear)
end

function trackFGearDeletion(gear)
    fGearValues[gear] = nil
    for k, g in ipairs(flames) do
        if g == gear then
            table.remove(flames, k)
            break
        end
    end
end

function getFGearValue(gear, key)
    if fGearValues[gear] ~= nil then
        return fGearValues[gear][key]
    end
    return nil
end

function setFGearValue(gear, key, value)
    found = false
    for id, values in pairs(fGearValues) do
        if id == gear then
            values[key] = value
            found = true
        end
    end
    if not found then
        fGearValues[gear] = { [key] = value }
    end
end

function decreaseFGearValue(gear, key)
    for id, values in pairs(fGearValues) do
        if id == gear then
            values[key] = values[key] - 1
        end
    end
end

function HandleLife(gear)

	decreaseFGearValue(gear, "L")
	if getFGearValue(gear, "L") == 0 then
		AddVisualGear(GetX(gear), GetY(gear), vgtSmoke, 0, false)
		DeleteGear(gear)
	end

end

----------------------------------------------------------------
----------------------------------------------------------------

function HideTags()

	for i = 0, 3 do 	
		SetVisualGearValues(vTag[i],0,0,0,0,0,1,0, 0, 240000, 0xffffff00)
	end

end

function DrawTag(i)
	
	zoomL = 1.3

	xOffset = 40

	if i == 0 then
		yOffset = 40	
		tCol = 0xffba00ff --0xffed09ff --0xffba00ff
		tValue = TimeLeft
	elseif i == 1 then
		zoomL = 1.1		
		yOffset = 70	
		tCol = wepCol[0]
		tValue = wepAmmo[0]
	elseif i == 2 then
		zoomL = 1.1		
		xOffset = 40 + 35
		yOffset = 70		
		tCol = wepCol[1]
		tValue = wepAmmo[1]
	elseif i == 3 then
		zoomL = 1.1		
		xOffset = 40 + 70
		yOffset = 70		
		tCol = wepCol[2]
		tValue = wepAmmo[2]
	end

	DeleteVisualGear(vTag[i])
	vTag[i] = AddVisualGear(0, 0, vgtHealthTag, 0, false)
	g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(vTag[i])
	SetVisualGearValues	(	
				vTag[i], 		--id
				-(ScreenWidth/2) + xOffset,	--xoffset
				ScreenHeight - yOffset, --yoffset
				0, 			--dx
				0, 			--dy
				zoomL, 			--zoom
				1, 			--~= 0 means align to screen
				g7, 			--frameticks
				tValue, 		--value
				240000, 		--timer
				tCol		--GetClanColor( GetHogClan(CurrentHedgehog) )
				)

end

function GetGearDistance(gear)

	g1X, g1Y = GetGearPosition(gear)
	g2X, g2Y = GetGearPosition(CurrentHedgehog)

	q = g1X - g2X
	w = g1Y - g2Y
	return( (q*q) + (w*w) )

end

-- add to your ammo ***WHEN YOU PUSH A KEY*** near them
-- yes that was my justification for a non generic method
function CheckProximityToExplosives(gear)

	if (GetGearDistance(gear) < 1400) then

		if (GetGearType(gear) == gtExplosives) then

			wepAmmo[0] = wepAmmo[0] + 1
			PlaySound(sndShotgunReload)
			DeleteGear(gear)
			AddCaption(wep[0] .. " " .. loc("ammo extended!"), wepCol[0], capgrpAmmoinfo )
			DrawTag(1)
			
			barrelsEaten = barrelsEaten + 1
			if barrelsEaten == 5 then
				AddCaption(loc("Achievement Unlocked") .. ": " .. loc("Barrel Eater!"),0xffba00ff,capgrpMessage2)
			end
		
		elseif (GetGearType(gear) == gtMine) then
			wepAmmo[1] = wepAmmo[1] + 1
			PlaySound(sndShotgunReload)
			DeleteGear(gear)
			AddCaption(wep[1] .. " " .. loc("ammo extended!"), wepCol[1], capgrpAmmoinfo )
			DrawTag(2)
			
			minesEaten = minesEaten + 1
			if minesEaten == 5 then
				AddCaption(loc("Achievement Unlocked") .. ": " .. loc("Mine Eater!"),0xffba00ff,capgrpMessage2)
			end

		end

	else
		--AddCaption("There is nothing here...")
	end

end

-- check proximity on crates
function CheckProximity(gear)

	dist = GetGearDistance(gear)

	if (dist < 1600) and (GetGearType(gear) == gtCase) then

		if GetHealth(gear) > 0 then

			AddCaption(loc("Tumbling Time Extended!"), 0xffba00ff, capgrpMessage2 )
			
			TimeLeft = TimeLeft + HealthCaseAmount  --5 --5s
			DrawTag(0)
			--PlaySound(sndShotgunReload)
		else
			wepAmmo[2] = wepAmmo[2] + 800
			PlaySound(sndShotgunReload)
			AddCaption(wep[2] .. " " .. loc("fuel extended!"), wepCol[2], capgrpAmmoinfo )
			DrawTag(3)
		end

		DeleteGear(gear)

	end

end

function ChangeWeapon()

	wepIndex = wepIndex + 1
	if wepIndex == wepCount then
		wepIndex = 0
	end

	AddCaption(wep[wepIndex] .. " " .. loc("selected!"), wepCol[wepIndex],capgrpAmmoinfo )
	AddCaption(wepAmmo[wepIndex] .. " " .. loc("shots remaining."), wepCol[wepIndex],capgrpMessage2)

end

---------------
-- action keys
---------------

function onPrecise()

	if (CurrentHedgehog ~= nil) and (stopMovement == false) and (tumbleStarted == true) and (wepAmmo[wepIndex] > 0) then

		wepAmmo[wepIndex] = wepAmmo[wepIndex] - 1
		AddCaption(wepAmmo[wepIndex] .. " " .. loc("shots remaining."), wepCol[wepIndex],capgrpMessage2)

		if wep[wepIndex] == loc("Barrel Launcher") then
			morte = AddGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), gtExplosives, 0, 0, 0, 1)
			CopyPV(CurrentHedgehog, morte) -- new addition
			x,y = GetGearVelocity(morte)
			x = x*2
			y = y*2
			SetGearVelocity(morte, x, y)
			DrawTag(1)

		elseif wep[wepIndex] == loc("Mine Deployer") then
			morte = AddGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), gtMine, 0, 0, 0, 0)
			SetTimer(morte, 1000)
			DrawTag(2)
		end

	end

	preciseOn = true

end

function onPreciseUp()
	preciseOn = false
end

function onHJump()
	-- pick up explosives/mines if nearby them
	if (CurrentHedgehog ~= nil) and (stopMovement == false) and (tumbleStarted == true) then
		runOnGears(CheckProximityToExplosives)
	end
end

function onLJump()
	ChangeWeapon()
end

-----------------
-- movement keys
-----------------

function onLeft()
	if (CurrentHedgehog ~= nil) and (stopMovement == false) then
		leftOn = true
	end
end

function onRight()
	if (CurrentHedgehog ~= nil) and (stopMovement == false) then
		rightOn = true
	end
end

function onUp()
	if (CurrentHedgehog ~= nil) and (stopMovement == false) then
		upOn = true
	end
end

function onDown()
	if (CurrentHedgehog ~= nil) and (stopMovement == false) then
		downOn = true
	end
end

function onDownUp()
	downOn = false
end
function onUpUp()
	upOn = false
end
function onLeftUp()
	leftOn = false
end
function onRightUp()
	rightOn = false
end

--------------------------
-- other event handlers
--------------------------

function onGameInit()
	CaseFreq = 0
	HealthCaseProb = 0
	Delay = 1000

	mineSpawn = MinesNum
	if mineSpawn > 4 then
		mineSpawn = 4	
	end

	barrelSpawn = Explosives
	if barrelSpawn > 4 then
		barrelSpawn = 4	
	end

	--MinesNum = 0
	--Explosives = 0

	for i = 0, 3 do 	
		vTag[0] = AddVisualGear(0, 0, vgtHealthTag, 0, false)	
	end

	HideTags()

	wep[0] = loc("Barrel Launcher")
	wep[1] = loc("Mine Deployer")	
	wep[2] = loc("Flamer")

	wepCol[0] = 0x78818eff
	wepCol[1] = 0xa12a77ff
	wepCol[2] = 0xf49318ff
	
	wepCount = 3

end

function onGameStart()

	ShowMission	(
			"TUMBLER",
			loc("a Hedgewars mini-game"),
			loc("Eliminate the enemy hogs to win.") .. "|" ..
			" " .. "|" ..

			loc("New Mines Per Turn") .. ": " .. (mineSpawn) .. "|" ..
			loc("New Barrels Per Turn") .. ": " .. (barrelSpawn) .. "|" ..
			loc("Time Extension") .. ": " .. (HealthCaseAmount) .. loc("sec") .. "|" ..
			" " .. "|" ..

			loc("Movement: [Up], [Down], [Left], [Right]") .. "|" ..
			loc("Fire") .. ": " .. loc("[Left Shift]") .. "|" ..
			loc("Change Weapon") .. ": " .. loc("[Enter]") .. "|" ..
			loc("Grab Mines/Explosives") .. ": " .. loc("[Backspace]") .. "|" ..

			" " .. "|" ..

			loc("Health crates extend your time.") .. "|" ..
			loc("Ammo is reset at the end of your turn.") .. "|" ..

			"", 4, 4000
			)

end


function onNewTurn()

	stopMovement = false
	tumbleStarted = false

	-- randomly create new barrels mines on the map every turn (can be disabled by setting mine/barrels to 0 in scheme)
	for i = 0, barrelSpawn-1 do
		gear = AddGear(100, 100, gtExplosives, 0, 0, 0, 0)
		SetHealth(gear, 100)
		if FindPlace(gear, false, 0, LAND_WIDTH, false) ~= nil then
			tempE = AddVisualGear(GetX(gear), GetY(gear), vgtBigExplosion, 0, false)
		end
	end
	for i = 0, mineSpawn-1 do
		gear = AddGear(100, 100, gtMine, 0, 0, 0, 0)
		if FindPlace(gear, false, 0, LAND_WIDTH, false) ~= nil then
			tempE = AddVisualGear(GetX(gear), GetY(gear), vgtBigExplosion, 0, false)
		end
	end

	-- randomly spawn time extension crates / flamer fuel on the map
	r = GetRandom(100)
	if r > 50 then
		gear = SpawnHealthCrate(0, 0)
	end
	r = GetRandom(100)
	if r > 70 then
		gear = SpawnAmmoCrate(0, 0, amSkip)
	end

	HideTags()

	--reset ammo counts
	wepAmmo[0] = 2
	wepAmmo[1] = 1 
	wepAmmo[2] = 50 -- 50000 -- 50
	wepIndex = 2
	ChangeWeapon()

	roundKills = 0
	barrelsEaten = 0
	minesEaten = 0

	FollowGear(CurrentHedgehog)

end


function DisableTumbler()
	stopMovement = true
	upOn = false
	down = false
	leftOn = false
	rightOn = false
	HideTags()
end

function onGameTick()

	-- start the player tumbling with a boom once their turn has actually begun
	if tumbleStarted == false then
		if (TurnTimeLeft > 0) and (TurnTimeLeft ~= TurnTime) then
			--AddCaption(loc("Good to go!"))
			tumbleStarted = true
			TimeLeft = (TurnTime/1000)
			AddGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), gtGrenade, 0, 0, 0, 1)
			SetHealth(CurrentHedgehog, GetHealth(CurrentHedgehog) + 47) -- new
			for i = 0, 3 do
				DrawTag(i)
			end			
		end
	end

	if (CurrentHedgehog ~= nil) and (tumbleStarted == true) then

		runOnGears(CheckProximity) -- crates

		-- Calculate and display turn time
		TimeLeftCounter = TimeLeftCounter + 1
		if TimeLeftCounter == 1000 then
			TimeLeftCounter = 0
			TimeLeft = TimeLeft - 1

			if TimeLeft >= 0 then
				DrawTag(0)
			end

		end

		if TimeLeft == 0 then
			DisableTumbler()
		end

		-- handle movement based on IO
		moveTimer = moveTimer + 1
		if moveTimer == 100 then -- 100
			moveTimer = 0

			runOnflames(HandleLife)

			---------------
			-- new trail code
			---------------
			-- the trail lets you know you have 5s left to pilot, akin to birdy feathers
			if (TimeLeft <= 5) and (TimeLeft > 0) then
				tempE = AddVisualGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), vgtSmoke, 0, false)
				g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(tempE)
				SetVisualGearValues(tempE, g1, g2, g3, g4, g5, g6, g7, g8, g9, GetClanColor(GetHogClan(CurrentHedgehog)) )
			end
			--------------

			dx, dy = GetGearVelocity(CurrentHedgehog)

			dxlimit = 0.4*fMod
			dylimit = 0.4*fMod

			if dx > dxlimit then
				dx = dxlimit
			end
			if dy > dylimit then
				dy = dylimit
			end
			if dx < -dxlimit then
				dx = -dxlimit
			end
			if dy < -dylimit then
				dy = -dylimit
			end


			if leftOn == true then
				dx = dx - 0.1*fMod
			end
			if rightOn == true then
				dx = dx + 0.1*fMod
			end

			if upOn == true then
				dy = dy - 0.1*fMod
			end
			if downOn == true then
				dy = dy + 0.1*fMod
			end

			SetGearVelocity(CurrentHedgehog, dx, dy)

		end

		--
		--flamer
		--
		fireTimer = fireTimer + 1
		if fireTimer == 6 then	-- 5 --10
			fireTimer = 0

			if (wep[wepIndex] == loc("Flamer") ) and (preciseOn == true) and (wepAmmo[wepIndex] > 0) and (stopMovement == false) and (tumbleStarted == true) then

				wepAmmo[wepIndex] = wepAmmo[wepIndex] - 1
				AddCaption(
						loc("Flamer") .. ": " ..
						(wepAmmo[wepIndex]/800*100) - (wepAmmo[wepIndex]/800*100)%2 .. "%",
						wepCol[2],
						capgrpMessage2
						)
				DrawTag(3)

				dx, dy = GetGearVelocity(CurrentHedgehog)
				shell = AddGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), gtFlame, 0, 0, 0, 0)

				xdev = 1 + GetRandom(25)	--15
				xdev = xdev / 100

				r = GetRandom(2)
				if r == 1 then
					xdev = xdev*-1
				end

				ydev = 1 + GetRandom(25)	--15
				ydev = ydev / 100

				r = GetRandom(2)
				if r == 1 then
					ydev = ydev*-1
				end

				--*13	--8	*-4
				SetGearVelocity(shell, (dx*4.5)+(xdev*fMod), (dy*4.5)+(ydev*fMod))	--10

			end

		end
		--

	end


end

function isATrackedGear(gear)
	if 	(GetGearType(gear) == gtExplosives) or
		(GetGearType(gear) == gtMine) or
		(GetGearType(gear) == gtCase)
	then
		return(true)
	else
		return(false)
	end
end

--[[function onGearDamage(gear, damage)
	if gear == CurrentHedgehog then
		-- You are now tumbling
	end
end]]

function onGearAdd(gear)

	if GetGearType(gear) == gtFlame then

		trackFGear(gear)

		fGears = fGears +1

		if fGears < 80 then
			setFGearValue(gear,"L",30)
		else
			setFGearValue(gear,"L",5) --3
		end

	elseif isATrackedGear(gear) then
		trackGear(gear)
	end

end

function onGearDelete(gear)

	if GetGearType(gear) == gtFlame then
		trackFGearDeletion(gear)
		fGears = fGears -1

	elseif isATrackedGear(gear) then
		trackDeletion(gear)

	-- achievements? prototype
	elseif GetGearType(gear) == gtHedgehog then

		if GetHogTeamName(gear) ~= GetHogTeamName(CurrentHedgehog) then

			roundKills = roundKills + 1
			if roundKills == 2 then
				AddCaption(loc("Double Kill!"),0xffba00ff,capgrpMessage2)
			elseif roundKills == 3 then
				AddCaption(loc("Killing spree!"),0xffba00ff,capgrpMessage2)
			elseif roundKills >= 4 then
				AddCaption(loc("Unstoppable!"),0xffba00ff,capgrpMessage2)
			end

		elseif gear == CurrentHedgehog then
			DisableTumbler()

		elseif gear ~= CurrentHedgehog then
			AddCaption(loc("Friendly Fire!"),0xffba00ff,capgrpMessage2)
		end

	end

	if CurrentHedgehog ~= nil then
		FollowGear(CurrentHedgehog)
	end

end


