
loadfile(GetDataPath() .. "Scripts/Locale.lua")()
loadfile(GetDataPath() .. "Scripts/Tracker.lua")()

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
--- Space Invasion Code Follows (0.7)
---------------------------------------------------
---------------------------------------------------
-- VERSION HISTORY
----------------
-- version 0.1
----------------
-- conversion of tumbler into space invasion
-- a million and one changes
-- bells and whistles

----------------
-- version 0.2
----------------
-- code slowly getting cleaner, it still looks like a spaghetti monster tho
-- lots of console tracking :/
-- all visual gears are now compulsary (will probably revert this)
-- implemented fMod to try combat desyncs and bring this in line with dev

----------------
-- version 0.3
----------------
-- values of scoring changed to 3:10, and now based on vCircScore
-- time gained from killing a red circ increased from 3 to 4
-- circles now spawn at a distance of at least 800 or until sanity limit
-- roundsLimit now based off MinesTime (kinda, its an experiment)

-----------------
--0.4
-----------------
-- commented out a lot of WriteLnToConsoles (dont need them at this point)
-- added some different WriteLnToConsoles
-- changed some of the collision detect for explosives in checkvarious()

-----------------
--0.5
-----------------
-- added implementation for a projectile shield
-- added a "bonus" orange invader that partially recharges player shield
-- added a tough "blueboss" blue invader
-- expanded user feedback
-- circles now have health and are capable of being merely "damaged"
-- redid a lot of the collision code and added CircleDamaged
-- added more sounds to events
-- added more visual gears

-----------------
--0.6
-----------------
-- removed a few WriteLns
-- added randomized grunts on circ damage
-- added (mostly) graceful fading out of circles :D:
-- changed odds for circles
-- changed user feedback
-- fixed the location of the explosion where player bashes into circ

-----------------
--0.7
-----------------
-- added PlaySound(sndSuddenDeath) when ammo gets depleted
-- added an extra "Ammo Depleted" note if user presses fire while empty
-- specified how much shield power is gained on shield powerup collection
-- changed odds for circles AGAIN, ammo is now sliiightly more common
-- switched most of the explosions/smoke effects back to non-critical vgears (with a few exceptions)
-- tumbletime is now based off turntime and is variable
-- delete explosives in DeleteFarFlungBarrel rather than explode them on map boundaries to save on performance
-- utilized the improved AddCaption to tint / prevent overrides
-- temporarily disabled bugged sort that displays teams according to their score
-- reluctantly changed the colour of the bonus circ to purple 
-- standarized point notation
-- added some missing locs
-- commented out remaining WriteLnToConsoles for the meanwhile with the prefix "nw"

-- ACHIEIVEMENTS added
-- (during one turn) aka repeatable
-- Ammo Manic (Destroy 3 green circles for + 5 points)
-- Drone Hunter (Destroy 5 red circles for + 10 points)
-- Shield Seeker (Destroy 3 purple circles for +10 points)
-- Boss Slayer (Destroy 2 blue circles for +25 points)

-- Shield Master (disolve 5 shells for +10 points)
-- Shield Miser (don't use your shield at all +20 points)

-- Depleted Kamikaze! (kamikaze into a blue/red circ when you are out of ammo) 5pts
-- Timed Kamikaze! (kamikaze into a blue/red circ when you only have 5s left) 10pts
-- Kamikaze Expert (combination of the above two) 15pts

-- Multi-shot (destroy more than 1 invader with a single bullet) 5pts
-- X-Hit Combo (destroy another invader in less than 3 seconds) chainLength*2 points

-- Accuracy Bonus (80% accuracy at the end of your turn with more than 5 shots fired) 15pts

--(during the length of the game) aka non-repeatable
-- 10/25/50 kills (+25/+50/+100 points)

--------------------------
--notes for later
--------------------------
-- maybe add a check for a tie, NAH
-- more achievements? (3 kamikazes in a row, long distance shooter, supreme shield expert/miser etc?)

--[[CAPTION CATEGORIES
-----------------
capgrpGameState
-----------------

-----------------
capgrpAmmostate
-----------------
AddCaption( chainLength .. LOC_NOT("-chain! +") .. chainLength*2 .. LOC_NOT(" points!"),0xffba00ff,capgrpAmmostate)
AddCaption(LOC_NOT("Multi-shot! +5 points!"),0xffba00ff,capgrpAmmostate) 

-----------------
capgrpAmmoinfo
-----------------
AddCaption(LOC_NOT("Shield Miser! +20 points!"),0xffba00ff,capgrpAmmoinfo)
AddCaption(LOC_NOT("Shield Master! +10 points!"),0xffba00ff,capgrpAmmoinfo)

-----------------
capgrpVolume
-----------------
AddCaption(LOC_NOT("Boom! +25 points!"),0xffba00ff,capgrpVolume)
AddCaption(LOC_NOT("BOOM! +50 points!"),0xffba00ff,capgrpVolume)
AddCaption(LOC_NOT("BOOM! BOOM! BOOM! +100 points!"),0xffba00ff,capgrpVolume)
AddCaption(LOC_NOT("Accuracy Bonus! +15 points!"),0xffba00ff,capgrpVolume)

-----------------
capgrpMessage 
-----------------
AddCaption(LOC_NOT("Ammo Depleted!"),0xff0000ff,capgrpMessage)
AddCaption(LOC_NOT("Ammo: ") .. primShotsLeft)
AddCaption("Shield Depleted",0xff0000ff,capgrpMessage)
AddCaption( LOC_NOT("Shield ON:") .. " " .. shieldHealth - 80 .. " " .. LOC_NOT("Power Remaining") )
AddCaption(LOC_NOT("Shield OFF:") .. " " .. shieldHealth - 80 .. " " .. LOC_NOT("Power Remaining") )

AddCaption(LOC_NOT("Time Extended!") .. "+" .. 4 .. LOC_NOT("s"), 0xff0000ff,capgrpMessage )
AddCaption("+" .. 3 .. " " .. LOC_NOT("Ammo"), 0x00ff00ff,capgrpMessage)
AddCaption(LOC_NOT("Shield boosted! +30 power"), 0xff00ffff,capgrpMessage)
AddCaption(LOC_NOT("Shield is fully recharged!"), 0xffae00ff,capgrpMessage)
AddCaption(LOC_NOT("Boss defeated! +50 points!"), 0x0050ffff,capgrpMessage)

AddCaption(LOC_NOT("GOTCHA!"))
AddCaption(LOC_NOT("Kamikaze Expert! +15 points!"),0xffba00ff,capgrpMessage)
AddCaption(LOC_NOT("Depleted Kamikaze! +5 points!"),0xffba00ff,capgrpMessage)
AddCaption(LOC_NOT("Timed Kamikaze! +10 points!"),0xffba00ff,capgrpMessage)

-----------------
capgrpMessage2 
-----------------
AddCaption(LOC_NOT("Drone Hunter! +10 points!"),0xffba00ff,capgrpMessage2)
AddCaption(LOC_NOT("Ammo Maniac! +5 points!"),0xffba00ff,capgrpMessage2)
AddCaption(LOC_NOT("Shield Seeker! +10 points!"),0xffba00ff,capgrpMessage2)
AddCaption(LOC_NOT("Boss Slayer! +25 points!"),0xffba00ff,capgrpMessage2)
]]

----------------------------------
-- so I herd u liek wariables
----------------------------------

--local fMod = 1	-- for use in .15 single player only, otherwise desync
local fMod = 1000000 -- use this for dev and .16+ games

-- some console stuff
local shellID = 0
local explosivesID = 0
local luaGameTicks = 0

-- gaudyRacer
local roundLimit = 3	-- no longer set here (see version history)
local roundNumber = 0
local firstClan = 10
local gameOver = false
local gameBegun = false

local bestClan = 10
local bestScore = 0
local sdScore = {}
local sdName = {}
local sdKills = {}

--------------------------
-- hog and team tracking variales
--------------------------

local numhhs = 0
local hhs = {}

local numTeams
local teamNameArr = {}
local teamClan = {}
local teamSize = {}
local teamIndex = {}

local teamComment = {}
local teamScore = {}
local teamCircsKilled = {}

-- stats variables
--local teamRed = {}
--local teamBlue = {}
--local teamOrange = {}
--local teamGreen = {}
local RK = 0
local GK = 0
local BK = 0
local OK = 0
local SK = 0
local shieldMiser = true
local chainCounter = 0
local chainLength = 0 
local shotsFired = 0
local shotsHit = 0

---------------------
-- tumbler goods
---------------------

local moveTimer = 0
local leftOn = false
local rightOn = false
local upOn = false
local downOn = false

local primShotsMax = 5
local primShotsLeft = 0

local TimeLeftCounter = 0
local TimeLeft = 0
local stopMovement = false
local tumbleStarted = false

local beam = false
local pShield
local shieldHealth

local Timer100 = 0


-----------------------------------------------
-- CIRCLY GOODIES
-----------------------------------------------

local CirclesAreGo = false
local playerIsFine = true
local targetHit = false

local FadeAlpha = 0 -- used to fade the circles out gracefully when player dies
local pTimer = 0 -- tracking projectiles following player

local circAdjustTimer = 0		-- handle adjustment of circs direction
local m2Count = 0		-- handle speed of circs

local vCirc = {}
local vCCount = 0

local vCircActive = {}
local vCircHealth = {}
local vType = {}
local vCounter = {}		-- how often this circ gets to "fire" etc
local vCounterLim = {} -- when vCounter == vCounterLim circle performs its special
local vCircScore = {} -- how many points killing this invader gives

local vCircRadMax = {}
local vCircRadMin = {}
local vCircRadDir = {}
local vCircRadCounter = {}

local vCircDX = {}
local vCircDY = {}

local vCircX = {}
local vCircY = {}
local vCircMinA = {}
local vCircMaxA = {}
local vCircType = {}
local vCircPulse = {}
local vCircFuckAll = {}
local vCircRadius = {}
local vCircWidth = {}
local vCircCol = {}

-------------------------------------------
-- some lazy copypasta/modified methods
-------------------------------------------

function RebuildTeamInfo()

	-- make a list of individual team names
	for i = 0, (TeamsCount-1) do
		teamNameArr[i] = " " -- = i
		teamSize[i] = 0
		teamIndex[i] = 0
		teamScore[i] = 0
		teamCircsKilled[i] = 0
	end
	numTeams = 0

	for i = 0, (numhhs-1) do

		z = 0
		unfinished = true
		while(unfinished == true) do

			newTeam = true
			tempHogTeamName = GetHogTeamName(hhs[i]) -- this is the new name

			if tempHogTeamName == teamNameArr[z] then
				newTeam = false
				unfinished = false
			end

			z = z + 1

			if z == (TeamsCount-1) then
				unfinished = false
				if newTeam == true then
					teamNameArr[numTeams] = tempHogTeamName
					numTeams = numTeams + 1
				end
			end

		end

	end

	-- find out how many hogs per team, and the index of the first hog in hhs
	for i = 0, (TeamsCount-1) do

		for z = 0, (numhhs-1) do
			if GetHogTeamName(hhs[z]) == teamNameArr[i] then
				teamClan[i] = GetHogClan(hhs[z])
				if teamSize[i] == 0 then
					teamIndex[i] = z -- should give starting index
				end
				teamSize[i] = teamSize[i] + 1
				--add a pointer so this hog appears at i in hhs
			end
		end

	end

end

-- control
function AwardPoints(p)

	for i = 0,(TeamsCount-1) do
		if teamClan[i] == GetHogClan(CurrentHedgehog) then
			teamScore[i] = teamScore[i] + p
		end
	end

end

function AwardKills(t)

	for i = 0,(TeamsCount-1) do
		if teamClan[i] == GetHogClan(CurrentHedgehog) then
			teamCircsKilled[i] = teamCircsKilled[i] + 1

			if teamCircsKilled[i] == 10 then
				AddCaption(loc("Boom!") .. " +25 " .. loc("points").."!",0xffba00ff,capgrpVolume)
				AwardPoints(25)
			elseif teamCircsKilled[i] == 25 then
				AddCaption(loc("BOOM!") .. " +50 " .. loc("points") .. "!",0xffba00ff,capgrpVolume)
				AwardPoints(50)
			elseif teamCircsKilled[i] == 50 then
				AddCaption(loc("BOOM!") .. loc("BOOM!") .. loc("BOOM!") .. " +100 " .. loc("points") .. "!",0xffba00ff,capgrpVolume)
				AwardPoints(100)
			end

			--[[
			if t == "R" then
				redCircsKilled[i] = redCircsKilled[i] + 1
			end
			--etc
			--etc
			]]
		end
	end

end

-----------------

function bubbleSort(table)

	for i = 1, #table do
        for j = 2, #table do
            if table[j] < table[j-1] then

				temp = table[j-1]
				t2 = sdName[j-1]
				t3 = sdKills[j-1]

				table[j-1] = table[j]
                sdName[j-1] = sdName[j]
				sdKills[j-1] = sdKills[j]

				table[j] = temp
				sdName[j] = t2
				sdKills[j] = t3

            end
        end
    end

    return

end

-----------------

function CommentOnScore()

	for i = 0,(TeamsCount-1) do
		sdScore[i] = teamScore[i]
		sdKills[i] = teamCircsKilled[i]
		sdName[i] = teamNameArr[i]
	end

	--bubbleSort(sdScore)

	for i = 0,(TeamsCount-1) do
		if sdName[i] ~= " " then
			teamComment[i] = sdName[i] .. " |" ..
			loc("SCORE") .. ": " .. sdScore[i] .. " " .. loc("points") .. "|" ..
			loc("KILLS") .. ": " .. sdKills[i] .. " " .. loc("invaders destroyed") .. "|" ..
			" " .. "|"
		elseif sdName[i] == " " then
			teamComment[i] = "|"
		end
	end

	entireC = ""
	for i = (TeamsCount-1),0,-1 do
		entireC = entireC .. teamComment[i]
	end

	ShowMission("SPACE INVASION", loc("STATUS UPDATE"), loc("Rounds Complete") .. ": " .. roundNumber .. "/" .. roundLimit .. "| " .. "|" .. loc("Team Scores") .. ": |" ..entireC, 4, 1)

end

-- gaudy racer
function CheckForNewRound()

	if GetHogClan(CurrentHedgehog) == firstClan then

		roundNumber = roundNumber + 1

		CommentOnScore()

		-- end game if its at round limit
		if roundNumber == roundLimit then

			for i = 0, (TeamsCount-1) do
				if teamScore[i] > bestScore then
					bestScore = teamScore[i]
					bestClan = teamClan[i]
				end
			end

			for i = 0, (numhhs-1) do
				if GetHogClan(hhs[i]) ~= bestClan then
					SetEffect(hhs[i], heResurrectable, false)
					SetHealth(hhs[i],0)
				end
			end
			gameOver = true
			TurnTimeLeft = 0	--1
			TimeLeft = 0
		end

	end

end


----------------------------------------
-- some tumbler/space invaders methods
----------------------------------------

function isATrackedGear(gear)
	if 	(GetGearType(gear) == gtExplosives) or
		(GetGearType(gear) == gtShell) or
		(GetGearType(gear) == gtFlame) or-- new -- gtBall
		(GetGearType(gear) == gtBall)
	then
		return(true)
	else
		return(false)
	end
end

function setNewGearValues(gear)

	if GetGearType(gear) == gtShell then
		lfs = 50	-- roughly 5 seconds
		shellID = shellID + 1
		setGearValue(gear,"ID",shellID)
		--nw WriteLnToConsole("Just assigned ID " .. getGearValue(gear,"ID") .. " to this shell")
	elseif GetGearType(gear) == gtBall then
		lfs = 70	-- 7s
	elseif GetGearType(gear) == gtExplosives then
		lfs = 15	-- 1.5s
		explosivesID = explosivesID + 1
		setGearValue(gear,"ID",explosivesID)
		--nw WriteLnToConsole("Just assigned ID " .. getGearValue(gear,"ID") .. " to this explosives")
	elseif GetGearType(gear) == gtFlame then
		lfs = 5	-- 0.5s
	else
		lfs = 100
	end

	setGearValue(gear,"lifespan",lfs)
	--WriteLnToConsole("I also set its lifespan to " .. lfs)


end

function HandleLifeSpan(gear)

	decreaseGearValue(gear,"lifespan")

	--WriteLnToConsole("Just decreased the lifespan of a gear to " .. getGearValue(gear,"lifespan"))
	--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)


	if getGearValue(gear,"lifespan") == 0 then

		if GetGearType(gear) == gtShell then
			AddVisualGear(GetX(gear), GetY(gear), vgtExplosion, 0, false)
			WriteLnToConsole("about to delete a shell due to lifespan == 0")
		--elseif GetGearType(gear) == gtBall then
		--	AddVisualGear(GetX(gear), GetY(gear), vgtSmoke, 0, true)
		elseif GetGearType(gear) == gtExplosives then
			AddVisualGear(GetX(gear), GetY(gear), vgtBigExplosion, 0, false)
			--nw WriteLnToConsole("about to delete a explosive due to lifespan == 0")
		elseif GetGearType(gear) == gtFlame then
			AddVisualGear(GetX(gear), GetY(gear), vgtSmoke, 0, false)
			--WriteLnToConsole("about to delete flame due to lifespan == 0")
		end

		DeleteGear(gear)

	end

end

-- this prevents ugly barrel clipping sounds when a barrel flies off map limits
function DeleteFarFlungBarrel(gear)

	if GetGearType(gear) == gtExplosives then
		if 	(GetX(gear) < -1900) or
			(GetX(gear) > 6200) or
			(GetY(gear) < -3400)
		then
			AddVisualGear(GetX(gear), GetY(gear), vgtBigExplosion, 0, false)			
			DeleteGear(gear)			
			--SetHealth(gear, 0)
			--WriteLnToConsole("I'm setting barrel ID " .. getGearValue(gear,"ID") .. " to 0 health because it's been flung too close to the map edges. at Game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)
		end

	end

end

-----------------------
--EVENT HANDLERS
-- action keys
-----------------------

-- o rite dis wan iz liek synched n stuff hope full lee
function onPrecise()

	--WriteLnToConsole("onPrecise event handler at Game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)

	-- Fire Barrel
	if (primShotsLeft > 0) and (CurrentHedgehog ~= nil) and (stopMovement == false) and (tumbleStarted == true) then

		shotsFired = shotsFired +1		
		
		morte = AddGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), gtExplosives, 0, 0, 0, 1)

		primShotsLeft = primShotsLeft - 1

		if primShotsLeft == 0 then
			PlaySound(sndSuddenDeath)
			AddCaption(loc("Ammo Depleted!"),0xff0000ff,capgrpMessage)
		else
			AddCaption(loc("Ammo") .. ": " .. primShotsLeft)
		end

		CopyPV(CurrentHedgehog, morte) -- new addition
		x,y = GetGearVelocity(morte)
		--WriteLnToConsole("I'm going to shoot a barrel so I just got the velocity of currenthedgehog. It is dx: " .. x .. "; dy: " .. y)
		--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)



		x = x*2
		y = y*2
		SetGearVelocity(morte, x, y)

		--WriteLnToConsole("I just SET the velocity of a barrel I created. It is now dx: " .. x .. "; dy: " .. y)
		--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)



	elseif (primShotsLeft == 0) and (CurrentHedgehog ~= nil) and (stopMovement == false) and (tumbleStarted == true) then
		AddCaption(loc("Ammo Depleted!"),0xff0000ff,capgrpMessage)
	end


end

function onLJump()

	if (CurrentHedgehog ~= nil) and (stopMovement == false) and (tumbleStarted == true) then
		shieldMiser = false
		if shieldHealth == 80 then
			AddCaption("Shield Depleted",0xff0000ff,capgrpMessage)
			PlaySound(sndMineTick)
			PlaySound(sndSwitchHog)
		elseif (beam == false) and (shieldHealth > 80) then
			beam = true
			SetVisualGearValues(pShield, GetX(CurrentHedgehog), GetY(CurrentHedgehog), 40, 255, 1, 10, 0, 300, 1, 0xa800ffff)
			AddCaption( loc("Shield ON:") .. " " .. shieldHealth - 80 .. " " .. loc("Power Remaining") )
			PlaySound(sndWarp)
		else
			beam = false
			SetVisualGearValues(pShield, GetX(CurrentHedgehog), GetY(CurrentHedgehog), 0, 0, 1, 10, 0, 0, 0, 0xa800ffff)
			AddCaption(loc("Shield OFF:") .. " " .. shieldHealth - 80 .. " " .. loc("Power Remaining") )
		end
	end
end

-----------------
-- movement keys
-----------------

function onLeft()
	leftOn = true
end

function onRight()
	rightOn = true
end

function onUp()
	upOn = true
end

function onDown()
	downOn = true
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
	GameFlags = 0 + gfRandomOrder
	Theme = "EarthRise"
	CaseFreq = 0
	HealthCaseProb = 0
	MinesNum = 0
	Explosives = 0
end

function onGameStart()

	if (MinesTime == -1000) or (MinesTime == 0) then
		roundLimit = 3
	else
		roundLimit = (MinesTime / 1000)
	end

	ShowMission	(
				"SPACE INVASION",
				loc("a Hedgewars mini-game"),

				loc("Destroy invaders to score points.") .. "|" ..
				" " .. "|" ..

				loc("Round Limit") .. ": " .. roundLimit .. "|" ..
				loc("Turn Time") .. ": " .. (TurnTime/1000) .. loc("s") .. "|" ..
				" " .. "|" ..

				loc("Movement: [Up], [Down], [Left], [Right]") .. "|" ..
				loc("Fire") .. ": " .. loc("[Left Shift]") .. "|" ..
				loc("Toggle Shield") .. ": " .. loc("[Enter]") .. "|" ..

				--" " .. "|" ..
				--LOC_NOT("Invaders List: ") .. "|" ..
				--LOC_NOT("Blue Jabberwock: (50 points)") .. "|" ..
				--LOC_NOT("Red Warbler: (10 points)") .. "|" ..
				--LOC_NOT("Orange Gob: (5 points)") .. "|" ..
				--LOC_NOT("Green Wrangler: (3 points)") .. "|" ..


				"", 4, 4000
				)

	CreateMeSomeCircles()
	RebuildTeamInfo() -- control

end


function onNewTurn()

	primShotsLeft = primShotsMax
	stopMovement = false
	tumbleStarted = false
	beam = false
	shieldHealth = 30 + 80 -- 50 = 5 secs, roughly

	RK = 0
	GK = 0
	BK = 0
	OK = 0
	SK = 0
	shieldMiser = true
	shotsFired = 0
	shotsHit = 0
	chainLength = 0
	chainCounter = 0

	-------------------------
	-- gaudy racer
	-------------------------
	CheckForNewRound()

	-- Handle Starting Stage of Game
	if (gameOver == false) and (gameBegun == false) then
		gameBegun = true
		roundNumber = 0 -- 0
		firstClan = GetHogClan(CurrentHedgehog)
	end

	if gameOver == true then
		gameBegun = false
		stopMovement = true
		tumbleStarted = false
		SetMyCircles(false)
	end
	---------------
	---------------
	--AddCaption("num g: " .. numGears() )

	--WriteLnToConsole("onNewTurn, I just set a bunch of variables to their necessary states. This was done at:")
	--WriteLnToConsole("The above occured at Game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)

end

function ThingsToBeRunOnGears(gear)

	HandleLifeSpan(gear)
	DeleteFarFlungBarrel(gear)

	if CirclesAreGo == true then
		CheckVarious(gear)
		ProjectileTrack(gear)
	end

end


function onGameTick()

	
	--WriteLnToConsole("Start of GameTick")	
	luaGameTicks = luaGameTicks + 1 -- GameTime

	HandleCircles()

	Timer100 = Timer100 + 1
	if Timer100 >= 100 then
		Timer100 = 0

		if beam == true then
			shieldHealth = shieldHealth - 1
			if shieldHealth <= 80 then
				shieldHealth = 80
				beam = false
				AddCaption(loc("Shield Depleted"),0xff0000ff,capgrpMessage)
				PlaySound(sndMineTick)
				PlaySound(sndSwitchHog)
			end
		end


		--nw WriteLnToConsole("Starting ThingsToBeRunOnGears()")

		runOnGears(ThingsToBeRunOnGears)

		--nw WriteLnToConsole("Finished ThingsToBeRunOnGears()")

		--runOnGears(HandleLifeSpan)
		--runOnGears(DeleteFarFlungBarrel)

		if CirclesAreGo == true then
			CheckDistances()
			--runOnGears(CheckVarious)	-- used to be in handletracking for some bizarre reason
			--runOnGears(ProjectileTrack)
		end

		-- white smoke trail as player falls from the sky
		if (TimeLeft <= 0) and (stopMovement == true) and (CurrentHedgehog ~= nil) then
			j,k = GetGearVelocity(CurrentHedgehog)
			if (j ~= 0) and (k ~= 0) then
				AddVisualGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), vgtSmoke, 0, true)
			end
		end

		--nw WriteLnToConsole("Finished 100Timer")

	end


	-- start the player tumbling with a boom once their turn has actually begun
	if (tumbleStarted == false) and (gameOver == false) then
		if (TurnTimeLeft > 0) and (TurnTimeLeft ~= TurnTime) then
			--AddCaption(LOC_NOT("Good to go!"))
			tumbleStarted = true
			TimeLeft = (TurnTime/1000)	--45
			FadeAlpha = 0
			AddGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), gtGrenade, 0, 0, 0, 1)
			SetMyCircles(true)
		end
	end

	--WriteLnToConsole("Finished initial check")

	if (CurrentHedgehog ~= nil) and (tumbleStarted == true) then

		--AddCaption(GetX(CurrentHedgehog) .. ";" .. GetY(CurrentHedgehog) )

		-- Calculate and display turn time
		TimeLeftCounter = TimeLeftCounter + 1
		if TimeLeftCounter == 1000 then
			TimeLeftCounter = 0
			TimeLeft = TimeLeft - 1

			if TimeLeft >= 0 then
				--AddCaption(LOC_NOT("Time Left: ") .. TimeLeft)
			end

		end

		--WriteLnToConsole("Finished timeleft calculations")

		-------------------------------
		-- Player has run out of luck (out of time or hit by gtShell)
		-------------------------------
		-- checks in FloatyThings
		if PlayerIsFine() == false then
			TimeLeft = 0
		end
		
		--WriteLnToConsole("successfully checked playerIsFine")
		
		if (TimeLeft == 0) then
			if (stopMovement == false) then	--time to stop the player
				stopMovement = true
				beam = false
				upOn = false
				down = false
				leftOn = false
				rightOn = false
				SetMyCircles(false)
				--nw WriteLnToConsole("Player is out of luck")

				if shieldMiser == true then
					AddCaption(loc("Shield Miser!") .. " +20 " .. loc("points") .. "!",0xffba00ff,capgrpAmmoinfo)
					AwardPoints(20)
				end

				if ((shotsHit / shotsFired * 100) >= 80) and (shotsFired > 4) then
					AddCaption(loc("Accuracy Bonus!") .. " +15 " .. loc("points") .. "!",0xffba00ff,capgrpVolume)
					AwardPoints(15)
				end

			end
		else -- remove this if you want tumbler to fall slowly on death
		-------------------------------
		-- Player is still in luck
		-------------------------------
			

			--WriteLnToConsole("about to do chainCounter checks")
			if chainCounter > 0 then
				chainCounter = chainCounter -1 
				if chainCounter == 0 then
					chainLength = 0
				end
			end
				
			-- handle movement based on IO
			moveTimer = moveTimer + 1
			if moveTimer == 100 then -- 100
				--nw WriteLnToConsole("Start of Player MoveTimer")
				moveTimer = 0

				---------------
				-- new trail code
				---------------
				-- the trail lets you know you have 5s left to pilot, akin to birdy feathers
				if (TimeLeft <= 5) and (TimeLeft > 0) then							--vgtSmoke
					tempE = AddVisualGear(GetX(CurrentHedgehog), GetY(CurrentHedgehog), vgtSmoke, 0, true)
					g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(tempE)
					SetVisualGearValues(tempE, g1, g2, g3, g4, g5, g6, g7, g8, g9, GetClanColor(GetHogClan(CurrentHedgehog)) )
				end
				--------------
				--------------

				dx, dy = GetGearVelocity(CurrentHedgehog)

				--WriteLnToConsole("I just got the velocity of currenthedgehog. It is dx: " .. dx .. "; dy: " .. dy)
				--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)


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

				--WriteLnToConsole("I just SET the velocity of currenthedgehog. It is now dx: " .. dx .. "; dy: " .. dy)
				--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)
				--nw WriteLnToConsole("End of Player MoveTimer")

			end

		end -- new end I put here to check if he's still alive or not

	end

	--WriteLnToConsole("End of GameTick")

end

function onGearResurrect(gear)

	-- did I fall into the water? well, that was a stupid thing to do
	if gear == CurrentHedgehog then
		TimeLeft = 0
		--WriteLnToConsole("Current hedgehog just drowned himself")
		--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)

	end

end

function onGearAdd(gear)

	if isATrackedGear(gear) then
		trackGear(gear)
		setNewGearValues(gear)
	end

	--if GetGearType(gear) == gtBall then
	--	SetTimer(gear, 5000)
	--end

	if GetGearType(gear) == gtHedgehog then
		SetEffect(gear, heResurrectable, true)

		-----------
		-- control
		hhs[numhhs] = gear
		numhhs = numhhs + 1
		-----------
	end

end

function onGearDelete(gear)

	if GetGearType(gear) == gtShell then
		--nw WriteLnToConsole("on GearDelete call. Shell ID: " .. getGearValue(gear,"ID"))
		--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)

		--if CurrentHedgehog ~= nil then
		--	WriteLnToConsole("As it happens, player is at: " .. GetX(CurrentHedgehog) .. "; " .. GetY(CurrentHedgehog))
		--end
	elseif GetGearType(gear) == gtExplosives then
		--nw WriteLnToConsole("on GearDelete call. Explosives ID: " .. getGearValue(gear,"ID"))
		--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)

		--if CurrentHedgehog ~= nil then
		--	WriteLnToConsole("As it happens, player is at: " .. GetX(CurrentHedgehog) .. "; " .. GetY(CurrentHedgehog))
		--end
	elseif GetGearType(gear) == gtFlame then
		--WriteLnToConsole("on GearDelete flame")
	end





	if isATrackedGear(gear) then
		trackDeletion(gear)
	end

	if CurrentHedgehog ~= nil then
		FollowGear(CurrentHedgehog)
	end

end



------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
-- FLOATY THINGS
-- "I'll make this into a generic library and code properly
-- when I have more time and feel less lazy"
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------




function PlayerIsFine()
	return (playerIsFine)
end

function GetDistFromGearToGear(gear, gear2)

	g1X, g1Y = GetGearPosition(gear)
	g2X, g2Y = GetGearPosition(gear2)
	q = g1X - g2X
	w = g1Y - g2Y


	--[[
	WriteLnToConsole("I just got the position of two gears and calculated the distance betwen them")
	if gear == CurrentHedgehog then
		WriteLnToConsole("Gear 1 is CurrentHedgehog.")
	end
	if gear2 == CurrentHedgehog then
		WriteLnToConsole("Gear 2 is CurrentHedgehog.")
	end
	WriteLnToConsole("G1X: " .. g1X .. "; G1Y: " .. g1Y)
	WriteLnToConsole("G2X: " .. g2X .. "; G2Y: " .. g2Y)
	WriteLnToConsole("Their distance is " .. (q*q) + (w*w) )
	WriteLnToConsole("The above events occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)
]]


	return ( (q*q) + (w*w) )

end

function GetDistFromGearToXY(gear, g2X, g2Y)

	g1X, g1Y = GetGearPosition(gear)
	q = g1X - g2X
	w = g1Y - g2Y


	--[[WriteLnToConsole("I just got the position of a gear and calculated the distance betwen it and another xy")
	if gear == CurrentHedgehog then
		WriteLnToConsole("Gear 1 is CurrentHedgehog.")
	end

	WriteLnToConsole("G1X: " .. g1X .. "; G1Y: " .. g1Y)
	WriteLnToConsole("Other X: " .. g2X .. "; Other Y: " .. g2Y)
	WriteLnToConsole("Their distance is " .. (q*q) + (w*w) )
	WriteLnToConsole("The above events occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)
]]


	return ( (q*q) + (w*w) )


end

function CreateMeSomeCircles()

	for i = 0, 7 do
		vCCount = vCCount +1
		vCirc[i] = AddVisualGear(0,0,vgtCircle,0,true)

		vCircDX[i] = 0
		vCircDY[i] = 0

		vType[i] = "generic"
		vCounter[i] = 0
		vCounterLim[i] = 3000
		vCircScore[i] = 0
		vCircHealth[i] = 1

		vCircMinA[i] = 80	--80 --20
		vCircMaxA[i] = 255
		vCircType[i] = 1	--1
		vCircPulse[i] = 10
		vCircFuckAll[i] = 0
		vCircRadius[i] = 0
		vCircWidth[i] = 3 --5

		vCircRadMax[i] = 0
		vCircRadMin[i] = 0
		vCircRadDir[i] = -1
		vCircRadCounter[i] = 0

		vCircX[i], vCircY[i] = 0,0

		vCircCol[i] = 0xff00ffff

		SetVisualGearValues(vCirc[i], vCircX[i], vCircY[i], vCircMinA[i], vCircMaxA[i], vCircType[i], vCircPulse[i], vCircFuckAll[i], vCircRadius[i], vCircWidth[i], vCircCol[i])
	end

	pShield = AddVisualGear(0,0,vgtCircle,0,true)
	--SetVisualGearValues(pShield, GetX(CurrentHedgehog), GetY(CurrentHedgehog), 80, 200, 1, 10, 0, 200, 5, 0xff00ffff)


end

function IGotMeASafeXYValue(i)

	acceptibleDistance = 800

	-- put this in here to thwart attempts at repositioning and test sanity limit
	--vCircX[i] = GetX(CurrentHedgehog)+250
	--vCircY[i] = GetY(CurrentHedgehog)+250

	vCircX[i] = GetRandom(5000)
	vCircY[i] = GetRandom(2000)
	dist = GetDistFromGearToXY(CurrentHedgehog, vCircX[i], vCircY[i])
	if dist > acceptibleDistance*acceptibleDistance then
		return(true)
	else
		return(false)
	end

end

function CircleDamaged(i)

	res = ""
	vCircHealth[i] = vCircHealth[i] -1

	if vCircHealth[i] <= 0 then
	-- circle is dead, do death effects/consequences

		vCircActive[i] = false

		if (vType[i] == "drone") then
			PlaySound(sndHellishImpact4)
			TimeLeft = TimeLeft + 4
			AddCaption(loc("Time Extended!") .. "+" .. 4 .. loc("s"), 0xff0000ff,capgrpMessage )

			morte = AddGear(vCircX[i], vCircY[i], gtExplosives, 0, 0, 0, 1)
			SetHealth(morte, 0)

			RK = RK + 1
			if RK == 5 then
				RK = 0
				AddCaption(loc("Drone Hunter!") .. " +10 " .. loc("points") .. "!",0xffba00ff,capgrpMessage2)
				AwardPoints(10)
			end

		elseif (vType[i] == "ammo") then
			AddVisualGear(vCircX[i], vCircY[i], vgtExplosion, 0, false)
			PlaySound(sndExplosion)
			PlaySound(sndShotgunReload)
			primShotsLeft = primShotsLeft + 3
			AddCaption("+" .. 3 .. " " .. loc("Ammo"), 0x00ff00ff,capgrpMessage)

			GK = GK + 1
			if GK == 3 then
				GK = 0
				AddCaption(loc("Ammo Maniac!") .. " +5 " .. loc("points") .. "!",0xffba00ff,capgrpMessage2)
				AwardPoints(5)
			end

		elseif (vType[i] == "bonus") then

			AddVisualGear(vCircX[i], vCircY[i], vgtExplosion, 0, false)
			PlaySound(sndExplosion)

			AddVisualGear(vCircX[i], vCircY[i], vgtFire, 0, false)
			AddVisualGear(vCircX[i], vCircY[i], vgtFire, 0, false)
			AddVisualGear(vCircX[i], vCircY[i], vgtFire, 0, false)
			AddVisualGear(vCircX[i], vCircY[i], vgtFire, 0, false)
			AddVisualGear(vCircX[i], vCircY[i], vgtFire, 0, false)
			AddVisualGear(vCircX[i], vCircY[i], vgtSmoke, 0, false)

			PlaySound(sndVaporize)
			--sndWarp sndMineTick --sndSwitchHog --sndSuddenDeath

			shieldHealth = shieldHealth + 30
			AddCaption(loc("Shield boosted! +30 power"), 0xa800ffff,capgrpMessage)
			if shieldHealth >= 250 then
				shieldHealth = 250
				AddCaption(loc("Shield is fully recharged!"),0xa800ffff,capgrpMessage)
			end

			OK = OK + 1
			if OK == 3 then
				OK = 0
				AddCaption(loc("Shield Seeker!") .. " + 10 " .. loc("points") .. "!",0xffba00ff,capgrpMessage2)
				AwardPoints(10)
			end

		elseif (vType[i] == "blueboss") then
			PlaySound(sndHellishImpact3)
			AddCaption(loc("Boss defeated!") .. " +50 " .. loc("points") .. "!", 0x0050ffff,capgrpMessage)

			morte = AddGear(vCircX[i], vCircY[i], gtExplosives, 0, 0, 0, 1)
			SetHealth(morte, 0)

			BK = BK + 1
			if BK == 2 then
				BK = 0
				AddCaption(loc("Boss Slayer!") .. " +25 " .. loc("points") .. "!"),0xffba00ff,capgrpMessage2)
				AwardPoints(25)
			end

		end

		AwardPoints(vCircScore[i])
		AwardKills()
		SetUpCircle(i)
		res = "fatal"

		chainCounter = 3000
		chainLength = chainLength + 1
		if chainLength > 1 then
			AddCaption( chainLength .. "-" .. loc("Hit Combo!") .. " +"  chainLength*2 .. " " .. loc("points") .. "!",0xffba00ff,capgrpAmmostate)
			AwardPoints(chainLength*2)
		end

	else
	-- circle is merely damaged
	-- do damage effects/sounds
		AddVisualGear(vCircX[i], vCircY[i], vgtSteam, 0, false)
		r = GetRandom(4)
		if r == 0 then
			PlaySound(sndHellishImpact1)
		elseif r == 1 then
			PlaySound(sndHellishImpact2)
		elseif r == 2 then
			PlaySound(sndHellishImpact3)
		elseif r == 3 then
			PlaySound(sndHellishImpact4)
		end
		res = "non-fatal"

	end

	return(res)

end

function SetUpCircle(i)


	r = GetRandom(10)
	--r = 8
	-- 80% of spawning either red/green
	if r <= 7 then

		--r = GetRandom(5)
		r = GetRandom(2)
		--r = 1
		if r == 0 then
		--if r <= 2 then
			vCircCol[i] = 0xff0000ff -- red
			vType[i] = "drone"
			vCircRadMin[i] = 50	*5
			vCircRadMax[i] = 90	*5
			vCounterLim[i] = 3000
			vCircScore[i] = 10
			vCircHealth[i] = 1
		--else
		elseif r == 1 then
			vCircCol[i] = 0x00ff00ff -- green
			vType[i] = "ammo"
			vCircRadMin[i] = 25	*7
			vCircRadMax[i] = 30	*7
			vCircScore[i] = 3
			vCircHealth[i] = 1
		end

	-- 20% chance of spawning boss or bonus
	else
		r = GetRandom(5)
		--r = GetRandom(2)
		--r = 0
		if r <= 1 then
		--if r == 0 then
			vCircCol[i] = 0x0050ffff -- sexy blue
			vType[i] = "blueboss"
			vCircRadMin[i] = 100*5
			vCircRadMax[i] = 180*5
			vCircWidth[i] = 1
			vCounterLim[i] = 2000
			vCircScore[i] = 50
			vCircHealth[i] = 3
		else
		--elseif r == 1 then
			--vCircCol[i] = 0xffae00ff -- orange
			vCircCol[i] = 0xa800ffff -- purp
			vType[i] = "bonus"
			vCircRadMin[i] = 20 *7
			vCircRadMax[i] = 40 *7
			vCircScore[i] = 5
			vCircHealth[i] = 1
		end

	end

	-- regenerate circle xy if too close to player or until sanity limit kicks in
	reN = 0
	--zzz = 0
	while (reN < 10) do
		if IGotMeASafeXYValue(i) == false then
			reN = reN + 1
			--zzz = zzz + 1
		else
			reN = 15
		end
	end
	--AddCaption("Took me this many retries: " .. zzz) -- number of times it took to work

	vCircRadius[i] = vCircRadMax[i] - GetRandom(vCircRadMin[i])

	g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(vCirc[i])
	SetVisualGearValues(vCirc[i], vCircX[i], vCircY[i], g3, g4, g5, g6, g7, vCircRadius[i], vCircWidth[i], vCircCol[i]-0x000000ff)
	-- - -0x000000ff
	vCircActive[i] = true -- new

	--nw WriteLnToConsole("CIRC " .. i .. ": X: " .. vCircX[i] .. "; Y: " .. vCircY[i])
	--nw WriteLnToConsole("CIRC " .. i .. ": dX: " .. vCircDX[i] .. "; dY: " .. vCircDY[i])
	--nw WriteLnToConsole("CIRC " .. i .. ": RAD:" .. vCircRadius[i])

end

function SetMyCircles(s)

	CirclesAreGo = s
	playerIsFine = s

	if s == true then
		--nw WriteLnToConsole("About to set up all circles, old values are here:")
		for i = 0,(vCCount-1) do
			--nw WriteLnToConsole("CIRC " .. i .. ": X: " .. vCircX[i] .. "; Y: " .. vCircY[i])
			--nw WriteLnToConsole("CIRC " .. i .. ": dX: " .. vCircDX[i] .. "; dY: " .. vCircDY[i])
			--nw WriteLnToConsole("CIRC " .. i .. ": RAD:" .. vCircRadius[i])
		end
		--nw WriteLnToConsole("Old values given, new values to follow...")
	end

	for i = 0,(vCCount-1) do

		if s == false then
			--vCircCol[i] = 0xffffffff
			vCircActive[i] = false
		elseif s == true then
			SetUpCircle(i)
		end

	end

end

function WellHeAintGonnaJumpNoMore(x,y)

	AddVisualGear(x, y, vgtBigExplosion, 0, false)
	playerIsFine = false
	AddCaption(loc("GOTCHA!"))
	PlaySound(sndExplosion)
	PlaySound(sndHellish)

	targetHit = true

end

--- collision detection for weapons fire
function CheckVarious(gear)

	--if (GetGearType(gear) == gtExplosives) then
		--nw WriteLnToConsole("Start of CheckVarious(): Exp ID: " .. getGearValue(gear,"ID"))
	--elseif (GetGearType(gear) == gtShell) then
		--nw WriteLnToConsole("Start of CheckVarious(): Shell ID: " .. getGearValue(gear,"ID"))
	--end




	targetHit = false

	-- if circle is hit by player fire
	if (GetGearType(gear) == gtExplosives) then
		circsHit = 0

		for i = 0,(vCCount-1) do

			--nw WriteLnToConsole("Is it neccessary to check for collision with circ " .. i)

			--if (vCircActive[i] == true) and ( (vType[i] == "drone") ) then

				--nw WriteLnToConsole("YES. about to calc distance between gtExplosives and circ " .. i)

				dist = GetDistFromGearToXY(gear, vCircX[i], vCircY[i])

				-- calculate my real radius if I am an aura
				if vCircType[i] == 0 then
					NR = vCircRadius[i]
				else
					NR = (48/100*vCircRadius[i])/2
				end

				if dist <= NR*NR then

						--nw WriteLnToConsole("Collision confirmed. The gtExplosives is within the circ radius!")

					--SetGearPosition(gear, vCircX[i], vCircY[i])
						--WriteLnToConsole("set the gtExplosives to be in the center of circ")
					AddVisualGear(GetX(gear), GetY(gear), vgtBigExplosion, 0, false)

					targetHit = true
					--DeleteGear(gear)
					--SetHealth(gear,0)
						--WriteLnToConsole("set " .. "Exp ID: " .. getGearValue(gear,"ID") .. " health to 0")
						--WriteLnToConsole("targetHit set to true, explosive is at distance " .. dist .. "(within range " .. NR*NR.. ") of circ" )

					CircleDamaged(i)

					circsHit = circsHit + 1
					if circsHit > 1 then
						AddCaption(loc("Multi-shot!") .. " +5 " .. loc("points") .. "!",0xffba00ff,capgrpAmmostate) 
					end

					shotsHit = shotsHit + 1

				end

			--end

		end

	-- if player is hit by circle bazooka
	elseif (GetGearType(gear) == gtShell) or (GetGearType(gear) == gtBall) then

		dist = GetDistFromGearToGear(gear, CurrentHedgehog)

		if beam == true then

			if dist < 3000 then
				tempE = AddVisualGear(GetX(gear), GetY(gear), vgtSmoke, 0, true)
				g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(tempE)
				SetVisualGearValues(tempE, g1, g2, g3, g4, g5, g6, g7, g8, g9, 0xff00ffff )
				PlaySound(sndVaporize)
				DeleteGear(gear)

				SK = SK + 1
				if SK == 5 then
					SK = 0
					AddCaption(loc("Shield Master!") .. " +10 " .. loc("points") .. "!",0xffba00ff,capgrpAmmoinfo)
					AwardPoints(10)
				end
			end

		elseif dist < 1600 then
			WellHeAintGonnaJumpNoMore(GetX(gear), GetY(gear))
		end

		--[[if targetHit == true then
			WriteLnToConsole("about to delete shell due to targetHit being set to true earlier")
			DeleteGear(gear)
			WriteLnToConsole("there, I deleted it")
		end]]


	end

	if targetHit == true then
			--nw WriteLnToConsole("about to delete something due to targetHit being set to true earlier")
			DeleteGear(gear)
			--nw WriteLnToConsole("there, I deleted it")
	end

	--nw WriteLnToConsole("End of CheckVarious()")

end

-- collision detection for player entering a circle
function CheckDistances()

	--nw WriteLnToConsole("Start of CheckDistances()")

	for i = 0,(vCCount-1) do


		--nw WriteLnToConsole("Attempting to calculate dist of circ " .. i)

		g1X, g1Y = GetGearPosition(CurrentHedgehog)
		g2X, g2Y = vCircX[i], vCircY[i]

		g1X = g1X - g2X
		g1Y = g1Y - g2Y
		dist = (g1X*g1X) + (g1Y*g1Y)

		--nw WriteLnToConsole("Calcs done. Dist to CurrentHedgehog is " .. dist)

		-- calculate my real radius if I am an aura
		if vCircType[i] == 0 then
			NR = vCircRadius[i]
		else
			NR = (48/100*vCircRadius[i])/2
		end

		if dist <= NR*NR then

			if 	(vCircActive[i] == true) and
				((vType[i] == "ammo") or (vType[i] == "bonus") )
			then

				CircleDamaged(i)

			elseif (vCircActive[i] == true) and
					( (vType[i] == "drone") or (vType[i] == "blueboss") )
			then

				ss = CircleDamaged(i)
				WellHeAintGonnaJumpNoMore(GetX(CurrentHedgehog),GetY(CurrentHedgehog))

				if ss == "fatal" then
					if (primShotsLeft == 0) and (TimeLeft <= 9) then
						AddCaption(loc("Kamikaze Expert!") .. " +15 " .. loc("points") .. "!",0xffba00ff,capgrpMessage)
						AwardPoints(15)
					elseif (primShotsLeft == 0) then
						AddCaption(loc("Depleted Kamikaze!") .. " +5 " .. loc("points") .. "!",0xffba00ff,capgrpMessage)
						AwardPoints(5)
					elseif TimeLeft <= 9 then
						AddCaption(loc("Timed Kamikaze!") .. " +10 " .. loc("points") .. "!",0xffba00ff,capgrpMessage)
						AwardPoints(10)
					end
				end

			end


		end

	end

	--nw WriteLnToConsole("End of CheckDistances()")

end

function HandleCircles()


	--[[if CirclesAreGo == true then

		--CheckDistances()
		--runOnGears(CheckVarious)	-- used to be in handletracking for some bizarre reason

		--pTimer = pTimer + 1
		--if pTimer == 100 then
		--	pTimer = 0
		--	runOnGears(ProjectileTrack)
		--end

	end]]

	for i = 0,(vCCount-1) do

		vCounter[i] = vCounter[i] + 1
		if vCounter[i] >= vCounterLim[i] then

			vCounter[i] = 0

			if 	((vType[i] == "drone") or (vType[i] == "blueboss") ) and
				(vCircActive[i] == true) then
				AddGear(vCircX[i], vCircY[i], gtShell, 0, 0, 0, 1)

				--WriteLnToConsole("Circle " .. i .. " just fired/added a gtShell")
				--WriteLnToConsole("The above event occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)

			--elseif (vType[i] == "bluebottle") and (vCircActive[i] == true) then
			--	AddGear(vCircX[i], vCircY[i]-vCircRadius[i], gtBall, 0, 0, 0, 1)
			--	AddGear(vCircX[i], vCircY[i]+vCircRadius[i], gtBall, 0, 0, 0, 1)
			--	AddGear(vCircX[i]-vCircRadius[i], vCircY[i], gtBall, 0, 0, 0, 1)
			--	AddGear(vCircX[i]+vCircRadius[i], vCircY[i], gtBall, 0, 0, 0, 1)
			end

		end

		if (vCircActive[i] == true) then

			vCircRadCounter[i] = vCircRadCounter[i] + 1
			if vCircRadCounter[i] == 100 then

				vCircRadCounter[i] = 0

				-- make my radius increase/decrease faster if I am an aura
				if vCircType[i] == 0 then
					M = 1
				else
					M = 10
				end

				vCircRadius[i] = vCircRadius[i] + vCircRadDir[i]
				if vCircRadius[i] > vCircRadMax[i] then
					vCircRadDir[i] = -M
				elseif vCircRadius[i] < vCircRadMin[i] then
					vCircRadDir[i] = M
				end


				-- random effect test
				-- maybe use this to tell the difference between circs
				-- you can kill by shooting or not
				--vgtSmoke vgtSmokeWhite
				--vgtSteam -- nice long trail
				--vgtDust -- short trail on earthrise
				--vgtSmokeTrace
				if vType[i] == "ammo" then

					tempE = AddVisualGear(vCircX[i], vCircY[i], vgtSmoke, 0, true)
					g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(tempE)	--0xff00ffff	--0x00ff00ff
					SetVisualGearValues(tempE, vCircX[i], vCircY[i], g3, g4, g5, g6, g7, g8, g9, vCircCol[i] )

					--AddVisualGear(vCircX[i], vCircY[i], vgtDust, 0, true)

				elseif vType[i] == "bonus" then

					tempE = AddVisualGear(vCircX[i], vCircY[i], vgtDust, 0, true)
					g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(tempE)	--0xff00ffff	--0x00ff00ff --vCircCol[i]
					SetVisualGearValues(tempE, vCircX[i], vCircY[i], g3, g4, g5, g6, g7, 1, g9, 0xff00ffff )


				elseif vType[i] == "blueboss" then

					k = 25
					g = vgtSteam
					trailColour = 0xae00ffff

					-- 0xffae00ff -- orange
					-- 0xae00ffff -- purp

					tempE = AddVisualGear(vCircX[i], vCircY[i], g, 0, true)
					g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(tempE)	--0xff00ffff	--0x00ff00ff
					SetVisualGearValues(tempE, vCircX[i], vCircY[i]+k, g3, g4, g5, g6, g7, g8, g9, trailColour-75 )

					tempE = AddVisualGear(vCircX[i], vCircY[i], g, 0, true)
					g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(tempE)	--0xff00ffff	--0x00ff00ff
					SetVisualGearValues(tempE, vCircX[i]+k, vCircY[i]-k, g3, g4, g5, g6, g7, g8, g9, trailColour-75 )

					tempE = AddVisualGear(vCircX[i], vCircY[i], g, 0, true)
					g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(tempE)	--0xff00ffff	--0x00ff00ff
					SetVisualGearValues(tempE, vCircX[i]-k, vCircY[i]-k, g3, g4, g5, g6, g7, g8, g9, trailColour-75 )


				end


			end

		end


	end

	-- alter the circles velocities
	circAdjustTimer = circAdjustTimer + 1
	if circAdjustTimer == 2000 then

		circAdjustTimer = 0

		for i = 0,(vCCount-1) do

			-- bounce the circles off the edges if they go too far
			-- or make them move in random directions

			if vCircX[i] > 5500 then
				vCircDX[i] = -5	--5 circmovchange
			elseif vCircX[i] < -1500 then
				vCircDX[i] = 5	--5 circmovchange
			else

				z = GetRandom(2)
				if z == 1 then
					z = 1
				else
					z = -1
				end
				vCircDX[i] = vCircDX[i] + GetRandom(3)*z	--3 circmovchange
			end

			if vCircY[i] > 1500 then
				vCircDY[i] = -5	--5 circmovchange
			elseif vCircY[i] < -2900 then
				vCircDY[i] = 5	--5 circmovchange
			else
				z = GetRandom(2)
				if z == 1 then
					z = 1
				else
					z = -1
				end
				vCircDY[i] = vCircDY[i] + GetRandom(3)*z	--3 circmovchange
			end

		end

	end

	-- move the circles according to their current velocities
	m2Count = m2Count + 1
	if m2Count == 25 then	--25 circmovchange

		m2Count = 0
		for i = 0,(vCCount-1) do
			vCircX[i] = vCircX[i] + vCircDX[i]
			vCircY[i] = vCircY[i] + vCircDY[i]
		end

		if (TimeLeft == 0) and (tumbleStarted == true) then

			FadeAlpha = FadeAlpha + 1
			if FadeAlpha >= 255 then
				FadeAlpha = 255
			end

			--new			
			--if FadeAlpha == 1 then
			--	AddCaption("GOT IT")				
			--	for i = 0,(vCCount-1) do
			--		g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(vCirc[i])
			--		vCircCol[i] = g10	
			--	end
			--end

		end

	end

	for i = 0,(vCCount-1) do
		g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(vCirc[i])		-- vCircCol[i] g10
		SetVisualGearValues(vCirc[i], vCircX[i], vCircY[i], g3, g4, g5, g6, g7, vCircRadius[i], g9, g10)
	end

	if 	(TimeLeft == 0) or
		((tumbleStarted == false)) then
		for i = 0,(vCCount-1) do
			g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(vCirc[i])		-- vCircCol[i] g10
			SetVisualGearValues(vCirc[i], vCircX[i], vCircY[i], g3, g4, g5, g6, g7, vCircRadius[i], g9, (vCircCol[i]-FadeAlpha))
		end
	end


	if (CurrentHedgehog ~= nil) and (beam == true) then
		g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(pShield)
		--SetVisualGearValues(pShield, GetX(CurrentHedgehog), GetY(CurrentHedgehog), g3, g4, g5, g6, g7, 200, g9, g10 )
		SetVisualGearValues(pShield, GetX(CurrentHedgehog), GetY(CurrentHedgehog), g3, g4, g5, g6, g7, 200, g9, 0xa800ffff-0x000000ff - -shieldHealth )
	else
		SetVisualGearValues(pShield, GetX(CurrentHedgehog), GetY(CurrentHedgehog), g3, g4, g5, g6, g7, 0, g9, g10 )
	end

end

function ProjectileTrack(gear)

	if (GetGearType(gear) == gtShell) then

		--nw WriteLnToConsole("ProjectileTrack() for Shell ID: " .. getGearValue(gear,"ID"))

		-- newnew
		if (GetGearType(gear) == gtShell) then
			turningSpeed = 0.1*fMod
		--elseif (GetGearType(gear) == gtBall) then
		--	turningSpeed = 0.2*fMod
		end

		dx, dy = GetGearVelocity(gear)

		--WriteLnToConsole("I'm trying to track currenthedge with shell ID: " .. getGearValue(gear,"ID"))
		--WriteLnToConsole("I just got the velocity of the shell. It is dx: " .. dx .. "; dy: " .. dy)
		--WriteLnToConsole("CurrentHedgehog is at X: " .. GetX(CurrentHedgehog) .. "; Y: " .. GetY(CurrentHedgehog) )

		if GetX(gear) > GetX(CurrentHedgehog) then
			dx = dx - turningSpeed--0.1
		else
			dx = dx + turningSpeed--0.1
		end

		if GetY(gear) > GetY(CurrentHedgehog) then
			dy = dy - turningSpeed--0.1
		else
			dy = dy + turningSpeed--0.1
		end


		if (GetGearType(gear) == gtShell) then
			dxlimit = 0.4*fMod
			dylimit = 0.4*fMod
		--elseif (GetGearType(gear) == gtBall) then
		--	dxlimit = 0.5	--  0.5 is about the same
		--	dylimit = 0.5 -- 0.6 is faster than player
		end

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

		SetGearVelocity(gear, dx, dy)

		--WriteLnToConsole("I just SET the velocity of shell towards currenthegdge. It is now dx: " .. dx .. "; dy: " .. dy)
		--WriteLnToConsole("The above events occured game Time: " .. GameTime .. "; luaTicks: " .. luaGameTicks)
		--nw WriteLnToConsole("ProjectileTrack() finished successfully")

	end

end

