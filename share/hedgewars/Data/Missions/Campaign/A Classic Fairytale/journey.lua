loadfile(GetDataPath() .. "Scripts/Animate.lua")()

--///////////////////////////////CONSTANTS///////////////////////////

choiceAccepted = 0
choiceRefused = 1
choiceAttacked = 2

endStage = 1

cannibalNum = 8
cannibalNames = {"John", "Flesh for Brainz", "Eye Chewer", "Torn Muscle",
                 "Nom-Nom", "Vedgies", "Brain Blower", "Gorkij"}
cannibalPos = {{2471, 1174}, {939, 1019}, {1953, 902}, {3055, 1041},
               {1121, 729}, {1150, 718}, {1149, 680}, {1161, 773}}

startLeaksPosDuo = {3572, 1426}
startEventXDuo = 3300
startDensePosDuo = {3454, 1471}
startCyborgPosDuo = {3202, 1307}
midDensePosDuo = {1464, 1408}
midCyborgPosDuo = {1264, 1390}

--///////////////////////////////VARIABLES///////////////////////////

m2Choice = 0
m2DenseDead = 0
m2RamonDead = 0
m2SpikyDead = 0

TurnsLeft = 0
stage = 0

cyborgHidden = false
princessHidden = false
blowTaken = false
fireTaken = false
gravityTaken = false
sniperTaken = false
girderTaken = false
girder1Taken = false
girder2Taken = false
leaksDead = false
denseDead = false
princessDead = false
cyborgDead = false
cannibalDead = {}

startAnim = {}
startAnimAD = {}
startAnimAL = {}
startAnimRL = {}

pastFlowerAnimAL = {}
pastFlowerAnimRL = {}
pastFlowerAnim = {}

outPitAnimAL = {}
outPitAnimRL = {}
outPitAnim = {}

midAnim = {}
midAnimAD = {}

failAnim = {}
failAnimAD = {}

endAnim = {}
endAnimAD = {}
endAnimAL = {}
endAnimRL = {}

endFailAnim = {}
endFailAnimAD = {}

winAnim = {}
winAnimAD = {}

--/////////////////////////Animation Functions///////////////////////
function AfterMidFailAnim()
  ParseCommand("teamgone Natives")
  TurnTimeLeft = 0
end

function AfterMidAnimAlone()
  SetupCourse()
  for i = 5, 8 do
    RestoreHog(cannibals[i])
    SetGearPosition(cannibals[i], unpack(cannibalPos[i]))
  end

  AddAmmo(cannibals[5], amDEagle, 0)

  AddEvent(CheckGirderTaken, {}, DoGirderTaken, {}, 0)
  AddEvent(CheckOnFirstGirder, {}, DoOnFirstGirder, {}, 0)
  AddEvent(CheckTookSniper, {}, DoTookSniper, {}, 0)
  AddEvent(CheckFailedCourse, {}, DoFailedCourse, {}, 0)
  SetGearMessage(leaks, 0)
  TurnsLeft = 12
  TurnTimeLeft = TurnTime
  ShowMission("The Journey Back", "Collateral Damage", "Save the princess by collecting the crate in under 12 turns!", 0, 6000)
  -----------------------///////////////------------
  --SetGearPosition(leaks, 417, 1800)
end

function SkipEndAnimAlone()
  if cyborgHidden then
    RestoreHog(cyborg)
    cyborgHidden = false
  end
  if princessHidden then
    RestoreHog(princess)
    princessHidden = false
  end
  SetGearPosition(cyborg, 437, 1700)
  SetGearPosition(princess, 519, 1722)
end

function SkipEndAnimDuo()
  if cyborgHidden then
    RestoreHog(cyborg)
    cyborgHidden = false
  end
  if princessHidden then
    RestoreHog(princess)
    princessHidden = false
  end
  SetGearPosition(cyborg, 437, 1700)
  SetGearPosition(princess, 519, 1722)
  SetGearPosition(leaks, 763, 1760)
  SetGearPosition(dense, 835, 1519)
  HogTurnLeft(leaks, true)
  HogTurnLeft(dense, true)
end

function AfterEndAnimAlone()
  stage = endStage
  SwitchHog(leaks)
  SetGearMessage(leaks, 0)
  TurnTimeLeft = -1
  ShowMission("The Journey Back", "Collateral Damage II", "Save Fell From Heaven!", 1, 4000)
  AddEvent(CheckLost, {}, DoLost, {}, 0)
  AddEvent(CheckWon, {}, DoWon, 0)
  RemoveEventFunc(CheckFailedCourse)
end

function AfterEndAnimDuo()
  stage = endStage
  SwitchHog(leaks)
  SetGearMessage(leaks, 0)
  TurnTimeLeft = -1
  ShowMission("The Journey Back", "Collateral Damage II", "Save Fell From Heaven!", 1, 4000)
  AddEvent(CheckLost, {}, DoLost, {}, 0)
  AddEvent(CheckWon, {}, DoWon, {}, 0)
end

function SkipMidAnimAlone()
  SetGearPosition(leaks, 2656, 1842)
  AnimSwitchHog(leaks)
  SetInputMask(0xFFFFFFFF)
  if princessHidden == false then
    HideHog(princess)
    princessHidden = true
  end
  if cyborgHidden == false then
    HideHog(cyborg)
    cyborgHidden = true
  end
end

function AfterStartAnim()
  SetGearMessage(leaks, 0)
  TurnTimeLeft = TurnTime
  local goal = "Get the crate on the other side of the island!|"
  local hint = "Hint: you might want to stay out of sight and take all the crates...|"
  local stuck = "If you get stuck, use your Desert Eagle or restart the mission!|"
  local conds = "Leaks A Lot must survive!"
  if m2DenseDead == 0 then
    conds = "Your hogs must survive!"
  end
  ShowMission("The Journey Back", "Adventurous", goal .. hint .. stuck .. conds, 0, 7000)
end

function SkipStartAnim()
  AnimSwitchHog(leaks)
end

function PlaceCratesDuo()
  SpawnAmmoCrate(3104, 827, amBaseballBat)
  girderCrate1 = SpawnUtilityCrate(2466, 1814, amGirder)
  girderCrate2 = SpawnUtilityCrate(2630, 1278, amGirder)
  SpawnUtilityCrate(2422, 1810, amParachute)
  SpawnUtilityCrate(3107, 1009, amLowGravity)
  sniperCrate = SpawnAmmoCrate(784, 1715, amSniperRifle)
end

function PlaceMinesDuo()
  SetTimer(AddGear(2920, 1448, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2985, 1338, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(3005, 1302, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(3030, 1270, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(3046, 1257, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2954, 1400, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2967, 1385, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2849, 1449, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2811, 1436, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2773, 1411, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2732, 1390, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2700, 1362, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2642, 1321, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2172, 1417, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2190, 1363, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2219, 1332, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1201, 1207, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1247, 1205, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1295, 1212, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1356, 1209, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1416, 1201, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1466, 1201, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1678, 1198, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1738, 1198, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1796, 1198, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1637, 1217, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1519, 1213, gtMine, 0, 0, 0, 0), 5000)
end

function AfterPastFlowerAnim()
  PlaceMinesDuo()
  AddEvent(CheckDensePit, {}, DoDensePit, {}, 0)
  AddEvent(CheckTookGirder1, {}, DoTookGirder1, {}, 0)
  AddEvent(CheckTookGirder2, {}, DoTookGirder2, {}, 0)
  SetGearMessage(leaks, 0)
  SetGearMessage(dense, 0)
  TurnTimeLeft = 0
  ShowMission("The Journey Back", "The Savior", "Get Dense Cloud out of the pit!", 1, 5000)
end

function SkipPastFlowerAnim()
  SetGearPosition(dense, 2656, 1842)
  AnimSwitchHog(dense)
  if cyborgHidden == false then
    HideHog(cyborg)
    cyborgHidden = true
  end
end

function AfterOutPitAnim()
  SetupCourseDuo()
  RestoreHog(cannibals[5])
  AddAmmo(cannibals[5], amDEagle, 0)
  HideHog(cannibals[5])
  AddEvent(CheckTookFire, {}, DoTookFire, {}, 0)
  SetGearMessage(leaks, 0)
  SetGearMessage(dense, 0)
  TurnTimeLeft = 0
  ShowMission("The Journey Back", "They never learn", "Free Dense Cloud and continue the mission!", 1, 5000)
end

function SkipOutPitAnim()
  SetGearPosition(dense, unpack(midDensePosDuo))
  AnimSwitchHog(dense)
  if cyborgHidden == false then
    HideHog(cyborg)
    cyborgHidden = true
  end
end

function RestoreCyborg(x, y, xx, yy)
  RestoreHog(cyborg)
  RestoreHog(princess)
  cyborgHidden = false
  princessHidden = false
  AnimOutOfNowhere(cyborg, x, y)
  AnimOutOfNowhere(princess, xx, yy)
  HogTurnLeft(princess, false)
  return true
end

function RestoreCyborgOnly(x, y)
  RestoreHog(cyborg)
  cyborgHidden = false
  AnimOutOfNowhere(cyborg, x, y)
  return true
end

function TargetPrincess()
  ParseCommand("setweap " .. string.char(amDEagle))
  SetGearMessage(cyborg, gmUp)
  return true
end

function HideCyborg()
  if cyborgHidden == false then
    HideHog(cyborg)
    cyborgHidden = true
  end
  if princessHidden == false then
    HideHog(princess)
    princessHidden = true
  end
end

function HideCyborgOnly()
  if cyborgHidden == false then
    HideHog(cyborg)
    cyborgHidden = true
  end
end

function SetupKillRoom()
  PlaceGirder(2342, 1814, 2)
  PlaceGirder(2294, 1783, 0)
  PlaceGirder(2245, 1814, 2)
end

function SetupCourseDuo()
  PlaceGirder(1083, 1152, 6)
  PlaceGirder(1087, 1150, 6)
  PlaceGirder(1133, 1155, 0)
  PlaceGirder(1135, 1152, 0)
  PlaceGirder(1135, 1078, 0)
  PlaceGirder(1087, 1016, 2)
  PlaceGirder(1018, 921, 5)
  PlaceGirder(1016, 921, 5)
  PlaceGirder(962, 782, 6)
  PlaceGirder(962, 662, 2)
  PlaceGirder(962, 661, 2)
  PlaceGirder(962, 650, 2)
  PlaceGirder(962, 630, 2)
  PlaceGirder(1033, 649, 0)
  PlaceGirder(952, 650, 0)

  fireCrate = SpawnAmmoCrate(1846, 1100, amFirePunch)
  SpawnUtilityCrate(1849, 1149, amPickHammer)
  SpawnAmmoCrate(960, 674, amDynamite)
  SpawnUtilityCrate(994, 825, amRope)
  SpawnUtilityCrate(570, 1357, amLowGravity)
end

function DumpMines()
  SetTimer(AddGear(2261, 1835, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2280, 1831, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2272, 1809, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2290, 1815, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2278, 1815, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2307, 1811, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2286, 1820, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2309, 1813, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2303, 1822, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2317, 1827, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2312, 1816, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2316, 1812, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2307, 1802, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2276, 1818, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2284, 1816, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2292, 1811, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2295, 1814, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2306, 1811, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2292, 1815, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2314, 1815, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2286, 1813, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2275, 1813, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2269, 1814, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2273, 1812, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2300, 1808, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2322, 1812, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2323, 1813, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2311, 1811, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2303, 1809, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2287, 1808, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2282, 1808, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2277, 1809, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2296, 1809, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(2314, 1818, gtMine, 0, 0, 0, 0), 5000)
end

function SetupAnimRefusedDied()
  SetupAnimAcceptedDied()
  table.insert(startAnim, {func = AnimSay, args = {leaks, "I just wonder where Ramon and Spiky disappeared...", SAY_THINK, 6000}})
end

function SetupAnimAttacked()
  SetupAnimAcceptedDied()
  startAnim = {}
  table.insert(startAnim, {func = AnimWait, args = {leaks, 3000}})
  table.insert(startAnim, {func = AnimTurn, args = {leaks, "Left"}})
  table.insert(startAnim, {func = AnimSay, args = {leaks, "I wonder where Dense Cloud is...", SAY_THINK, 4000}})
  table.insert(startAnim, {func = AnimSay, args = {leaks, "He must be in the village already.", SAY_THINK, 4000}})
  table.insert(startAnim, {func = AnimSay, args = {leaks, "I'd better get going myself.", SAY_THINK, 4000}})

  midAnim = {}
  table.insert(midAnim, {func = AnimWait, args = {leaks, 500}})
  table.insert(midAnim, {func = AnimCustomFunction, swh = false, args = {leaks, RestoreCyborg, {1300, 1200, 1390, 1200}}})
  table.insert(midAnim, {func = AnimSwitchHog, args = {cyborg}})
  table.insert(midAnim, {func = AnimCustomFunction, args = {cyborg, TargetPrincess, {}}})
  table.insert(midAnim, {func = AnimSay, args = {cyborg, "Welcome, Leaks A Lot!", SAY_SAY, 3000}})
  table.insert(midAnim, {func = AnimSay, args = {cyborg, "I want to play a game...", SAY_SAY, 3000}})
  table.insert(midAnim, {func = AnimSay, args = {princess, "Help me, please!!!", SAY_SHOUT, 3000}})
  table.insert(midAnim, {func = AnimSay, args = {cyborg, "If you can get that crate fast enough, your beloved \"princess\" may go free.", SAY_SAY, 7000}})
  table.insert(midAnim, {func = AnimSay, args = {cyborg, "However, if you fail to do so, she dies a most violent death! Muahahaha!", SAY_SAY, 8000}})
  table.insert(midAnim, {func = AnimSay, args = {cyborg, "Good luck...or else!", SAY_SAY, 4000}})
  table.insert(midAnim, {func = AnimTeleportGear, args = {leaks, 2656, 1842}})
  table.insert(midAnim, {func = AnimCustomFunction, args = {cyborg, HideCyborg, {}}, swh = false})
  table.insert(midAnim, {func = AnimSay, args = {leaks, "Hey! This is cheating!", SAY_SHOUT, 4000}})
  AddSkipFunction(midAnim, SkipMidAnimAlone, {})
end

function SetupAnimAcceptedDied()
  table.insert(startAnimAD, {func = AnimWait, args = {leaks, 3000}})
  table.insert(startAnimAD, {func = AnimTurn, args = {leaks, "left"}})
  table.insert(startAnimAD, {func = AnimSay, args = {leaks, "I need to get to the other side of this island, fast!", SAY_THINK, 5000}})
  table.insert(startAnimAD, {func = AnimSay, args = {leaks, "With Dense Cloud on the land of shadows, I'm the village's only hope...", SAY_THINK, 7000}})

  table.insert(midAnimAD, {func = AnimWait, args = {leaks, 500}})
  table.insert(midAnimAD, {func = AnimCustomFunction, swh = false, args = {leaks, RestoreCyborg, {1300, 1200, 1390, 1200}}})
  table.insert(midAnimAD, {func = AnimSwitchHog, args = {cyborg}})
  table.insert(midAnimAD, {func = AnimCustomFunction, args = {cyborg, TargetPrincess, {}}})
  table.insert(midAnimAD, {func = AnimSay, args = {cyborg, "Welcome, Leaks A Lot!", SAY_SAY, 3000}})
  table.insert(midAnimAD, {func = AnimSay, args = {cyborg, "I want to play a game...", SAY_SAY, 3000}})
  table.insert(midAnimAD, {func = AnimSay, args = {princess, "Help me, please!!!", SAY_SHOUT, 3000}})
  table.insert(midAnimAD, {func = AnimSay, args = {cyborg, "If you can get that crate fast enough, your beloved \"princess\" may go free.", SAY_SAY, 7000}})
  table.insert(midAnimAD, {func = AnimSay, args = {cyborg, "However, if you fail to do so, she dies a most violent death, just like your friend! Muahahaha!", SAY_SAY, 8000}})
  table.insert(midAnimAD, {func = AnimSay, args = {cyborg, "Good luck...or else!", SAY_SAY, 4000}})
  table.insert(midAnimAD, {func = AnimTeleportGear, args = {leaks, 2656, 1842}})
  table.insert(midAnimAD, {func = AnimCustomFunction, args = {cyborg, HideCyborg, {}}, swh = false})
  table.insert(midAnimAD, {func = AnimSay, args = {leaks, "Hey! This is cheating!", SAY_SHOUT, 4000}})
  AddSkipFunction(midAnimAD, SkipMidAnimAlone, {})

  table.insert(failAnimAD, {func = AnimCustomFunction, swh = false, args = {leaks, RestoreCyborg, {2299, 1687, 2294, 1841}}})
  table.insert(failAnimAD, {func = AnimTeleportGear, args = {leaks, 2090, 1841}})
  table.insert(failAnimAD, {func = AnimCustomFunction, swh = false, args = {cyborg, SetupKillRoom, {}}})
  table.insert(failAnimAD, {func = AnimTurn, swh = false, args = {cyborg, "Left"}})
  table.insert(failAnimAD, {func = AnimTurn, swh = false, args = {princess, "Left"}})
  table.insert(failAnimAD, {func = AnimTurn, swh = false, args = {leaks, "Right"}})
  table.insert(failAnimAD, {func = AnimWait, args = {cyborg, 1000}})
  table.insert(failAnimAD, {func = AnimSay, args = {cyborg, "You have failed to complete your task, young one!", SAY_SAY, 6000}})
  table.insert(failAnimAD, {func = AnimSay, args = {cyborg, "It's time you learned that your actions have consequences!", SAY_SAY, 7000}})
  table.insert(failAnimAD, {func = AnimSay, args = {princess, "No! Please, help me!", SAY_SAY, 4000}})
  table.insert(failAnimAD, {func = AnimSwitchHog, args = {cyborg}})
  table.insert(failAnimAD, {func = AnimCustomFunction, args = {cyborg, DumpMines, {}}})
  table.insert(failAnimAD, {func = AnimCustomFunction, args = {cyborg, KillPrincess, {}}})
  table.insert(failAnimAD, {func = AnimWait, args = {cyborg, 12000}})
  table.insert(failAnimAD, {func = AnimSay, args = {leaks, "No! What have I done?! What have YOU done?!", SAY_SHOUT, 6000}})

  table.insert(endAnimAD, {func = AnimCustomFunction, swh = false, args = {leaks, RestoreCyborg, {437, 1700, 519, 1722}}})
  table.insert(endAnimAD, {func = AnimTurn, swh = false, args = {cyborg, "Right"}})
  table.insert(endAnimAD, {func = AnimTurn, swh = false, args = {princess, "Right"}})
  table.insert(endAnimAD, {func = AnimSay, args = {princess, "Help me, Leaks!", SAY_SHOUT, 3000}})
  table.insert(endAnimAD, {func = AnimSay, args = {leaks, "But you said you'd let her go!", SAY_SHOUT, 5000}})
  table.insert(endAnimAD, {func = AnimSay, args = {cyborg, "And you believed me? Oh, god, that's cute!", SAY_SHOUT, 7000}})
  table.insert(endAnimAD, {func = AnimSay, args = {leaks, "I won't let you kill her!", SAY_SHOUT, 4000}})
  AddSkipFunction(endAnimAD, SkipEndAnimAlone, {})
  
  table.insert(endFailAnim, {func = AnimCaption, args = {leaks, "Leaks A Lot, depressed for killing his loved one, failed to save the village...", 3000}})

  table.insert(winAnimAD, {func = AnimSay, args = {princess, "Thank you, oh, thank you, Leaks A Lot!", SAY_SAY, 5000}})
  table.insert(winAnimAD, {func = AnimSay, args = {princess, "How can I ever repay you for saving my life?", SAY_SAY, 6000}})
  table.insert(winAnimAD, {func = AnimSay, args = {leaks, "There's nothing more satisfying for me than seeing you share your beauty with the world every morning, my princess!", SAY_SAY, 10000}})
  table.insert(winAnimAD, {func = AnimSay, args = {leaks, "Let's go home!", SAY_SAY, 3000}})
  table.insert(winAnimAD, {func = AnimCaption, args = {leaks, "And so they discovered that cyborgs weren't invulnerable...", 2000}})

  startAnim = startAnimAD
  midAnim = midAnimAD
  failAnim = failAnimAD
  endAnim = endAnimAD
  endFailAnim = endFailAnimAD
  winAnim = winAnimAD
end

function SetupAnimAcceptedLived()
  table.insert(startAnimAL, {func = AnimWait, args = {leaks, 3000}})
  table.insert(startAnimAL, {func = AnimCustomFunction, args = {dense, CondNeedToTurn, {leaks, dense}}})
  table.insert(startAnimAL, {func = AnimSay, args = {leaks, "All right, we just need to get to the other side of the island!", SAY_SAY, 8000}})
  table.insert(startAnimAL, {func = AnimSay, args = {dense, "We have no time to waste...", SAY_SAY, 4000}})
  table.insert(startAnimAL, {func = AnimSwitchHog, args = {leaks}})
  AddSkipFunction(startAnimAL, SkipStartAnim, {})

  table.insert(pastFlowerAnimAL, {func = AnimCustomFunction, args = {dense, RestoreCyborgOnly, {unpack(startCyborgPosDuo)}}, swh = false})
  table.insert(pastFlowerAnimAL, {func = AnimTurn, args = {cyborg, "Right"}})
  table.insert(pastFlowerAnimAL, {func = AnimSay, args = {cyborg, "Well, well! Isn't that the cutest thing you've ever seen?", SAY_SAY, 7000}})
  table.insert(pastFlowerAnimAL, {func = AnimSay, args = {cyborg, "Two little hogs cooperating, getting past obstacles...", SAY_SAY, 7000}})
  table.insert(pastFlowerAnimAL, {func = AnimSay, args = {cyborg, "Let me test your skills a little, will you?", SAY_SAY, 6000}})
  table.insert(pastFlowerAnimAL, {func = AnimTeleportGear, args = {cyborg, 2456, 1842}})
  table.insert(pastFlowerAnimAL, {func = AnimTeleportGear, args = {dense, 2656, 1842}})
  table.insert(pastFlowerAnimAL, {func = AnimCustomFunction, args = {dense, CondNeedToTurn, {cyborg, dense}}})
  table.insert(pastFlowerAnimAL, {func = AnimSay, args = {dense, "Why are you doing this?", SAY_SAY, 4000}})
  table.insert(pastFlowerAnimAL, {func = AnimSay, args = {cyborg, "To help you, of course!", SAY_SAY, 4000}})
  table.insert(pastFlowerAnimAL, {func = AnimSwitchHog, args = {dense}})
  table.insert(pastFlowerAnimAL, {func = AnimDisappear, swh = false, args = {cyborg, 3781, 1583}})
  table.insert(pastFlowerAnimAL, {func = AnimCustomFunction, swh = false, args = {cyborg, HideCyborgOnly, {}}})
  AddSkipFunction(pastFlowerAnimAL, SkipPastFlowerAnim, {})

  table.insert(outPitAnimAL, {func = AnimCustomFunction, args = {dense, RestoreCyborgOnly, {unpack(midCyborgPosDuo)}}, swh = false})
  table.insert(outPitAnimAL, {func = AnimTurn, args = {cyborg, "Right"}})
  table.insert(outPitAnimAL, {func = AnimTeleportGear, args = {dense, unpack(midDensePosDuo)}})
  table.insert(outPitAnimAL, {func = AnimSay, args = {dense, "OH, COME ON!", SAY_SHOUT, 3000}})
  table.insert(outPitAnimAL, {func = AnimSay, args = {cyborg, "Let's see what your comrade does now!", SAY_SAY, 5000}})
  table.insert(outPitAnimAL, {func = AnimSwitchHog, args = {dense}})
  table.insert(outPitAnimAL, {func = AnimDisappear, swh = false, args = {cyborg, 3781, 1583}})
  table.insert(outPitAnimAL, {func = AnimCustomFunction, swh = false, args = {cyborg, HideCyborgOnly, {}}})
  AddSkipFunction(outPitAnimAL, SkipOutPitAnim, {})

  table.insert(endAnim, {func = AnimCustomFunction, swh = false, args = {leaks, RestoreCyborg, {437, 1700, 519, 1722}}})
  table.insert(endAnim, {func = AnimTeleportGear, args = {leaks, 763, 1760}})
  table.insert(endAnim, {func = AnimTeleportGear, args = {dense, 835, 1519}})
  table.insert(endAnim, {func = AnimTurn, swh = false, args = {leaks, "Left"}})
  table.insert(endAnim, {func = AnimTurn, swh = false, args = {dense, "Left"}})
  table.insert(endAnim, {func = AnimTurn, swh = false, args = {cyborg, "Right"}})
  table.insert(endAnim, {func = AnimTurn, swh = false, args = {princess, "Right"}})
  table.insert(endAnim, {func = AnimSay, args = {princess, "Help me, please!", SAY_SHOUT, 3000}})
  table.insert(endAnim, {func = AnimSay, args = {leaks, "What are you doing? Let her go!", SAY_SHOUT, 5000}})
  table.insert(endAnim, {func = AnimSay, args = {cyborg, "Yeah? Watcha gonna do? Cry?", SAY_SHOUT, 5000}})
  table.insert(endAnim, {func = AnimSay, args = {leaks, "We won't let you hurt her!", SAY_SHOUT, 4000}})
  AddSkipFunction(endAnim, SkipEndAnimDuo, {})
  
  table.insert(endFailAnim, {func = AnimCaption, args = {leaks, "Leaks A Lot, depressed for killing his loved one, failed to save the village...", 3000}})

  table.insert(winAnim, {func = AnimSay, args = {princess, "Thank you, oh, thank you, my heroes!", SAY_SAY, 5000}})
  table.insert(winAnim, {func = AnimSay, args = {princess, "How can I ever repay you for saving my life?", SAY_SAY, 6000}})
  table.insert(winAnim, {func = AnimSay, args = {leaks, "There's nothing more satisfying to us than seeing you share your beauty with the world every morning, my princess!", SAY_SAY, 10000}})
  table.insert(winAnim, {func = AnimSay, args = {leaks, "Let's go home!", SAY_SAY, 3000}})
  table.insert(winAnim, {func = AnimCaption, args = {leaks, "And so they discovered that cyborgs weren't invulnerable...", 2000}})

  startAnim = startAnimAL
  pastFlowerAnim = pastFlowerAnimAL
  outPitAnim = outPitAnimAL
end

function SetupAnimRefusedLived()
  table.insert(startAnimRL, {func = AnimWait, args = {leaks, 3000}})
  table.insert(startAnimRL, {func = AnimCustomFunction, args = {dense, CondNeedToTurn, {leaks, dense}}})
  table.insert(startAnimRL, {func = AnimSay, args = {leaks, "All right, we just need to get to the other side of the island!", SAY_SAY, 7000}})
  table.insert(startAnimRL, {func = AnimSay, args = {dense, "Dude, can you see Ramon and Spiky?", SAY_SAY, 5000}})
  table.insert(startAnimRL, {func = AnimSay, args = {leaks, "No...I wonder where they disappeared?!", SAY_SAY, 5000}})
  AddSkipFunction(startAnimRL, SkipStartAnim, {})

  table.insert(pastFlowerAnimRL, {func = AnimCustomFunction, args = {dense, RestoreCyborgOnly, {unpack(startCyborgPosDuo)}}, swh = false})
  table.insert(pastFlowerAnimRL, {func = AnimTurn, args = {cyborg, "Right"}})
  table.insert(pastFlowerAnimRL, {func = AnimSay, args = {cyborg, "Well, well! Isn't that the cutest thing you've ever seen?", SAY_SAY, 7000}})
  table.insert(pastFlowerAnimRL, {func = AnimSay, args = {cyborg, "Two little hogs cooperating, getting past obstacles...", SAY_SAY, 7000}})
  table.insert(pastFlowerAnimRL, {func = AnimSay, args = {cyborg, "Let me test your skills a little, will you?", SAY_SAY, 6000}})
  table.insert(pastFlowerAnimRL, {func = AnimTeleportGear, args = {cyborg, 2456, 1842}})
  table.insert(pastFlowerAnimRL, {func = AnimTeleportGear, args = {dense, 2656, 1842}})
  table.insert(pastFlowerAnimRL, {func = AnimCustomFunction, args = {dense, CondNeedToTurn, {cyborg, dense}}})
  table.insert(pastFlowerAnimRL, {func = AnimSay, args = {dense, "Why are you doing this?", SAY_SAY, 4000}})
  table.insert(pastFlowerAnimRL, {func = AnimSay, args = {cyborg, "You couldn't possibly believe that after refusing my offer I'd just let you go!", SAY_SAY, 9000}})
  table.insert(pastFlowerAnimRL, {func = AnimSay, args = {cyborg, "You're funny!", SAY_SAY, 4000}})
  table.insert(pastFlowerAnimRL, {func = AnimSwitchHog, args = {dense}})
  table.insert(pastFlowerAnimRL, {func = AnimDisappear, swh = false, args = {cyborg, 3781, 1583}})
  table.insert(pastFlowerAnimRL, {func = AnimCustomFunction, swh = false, args = {cyborg, HideCyborgOnly, {}}})
  AddSkipFunction(pastFlowerAnimRL, SkipPastFlowerAnim, {})

  table.insert(outPitAnimRL, {func = AnimCustomFunction, args = {dense, RestoreCyborgOnly, {unpack(midCyborgPosDuo)}}, swh = false})
  table.insert(outPitAnimRL, {func = AnimTurn, args = {cyborg, "Right"}})
  table.insert(outPitAnimRL, {func = AnimTeleportGear, args = {dense, unpack(midDensePosDuo)}})
  table.insert(outPitAnimRL, {func = AnimSay, args = {dense, "OH, COME ON!", SAY_SHOUT, 3000}})
  table.insert(outPitAnimRL, {func = AnimSay, args = {cyborg, "Let's see what your comrade does now!", SAY_SAY, 5000}})
  table.insert(outPitAnimRL, {func = AnimSwitchHog, args = {dense}})
  table.insert(outPitAnimRL, {func = AnimDisappear, swh = false, args = {cyborg, 3781, 1583}})
  table.insert(outPitAnimRL, {func = AnimCustomFunction, swh = false, args = {cyborg, HideCyborgOnly, {}}})
  AddSkipFunction(outPitAnimRL, SkipOutPitAnim, {})

  table.insert(endAnim, {func = AnimCustomFunction, args = {leaks, RestoreCyborg, {437, 1700, 519, 1722}}})
  table.insert(endAnim, {func = AnimTeleportGear, args = {leaks, 763, 1760}})
  table.insert(endAnim, {func = AnimTeleportGear, args = {dense, 835, 1519}})
  table.insert(endAnim, {func = AnimTurn, swh = false, args = {leaks, "Left"}})
  table.insert(endAnim, {func = AnimTurn, swh = false, args = {dense, "Left"}})
  table.insert(endAnim, {func = AnimTurn, swh = false, args = {cyborg, "Right"}})
  table.insert(endAnim, {func = AnimTurn, swh = false, args = {princess, "Right"}})
  table.insert(endAnim, {func = AnimSay, args = {princess, "Help me, please!", SAY_SHOUT, 3000}})
  table.insert(endAnim, {func = AnimSay, args = {leaks, "What are you doing? Let her go!", SAY_SHOUT, 5000}})
  table.insert(endAnim, {func = AnimSay, args = {cyborg, "Yeah? Watcha gonna do? Cry?", SAY_SHOUT, 5000}})
  table.insert(endAnim, {func = AnimSay, args = {leaks, "We won't let you hurt her!", SAY_SHOUT, 4000}})
  AddSkipFunction(endAnim, SkipEndAnimDuo, {})
  
  table.insert(endFailAnim, {func = AnimCaption, args = {leaks, "Leaks A Lot, depressed for killing his loved one, failed to save the village...", 3000}})

  table.insert(winAnim, {func = AnimSay, args = {princess, "Thank you, oh, thank you, my heroes!", SAY_SAY, 5000}})
  table.insert(winAnim, {func = AnimSay, args = {princess, "How can I ever repay you for saving my life?", SAY_SAY, 6000}})
  table.insert(winAnim, {func = AnimSay, args = {leaks, "There's nothing more satisfying to us than seeing you share your beauty with the world every morning, my princess!", SAY_SAY, 10000}})
  table.insert(winAnim, {func = AnimSay, args = {leaks, "Let's go home!", SAY_SAY, 3000}})
  table.insert(winAnim, {func = AnimCaption, args = {leaks, "And so they discovered that cyborgs weren't invulnerable...", 2000}})

  startAnim = startAnimRL
  pastFlowerAnim = pastFlowerAnimRL
  outPitAnim = outPitAnimRL
end

function KillPrincess()
  ParseCommand("teamgone Cannibal Sentry")
  TurnTimeLeft = 0
end
--/////////////////////////////Misc Functions////////////////////////

function CondNeedToTurn(hog1, hog2)
  xl, xd = GetX(hog1), GetX(hog2)
  if xl > xd then
    AnimInsertStepNext({func = AnimTurn, args = {hog1, "Left"}})
    AnimInsertStepNext({func = AnimTurn, args = {hog2, "Right"}})
  elseif xl < xd then
    AnimInsertStepNext({func = AnimTurn, args = {hog2, "Left"}})
    AnimInsertStepNext({func = AnimTurn, args = {hog1, "Right"}})
  end
end

function SetupPlaceAlone()
  ------ AMMO CRATE LIST ------
  --SpawnAmmoCrate(3122, 994, amShotgun)
  SpawnAmmoCrate(3124, 952, amBaseballBat)
  SpawnAmmoCrate(2508, 1110, amFirePunch)
  ------ UTILITY CRATE LIST ------
  blowCrate = SpawnUtilityCrate(3675, 1480, amBlowTorch)
  gravityCrate = SpawnUtilityCrate(3448, 1349, amLowGravity)
  SpawnUtilityCrate(3212, 1256, amGirder)
  SpawnUtilityCrate(3113, 911, amParachute)
  sniperCrate = SpawnAmmoCrate(784, 1715, amSniperRifle)
  ------ MINE LIST ------
  SetTimer(AddGear(3328, 1399, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(3028, 1262, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2994, 1274, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2956, 1277, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2925, 1282, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2838, 1276, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2822, 1278, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2786, 1283, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2766, 1270, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2749, 1231, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2717, 1354, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2167, 1330, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2201, 1321, gtMine, 0, 0, 0, 0), 3000)
  SetTimer(AddGear(2239, 1295, gtMine, 0, 0, 0, 0), 3000)

  SetGearPosition(leaks, 3781, 1583)
  --SetGearPosition(leaks, 1650, 1583)
  AddAmmo(cannibals[1], amShotgun, 100)
end

function SetupPlaceDuo()
  PlaceCratesDuo()
  SetGearPosition(leaks, unpack(startLeaksPosDuo))
  SetGearPosition(dense, unpack(startDensePosDuo))
end

function SetupEventsDuo()
  AddEvent(CheckPastFlower, {}, DoPastFlower, {}, 0)
  AddEvent(CheckLeaksDead, {}, DoLeaksDead, {}, 0)
  AddEvent(CheckDenseDead, {}, DoDenseDead, {}, 0)
  AddEvent(CheckTookSniper2, {}, DoTookSniper2, {}, 0)
end

function SetupEventsAlone()
  AddEvent(CheckLeaksDead, {}, DoLeaksDead, {}, 0)
  AddEvent(CheckTookBlowTorch, {}, DoTookBlowTorch, {}, 0)
  AddEvent(CheckTookLowGravity, {}, DoTookLowGravity, {}, 0)
  AddEvent(CheckOnBridge, {}, DoOnBridge, {}, 0)
end

function StartMission()
  m2Choice = 2
  m2DenseDead = 1

  HideHog(cyborg)
  HideHog(princess)
  cyborgHidden = true
  princessHidden = true
  for i = 5, 8 do
    HideHog(cannibals[i])
  end

  if m2DenseDead == 1 then
    DeleteGear(dense)
    if m2Choice == choiceAccepted then
      SetupAnimAcceptedDied()
    elseif m2Choice == choiceRefused then
      SetupAnimRefusedDied()
    else
      SetupAnimAttacked()
    end
    SetupPlaceAlone()
    SetupEventsAlone()
    AddAnim(startAnim)
    AddFunction({func = AfterStartAnim, args = {}})
  else
    if m2Choice == choiceAccepted then
      SetupAnimAcceptedLived()
    else
      SetupAnimRefusedLived()
    end
    SetupPlaceDuo()
    SetupEventsDuo()
    AddAnim(startAnim)
    AddFunction({func = AfterStartAnim, args = {}})
  end
end
  
function SetupCourse()

  ------ GIRDER LIST ------
  PlaceGirder(1091, 1150, 6)
  PlaceGirder(1091, 989, 6)
  PlaceGirder(1091, 829, 6)
  PlaceGirder(1091, 669, 6)
  PlaceGirder(1091, 668, 6)
  PlaceGirder(1091, 669, 6)
  PlaceGirder(1088, 667, 6)
  PlaceGirder(1091, 658, 6)
  PlaceGirder(1091, 646, 6)
  PlaceGirder(1091, 607, 6)
  PlaceGirder(1091, 571, 6)
  PlaceGirder(1376, 821, 6)
  PlaceGirder(1145, 1192, 1)
  PlaceGirder(1169, 1076, 3)
  PlaceGirder(1351, 1082, 4)
  PlaceGirder(1469, 987, 3)
  PlaceGirder(1386, 951, 0)
  PlaceGirder(1465, 852, 3)
  PlaceGirder(1630, 913, 0)
  PlaceGirder(1733, 856, 7)
  PlaceGirder(1688, 713, 5)
  PlaceGirder(1556, 696, 2)
  PlaceGirder(1525, 696, 2)
  PlaceGirder(1457, 697, 2)
  PlaceGirder(1413, 700, 3)
  PlaceGirder(1270, 783, 2)
  PlaceGirder(1207, 825, 2)
  PlaceGirder(1135, 775, 1)

  ------ UTILITY CRATE LIST ------
  SpawnUtilityCrate(1540, 628, amParachute)
  SpawnAmmoCrate(1540, 100, amDynamite)
  SpawnUtilityCrate(2175, 1815, amLowGravity)
  SpawnUtilityCrate(2210, 1499, amFirePunch)
  girderCrate = SpawnUtilityCrate(2300, 1663, amGirder)
  SpawnUtilityCrate(610, 1394, amPickHammer)
  
  ------ BARREL LIST ------
  SetHealth(AddGear(1148, 736, gtExplosives, 0, 0, 0, 0), 20)

end

function PlaceCourseMines()
  SetTimer(AddGear(1215, 1193, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1259, 1199, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1310, 1198, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1346, 1196, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1383, 1192, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1436, 1196, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1487, 1199, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1651, 1209, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1708, 1209, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1759, 1190, gtMine, 0, 0, 0, 0), 5000)
  SetTimer(AddGear(1815, 1184, gtMine, 0, 0, 0, 0), 5000)
end


--////////////////////////////Event Functions////////////////////////
function CheckTookFire()
  return fireTaken
end

function DoTookFire()
  AddAmmo(leaks, amFirePunch, 100)
end

function CheckTookGirder1()
  return girder1Taken
end

function CheckTookGirder2()
  return girder2Taken
end

function DoTookGirder1()
  AddAmmo(dense, amGirder, 2)
end

function DoTookGirder2()
  AddAmmo(dense, amGirder, 3)
end

function CheckDensePit()
  return GetY(dense) < 1250 and StoppedGear(dense)
end

function DoDensePit()
  AddAnim(outPitAnim)
  AddFunction({func = AfterOutPitAnim, args = {}})
end

function CheckPastFlower()
  if denseDead == true or leaksDead == true then
    return false
  end
  return (GetX(dense) < startEventXDuo and StoppedGear(dense))
      or (GetX(leaks) < startEventXDuo and StoppedGear(leaks))
end

function DoPastFlower()
  AddAnim(pastFlowerAnim)
  AddFunction({func = AfterPastFlowerAnim, args = {}})
end


function CheckLeaksDead()
  return leaksDead
end

function DoLeaksDead()
  AddCaption("The village, unprepared, was destroyed by the cyborgs...")
  ParseCommand("teamgone Natives")
end

function CheckDenseDead()
  return denseDead
end

function DoDenseDead()
  AddCaption("The village, unprepared, was destroyed by the cyborgs...")
  ParseCommand("teamgone Natives")
end

function CheckTookBlowTorch()
  return blowTaken
end

function DoTookBlowTorch()
  ShowMission("The Journey Back", "The Tunnel Maker", "Hint: Select the BlowTorch, aim and press [Fire]. Press [Fire] again to stop.|Don't blow up the crate.", 0, 6000)
end

function CheckTookLowGravity()
  return gravityTaken
end

function DoTookLowGravity()
  ShowMission("The Journey Back", "The Moonwalk", "Hint: Select the LowGravity and press [Fire].", 0, 6000)
end

function CheckOnBridge()
  return leaksDead == false and GetX(leaks) < 1651 and StoppedGear(leaks)
end

function DoOnBridge()
  AddAnim(midAnim)
  AddFunction({func = AfterMidAnimAlone, args = {}})
end

function CheckGirderTaken()
  return girderTaken
end

function DoGirderTaken()
  AddAmmo(leaks, amGirder, 2)
--  AddAmmo(leaks, amGirder, 3)
end

function CheckOnFirstGirder()
  return leaksDead == false and GetX(leaks) < 1160 and StoppedGear(leaks)
end

function DoOnFirstGirder()
  PlaceCourseMines()
  ShowMission("The Journey Back", "Slippery", "You'd better watch your steps...", 0, 4000)
end

function CheckTookSniper()
  return sniperTaken and StoppedGear(leaks)
end

function DoTookSniper()
  AddAnim(endAnim)
  AddFunction({func = AfterEndAnimAlone, args = {}})
end

function CheckTookSniper2()
  return sniperTaken and StoppedGear(leaks) and StoppedGear(dense)
end

function DoTookSniper2()
  AddAnim(endAnim)
  AddFunction({func = AfterEndAnimDuo, args = {}})
end

function CheckLost()
  return princessDead
end

function DoLost()
  AddAnim(endFailAnim)
  AddFunction({func = ParseCommand, args = {'teamgone Natives'}})
end

function CheckWon()
  return cyborgDead and not princessDead
end

function DoWon()
  SaveCampaignVar("Progress", "3")
  AddAnim(winAnim)
  AddFunction({func = FinishWon, args = {}})
end

function FinishWon()
  SwitchHog(leaks)
  ParseCommand("teamgone Cannibal Sentry")
  ParseCommand("teamgone 011101001")
  TurnTimeLeft = 0
end

function CheckFailedCourse()
  return TurnsLeft == 0
end

function DoFailedCourse()
  AddAnim(failAnim)
  AddFunction({func = AfterMidFailAnim, args = {}})
end

--////////////////////////////Main Functions/////////////////////////

function onGameInit()
	Seed = 0
  TemplateFilter = 3
	GameFlags = gfSolidLand + gfDisableWind
	TurnTime = 25000 
	CaseFreq = 0
	MinesNum = 0
	MinesTime = 3000
	Explosives = 0
	Delay = 5
	MapGen = 0
	Theme = "Nature"
  SuddenDeathTurns = 3000

	AddTeam("Natives", 2567585, "Bone", "Island", "HillBilly", "cm_birdy")
	leaks = AddHog("Leaks A Lot", 0, 100, "Rambo")
  dense = AddHog("Dense Cloud", 0, 100, "RobinHood")

  AddTeam("Cannibal Sentry", 14483456, "Skull", "Island", "Pirate","cm_vampire")
  cannibals = {}
  for i = 1, 4 do
    cannibals[i] = AddHog(cannibalNames[i], 3, 40, "Zombi")
    SetGearPosition(cannibals[i], unpack(cannibalPos[i]))
  end

  for i = 5, 8 do
    cannibals[i] = AddHog(cannibalNames[i], 3, 40, "Zombi")
    SetGearPosition(cannibals[i], 0, 0)
  end

  AddTeam("011101001", 14483456, "ring", "UFO", "Robot", "cm_star")
  cyborg = AddHog("Y3K1337", 0, 200, "cyborg1")
  princess = AddHog("Fell From Heaven", 0, 200, "tiara")

  SetGearPosition(dense, 0, 0)
  SetGearPosition(leaks, 0, 0)
  SetGearPosition(cyborg, 0, 0)
  SetGearPosition(princess, 0, 0)
  
  AnimInit()
end

function onGameStart()
  m2Choice = tonumber(GetCampaignVar("M2Choice"))
  m2DenseDead = tonumber(GetCampaignVar("M2DenseDead"))
  m2RamonDead = tonumber(GetCampaignVar("M2RamonDead"))
  m2SpikyDead = tonumber(GetCampaignVar("M2SpikyDead"))
  StartMission()
end

function onGameTick()
  AnimUnWait()
  if ShowAnimation() == false then
    return
  end
  ExecuteAfterAnimations()
  CheckEvents()
end

function onGearDelete(gear)
  if gear == blowCrate then
    blowTaken = true
  elseif gear == fireCrate then
    fireTaken = true
  elseif gear == gravityCrate then
    gravityTaken = true
  elseif gear == leaks then
    leaksDead = true
  elseif gear == dense then
    denseDead = true
  elseif gear == cyborg then
    cyborgDead = true
  elseif gear == princess then
    princessDead = true
  elseif gear == girderCrate then
    girderTaken = true
  elseif gear == girderCrate1 then
    girder1Taken = true
  elseif gear == girderCrate2 then
    girder2Taken = true
  elseif gear == sniperCrate then
    sniperTaken = true
  else
    for i = 1, 4 do
      if gear == cannibals[i] then
        cannibalDead[i] = true
      end
    end
  end
end

function onGearAdd(gear)
end

function onAmmoStoreInit()
  SetAmmo(amBlowTorch, 0, 0, 0, 1)
  SetAmmo(amParachute, 0, 0, 0, 1)
  SetAmmo(amGirder, 0, 0, 0, 3)
  SetAmmo(amLowGravity, 0, 0, 0, 1)
  SetAmmo(amBaseballBat, 0, 0, 0, 1)
  SetAmmo(amFirePunch, 0, 0, 0, 1)
  SetAmmo(amSkip, 9, 0, 0, 0)
  SetAmmo(amSwitch, 9, 0, 0, 0)
  SetAmmo(amDEagle, 9, 0, 0, 0)
  SetAmmo(amRope, 0, 0, 0, 1)
  SetAmmo(amSniperRifle, 0, 0, 0, 1)
  SetAmmo(amDynamite, 0, 0, 0, 1)
  SetAmmo(amPickHammer, 0, 0, 0, 1)
end

function onNewTurn()
  if AnimInProgress() then
    TurnTimeLeft = -1
  elseif stage == endStage and CurrentHedgehog ~= leaks then
    AnimSwitchHog(leaks)
    SetGearMessage(leaks, 0)
    TurnTimeLeft = -1
  elseif GetHogTeamName(CurrentHedgehog) ~= "Natives" then
    for i = 1, 4 do
      if cannibalDead[i] ~= true then
        if GetX(cannibals[i]) < GetX(leaks) then
          HogTurnLeft(cannibals[i], false)
        else
          HogTurnLeft(cannibals[i], true)
        end
      end
    end
    SetInputMask(band(0xFFFFFFFF, bnot(gmLeft + gmRight + gmLJump + gmHJump)))
  else
    SetInputMask(0xFFFFFFFF)
    TurnsLeft = TurnsLeft - 1
  end
end

function onGearDamage(gear, damage)
end

function onPrecise()
  if GameTime > 2500 then
    SetAnimSkip(true)
  end
end

