module Utils where

import Control.Concurrent
import Control.Concurrent.STM
import Data.Char
import Data.Word
import qualified Data.Map as Map
import qualified Data.IntMap as IntMap
import qualified Data.Set as Set
import Data.ByteString.Internal (w2c)
import Numeric
import Network.Socket
import System.IO
import qualified Data.List as List
import Control.Monad
import Maybe
-------------------------------------------------
import qualified Codec.Binary.Base64 as Base64
import qualified Codec.Binary.UTF8.String as UTF8
import CoreTypes


sockAddr2String :: SockAddr -> IO String
sockAddr2String (SockAddrInet _ hostAddr) = inet_ntoa hostAddr
sockAddr2String (SockAddrInet6 _ _ (a, b, c, d) _) =
	return $ (foldr1 (.)
		$ List.intersperse (\a -> ':':a)
		$ concatMap (\n -> (\(a, b) -> [showHex a, showHex b]) $ divMod n 65536) [a, b, c, d]) []

toEngineMsg :: String -> String
toEngineMsg msg = Base64.encode (fromIntegral (length encodedMsg) : encodedMsg)
	where
	encodedMsg = UTF8.encode msg

fromEngineMsg :: String -> Maybe String
fromEngineMsg msg = liftM (map w2c) (Base64.decode msg >>= removeLength)
	where
		removeLength (x:xs) = if length xs == fromIntegral x then Just xs else Nothing
		removeLength _ = Nothing

checkNetCmd :: String -> (Bool, Bool)
checkNetCmd msg = check decoded
	where
		decoded = fromEngineMsg msg
		check Nothing = (False, False)
		check (Just (m:ms)) = (m `Set.member` legalMessages, m == '+')
		check _ = (False, False)
		legalMessages = Set.fromList $ "M#+LlRrUuDdZzAaSjJ,sFNpPwtghb12345" ++ slotMessages
		slotMessages = "\128\129\130\131\132\133\134\135\136\137\138"

maybeRead :: Read a => String -> Maybe a
maybeRead s = case reads s of
	[(x, rest)] | all isSpace rest -> Just x
	_         -> Nothing

teamToNet team = [
		"ADD_TEAM",
		teamname team,
		teamgrave team,
		teamfort team,
		teamvoicepack team,
		teamowner team,
		show $ difficulty team
		]
		++ hhsInfo
	where
		hhsInfo = concatMap (\(HedgehogInfo name hat) -> [name, hat]) $ hedgehogs team

modifyTeam :: TeamInfo -> RoomInfo -> RoomInfo
modifyTeam team room = room{teams = replaceTeam team $ teams room}
	where
	replaceTeam _ [] = error "modifyTeam: no such team"
	replaceTeam team (t:teams) =
		if teamname team == teamname t then
			team : teams
		else
			t : replaceTeam team teams

illegalName :: String -> Bool
illegalName = all isSpace

protoNumber2ver :: Word16 -> String
protoNumber2ver 17 = "0.9.7-dev"
protoNumber2ver 19 = "0.9.7"
protoNumber2ver 20 = "0.9.8-dev"
protoNumber2ver 21 = "0.9.8"
protoNumber2ver 22 = "0.9.9-dev"
protoNumber2ver 23 = "0.9.9"
protoNumber2ver 24 = "0.9.10-dev"
protoNumber2ver 25 = "0.9.10"
protoNumber2ver 26 = "0.9.11-dev"
protoNumber2ver 27 = "0.9.11"
protoNumber2ver 28 = "0.9.12-dev"
protoNumber2ver 29 = "0.9.12"
protoNumber2ver 30 = "0.9.13-dev"
protoNumber2ver _ = "Unknown"

askFromConsole :: String -> IO String
askFromConsole msg = do
	putStr msg
	hFlush stdout
	getLine
