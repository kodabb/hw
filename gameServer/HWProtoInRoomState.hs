{-# LANGUAGE OverloadedStrings #-}
module HWProtoInRoomState where

import qualified Data.Map as Map
import Data.Sequence((|>), empty)
import Data.List
import Data.Maybe
import qualified Data.ByteString.Char8 as B
import Control.Monad
import Control.Monad.Reader
--------------------------------------
import CoreTypes
import Actions
import Utils
import HandlerUtils
import RoomsAndClients

handleCmd_inRoom :: CmdHandler

handleCmd_inRoom ["CHAT", msg] = do
    n <- clientNick
    s <- roomOthersChans
    return [AnswerClients s ["CHAT", n, msg]]

handleCmd_inRoom ["PART"] = return [MoveToLobby "part"]
handleCmd_inRoom ["PART", msg] = return [MoveToLobby $ "part: " `B.append` msg]


handleCmd_inRoom ("CFG" : paramName : paramStrs)
    | null paramStrs = return [ProtocolError "Empty config entry"]
    | otherwise = do
        chans <- roomOthersChans
        cl <- thisClient
        if isMaster cl then
           return [
                ModifyRoom f,
                AnswerClients chans ("CFG" : paramName : paramStrs)]
            else
            return [ProtocolError "Not room master"]
    where
        f r = if paramName `Map.member` (mapParams r) then
                r{mapParams = Map.insert paramName (head paramStrs) (mapParams r)}
                else
                r{params = Map.insert paramName paramStrs (params r)}

handleCmd_inRoom ("ADD_TEAM" : tName : color : grave : fort : voicepack : flag : difStr : hhsInfo)
    | length hhsInfo /= 16 = return [ProtocolError "Corrupted hedgehogs info"]
    | otherwise = do
        (ci, _) <- ask
        rm <- thisRoom
        clNick <- clientNick
        clChan <- thisClientChans
        othChans <- roomOthersChans
        return $
            if not . null . drop (maxTeams rm - 1) $ teams rm then
                [Warning "too many teams"]
            else if canAddNumber rm <= 0 then
                [Warning "too many hedgehogs"]
            else if isJust $ findTeam rm then
                [Warning "There's already a team with same name in the list"]
            else if gameinprogress rm then
                [Warning "round in progress"]
            else if isRestrictedTeams rm then
                [Warning "restricted"]
            else
                [ModifyRoom (\r -> r{teams = teams r ++ [newTeam ci clNick r]}),
                ModifyClient (\c -> c{teamsInGame = teamsInGame c + 1, clientClan = Just color}),
                AnswerClients clChan ["TEAM_ACCEPTED", tName],
                AnswerClients othChans $ teamToNet $ newTeam ci clNick rm,
                AnswerClients othChans ["TEAM_COLOR", tName, color]
                ]
        where
        canAddNumber r = 48 - (sum . map hhnum $ teams r)
        findTeam = find (\t -> tName == teamname t) . teams
        newTeam ci clNick r = TeamInfo ci clNick tName color grave fort voicepack flag dif (newTeamHHNum r) (hhsList hhsInfo)
        dif = readInt_ difStr
        hhsList [] = []
        hhsList [_] = error "Hedgehogs list with odd elements number"
        hhsList (n:h:hhs) = HedgehogInfo n h : hhsList hhs
        newTeamHHNum r = min 4 (canAddNumber r)
        maxTeams r 
            | roomProto r < 38 = 6
            | otherwise = 8
                

handleCmd_inRoom ["REMOVE_TEAM", tName] = do
        (ci, _) <- ask
        r <- thisRoom
        clNick <- clientNick

        let maybeTeam = findTeam r
        let team = fromJust maybeTeam

        return $
            if isNothing $ findTeam r then
                [Warning "REMOVE_TEAM: no such team"]
            else if clNick /= teamowner team then
                [ProtocolError "Not team owner!"]
            else
                [RemoveTeam tName,
                ModifyClient
                    (\c -> c{
                        teamsInGame = teamsInGame c - 1,
                        clientClan = if teamsInGame c == 1 then Nothing else Just $ anotherTeamClan ci r
                    })
                ]
    where
        anotherTeamClan ci = teamcolor . fromJust . find (\t -> teamownerId t == ci) . teams
        findTeam = find (\t -> tName == teamname t) . teams


handleCmd_inRoom ["HH_NUM", teamName, numberStr] = do
    cl <- thisClient
    others <- roomOthersChans
    r <- thisRoom

    let maybeTeam = findTeam r
    let team = fromJust maybeTeam

    return $
        if not $ isMaster cl then
            [ProtocolError "Not room master"]
        else if hhNumber < 1 || hhNumber > 8 || isNothing maybeTeam || hhNumber > canAddNumber r + hhnum team then
            []
        else
            [ModifyRoom $ modifyTeam team{hhnum = hhNumber},
            AnswerClients others ["HH_NUM", teamName, showB hhNumber]]
    where
        hhNumber = readInt_ numberStr
        findTeam = find (\t -> teamName == teamname t) . teams
        canAddNumber = (-) 48 . sum . map hhnum . teams



handleCmd_inRoom ["TEAM_COLOR", teamName, newColor] = do
    cl <- thisClient
    others <- roomOthersChans
    r <- thisRoom

    let maybeTeam = findTeam r
    let team = fromJust maybeTeam

    return $
        if not $ isMaster cl then
            [ProtocolError "Not room master"]
        else if isNothing maybeTeam then
            []
        else
            [ModifyRoom $ modifyTeam team{teamcolor = newColor},
            AnswerClients others ["TEAM_COLOR", teamName, newColor],
            ModifyClient2 (teamownerId team) (\c -> c{clientClan = Just newColor})]
    where
        findTeam = find (\t -> teamName == teamname t) . teams


handleCmd_inRoom ["TOGGLE_READY"] = do
    cl <- thisClient
    chans <- roomClientsChans
    return [
        ModifyClient (\c -> c{isReady = not $ isReady cl}),
        ModifyRoom (\r -> r{readyPlayers = readyPlayers r + (if isReady cl then -1 else 1)}),
        AnswerClients chans $ if clientProto cl < 38 then
                [if isReady cl then "NOT_READY" else "READY", nick cl]
                else
                ["CLIENT_FLAGS", if isReady cl then "-r" else "+r", nick cl]
        ]

handleCmd_inRoom ["START_GAME"] = do
    cl <- thisClient
    rm <- thisRoom
    chans <- roomClientsChans

    if isMaster cl && playersIn rm == readyPlayers rm && not (gameinprogress rm) then
        if enoughClans rm then
            return [
                ModifyRoom
                    (\r -> r{
                        gameinprogress = True,
                        roundMsgs = empty,
                        leftTeams = [],
                        teamsAtStart = teams r}
                    ),
                AnswerClients chans ["RUN_GAME"]
                ]
            else
            return [Warning "Less than two clans!"]
        else
        return []
    where
        enoughClans = not . null . drop 1 . group . map teamcolor . teams


handleCmd_inRoom ["EM", msg] = do
    cl <- thisClient
    rm <- thisRoom
    chans <- roomOthersChans

    if teamsInGame cl > 0 && gameinprogress rm && isLegal then
        return $ AnswerClients chans ["EM", msg] : [ModifyRoom (\r -> r{roundMsgs = roundMsgs r |> msg}) | not isKeepAlive]
        else
        return []
    where
        (isLegal, isKeepAlive) = checkNetCmd msg


handleCmd_inRoom ["ROUNDFINISHED", _] = do
    cl <- thisClient
    rm <- thisRoom
    chans <- roomClientsChans

    if isMaster cl && gameinprogress rm then
        return $ 
            ModifyRoom
                (\r -> r{
                    gameinprogress = False,
                    readyPlayers = 0,
                    roundMsgs = empty,
                    leftTeams = [],
                    teamsAtStart = []}
                )
            : UnreadyRoomClients
            : answerRemovedTeams chans rm
        else
        return []
    where
        answerRemovedTeams chans = map (\t -> AnswerClients chans ["REMOVE_TEAM", t]) . leftTeams

-- compatibility with clients with protocol < 38
handleCmd_inRoom ["ROUNDFINISHED"] =
    handleCmd_inRoom ["ROUNDFINISHED", "1"]

handleCmd_inRoom ["TOGGLE_RESTRICT_JOINS"] = do
    cl <- thisClient
    return $
        if not $ isMaster cl then
            [ProtocolError "Not room master"]
        else
            [ModifyRoom (\r -> r{isRestrictedJoins = not $ isRestrictedJoins r})]


handleCmd_inRoom ["TOGGLE_RESTRICT_TEAMS"] = do
    cl <- thisClient
    return $
        if not $ isMaster cl then
            [ProtocolError "Not room master"]
        else
            [ModifyRoom (\r -> r{isRestrictedTeams = not $ isRestrictedTeams r})]


handleCmd_inRoom ["ROOM_NAME", newName] = do
    cl <- thisClient
    rs <- allRoomInfos
    
    return $
        if not $ isMaster cl then
            [ProtocolError "Not room master"]
        else
        if isJust $ find (\r -> newName == name r) rs then
            [Warning "Room with such name already exists"]
        else
            [ModifyRoom (\r -> r{name = newName})]


handleCmd_inRoom ["KICK", kickNick] = do
    (thisClientId, rnc) <- ask
    maybeClientId <- clientByNick kickNick
    master <- liftM isMaster thisClient
    let kickId = fromJust maybeClientId
    let sameRoom = clientRoom rnc thisClientId == clientRoom rnc kickId
    return
        [KickRoomClient kickId | master && isJust maybeClientId && (kickId /= thisClientId) && sameRoom]


handleCmd_inRoom ["TEAMCHAT", msg] = do
    cl <- thisClient
    chans <- roomSameClanChans
    return [AnswerClients chans ["EM", engineMsg cl]]
    where
        engineMsg cl = toEngineMsg $ B.concat ["b", nick cl, "(team): ", msg, "\x20\x20"]

handleCmd_inRoom _ = return [ProtocolError "Incorrect command (state: in room)"]
