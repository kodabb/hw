{-# LANGUAGE OverloadedStrings #-}
module Utils where

import Data.Char
import Data.Word
import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.Char as Char
import Numeric
import Network.Socket
import System.IO
import qualified Data.List as List
import Control.Monad
import qualified Codec.Binary.Base64 as Base64
import qualified Data.ByteString.Lazy as BL
import qualified Text.Show.ByteString as BS
import qualified Data.ByteString.Char8 as B
import qualified Data.ByteString.UTF8 as UTF8
import qualified Data.ByteString as BW
-------------------------------------------------
import CoreTypes


sockAddr2String :: SockAddr -> IO B.ByteString
sockAddr2String (SockAddrInet _ hostAddr) = liftM B.pack $ inet_ntoa hostAddr
sockAddr2String (SockAddrInet6 _ _ (a, b, c, d) _) =
    return $ B.pack $ (foldr1 (.)
        $ List.intersperse (':':)
        $ concatMap (\n -> (\(a0, a1) -> [showHex a0, showHex a1]) $ divMod n 65536) [a, b, c, d]) []

maybeRead :: Read a => String -> Maybe a
maybeRead s = case reads s of
    [(x, rest)] | all isSpace rest -> Just x
    _         -> Nothing

teamToNet :: TeamInfo -> [B.ByteString]
teamToNet team =
        "ADD_TEAM"
        : teamname team
        : teamgrave team
        : teamfort team
        : teamvoicepack team
        : teamflag team
        : teamowner team
        : (showB . difficulty $ team)
        : hhsInfo
    where
        hhsInfo = concatMap (\(HedgehogInfo n hat) -> [n, hat]) $ hedgehogs team

modifyTeam :: TeamInfo -> RoomInfo -> RoomInfo
modifyTeam team room = room{teams = replaceTeam team $ teams room}
    where
    replaceTeam _ [] = error "modifyTeam: no such team"
    replaceTeam tm (t:ts) =
        if teamname tm == teamname t then
            tm : ts
        else
            t : replaceTeam tm ts

illegalName :: B.ByteString -> Bool
illegalName s = B.null s || B.all isSpace s || isSpace (B.head s) || isSpace (B.last s) || B.any isIllegalChar s
    where
        isIllegalChar c = c `List.elem` "$()*+?[]^{|}"

protoNumber2ver :: Word16 -> B.ByteString
protoNumber2ver v = Map.findWithDefault "Unknown" v vermap
    where
        vermap = Map.fromList [
            (17, "0.9.7-dev")
            , (19, "0.9.7")
            , (20, "0.9.8-dev")
            , (21, "0.9.8")
            , (22, "0.9.9-dev")
            , (23, "0.9.9")
            , (24, "0.9.10-dev")
            , (25, "0.9.10")
            , (26, "0.9.11-dev")
            , (27, "0.9.11")
            , (28, "0.9.12-dev")
            , (29, "0.9.12")
            , (30, "0.9.13-dev")
            , (31, "0.9.13")
            , (32, "0.9.14-dev")
            , (33, "0.9.14")
            , (34, "0.9.15-dev")
            , (35, "0.9.14.1")
            , (37, "0.9.15")
            , (38, "0.9.16-dev")
            , (39, "0.9.16")
            , (40, "0.9.17-dev")
            ]

askFromConsole :: B.ByteString -> IO B.ByteString
askFromConsole msg = do
    B.putStr msg
    hFlush stdout
    B.getLine


unfoldrE :: (b -> Either b (a, b)) -> b -> ([a], b)
unfoldrE f b  =
    case f b of
        Right (a, new_b) -> let (a', b') = unfoldrE f new_b in (a : a', b')
        Left new_b       -> ([], new_b)

showB :: (BS.Show a) => a -> B.ByteString
showB = B.concat . BL.toChunks . BS.show

readInt_ :: (Num a) => B.ByteString -> a
readInt_ str =
  case B.readInt str of
       Just (i, t) | B.null t -> fromIntegral i
       _                      -> 0 

cutHost :: B.ByteString -> B.ByteString
cutHost = B.intercalate "." .  flip (++) ["*","*"] . List.take 2 . B.split '.'

caseInsensitiveCompare :: B.ByteString -> B.ByteString -> Bool
caseInsensitiveCompare a b = f a == f b
    where
        f = map Char.toUpper . UTF8.toString
