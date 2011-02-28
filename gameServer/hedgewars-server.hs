{-# LANGUAGE CPP, ScopedTypeVariables, OverloadedStrings #-}

module Main where

import Network.Socket
import Network.BSD
import Control.Concurrent.Chan
import qualified Control.Exception as E
import System.Log.Logger
import System.Process
#if defined(OFFICIAL_SERVER)
import Control.Monad
#endif
-----------------------------------
import Opts
import CoreTypes
import ServerCore

#if !defined(mingw32_HOST_OS)
import System.Posix
#endif


setupLoggers :: IO ()
setupLoggers =
    updateGlobalLogger "Clients"
        (setLevel INFO)


server :: ServerInfo -> IO ()
server si = do
    proto <- getProtocolNumber "tcp"
    E.bracket
        (socket AF_INET Stream proto)
        sClose
        (\sock -> do
            setSocketOption sock ReuseAddr 1
            bindSocket sock (SockAddrInet (listenPort si) iNADDR_ANY)
            listen sock maxListenQueue
            startServer si sock
        )

handleRestart :: ShutdownException -> IO ()
handleRestart ShutdownException = return ()
handleRestart RestartException = do
    _ <- createProcess (proc "./hedgewars-server" [])
    return ()

main :: IO ()
main = withSocketsDo $ do
#if !defined(mingw32_HOST_OS)
    _ <- installHandler sigPIPE Ignore Nothing
    _ <- installHandler sigCHLD Ignore Nothing
#endif

    setupLoggers

    dbQueriesChan <- newChan
    coreChan' <- newChan
    serverInfo' <- getOpts $ newServerInfo coreChan' dbQueriesChan

#if defined(OFFICIAL_SERVER)
    [dbHost', dbLogin', dbPassword'] <- liftM read $ readFile "hedgewars-server.ini"
    let si = serverInfo'{dbHost = dbHost', dbLogin = dbLogin', dbPassword = dbPassword'}
#else
    let si = serverInfo'
#endif

    (server si) `E.catch` handleRestart
