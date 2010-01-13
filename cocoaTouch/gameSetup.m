//
//  gameSetup.m
//  hwengine
//
//  Created by Vittorio on 10/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameSetup.h"
#import "SDL_uikitappdelegate.h"
#import "SDL_net.h"
#import "PascalImports.h"

#define IPC_PORT 51342
#define IPC_PORT_STR "51342"
#define BUFFER_SIZE 256


// they should go in the interface
TCPsocket sd, csd; /* Socket descriptor, Client socket descriptor */
int sendToEngine (NSString * string) {
	Uint8 length = [string length];
	
	SDLNet_TCP_Send(csd, &length , 1);
	return SDLNet_TCP_Send(csd, [string UTF8String], length);
}


@implementation GameSetup

@synthesize locale, engineProtocolStarted;

-(id) init {
	self = [super init];
	self.locale = [NSLocale currentLocale];
	self.engineProtocolStarted = NO;
	return self;
}

-(void) startThread: (NSString *) selector {
	SEL usage = NSSelectorFromString(selector);
	
	// do not start the server thread because the port is already bound
	if (NO == engineProtocolStarted) {
		engineProtocolStarted = YES;
		[NSThread detachNewThreadSelector:usage toTarget:self withObject:nil];
	}
}

-(void) engineProtocol {
	IPaddress ip;
	int idx, eProto;
	BOOL serverQuit, clientQuit;
	char buffer[BUFFER_SIZE], string[BUFFER_SIZE];
	Uint8 msgSize;
	Uint16 gameTicks;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (SDLNet_Init() < 0) {
		fprintf(stderr, "SDLNet_Init: %s\n", SDLNet_GetError());
		exit(EXIT_FAILURE);
	}
	
	/* Resolving the host using NULL make network interface to listen */
	if (SDLNet_ResolveHost(&ip, NULL, IPC_PORT) < 0) {
		fprintf(stderr, "SDLNet_ResolveHost: %s\n", SDLNet_GetError());
		exit(EXIT_FAILURE);
	}
	
	/* Open a connection with the IP provided (listen on the host's port) */
	if (!(sd = SDLNet_TCP_Open(&ip))) {
		fprintf(stderr, "SDLNet_TCP_Open: %s\n", SDLNet_GetError());
		exit(EXIT_FAILURE);
	}
	
	NSLog(@"engineProtocol - Waiting for a client");
	
	serverQuit = NO;
	while (!serverQuit) {
		
		/* This check the sd if there is a pending connection.
		 * If there is one, accept that, and open a new socket for communicating */
		if ((csd = SDLNet_TCP_Accept(sd))) {
			
			NSLog(@"engineProtocol - Client found");
			
			//first byte of the command alwayas contain the size of the command
			SDLNet_TCP_Recv(csd, &msgSize, sizeof(Uint8));
			
			SDLNet_TCP_Recv(csd, buffer, msgSize);
			gameTicks = SDLNet_Read16(&buffer[msgSize - 2]);
			//NSLog(@"engineProtocol - %d: received [%s]", gameTicks, buffer);
			
			if ('C' == buffer[0]) {
				NSLog(@"engineProtocol - sending game config");
				
				// send config data data
				
				// local game
				sendToEngine(@"TL");
				
				// seed info
				sendToEngine(@"eseed {232c1b42-7d39-4ee6-adf8-4240e1f1efb8}");
				
				// various flags
				sendToEngine(@"e$gmflags 256"); 

				// various flags
				sendToEngine(@"e$damagepct 100");
				
				// various flags
				sendToEngine(@"e$turntime 45000");
				
				// various flags
				sendToEngine(@"e$minestime 3000");
				
				// various flags
				sendToEngine(@"e$landadds 4");
				
				// various flags
				sendToEngine(@"e$sd_turns 15");
												
				// various flags
				sendToEngine(@"e$casefreq 5");
				
				// various flags
				sendToEngine(@"e$template_filter 1");
								
				// theme info
				sendToEngine(@"etheme Freeway");
				
				// team 1 info
				sendToEngine(@"eaddteam 4421353 System Cats");
				
				// team 1 grave info
				sendToEngine(@"egrave star");
				
				// team 1 fort info
				sendToEngine(@"efort  Earth");
								
				// team 1 voicepack info
				sendToEngine(@"evoicepack Classic");
				
				// team 1 binds (skipped)				
				// team 1 members info
				sendToEngine(@"eaddhh 0 100 Snow Leopard");
				sendToEngine(@"ehat NoHat");
				
				// team 1 ammostore
				sendToEngine(@"eammstore 93919294221991210322351110012010000002110404000441400444645644444774776112211144");

				// team 2 info
				sendToEngine(@"eaddteam 4100897 Poke-MAN");
				
				// team 2 grave info
				sendToEngine(@"egrave Badger");
				
				// team 2 fort info
				sendToEngine(@"efort UFO");
				
				// team 2 voicepack info
				sendToEngine(@"evoicepack Classic");
				
				// team 2 binds (skipped)
				// team 2 members info
				sendToEngine(@"eaddhh 0 100 Raichu");
				sendToEngine(@"ehat Bunny");
				
				// team 2 ammostore
				sendToEngine(@"eammstore 93919294221991210322351110012010000002110404000441400444645644444774776112211144");
				
				clientQuit = NO;
			} else {
				NSLog(@"engineProtocolThread - wrong message, closing connection");
				clientQuit = YES;
			}
			
			while (!clientQuit){
				/* Now we can communicate with the client using csd socket
				 * sd will remain opened waiting other connections */
				idx = 0;
				msgSize = 0;
				memset(buffer, 0, BUFFER_SIZE);
				memset(string, 0, BUFFER_SIZE);
				if (SDLNet_TCP_Recv(csd, &msgSize, sizeof(Uint8)) <= 0)
					clientQuit = YES;
				if (SDLNet_TCP_Recv(csd, buffer, msgSize) <=0)
					clientQuit = YES;
				
				gameTicks = SDLNet_Read16(&buffer[msgSize - 2]);
				//NSLog(@"engineProtocolThread - %d: received [%s]", gameTicks, buffer);
				
				switch (buffer[0]) {
					case '?':
						NSLog(@"Ping? Pong!");
						sendToEngine(@"!");
						break;
					case 'E':
						NSLog(@"ERROR - last console line: [%s]", buffer);
						clientQuit = YES;
						break;
					case 'e':
						sscanf(buffer, "%*s %d", &eProto);
						if (HW_protoVer() == eProto) {
							NSLog(@"Setting protocol version %s", buffer);
						} else {
							NSLog(@"ERROR - wrong protocol number: [%s] - expecting %d", buffer, eProto);
							clientQuit = YES;
						}
						break;
					case 'i':
						switch (buffer[1]) {
							case 'r':
								NSLog(@"Winning team: %s", &buffer[2]);
								break;
							case 'k':
								NSLog(@"Best Hedgehog: %s", &buffer[2]);
								break;
						}
						break;
					default:
						// empty packet or just statistics
						break;
					// missing case for exiting right away
				} 
			}
		}
		
		/* Close the client socket */
		SDLNet_TCP_Close(csd);
	}

	SDLNet_TCP_Close(sd);
	SDLNet_Quit();

	[pool release];
	[NSThread exit];
}

-(void) setArgsForLocalPlay {
	NSString *localeString = [[self.locale localeIdentifier] stringByAppendingString:@".txt"];
	NSLog(localeString);
	
	memset(forward_argv, 0, forward_argc);
	
	forward_argc = 18;
	forward_argv = (char **)realloc(forward_argv, forward_argc * sizeof(char *));
	//forward_argv[i] = malloc( (strlen(argv[i])+1) * sizeof(char));
	forward_argv[ 1] = forward_argv[0];	// (UNUSED)
	forward_argv[ 2] = "320";			// cScreenWidth (NO EFFECT)
	forward_argv[ 3] = "480";			// cScreenHeight (NO EFFECT)
	forward_argv[ 4] = "32";			// cBitsStr
	forward_argv[ 5] = IPC_PORT_STR;	// ipcPort;
	forward_argv[ 6] = "1";				// cFullScreen (NO EFFECT)
	forward_argv[ 7] = "0";				// isSoundEnabled (TOSET)
	forward_argv[ 8] = "1";				// cVSyncInUse (UNUSED)
	forward_argv[ 9] = [localeString UTF8String];		// cLocaleFName
	forward_argv[10] = "100";			// cInitVolume (TOSET)
	forward_argv[11] = "8";				// cTimerInterval
	forward_argv[12] = "Data";			// PathPrefix
	forward_argv[13] = "1";				// cShowFPS (TOSET?)
	forward_argv[14] = "0";				// cAltDamage (TOSET)
	forward_argv[15] = "Koda";			// UserNick (DecodeBase64(ParamStr(15)) FTW) <- TODO
	forward_argv[16] = "0";				// isMusicEnabled (TOSET)
	forward_argv[17] = "0";				// cReducedQuality

fprintf(stderr, forward_argv[9]);
	return;
}


/*
 -(void) dealloc {
	[super dealloc];
}
 */


@end
