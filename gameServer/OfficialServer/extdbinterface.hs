{-# LANGUAGE ScopedTypeVariables, OverloadedStrings #-}

module Main where

import Prelude hiding (catch)
import Control.Monad
import Control.Exception
import System.IO
import Data.Maybe
import Database.HDBC
import Database.HDBC.MySQL
--------------------------
import CoreTypes


dbQueryAccount =
    "SELECT users.pass, users_roles.rid FROM users LEFT JOIN users_roles ON (users.uid = users_roles.uid AND users_roles.rid = 3) WHERE users.name = ?"

dbQueryStats =
    "INSERT INTO gameserver_stats (players, rooms, last_update) VALUES (?, ?, UNIX_TIMESTAMP())"

dbInteractionLoop dbConn = forever $ do
    q <- liftM read getLine
    hPutStrLn stderr $ show q

    case q of
        CheckAccount clId clUid clNick _ -> do
                statement <- prepare dbConn dbQueryAccount
                execute statement [SqlByteString clNick]
                passAndRole <- fetchRow statement
                finish statement
                let response =
                        if isJust passAndRole then
                        (
                            clId,
                            clUid,
                            HasAccount
                                (fromSql . head . fromJust $ passAndRole)
                                (fromSql (last . fromJust $ passAndRole) == Just (3 :: Int))
                        )
                        else
                        (clId, clUid, Guest)
                print response
                hFlush stdout

        SendStats clients rooms ->
                run dbConn dbQueryStats [SqlInt32 $ fromIntegral clients, SqlInt32 $ fromIntegral rooms] >> return ()

        StoreAchievements -> return ()


dbConnectionLoop mySQLConnectionInfo =
    Control.Exception.handle (\(e :: IOException) -> hPutStrLn stderr $ show e) $ handleSqlError $
        bracket
            (connectMySQL mySQLConnectionInfo)
            disconnect
            dbInteractionLoop


--processRequest :: DBQuery -> IO String
--processRequest (CheckAccount clId clUid clNick clHost) = return $ show (clclId, clUid, Guest)

main = do
        dbHost <- getLine
        dbName <- getLine
        dbLogin <- getLine
        dbPassword <- getLine

        let mySQLConnectInfo = defaultMySQLConnectInfo {mysqlHost = dbHost, mysqlDatabase = dbName, mysqlUser = dbLogin, mysqlPassword = dbPassword}

        dbConnectionLoop mySQLConnectInfo
