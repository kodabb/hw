module HWProtoInRoomState where

import qualified Data.Foldable as Foldable
import qualified Data.IntMap as IntMap
import qualified Data.Map as Map
import Data.Sequence(Seq, (|>), (><), fromList, empty)
import Data.List
import Maybe
--------------------------------------
import CoreTypes
import Actions
import Utils


handleCmd_inRoom :: CmdHandler

handleCmd_inRoom clID clients _ ["CHAT", msg] =
	[AnswerOthersInRoom ["CHAT", clientNick, msg]]
	where
		clientNick = nick $ clients IntMap.! clID


handleCmd_inRoom clID clients _ ["TEAM_CHAT", msg] =
	[AnswerOthersInRoom ["TEAM_CHAT", clientNick, msg]]
	where
		clientNick = nick $ clients IntMap.! clID


handleCmd_inRoom clID clients rooms ["PART"] =
	if isMaster client then
		[RemoveRoom]
	else
		[RoomRemoveThisClient "part"]
	where
		client = clients IntMap.! clID


handleCmd_inRoom clID clients rooms ("CFG" : paramName : paramStrs) =
	if isMaster client then
		[ModifyRoom (\r -> r{params = Map.insert paramName paramStrs (params r)})
		, AnswerOthersInRoom ("CFG" : paramName : paramStrs)]
	else
		[ProtocolError "Not room master"]
	where
		client = clients IntMap.! clID

handleCmd_inRoom clID clients rooms ("ADD_TEAM" : name : color : grave : fort : voicepack : difStr : hhsInfo)
	| length hhsInfo == 16 =
	if length (teams room) == 6 then
		[Warning "too many teams"]
	else if canAddNumber <= 0 then
		[Warning "too many hedgehogs"]
	else if isJust findTeam then
		[Warning "already have a team with same name"]
	else if gameinprogress room then
		[Warning "round in progress"]
	else if isRestrictedTeams room then
		[Warning "restricted"]
	else
		[ModifyRoom (\r -> r{teams = teams r ++ [newTeam]}),
		ModifyClient (\c -> c{teamsInGame = teamsInGame c + 1}),
		AnswerThisClient ["TEAM_ACCEPTED", name],
		AnswerOthersInRoom $ teamToNet newTeam,
		AnswerOthersInRoom ["TEAM_COLOR", name, color]
		]
	where
		client = clients IntMap.! clID
		room = rooms IntMap.! (roomID client)
		canAddNumber = 48 - (sum . map hhnum $ teams room)
		findTeam = find (\t -> name == teamname t) $ teams room
		newTeam = (TeamInfo (nick client) name color grave fort voicepack difficulty newTeamHHNum (hhsList hhsInfo))
		difficulty = fromMaybe 0 (maybeRead difStr :: Maybe Int)
		hhsList [] = []
		hhsList (n:h:hhs) = HedgehogInfo n h : hhsList hhs
		newTeamHHNum = min 4 canAddNumber


handleCmd_inRoom clID clients rooms ["REMOVE_TEAM", teamName] =
	if noSuchTeam then
		[Warning "REMOVE_TEAM: no such team"]
	else
		if not $ nick client == teamowner team then
			[ProtocolError "Not team owner!"]
		else
			[RemoveTeam teamName,
			ModifyClient (\c -> c{teamsInGame = teamsInGame c - 1})	
			]
	where
		client = clients IntMap.! clID
		room = rooms IntMap.! (roomID client)
		noSuchTeam = isNothing findTeam
		team = fromJust findTeam
		findTeam = find (\t -> teamName == teamname t) $ teams room


handleCmd_inRoom clID clients rooms ["HH_NUM", teamName, numberStr] =
	if not $ isMaster client then
		[ProtocolError "Not room master"]
	else
		if hhNumber < 1 || hhNumber > 8 || noSuchTeam || hhNumber > (canAddNumber + (hhnum team)) then
			[]
		else
			[ModifyRoom $ modifyTeam team{hhnum = hhNumber},
			AnswerOthersInRoom ["HH_NUM", teamName, show hhNumber]]
	where
		client = clients IntMap.! clID
		room = rooms IntMap.! (roomID client)
		hhNumber = fromMaybe 0 (maybeRead numberStr :: Maybe Int)
		noSuchTeam = isNothing findTeam
		team = fromJust findTeam
		findTeam = find (\t -> teamName == teamname t) $ teams room
		canAddNumber = 48 - (sum . map hhnum $ teams room)


handleCmd_inRoom clID clients rooms ["TEAM_COLOR", teamName, newColor] =
	if not $ isMaster client then
		[ProtocolError "Not room master"]
	else
		if noSuchTeam then
			[]
		else
			[ModifyRoom $ modifyTeam team{teamcolor = newColor},
			AnswerOthersInRoom ["TEAM_COLOR", teamName, newColor]]
	where
		noSuchTeam = isNothing findTeam
		team = fromJust findTeam
		findTeam = find (\t -> teamName == teamname t) $ teams room
		client = clients IntMap.! clID
		room = rooms IntMap.! (roomID client)


handleCmd_inRoom clID clients rooms ["TOGGLE_READY"] =
	[ModifyClient (\c -> c{isReady = not $ isReady client}),
	ModifyRoom (\r -> r{readyPlayers = readyPlayers r + (if isReady client then -1 else 1)}),
	AnswerThisRoom $ [if isReady client then "NOT_READY" else "READY", nick client]]
	where
		client = clients IntMap.! clID


handleCmd_inRoom clID clients rooms ["START_GAME"] =
	if isMaster client && (playersIn room == readyPlayers room) && (not $ gameinprogress room) then
		if enoughClans then
			[ModifyRoom
					(\r -> r{
						gameinprogress = True,
						roundMsgs = empty,
						leftTeams = [],
						teamsAtStart = teams r}
					),
			AnswerThisRoom ["RUN_GAME"]]
		else
			[Warning "Less than two clans!"]
	else
		[]
	where
		client = clients IntMap.! clID
		room = rooms IntMap.! (roomID client)
		enoughClans = not $ null $ drop 1 $ group $ map teamcolor $ teams room


handleCmd_inRoom clID clients rooms ["EM", msg] =
	if teamsInGame client > 0 then
		[ModifyRoom (\r -> r{roundMsgs = roundMsgs r |> msg}),
		AnswerOthersInRoom ["EM", msg]]
	else
		[]
	where
		client = clients IntMap.! clID

handleCmd_inRoom clID clients rooms ["ROUNDFINISHED"] =
	if isMaster client then
		[ModifyRoom
				(\r -> r{
					gameinprogress = False,
					readyPlayers = 0,
					roundMsgs = empty,
					leftTeams = [],
					teamsAtStart = []}
				),
		UnreadyRoomClients
		] ++ answerRemovedTeams
	else
		[]
	where
		client = clients IntMap.! clID
		room = rooms IntMap.! (roomID client)
		answerRemovedTeams = map (\t -> AnswerThisRoom ["REMOVE_TEAM", t]) $ leftTeams room


handleCmd_inRoom clID clients _ ["TOGGLE_RESTRICT_JOINS"] =
	if isMaster client then
		[ModifyRoom (\r -> r{isRestrictedJoins = not $ isRestrictedJoins r})]
	else
		[ProtocolError "Not room master"]
	where
		client = clients IntMap.! clID


handleCmd_inRoom clID clients _ ["TOGGLE_RESTRICT_TEAMS"] =
	if isMaster client then
		[ModifyRoom (\r -> r{isRestrictedTeams = not $ isRestrictedTeams r})]
	else
		[ProtocolError "Not room master"]
	where
		client = clients IntMap.! clID

handleCmd_inRoom clID clients rooms ["KICK", kickNick] =
	if not $ isMaster client then
		[]
	else
		if noSuchClient then
			[]
		else
			if (kickID == clID) || (roomID client /= roomID kickClient) then
				[]
			else
				[KickRoomClient kickID]
	where
		client = clients IntMap.! clID
		maybeClient = Foldable.find (\cl -> kickNick == nick cl) clients
		noSuchClient = isNothing maybeClient
		kickClient = fromJust maybeClient
		kickID = clientUID kickClient


handleCmd_inRoom clID _ _ _ = [ProtocolError "Incorrect command (state: in room)"]
