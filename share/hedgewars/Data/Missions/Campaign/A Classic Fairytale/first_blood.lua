loadfile(GetDataPath() .. "Scripts/Animate.lua")()

-----------------------------Variables---------------------------------
startDialogue = {}
damageAnim = {}
onShroomAnim = {}
onFlowerAnim = {}
tookParaAnim = {}
tookPunchAnim = {}
onMoleHeadAnim = {}
tookRope2Anim = {}
challengeAnim = {}
challengeFailedAnim = {}
challengeCompletedAnim = {}
beforeKillAnim = {}
closeCannim = {}
cannKilledAnim = {}
cannKilledEarlyAnim = {}
princessDamagedAnim = {}
elderDamagedAnim = {}
pastMoleHeadAnim = {}


targets = {}
crates = {}
targXdif2 = {2755, 2638, 2921, 2664, 2973, 3162, 3268, 3067, 3588, 3759, 3062, 1300}
targYdif2 = {1197, 1537, 1646, 1852, 1857, 1804, 1538, 1173, 984, 1290, 1167, 1183}
targXdif1 = {2749, 2909, 2770, 2892, 2836, 3296, 3567, 3066, 1558, 1305}
targYdif1 = {1179, 1313, 1734, 1603, 1441, 1522, 982, 1190, 1152, 1259}
targetPosX = {{821, 866, 789}, {614, 656, 638}, {1238, 1237, 1200}, {1558, 1596, 1631}, {2190, 2396, 2457}}
targetPosY = {{1342, 1347, 1326}, {1112, 1121, 1061}, {1152, 1111, 1111}, {1132, 1136, 1280}, {1291, 1379, 1317}}
crateNum = {10, 12}


stage = 1
cratesCollected = 0
chalTries = 0
targetsDestroyed = 0
targsWave = 1
tTime = -1
difficulty = 0

cannibalVisible = false
cannibalKilles = false
youngdamaged = false
youngKilled = false
elderDamaged = false
princessDamaged = false
elderKilled = false
princessKilled = false
rope1Taken = false
paraTaken = false
rope2Taken = false
punchTaken = false
canKilled = false
desertTaken = false
challengeFailed = false
difficultyChoice = false

goals = {
  [startDialogue] = {"First Blood", "First Steps", "Press [Left] or [Right] to move around, [Enter] to jump", 1, 4000},
  [onShroomAnim] = {"First Blood", "A leap in a leap", "Go on top of the flower", 1, 4000},
  [onFlowerAnim] = {"First Blood", "Hightime", "Collect the crate on the right.|Hint: Select the rope, [Up] or [Down] to aim, [Space] to fire, directional keys to move.|Ropes can be fired again in the air!", 1, 7000},
  [tookParaAnim] = {"First Blood", "Omnivore", "Get on the head of the mole", 1, 4000},
  [onMoleHeadAnim] = {"First Blood", "The Leap of Faith", "Use the parachute ([Space] while in air) to get the next crate", 1, 4000},
  [tookRope2Anim] = {"First Blood", "The Rising", "Do the deed", 1, 4000},
  [tookPunchAnim] = {"First Blood", "The Slaughter", "Destroy the targets!|Hint: Select the Shoryuken and hit [Space]|P.S. You can use it mid-air.", 1, 5000},
  [challengeAnim] = {"First Blood", "The Crate Frenzy", "Collect the crates within the time limit!|If you fail, you'll have to try again.", 1, 5000},
  [challengeFailedAnim] = {"First Blood", "The Crate Frenzy", "Collect the crates within the time limit!|If you fail, you'll have to try again.", 1, 5000},
  [challengeCompletedAnim] = {"First Blood", "The Ultimate Weapon", "Destroy the targets!|Hint: [Up], [Down] to aim, [Space] to shoot", 1, 5000},
  [beforeKillAnim] = {"First Blood", "The First Blood", "Kill the cannibal!", 1, 5000},
  [closeCannim] = {"First Blood", "The First Blood", "KILL IT!", 1, 5000}
}
-----------------------------Animations--------------------------------
function Skipanim(anim)
  AnimSwitchHog(youngh)
  if goals[anim] ~= nil then
    ShowMission(unpack(goals[anim]))
  end
end

function SkipDamageAnim(anim)
  SwitchHog(youngh)
  SetInputMask(0xFFFFFFFF)
end

function SkipOnShroom()
  Skipanim(onShroomAnim)
  SetGearPosition(elderh, 2700, 1278)
end

function AnimationSetup()
  AddSkipFunction(damageAnim, SkipDamageAnim, {damageAnim})
  table.insert(damageAnim, {func = AnimWait, args = {youngh, 500}, skipFunc = Skipanim, skipArgs = damageAnim})
  table.insert(damageAnim, {func = AnimSay, args = {elderh, "Watch your steps, young one!", SAY_SAY, 2000}})
  table.insert(damageAnim, {func = AnimGearWait, args = {youngh, 500}})

  AddSkipFunction(princessDamagedAnim, SkipDamageAnim, {princessDamagedAnim})
  table.insert(princessDamagedAnim, {func = AnimWait, args = {princess, 500}, skipFunc = Skipanim, skipArgs = princessDamagedAnim})
  table.insert(princessDamagedAnim, {func = AnimSay, args = {princess, "Why do men keep hurting me?", SAY_THINK, 3000}})
  table.insert(princessDamagedAnim, {func = AnimGearWait, args = {youngh, 500}})

  AddSkipFunction(elderDamagedAnim, SkipDamageAnim, {elderDamagedAnim})
  table.insert(elderDamagedAnim, {func = AnimWait, args = {elderh, 500}, skipFunc = Skipanim, skipArgs = elderDamagedAnim})
  table.insert(elderDamagedAnim, {func = AnimSay, args = {elderh, "Violence is not the answer to your problems!", SAY_SAY, 3000}})
  table.insert(elderDamagedAnim, {func = AnimGearWait, args = {youngh, 500}})
  
  AddSkipFunction(startDialogue, Skipanim, {startDialogue})
  table.insert(startDialogue, {func = AnimWait, args = {youngh, 3500}, skipFunc = Skipanim, skipArgs = startDialogue})
  table.insert(startDialogue, {func = AnimCaption, args = {youngh, "Once upon a time, on an island with great natural resources, lived two tribes in heated conflict...",  5000}})
  table.insert(startDialogue, {func = AnimCaption, args = {youngh, "One tribe was peaceful, spending their time hunting and training, enjoying the small pleasures of life...", 5000}})
  table.insert(startDialogue, {func = AnimCaption, args = {youngh, "The other one were all cannibals, spending their time eating the organs of fellow hedgehogs...", 5000}})
  table.insert(startDialogue, {func = AnimCaption, args = {youngh, "And so it began...", 1000}})
  table.insert(startDialogue, {func = AnimSay, args = {elderh, "What are you doing at a distance so great, young one?", SAY_SHOUT, 4000}})
  table.insert(startDialogue, {func = AnimSay, args = {elderh, "Come closer, so that your training may continue!", SAY_SHOUT, 6000}})
  table.insert(startDialogue, {func = AnimSay, args = {youngh, "This is it! It's time to make Fell From Heaven fall for me...", SAY_THINK, 6000}})
  table.insert(startDialogue, {func = AnimJump, args = {youngh, "long"}})
  table.insert(startDialogue, {func = AnimTurn, args = {princess, "Right"}})
  table.insert(startDialogue, {func = AnimSwitchHog, args = {youngh}})
  table.insert(startDialogue, {func = AnimShowMission, args = {youngh, "First Blood", "First Steps", "Press [Left] or [Right] to move around, [Enter] to jump", 1, 4000}}) 

  AddSkipFunction(onShroomAnim, SkipOnShroom, {onShroomAnim})
  table.insert(onShroomAnim, {func = AnimSay, args = {elderh, "I can see you have been training diligently.", SAY_SAY, 4000}, skipFunc = Skipanim, skipArgs = onShroomAnim})
  table.insert(onShroomAnim, {func = AnimSay, args = {elderh, "The wind whispers that you are ready to become familiar with tools, now...", SAY_SAY, 4000}})
  table.insert(onShroomAnim, {func = AnimSay, args = {elderh, "Open that crate and we will continue!", SAY_SAY, 5000}})
  table.insert(onShroomAnim, {func = AnimMove, args = {elderh, "right", 2700, 0}})
  table.insert(onShroomAnim, {func = AnimTurn, args = {elderh, "Left"}})
  table.insert(onShroomAnim, {func = AnimSay, args = {princess, "He moves like an eagle in the sky.", SAY_THINK, 4000}})
  table.insert(onShroomAnim, {func = AnimSwitchHog, args = {youngh}})
  table.insert(onShroomAnim, {func = AnimShowMission, args = {youngh, "First Blood", "A leap in a leap", "Go on top of the flower", 1, 4000}}) 

  AddSkipFunction(onFlowerAnim, Skipanim, {onFlowerAnim})
  table.insert(onFlowerAnim, {func = AnimTurn, args = {elderh, "Right"}, skipFunc = Skipanim, skipArgs = onFlowerAnim})
  table.insert(onFlowerAnim, {func = AnimSay, args = {elderh, "See that crate farther on the right?", SAY_SAY, 4000}})
  table.insert(onFlowerAnim, {func = AnimSay, args = {elderh, "Swing, Leaks A Lot, on the wings of the wind!", SAY_SAY, 6000}})
  table.insert(onFlowerAnim, {func = AnimSay, args = {princess, "His arms are so strong!", SAY_THINK, 4000}})
  table.insert(onFlowerAnim, {func = AnimSwitchHog, args = {youngh}})
  table.insert(onFlowerAnim, {func = AnimShowMission, args = {youngh, "First Blood", "Hightime", "Collect the crate on the right.|Hint: Select the rope, [Up] or [Down] to aim, [Space] to fire, directional keys to move.|Ropes can be fired again in the air!", 1, 7000}}) 
  
  AddSkipFunction(tookParaAnim, Skipanim, {tookParaAnim})
  table.insert(tookParaAnim, {func = AnimGearWait, args = {youngh, 1000}, skipFunc = Skipanim, skipArgs = tookParaAnim})
  table.insert(tookParaAnim, {func = AnimSay, args = {elderh, "Use the rope to get on the head of the mole, young one!", SAY_SHOUT, 4000}})
  table.insert(tookParaAnim, {func = AnimSay, args = {elderh, "Worry not, for it is a peaceful animal! There is no reason to be afraid...", SAY_SHOUT, 5000}})
  table.insert(tookParaAnim, {func = AnimSay, args = {elderh, "We all know what happens when you get frightened...", SAY_SAY, 4000}})
  table.insert(tookParaAnim, {func = AnimSay, args = {youngh, "So humiliating...", SAY_SAY, 4000}})
  table.insert(tookParaAnim, {func = AnimShowMission, args = {youngh, "First Blood", "Omnivore", "Get on the head of the mole", 1, 4000}}) 
  table.insert(tookParaAnim, {func = AnimSwitchHog, args = {youngh}})

  AddSkipFunction(onMoleHeadAnim, Skipanim, {onMoleHeadAnim})
  table.insert(onMoleHeadAnim, {func = AnimSay, args = {elderh, "Perfect! Now try to get the next crate without hurting yourself!", SAY_SAY, 4000}, skipFunc = Skipanim, skipArgs = onMoleHeadAnim})
  table.insert(onMoleHeadAnim, {func = AnimSay, args = {elderh, "The giant umbrella from the last crate should help break the fall.", SAY_SAY, 4000}})
  table.insert(onMoleHeadAnim, {func = AnimSay, args = {princess, "He's so brave...", SAY_THINK, 4000}})
  table.insert(onMoleHeadAnim, {func = AnimShowMission, args = {youngh, "First Blood", "The Leap of Faith", "Use the parachute ([Space] while in air) to get the next crate", 1, 4000}}) 
  table.insert(onMoleHeadAnim, {func = AnimSwitchHog, args = {youngh}})

  AddSkipFunction(pastMoleHeadAnim, Skipanim, {pastMoleHeadAnim})
  table.insert(pastMoleHeadAnim, {func = AnimSay, args = {elderh, "I see you have already taken the leap of faith.", SAY_SAY, 4000}, skipFunc = Skipanim, skipArgs = pastMoleHeadAnim})
  table.insert(pastMoleHeadAnim, {func = AnimSay, args = {elderh, "Get that crate!", SAY_SAY, 4000}})
  table.insert(pastMoleHeadAnim, {func = AnimSwitchHog, args = {youngh}})

  AddSkipFunction(tookRope2Anim, Skipanim, {tookRope2Anim})
  table.insert(tookRope2Anim, {func = AnimSay, args = {elderh, "Impressive...you are still dry as the corpse of a hawk after a week in the desert...", SAY_SAY, 5000}, skipFunc = Skipanim, skipArgs = tookRope2Anim})
  table.insert(tookRope2Anim, {func = AnimSay, args = {elderh, "You probably know what to do next...", SAY_SAY, 4000}})
  table.insert(tookRope2Anim, {func = AnimShowMission, args = {youngh, "First Blood", "The Rising", "Do the deed", 1, 4000}}) 
  table.insert(tookRope2Anim, {func = AnimSwitchHog, args = {youngh}})

  AddSkipFunction(tookPunchAnim, Skipanim, {tookPunchAnim})
  table.insert(tookPunchAnim, {func = AnimTurn, args = {elderh, "Left"}, skipFunc = Skipanim, skipArgs = tookPunchAnim})
  table.insert(tookPunchAnim, {func = AnimSay, args = {elderh, "It is time to practice your fighting skills.", SAY_SAY, 4000}})
  table.insert(tookPunchAnim, {func = AnimSay, args = {elderh, "Imagine those targets are the wolves that killed your parents! Take your anger out on them!", SAY_SAY, 5000}})
  table.insert(tookPunchAnim, {func = AnimShowMission, args = {youngh, "First Blood", "The Slaughter", "Destroy the targets!|Hint: Select the Shoryuken and hit [Space]|P.S. You can use it mid-air.", 1, 5000}}) 
  table.insert(tookPunchAnim, {func = AnimSwitchHog, args = {youngh}})

  AddSkipFunction(challengeAnim, Skipanim, {challengeAnim})
  table.insert(challengeAnim, {func = AnimSay, args = {elderh, "I hope you are prepared for a small challenge, young one.", SAY_SAY, 4000}, skipFunc = Skipanim, skipArgs = challengeAnim})
  table.insert(challengeAnim, {func = AnimSay, args = {elderh, "Your movement skills will be evaluated now.", SAY_SAY, 4000}})
  table.insert(challengeAnim, {func = AnimSay, args = {elderh, "Collect all the crates, but remember, our time in this life is limited!", SAY_SAY, 4000}})
  table.insert(challengeAnim, {func = AnimSay, args = {elderh, "How difficult would you like it to be?"}})
  table.insert(challengeAnim, {func = AnimSwitchHog, args = {youngh}})
  table.insert(challengeAnim, {func = AnimWait, args = {youngh, 500}})

  AddSkipFunction(challengeFailedAnim, Skipanim, {challengeFailedAnim})
  table.insert(challengeFailedAnim, {func = AnimSay, args = {elderh, "Hmmm...perhaps a little more time will help.", SAY_SAY, 4000}, skipFunc = Skipanim, skipArgs = challengeFailedAnim})
  table.insert(challengeFailedAnim, {func = AnimShowMission, args = {youngh, "First Blood", "The Crate Frenzy", "Collect the crates within the time limit!|If you fail, you'll have to try again.", 1, 5000}}) 
  table.insert(challengeFailedAnim, {func = AnimSwitchHog, args = {youngh}})

  AddSkipFunction(challengeCompletedAnim, Skipanim, {challengeCompletedAnim})
  table.insert(challengeCompletedAnim, {func = AnimSay, args = {elderh, "The spirits of the ancerstors are surely pleased, Leaks A Lot.", SAY_SAY, 4000}, skipFunc = Skipanim, skipArgs = challengeCompletedAnim})
  table.insert(challengeCompletedAnim, {func = AnimSay, args = {elderh, "You have proven yourself worthy to see our most ancient secret!", SAY_SAY, 4000}})
  table.insert(challengeCompletedAnim, {func = AnimSay, args = {elderh, "The weapon in that last crate was bestowed upon us by the ancients!", SAY_SAY, 4000}})
  table.insert(challengeCompletedAnim, {func = AnimSay, args = {elderh, "Use it with precaution!", SAY_SAY, 4000}})
  table.insert(challengeCompletedAnim, {func = AnimShowMission, args = {youngh, "First Blood", "The Ultimate Weapon", "Destroy the targets!|Hint: [Up], [Down] to aim, [Space] to shoot", 1, 5000}}) 
  table.insert(challengeCompletedAnim, {func = AnimSwitchHog, args = {youngh}})

  AddSkipFunction(beforeKillAnim, Skipanim, {beforeKillAnim})
  table.insert(beforeKillAnim, {func = AnimSay, args = {elderh, "What do my faulty eyes observe? A spy!", SAY_SHOUT, 4000}, skipFunc = Skipanim, skipArgs = beforeKillAnim})
  table.insert(beforeKillAnim, {func = AnimFollowGear, args = {cannibal}})
  table.insert(beforeKillAnim, {func = AnimWait, args = {cannibal, 1000}})
  table.insert(beforeKillAnim, {func = AnimSay, args = {elderh, "Destroy him, Leaks A Lot! He is responsible for the deaths of many of us!", SAY_SHOUT, 4000}})
  table.insert(beforeKillAnim, {func = AnimSay, args = {cannibal, "Oh, my!", SAY_THINK, 4000}})
  table.insert(beforeKillAnim, {func = AnimShowMission, args = {youngh, "First Blood", "The First Blood", "Kill the cannibal!", 1, 5000}}) 
  table.insert(beforeKillAnim, {func = AnimSwitchHog, args = {youngh}})
  
  AddSkipFunction(closeCannim, Skipanim, {closeCannim})
  table.insert(closeCannim, {func = AnimSay, args = {elderh, "I see you would like his punishment to be more...personal...", SAY_SAY, 4000}, skipFunc = Skipanim, skipArgs = closeCannim})
  table.insert(closeCannim, {func = AnimSay, args = {cannibal, "I'm certain that this is a misunderstanding, fellow hedgehogs!", SAY_SAY, 4000}})
  table.insert(closeCannim, {func = AnimSay, args = {cannibal, "If only I were given a chance to explain my being here...", SAY_SAY, 4000}})
  table.insert(closeCannim, {func = AnimSay, args = {elderh, "Do not let his words fool you, young one! He will stab you in the back as soon as you turn away!", SAY_SAY, 6000}})
  table.insert(closeCannim, {func = AnimSay, args = {elderh, "Here...pick your weapon!", SAY_SAY, 5000}})
  table.insert(closeCannim, {func = AnimShowMission, args = {youngh, "First Blood", "The First Blood", "KILL IT!", 1, 5000}}) 
  table.insert(closeCannim, {func = AnimSwitchHog, args = {youngh}})

  table.insert(cannKilledAnim, {func = AnimSay, args = {elderh, "Yes, yeees! You are now ready to enter the real world!", SAY_SHOUT, 6000}})

  table.insert(cannKilledEarlyAnim, {func = AnimSay, args = {elderh, "What?! A cannibal? Here? There is no time to waste! Come, you are prepared.", SAY_SHOUT, 4000}})
end
-----------------------------Events------------------------------------

function CheckDamage()
  return youngdamaged and StoppedGear(youngh) 
end

function DoOnDamage()
  AddAnim(damageAnim)
  youngdamaged = false
  AddFunction({func = ResetTurnTime, args = {}})
end

function CheckDeath()
  return youngKilled
end

function DoDeath()
  RemoveEventFunc(CheckKilledOthers)
  RemoveEventFunc(CheckDamage)
  RemoveEventFunc(CheckDamagedOthers)
  FinishThem()
  ShowMission("First Blood", "The wasted youth", "Leaks A Lot gave his life for his tribe! He should have survived!", 2, 4000)
end

function CheckDamagedOthers()
  return (princessDamaged and StoppedGear(princess)) or (elderDamaged and StoppedGear(elderh))
end

function CheckKilledOthers()
  return princessKilled or elderKilled
end

function DoOnDamagedOthers()
  if princessDamaged then
    AddAnim(princessDamagedAnim)
  end
  if elderDamaged then
    AddAnim(elderDamagedAnim)
  end
  elderDamaged = false
  princessDamaged = false
  AddFunction({func = ResetTurnTime, args = {}})
end

function DoKilledOthers()
  AddCaption("After Leaks A Lot betrayed his tribe, he joined the cannibals...")
  FinishThem()
end

function CheckMovedUntilJump()
   return GetX(youngh) >= 2343
end

function DoMovedUntilJump()
  ShowMission("First Blood", "Step By Step", "Hint: Double Jump - Press [Backspace] twice", -amSkip, 0)
  AddEvent(CheckOnShroom, {}, DoOnShroom, {}, 0)
end

function CheckOnShroom()
  return GetX(youngh) >= 2461
end

function DoOnShroom()
  ropeCrate1 = SpawnUtilityCrate(2751, 1194, amRope)
  AddAnim(onShroomAnim)
  AddEvent(CheckOnFlower, {}, DoOnFlower, {}, 0)
end

function CheckOnFlower()
  return rope1Taken
end

function DoOnFlower()
  AddAmmo(youngh, amRope, 100)
  paraCrate = SpawnUtilityCrate(3245, 1758, amParachute)
  AddAnim(onFlowerAnim)
  AddEvent(CheckTookParaCrate, {}, DoTookParaCrate, {}, 0)
end

function CheckTookParaCrate()
  return paraTaken and StoppedGear(youngh)
end

function DoTookParaCrate()
  AddAmmo(youngh, amParachute, 100)
  AddAnim(tookParaAnim)
  AddEvent(CheckOnMoleHead, {}, DoOnMoleHead, {}, 0)
  AddEvent(CheckPastMoleHead, {}, DoPastMoleHead, {}, 0)
end

function CheckOnMoleHead()
  x = GetX(youngh)
  return x >= 3005 and x <= 3126 and StoppedGear(youngh)
end

function CheckPastMoleHead()
  x = GetX(youngh)
  y = GetY(youngh)
  return x < 3005 and y > StoppedGear(youngh) 
end

function DoPastMoleHead()
  RemoveEventFunc(CheckOnMoleHead)
  ropeCrate2 = SpawnUtilityCrate(2782, 1720, amRope)
  AddAmmo(youngh, amRope, 0)
  AddAnim(pastMoleHeadAnim)
  AddEvent(CheckTookRope2, {}, DoTookRope2, {}, 0)
end

function DoOnMoleHead()
  RemoveEventFunc(CheckPastMoleHead)
  ropeCrate2 = SpawnUtilityCrate(2782, 1720, amRope)
  AddAmmo(youngh, amRope, 0)
  AddAnim(onMoleHeadAnim)
  AddEvent(CheckTookRope2, {}, DoTookRope2, {}, 0)
end

function CheckTookRope2()
  return rope2Taken and StoppedGear(youngh)
end

function DoTookRope2()
  AddAmmo(youngh, amRope, 100)
  AddAnim(tookRope2Anim)
  punchCrate = SpawnAmmoCrate(2460, 1321, amFirePunch)
  AddEvent(CheckTookPunch, {}, DoTookPunch, {})
end

function CheckTookPunch()
  return punchTaken and StoppedGear(youngh)
end

function DoTookPunch()
  AddAmmo(youngh, amFirePunch, 100)
  AddAmmo(youngh, amRope, 0)
  AddAnim(tookPunchAnim)
  targets[1] = AddGear(1594, 1185, gtTarget, 0, 0, 0, 0)
  targets[2] = AddGear(2188, 1314, gtTarget, 0, 0, 0, 0)
  targets[3] = AddGear(1961, 1318, gtTarget, 0, 0, 0, 0)
  targets[4] = AddGear(1961, 1200, gtTarget, 0, 0, 0, 0)
  targets[5] = AddGear(1961, 1100, gtTarget, 0, 0, 0, 0)
  AddEvent(CheckTargDestroyed, {}, DoTargDestroyed, {}, 0)
end

function CheckTargDestroyed()
  return targetsDestroyed == 5 and StoppedGear(youngh)
end

function DoTargDestroyed()
  AddAnim(challengeAnim)
  targetsDestroyed = 0
  AddFunction({func = SetChoice, args = {}})
  ropeCrate3 = SpawnAmmoCrate(2000, 1200, amRope)
  AddEvent(CheckTookRope3, {}, AddAmmo, {youngh, amRope, 100}, 0)
  AddEvent(CheckCratesColled, {}, DoCratesColled, {}, 0)
  AddEvent(CheckChallengeWon, {}, DoChallengeWon, {}, 0)
  AddEvent(CheckTimesUp, {}, DoTimesUp, {}, 1)
end

function CheckChoice()
  return difficulty ~= 0
end

function DoChoice()
  difficultyChoice = false
  SetInputMask(0xFFFFFFFF)
  StartChallenge(120000 + chalTries * 20000)
end

function CheckCratesColled()
  return cratesCollected == crateNum[difficulty]
end

function DoCratesColled()
  RemoveEventFunc(CheckTimesUp)
  TurnTimeLeft = -1
  AddCaption("As the challenge was completed, Leaks A Lot set foot on the ground...")
end

function CheckChallengeWon()
  return cratesCollected == crateNum[difficulty] and StoppedGear(youngh)
end

function DoChallengeWon()
  desertCrate = SpawnAmmoCrate(1240, 1212, amDEagle)
  AddAnim(challengeCompletedAnim)
  AddEvent(CheckDesertColled, {}, DoDesertColled, {}, 0)
end

function CheckTookRope3()
  return rope3Taken
end

function CheckTimesUp()
  return TurnTimeLeft == 100
end

function DoTimesUp()
  challengeFailed = true
  DeleteGear(crates[1])
  TurnTimeLeft = -1
  AddCaption("And so happenned that Leaks A Lot failed to complete the challenge! He landed, pressured by shame...")
  AddEvent(CheckChallengeFailed, {}, DoChallengeFailed, {}, 0)
end

function CheckChallengeFailed()
  return challengeFailed and StoppedGear(youngh)
end

function DoChallengeFailed()
  challengeFailed = false
  AddAnim(challengeFailedAnim)
  chalTries = chalTries + 1
  difficulty = 0
  AddFunction({func = SetChoice, args = {}})
end

function CheckDesertColled()
  return desertTaken and StoppedGear(youngh)
end

function DoDesertColled()
  AddAmmo(youngh, amDEagle, 100)
  PutTargets(1)
  AddEvent(CheckTargetsKilled, {}, DoTargetsKilled, {}, 1)
  AddEvent(CheckCannibalKilled, {}, DoCannibalKilledEarly, {}, 0)
  ShowMission("First Blood", "The Bull's Eye", "[Up], [Down] to aim, [Space] to shoot!", 1, 5000)
end

function CheckTargetsKilled()
  return targetsDestroyed == 3 and StoppedGear(youngh)
end

function DoTargetsKilled()
  targetsDestroyed = 0
  targsWave = targsWave + 1
  if targsWave > 5 then
    RemoveEventFunc(CheckTargetsKilled)
    SetState(cannibal, gstVisible)
    cannibalVisible = true
    AddAnim(beforeKillAnim)
    AddEvent(CheckCloseToCannibal, {}, DoCloseToCannibal, {}, 0)
    AddEvent(CheckCannibalKilled, {}, DoCannibalKilled, {}, 0)
  else
    PutTargets(targsWave)
  end
end

function CheckCloseToCannibal()
  if CheckCannibalKilled() then
    return false
  end
  return math.abs(GetX(cannibal) - GetX(youngh)) <= 400 and StoppedGear(youngh)
end

function DoCloseToCannibal()
  AddAnim(closeCannim)
  AddFunction({func = SpawnAmmoCrate, args = {targetPosX[1][1], targetPosY[1][1], amWhip}})
  AddFunction({func = SpawnAmmoCrate, args = {targetPosX[1][2], targetPosY[1][2], amBaseballBat}})
  AddFunction({func = SpawnAmmoCrate, args = {targetPosX[1][3], targetPosY[1][3], amHammer}})
end

function CheckCannibalKilled()
  return cannibalKilled and StoppedGear(youngh)
end

function DoCannibalKilled()
  AddAnim(cannKilledAnim)
  SaveCampaignVar("Progress", "1")
end

function DoCannibalKilledEarly()
  AddAnim(cannKilledEarlyAnim)
  DoCannibalKilled()
end

-----------------------------Misc--------------------------------------
function StartChallenge(time)
  cratesCollected = 0
  PutCrate(1)
  TurnTimeLeft = time
  ShowMission("First Blood", "The Crate Frenzy", "Collect the crates within the time limit!|If you fail, you'll have to try again.", 1, 5000) 
end

function SetChoice()
  SetInputMask(band(0xFFFFFFFF, bnot(gmAnimate+gmAttack+gmDown+gmHJump+gmLJump+gmSlot+gmSwitch+gmTimer+gmUp+gmWeapon)))
  difficultyChoice = true
  ShowMission("First Blood", "The Torment", "Select difficulty: [Left] - easier or [Right] - harder", 0, 4000)
  AddEvent(CheckChoice, {}, DoChoice, {}, 0) 
end

function SetTime(time)
  TurnTimeLeft = time
end

function ResetTurnTime()
  TurnTimeLeft = tTime
  tTime = -1
end

function PutCrate(i)
  if i > crateNum[difficulty] then
    return
  end
  if difficulty == 1 then
    crates[1] = SpawnAmmoCrate(targXdif1[i], targYdif1[i], amRope)
  else
    crates[1] = SpawnAmmoCrate(targXdif2[i], targYdif2[i], amRope)
  end
end

function PutTargets(i)
  targets[1] = AddGear(targetPosX[i][1], targetPosY[i][1], gtTarget, 0, 0, 0, 0)
  targets[2] = AddGear(targetPosX[i][2], targetPosY[i][2], gtTarget, 0, 0, 0, 0)
  targets[3] = AddGear(targetPosX[i][3], targetPosY[i][3], gtTarget, 0, 0, 0, 0)
end

function FinishThem()
  SetHealth(elderh, 0)
  SetHealth(youngh, 0)
  SetHealth(princess, 0)
end
-----------------------------Main Functions----------------------------

function onGameInit()
	Seed = 69 
	GameFlags = gfInfAttack + gfSolidLand + gfDisableWind 
	TurnTime = 100000 
	CaseFreq = 0
	MinesNum = 0
	MinesTime = 3000
	Explosives = 0
	Delay = 10 
	MapGen = 0
	Theme = "Nature"


	AddTeam("Natives", 1117585, "Bone", "Island", "HillBilly", "cm_birdy")
	youngh = AddHog("Leaks A Lot", 0, 100, "Rambo")
  elderh = AddHog("White Raven", 0, 99, "IndianChief")
  princess = AddHog("Fell From Heaven", 0, 300, "tiara")
  SetGearPosition(princess, 1911, 1361)
  HogTurnLeft(princess, true)
  SetGearPosition(elderh, 2667, 1208)
  HogTurnLeft(elderh, true)
  SetGearPosition(youngh, 1862, 1362)
  HogTurnLeft(youngh, false)

  AddTeam("Cannibals", 14483456, "Skull", "Island", "Pirate","cm_vampire")
  cannibal = AddHog("Brainiac", 0, 5, "Zombi")
  SetGearPosition(cannibal, 525, 1256)
  HogTurnLeft(cannibal, false)
  
  AnimInit()
  AnimationSetup()
end

function onGameStart()
  TurnTimeLeft = -1
  FollowGear(youngh)
	ShowMission("A Classic Fairytale", "First Blood", "Finish your training|Hint: Animations can be skipped with the [Precise] key.", -amSkip, 0)
  SetState(cannibal, gstInvisible)

  AddAnim(startDialogue)
  AddEvent(CheckDamage, {}, DoOnDamage, {}, 1)
  AddEvent(CheckDeath, {}, DoDeath, {}, 0)
  AddEvent(CheckDamagedOthers, {}, DoOnDamagedOthers, {}, 1)
  AddEvent(CheckKilledOthers, {}, DoKilledOthers, {}, 0)
  AddEvent(CheckMovedUntilJump, {}, DoMovedUntilJump, {}, 0)
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
  if gear == ropeCrate1 then
    rope1Taken = true
  elseif gear == paraCrate then
    paraTaken = true
  elseif gear == ropeCrate2 then
    rope2Taken = true
  elseif gear == ropeCrate3 then
    rope3Taken = true
  elseif gear == crates[1] and challengeFailed == false then
    crates[1] = nil
    cratesCollected = cratesCollected + 1
    PutCrate(cratesCollected + 1)
  elseif gear == punchCrate then
    punchTaken = true
  elseif gear == desertCrate then
    desertTaken = true
  elseif GetGearType(gear) == gtTarget then
    i = 1
    while targets[i] ~= gear do
      i = i + 1
    end
    targets[i] = nil
    targetsDestroyed = targetsDestroyed + 1 
  elseif gear == cannibal then
    cannibalKilled = true
  elseif gear == princess then
    princessKilled = true
  elseif gear == elderh then
    elderKilled = true
  elseif gear == youngh then
    youngKilled = true
  end
end

function onGearAdd(gear)
end

function onAmmoStoreInit()
  SetAmmo(amWhip, 0, 0, 0, 8)
  SetAmmo(amBaseballBat, 0, 0, 0, 8)
  SetAmmo(amHammer, 0, 0, 0, 8)
end

function onNewTurn()
  if CurrentHedgehog == cannibal and cannibalVisible == false then
    SetState(cannibal, gstInvisible)
  end
  SwitchHog(youngh)
  FollowGear(youngh)
  TurnTimeLeft = -1
end

function onGearDamage(gear, damage)
  if gear == youngh then
    youngdamaged = true
    tTime = TurnTimeLeft
  elseif gear == princess then
    princessDamaged = true
    tTime = TurnTimeLeft
  elseif gear == elderh then
    elderDamaged = true
    tTime = TurnTimeLeft
  elseif gear == cannibal then
    cannibalVisible = true
    cannibalDamaged = true
    SetState(cannibal, 0)
  end
end

function onPrecise()
  if GameTime > 2000 then
    SetAnimSkip(true)
  end
end

function onLeft()
  if difficultyChoice == true then
    difficulty = 1
  end
end

function onRight()
  if difficultyChoice == true then
    difficulty = 2
  end
end

