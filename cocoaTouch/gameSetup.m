//
//  gameSetup.m
//  hwengine
//
//  Created by Vittorio on 10/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>

#import "GameSetup.h"
#import "SDL_uikitappdelegate.h"
#import "SDL_net.h"
#import "PascalImports.h"
#import "CommodityFunctions.h"

#define BUFFER_SIZE 256
#define debug(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);

@implementation GameSetup

@synthesize systemSettings, gameConfig;

-(id) init {
	if (self = [super init]) {
    	srandom(time(NULL));
        ipcPort = randomPort();
        
        NSDictionary *dictSett = [[NSDictionary alloc] initWithContentsOfFile:SETTINGS_FILE()]; //should check it exists
        self.systemSettings = dictSett;
        [dictSett release];
        
        NSDictionary *dictGame = [[NSDictionary alloc] initWithContentsOfFile:GAMECONFIG_FILE()];
        self.gameConfig = dictGame;
        [dictGame release];
    } 
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"ipcport: %d\nsockets: %d,%d\n teams: %@\n systemSettings: %@",ipcPort,sd,csd,gameConfig,systemSettings];
}

-(void) dealloc {
    [gameConfig release];
    [systemSettings release];
	[super dealloc];
}

#pragma mark -
#pragma mark Thread/Network relevant code
-(void) startThread: (NSString *) selector {
	SEL usage = NSSelectorFromString(selector);
	[NSThread detachNewThreadSelector:usage toTarget:self withObject:nil];
}

-(int) sendToEngine: (NSString *)string {
	unsigned char length = [string length];
	
	SDLNet_TCP_Send(csd, &length , 1);
	return SDLNet_TCP_Send(csd, [string UTF8String], length);
}

-(void) sendTeamData:(NSString *)fileName withPlayingHogs:(NSInteger) playingHogs ofColor:(NSNumber *)color{    
    NSString *teamFile = [[NSString alloc] initWithFormat:@"%@/%@", TEAMS_DIRECTORY(), fileName];
    NSDictionary *teamData = [[NSDictionary alloc] initWithContentsOfFile:teamFile];
    [teamFile release];
    
    NSString *teamHashColorAndName = [[NSString alloc] initWithFormat:@"eaddteam %@ %@ %@", [teamData objectForKey:@"hash"], [color stringValue], [teamData objectForKey:@"teamname"]];
    [self sendToEngine: teamHashColorAndName];
    [teamHashColorAndName release];
    
    NSString *grave = [[NSString alloc] initWithFormat:@"egrave %@", [teamData objectForKey:@"grave"]];
    [self sendToEngine: grave];
    [grave release];
    
    NSString *fort = [[NSString alloc] initWithFormat:@"efort %@", [teamData objectForKey:@"fort"]];
    [self sendToEngine: fort];
    [fort release];
    
    NSString *voicepack = [[NSString alloc] initWithFormat:@"evoicepack %@", [teamData objectForKey:@"voicepack"]];
    [self sendToEngine: voicepack];
    [voicepack release];
    
    NSString *flag = [[NSString alloc] initWithFormat:@"eflag %@", [teamData objectForKey:@"flag"]];
    [self sendToEngine: flag];
    [flag release];
    
    NSArray *hogs = [teamData objectForKey:@"hedgehogs"];
    for (int i = 0; i < playingHogs; i++) {
        NSDictionary *hog = [hogs objectAtIndex:i];
        
        NSString *hogLevelHealthAndName = [[NSString alloc] initWithFormat:@"eaddhh %@ %@ %@", [hog objectForKey:@"level"], [hog objectForKey:@"health"], [hog objectForKey:@"hogname"]];
        [self sendToEngine: hogLevelHealthAndName];
        [hogLevelHealthAndName release];
        
        NSString *hogHat = [[NSString alloc] initWithFormat:@"ehat %@", [hog objectForKey:@"hat"]];
        [self sendToEngine: hogHat];
        [hogHat release];
    }
    
    [teamData release];
}

-(void) sendAmmoData:(NSDictionary *)ammoData forTeams: (NSInteger)numberPlaying {
    NSString *ammloadt = [[NSString alloc] initWithFormat:@"eammloadt %@", [ammoData objectForKey:@"ammostore_initialqt"]];
    [self sendToEngine: ammloadt];
    [ammloadt release];
    
    NSString *ammdelay = [[NSString alloc] initWithFormat:@"eammprob %@", [ammoData objectForKey:@"ammostore_probability"]];
    [self sendToEngine: ammdelay];
    [ammdelay release];
    
    NSString *ammprob = [[NSString alloc] initWithFormat:@"eammdelay %@", [ammoData objectForKey:@"ammostore_delay"]];
    [self sendToEngine: ammprob];
    [ammprob release];
    
    NSString *ammreinf = [[NSString alloc] initWithFormat:@"eammreinf %@", [ammoData objectForKey:@"ammostore_crate"]];
    [self sendToEngine: ammreinf];
    [ammreinf release];
    
    // sent twice so it applies to both teams
    NSString *ammstore = [[NSString alloc] initWithString:@"eammstore"];
    for (int i = 0; i < numberPlaying; i++)
        [self sendToEngine: ammstore];
    [ammstore release];
}

-(void) engineProtocol {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	IPaddress ip;
	int eProto;
	BOOL clientQuit, serverQuit;
	char buffer[BUFFER_SIZE], string[BUFFER_SIZE];
	Uint8 msgSize;
	Uint16 gameTicks;

    serverQuit = NO;

	if (SDLNet_Init() < 0) {
		NSLog(@"SDLNet_Init: %s", SDLNet_GetError());
        serverQuit = YES;
	}
	
	/* Resolving the host using NULL make network interface to listen */
	if (SDLNet_ResolveHost(&ip, NULL, ipcPort) < 0) {
		NSLog(@"SDLNet_ResolveHost: %s\n", SDLNet_GetError());
        serverQuit = YES;
	}
	
	/* Open a connection with the IP provided (listen on the host's port) */
	if (!(sd = SDLNet_TCP_Open(&ip))) {
		NSLog(@"SDLNet_TCP_Open: %s %\n", SDLNet_GetError(), ipcPort);
        serverQuit = YES;
	}
	
	NSLog(@"engineProtocol - Waiting for a client on port %d", ipcPort);
	while (!serverQuit) {
		
		/* This check the sd if there is a pending connection.
		 * If there is one, accept that, and open a new socket for communicating */
		csd = SDLNet_TCP_Accept(sd);
		if (NULL != csd) {
			
			NSLog(@"engineProtocol - Client found");
			
			//first byte of the command alwayas contain the size of the command
			SDLNet_TCP_Recv(csd, &msgSize, sizeof(Uint8));
			
			SDLNet_TCP_Recv(csd, buffer, msgSize);
			gameTicks = SDLNet_Read16(&buffer[msgSize - 2]);
			//NSLog(@"engineProtocol - %d: received [%s]", gameTicks, buffer);
			
			if ('C' == buffer[0]) {
				NSLog(@"engineProtocol - sending game config");
                
				// send config data data
				/*
				seed is arbitrary string
				addteam <32charsMD5hash> <color> <team name>
				addhh <level> <health> <hedgehog name>
				  <level> is 0 for human, 1-5 for bots (5 is the most stupid)
				*/
				// local game
				[self sendToEngine:@"TL"];
				
				// seed info
				[self sendToEngine:[self.gameConfig objectForKey:@"seed_command"]];
				
				// various flags
				[self sendToEngine:@"e$gmflags 256"]; 
				[self sendToEngine:@"e$damagepct 100"];
				[self sendToEngine:@"e$turntime 45000"];
				[self sendToEngine:@"e$minestime 3000"];
				[self sendToEngine:@"e$landadds 4"];
				[self sendToEngine:@"e$sd_turns 15"];
				[self sendToEngine:@"e$casefreq 5"];

				// dimension of the map
				[self sendToEngine:[self.gameConfig objectForKey:@"templatefilter_command"]];
				[self sendToEngine:[self.gameConfig objectForKey:@"mapgen_command"]];
				[self sendToEngine:[self.gameConfig objectForKey:@"mazesize_command"]];
								
				// theme info
				[self sendToEngine:@"etheme Compost"];
				
                NSArray *teamsConfig = [self.gameConfig objectForKey:@"teams_list"];
                for (NSDictionary *teamData in teamsConfig) {
                    [self sendTeamData:[teamData objectForKey:@"team"] 
                       withPlayingHogs:[[teamData objectForKey:@"number"] intValue]
                               ofColor:[teamData objectForKey:@"color"]];
                    NSLog(@"teamData sent");
                }
                
                NSDictionary *ammoData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          @"9391929422199121032235111001201000000211190",@"ammostore_initialqt",
                                          @"0405040541600655546554464776576666666155501",@"ammostore_probability",
                                          @"0000000000000205500000040007004000000000200",@"ammostore_delay",
                                          @"1311110312111111123114111111111111111211101",@"ammostore_crate", nil];
                [self sendAmmoData:ammoData forTeams:[teamsConfig count]];
                [ammoData release];
                
                clientQuit = NO;
			} else {
				NSLog(@"engineProtocolThread - wrong message or client closed connection");
				clientQuit = YES;
			}
			
			while (!clientQuit){
				/* Now we can communicate with the client using csd socket
				 * sd will remain opened waiting other connections */
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
						[self sendToEngine:@"!"];
						break;
					case 'E':
						NSLog(@"ERROR - last console line: [%s]", buffer);
						clientQuit = YES;
						break;
					case 'e':
						sscanf(buffer, "%*s %d", &eProto);
						short int netProto = 0;
						char *versionStr;
						
                        HW_versionInfo(&netProto, &versionStr);
						if (netProto == eProto) {
							NSLog(@"Setting protocol version %d (%s)", eProto, versionStr);
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
			NSLog(@"Engine exited, closing server");
			// wait a little to let the client close cleanly
			[NSThread sleepForTimeInterval:2];
			// Close the client socket
			SDLNet_TCP_Close(csd);
			serverQuit = YES;
		}
	}
	
	SDLNet_TCP_Close(sd);
	SDLNet_Quit();

    [[NSFileManager defaultManager] removeItemAtPath:GAMECONFIG_FILE() error:NULL];
    
	[pool release];
	[NSThread exit];
}

#pragma mark -
#pragma mark Setting methods
-(const char **)getSettings {
	NSString *ipcString = [[NSString alloc] initWithFormat:@"%d", ipcPort];
	NSString *localeString = [[NSString alloc] initWithFormat:@"%@.txt", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString *wSize = [[NSString alloc] initWithFormat:@"%d", (int) screenBounds.size.width];
    NSString *hSize = [[NSString alloc] initWithFormat:@"%d", (int) screenBounds.size.height];
	const char **gameArgs = (const char**) malloc(sizeof(char *) * 8);

    /*
    size_t size;
    // Set 'oldp' parameter to NULL to get the size of the data returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
    char *name = malloc(size);
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    NSString *machine = [[NSString alloc] initWithUTF8String:name];
    free(name);
    
   	const char **gameArgs = (const char**) malloc(sizeof(char*) * 9);

    // if the machine is less than iphone 3gs or less than ipod touch 3g use reduced graphics (land array)
    if ([machine hasPrefix:@"iPhone1"] || ([machine hasPrefix:@"iPod"] && ([machine hasSuffix:@"1,1"] || [machine hasSuffix:@"2,1"])))
        gameArgs[8] = "1";
    else
        gameArgs[8] = "0";
    [machine release];
    */
    
    // prevents using an empty nickname
    NSString *username;
    NSString *originalUsername = [self.systemSettings objectForKey:@"username"];
    if ([originalUsername length] == 0) {
        username = [[NSString alloc] initWithFormat:@"MobileUser-%@",ipcString];
    } else {
        username = [[NSString alloc] initWithString:originalUsername];
    }
    
	gameArgs[0] = [username UTF8String];                                                        //UserNick
	gameArgs[1] = [ipcString UTF8String];                                                       //ipcPort
	gameArgs[2] = [[[self.systemSettings objectForKey:@"sound"] stringValue] UTF8String];       //isSoundEnabled
	gameArgs[3] = [[[self.systemSettings objectForKey:@"music"] stringValue] UTF8String];       //isMusicEnabled
	gameArgs[4] = [localeString UTF8String];                                                    //cLocaleFName
	gameArgs[5] = [[[self.systemSettings objectForKey:@"alternate"] stringValue] UTF8String];	//cAltDamage
	gameArgs[6] = [wSize UTF8String];                                                           //cScreenHeight
    gameArgs[7] = [hSize UTF8String];                                                           //cScreenWidth
    
    [wSize release];
    [hSize release];
	[localeString release];
	[ipcString release];
    [username release];
	return gameArgs;
}


@end
