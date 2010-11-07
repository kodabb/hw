-- IMPORTANT -- THIS IS WORK IN PROGRESS AND VERY LIKELY TO BE CHANGED AGAIN
-- IMPORTANT -- SAVE YOURSELF THE WORK AND DON'T TRANSLATE THE TEXTS IF YOU FEAR STARTING OVER LATER!

local teamnames = {}
local hognames = {}
teamnames[0] = {
	["en"] = "Bloody Rookies",
	["de"] = "Blutige Anfänger",
	["pl"] = "Żótodzioby",
	["sv"] = "Blodiga nybörjare",
	["es"] = "Reclutas"
}

teamnames[1] = {
	["en"] = "Instructors",
	["de"] = "Ausbilder",
	["pl"] = "Instruktor",
	["sv"] = "Instruktör",
	["es"] = "Instructores"
}

hognames[0] = {
	["en"] = "Joker",
	["de"] = "Joker",
	["pl"] = "Joker",
	["sv"] = "Joker",
	["es"] = "Joker"
}

hognames[1] = {
	["en"] = "Harthog",
	["de"] = "Harthog",
	["pl"] = "Harthog",
	["sv"] = "Harthog",
	["es"] = "Harthog"
}

local caption = {
	["en"] = "Boot Camp",
	["de"] = "Grundausbildung",
	["pl"] = "Poligon",
	["sv"] = "Grundutbildning",
	["es"] = "Campamento militar"
}

local subcaption = {
	["en"] = "Follow the instructions!",
	["de"] = "Befolge die Anweisungen!",
	["pl"] = "Wykonuj polecenia!",
	["sv"] = "Följ instruktioner!",
	["es"] = "¡Sigue las órdenes!"
}

local goals = {}

goals[0] = {
	["en"] = "Listen to your Drill Instructor and follow his lead!",
	["de"] = "Höre deinem Ausbilder zu und befolge seine Anweisungen!",
	["pl"] = "Słuchaj instruktora i wykonuj jego rozkazy!",
	["sv"] = "Lyssna på din instruktör och gör som han säger!",
	["es"] = "¡Escucha atentamente a tu instructor de maniobras y sigue sus órdenes!"
}

goals[1] = {
	["en"] = "Destroy the target to finish this mission!",
	["de"] = "Zerstöre das Ziel, um diese Mission abzuschließen!",
	["pl"] = "Zniszcz cel by ukończyć misję!",
	["sv"] = "Förstör målet för att avklara uppdraget!",
	["es"] = "¡Destruye el objetivo para completar esta misión!"
}

goals[2] = {
	["en"] = "Excellent! You've passed the Boot Camp!",
	["de"] = "Ausgezeichnet! Du hast das Ausbildungslager bestanden!",
	["pl"] = "Doskonale! Wyszedłeś cało z poligonu!",
	["sv"] = "Brilliant! Du har klarat av grundutbildningen!",
	["es"] = "¡Excelente! ¡Has completado la maniobra de hoy!"
}

local failed = {
	["en"] = "You failed! Follow the instructions and shoot the target only!",
	["de"] = "Du hast versagt! Befolge die Anweisungen und schieß nur auf das Ziel!",
	["pl"] = "Przegrałeś! Wykonuj instrukcje poprawnie i strzelaj tylko w podane cele!",
	["sv"] = "Du har misslyckats! Följ instruktionerna och sjut endast på målen!",
	["es"] = "¡Has fallado! ¡Sigue las instrucciones y destruye únicamente el objetivo!"
}

local drill = {}

drill[0] = {
	["en"] = "Allright, maggot!",
	["de"] = "Also gut, du Made!",
	["pl"] = "Słuchaj mnie gnido!",
	["sv"] = "Dåså, din mask!",
	["es"] = "¡Muy bien, escoria!"
}

drill[1] = {
	["en"] = "Show that you aren't that useless.",
	["de"] = "Zeig, dass du nicht so nutzlos bist.",
	["pl"] = "Udowodnij, że nie jesteś bezwartościowy.",
	["sv"] = "Visa att du inte är så värdelös!",
	["es"] = "Demuéstrame que no eres tan inútil como pareces."
}

drill[2] = {
	["en"] = "Use [left] to move to the left!",
	["de"] = "Benutze [Links], um nach links zu gehen!",
	["pl"] = "Użyj [lewo] by poruszyć się w lewą stronę!",
	["sv"] = "Använd [vänster] för att gå åt vänster!",
	["es"] = "¡Aprieta [izquierda] para desplazarte a la izquierda!"
}

drill[3] = {
	["en"] = "Good! Now use [right] to come back!",
	["de"] = "Gut! Nun komm mit [Rechts] zurück!",
	["pl"] = "Dobzre, Teraz użyj [prawo] by wrócić!",
	["sv"] = "Bra! Använd nu [höger] för att gå tillbaka!",
	["es"] = "¡Muy bien! ¡Ahora presiona [derecha] para volver!"
}

drill[4] = {
	["en"] = "Excellent!",
	["de"] = "Ausgezeichnet!",
	["pl"] = "Wspaniale!",
	["sv"] = "Utmärkt!",
	["es"] = "¡Excelente!"
}

drill[5] = {
	["en"] = "Now jump to the left using [return]!",
	["de"] = "Jetzt springe mit [Eingabetaste] nach links!",
	["pl"] = "Teraz skocz w lewo używając [Enter]",
	["sv"] = "Hoppa nu åt vänster med hjälp av [enter]!",
	["es"] = "¡Ahora salta hacia la izquierda usando [intro]!"
}

drill[6] = {
	["en"] = "Use [up] and [down] to aim.",
	["de"] = "Benutze [Hoch] und [Runter], um zu zielen.",
	["pl"] = "Użyj klawiszy [góra] i [dół] by celować.",
	["sv"] = "Använd [upp] och [ner] för att sikta!",
	["es"] = "Presiora [arriba] y [abajo] para apuntar."
}

drill[7] = {
	["en"] = "Hold [space] to power up your shot and then release it to shoot.",
	["de"] = "Halte [Leertaste], um deinen Schuss aufzuladen, und lasse dann rechtzeitig los.",
	["pl"] = "Przytrzymaj spację by zwiększyć siłę strzału.",
	["sv"] = "Håll ner [mellanslag] för att få kraft och släpp för att skjuta!",
	["es"] = "Mantén presionada la [barra espaciadora] para controlar la fuerza del disparo y suéltala para disparar."
}

drill[8] = {
	["en"] = "Destroy the target to finish your basic training!",
	["de"] = "Zerstöre das Ziel, um deine Grundausbildung abzuschließen!",
	["pl"] = "Zniszcz cel by by ukończyć trening podstawowy!",
	["sv"] = "Förstör målet för att avsluta din grundutbildning!",
	["es"] = "¡Destruye el objetivo para completar el entrenamiento básico!"
}

local function loc(text)
	if text == nil then return "**missing**"
	elseif text[L] == nil then return text["en"]
	else return text[L]
	end
end

local player = nil
local instructor = nil
local target = nil

function onGameStart()

end

local player_start_x = 2300
local player_start_y = 1250
local target_x = 1900
local target_y = 1250
local player_health = 100
local instructor_health = 100
local teamcolor = 14483456

local progress = 0
local time_start = 0

function onGameTick()
	if progress == -1 and (time_start + 2500) == GameTime then
		EndGame()
	elseif progress == -1 then
		
	elseif progress > 0 and ((TurnTimeLeft == 0) or (GetHealth(player) ~= player_health) or (GetHealth(instructor) ~= instructor_health)) then
		progress = -1
		ShowMission(loc(caption), loc(subcaption), loc(failed), -amBazooka, 0);
		time_start = GameTime
		PlaySound(sndNooo)
		TurnTimeLeft = 0
	elseif GameTime == 0 then
		ShowMission(loc(caption), loc(subcaption), loc(goals[0]), -amBazooka, 0);
		TurnTimeLeft = 60000
	elseif GameTime == 2500 then
		FollowGear(instructor)
		HogSay(instructor, loc(drill[0]), SAY_SAY)
	elseif GameTime == 5000 then
		FollowGear(instructor)
		HogSay(instructor, loc(drill[1]), SAY_SAY)
	elseif GameTime == 7500 then
		FollowGear(instructor)
		HogSay(instructor, loc(drill[2]), SAY_SHOUT)
		progress = 1
		TurnTimeLeft = 10000
	elseif progress == 1 then
		local x, y = GetGearPosition(player);
		if x < player_start_x - 50 then
			progress = 2
			FollowGear(instructor)
			HogSay(instructor, loc(drill[3]), SAY_SHOUT)
			TurnTimeLeft = 10000
		end
	elseif progress == 2 then
		local x, y = GetGearPosition(player);
		if x > player_start_x then
			progress = 3
			FollowGear(instructor)
			HogSay(instructor, loc(drill[4]), SAY_SAY)
			time_start = GameTime
		end
	elseif progress == 3 and (time_start + 2500 == GameTime) then
		progress = 4
		FollowGear(instructor)
		HogSay(instructor, loc(drill[5]), SAY_SHOUT)
		HogTurnLeft(player, true)
		TurnTimeLeft = 10000
	elseif progress == 4 then
		local x, y = GetGearPosition(player);
		if y < player_start_y then
			progress = 5
			FollowGear(instructor)
			HogSay(instructor, "Yeah!", SAY_SAY)
			time_start = GameTime
			TurnTimeLeft = 30000
		end
	elseif progress == 5 and (time_start + 2500 == GameTime) then
		FollowGear(instructor)
		HogSay(instructor, loc(drill[6]), SAY_SAY)
	elseif progress == 5 and (time_start + 5000 == GameTime) then
		FollowGear(instructor)
		HogSay(instructor, loc(drill[7]), SAY_SAY)
	elseif progress == 5 and (time_start + 7500 == GameTime) then
		FollowGear(instructor)
		HogSay(instructor, loc(drill[8]), SAY_SHOUT)
		ShowMission(loc(caption), loc(subcaption), loc(goals[1]), 1, 0);
		target = AddGear(target_x, target_y, gtTarget, 0, 0, 0, 0)
		TurnTimeLeft = 60000
	elseif progress == 5 and (time_start + 10000 == GameTime) then
		FollowGear(target)
	elseif progress == 6 then
		progress = 7
		ShowMission(loc(caption), loc(subcaption), loc(goals[2]), 0, 0);
		PlaySound(sndVictory);
		time_start = GameTime
	elseif progress == 7 and (time_start + 2500 == GameTime) then
		EndGame()
	end
end

function onGameInit()
	Seed = 0
	GameFlags = gfMultiWeapon + gfOneClanMode
	TurnTime = 25000
	CaseFreq = 0
	MinesNum = 0
	Explosives = 0
	Delay = 2500
	Map = "Mushrooms"
	Theme = "Nature"
	
	AddTeam(loc(teamnames[0]), teamcolor, "Simple", "Island", "Default")
	player = AddHog(loc(hognames[0]), 0, player_health, "NoHat")
	SetGearPosition(player, player_start_x, player_start_y);
	
	AddTeam(loc(teamnames[1]), teamcolor + 1, "Simple", "Island", "Default")
	instructor = AddHog(loc(hognames[1]), 0, instructor_health, "NoHat")
	SetGearPosition(instructor, player_start_x + 100, player_start_y)
	HogTurnLeft(instructor, true)

	FollowGear(player);
end

function onAmmoStoreInit()
	SetAmmo(amBazooka, 9, 0, 0, 0)
end

function onGearDelete(gear)
	if GetGearType(gear) == gtTarget then
		progress = 6
	end
end
