/*
 * Hedgewars-iOS, a Hedgewars port for iOS devices
 * Copyright (c) 2009-2011 Vittorio Giovara <vittorio.giovara@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * File created on 12/11/2010.
 */


#import "CreationChamber.h"
#import "hwconsts.h"


@implementation CreationChamber

#pragma mark Settings
+(void) createSettings {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:[NSNumber numberWithBool:NO] forKey:@"alternate"];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"music"];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"sound"];
    [settings setObject:[NSNumber numberWithBool:NO] forKey:@"classic_menu"];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"sync_ws"];

    // don't overwrite these two strings when present
    if ([settings objectForKey:@"username"] == nil)
        [settings setObject:@"" forKey:@"username"];
    if ([settings objectForKey:@"password"] == nil)
        [settings setObject:@"" forKey:@"password"];

    [settings synchronize];
}

#pragma mark Teams
+(void) createTeamNamed:(NSString *)nameWithoutExt {
    [CreationChamber createTeamNamed:nameWithoutExt ofType:0 controlledByAI:NO];
}

+(void) createTeamNamed:(NSString *)nameWithoutExt ofType:(NSInteger) type {
    [CreationChamber createTeamNamed:nameWithoutExt ofType:type controlledByAI:NO];
}

+(void) createTeamNamed:(NSString *)nameWithoutExt ofType:(NSInteger) type controlledByAI:(BOOL) shouldAITakeOver {
    NSString *teamsDirectory = TEAMS_DIRECTORY();

    if (![[NSFileManager defaultManager] fileExistsAtPath: teamsDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:teamsDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:NULL];
    }

    NSArray *customNames;
    NSArray *customHats;
    NSString *flag, *grave, *voicepack, *fort;
    switch (type) {
        default: // default
            customNames = [[NSArray alloc] initWithObjects:@"No Name",@"Unnamed",@"Anonymous",@"Nameless",@"Incognito",@"Unidentified",
                           @"Uknown",@"Secret",nil];
            customHats = [[NSArray alloc] initWithObjects:@"NoHat",@"NoHat",@"NoHat",@"NoHat",@"NoHat",@"NoHat",@"NoHat",@"NoHat",nil];
            flag = @"hedgewars";
            grave = @"Statue";
            voicepack = @"Default";
            fort = @"Plane";
            break;
        case 1:  // ninjas
            customNames = [[NSArray alloc] initWithObjects:@"Shinobi",@"Ukemi",@"Godai",@"Ninpo",@"Tatsujin",@"Arashi",@"Bushi",@"Itami",nil];
            customHats = [[NSArray alloc] initWithObjects:@"NinjaFull",@"NinjaStraight",@"NinjaTriangle",@"NinjaFull",@"NinjaStraight",
                          @"NinjaTriangle",@"NinjaFull",@"NinjaTriangle",nil];
            flag = @"japan";
            grave = @"bp2";
            voicepack = @"Singer";
            fort = @"Wood";
            break;
        case 2: // pirates
            customNames = [[NSArray alloc] initWithObjects:@"Toothless Wayne",@"Long-nose Kidd",@"Eye-patch Jim",@"Rackham Blood",@"One-eyed Ayee",
                           @"Dirty Ben",@"Morris",@"Cruise Seymour",nil];
            customHats = [[NSArray alloc] initWithObjects:@"pirate_jack_bandana",@"pirate_jack",@"dwarf",@"pirate_jack_bandana",@"pirate_jack",
                          @"dwarf",@"pirate_jack_bandana",@"pirate_jack",nil];
            flag = @"cm_pirate";
            grave = @"chest";
            voicepack = @"Pirate";
            fort = @"Hydrant";
            break;
        case 3: // robots
            customNames = [[NSArray alloc] initWithObjects:@"HAL",@"R2-D2",@"Wall-E",@"Robocop",@"Optimus Prime",@"Terminator",@"C-3PO",@"KITT",nil];
            customHats = [[NSArray alloc] initWithObjects:@"cyborg1",@"cyborg2",@"cyborg1",@"cyborg2",@"cyborg1",@"cyborg2",@"cyborg1",
                          @"cyborg2",nil];
            flag = @"cm_binary";
            grave = @"Rip";
            voicepack = @"Robot";
            fort = @"UFO";
            break;
    }

    NSMutableArray *hedgehogs = [[NSMutableArray alloc] initWithCapacity:HW_getMaxNumberOfHogs()];
    for (int i = 0; i < HW_getMaxNumberOfHogs(); i++) {
        NSDictionary *hog = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithInt:(shouldAITakeOver ? 4 : 0)],@"level",
                             [customNames objectAtIndex:i],@"hogname",
                             [customHats objectAtIndex:i],@"hat",
                             nil];
        [hedgehogs addObject:hog];
        [hog release];
    }
    [customHats release];
    [customNames release];

    NSDictionary *theTeam = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"0",@"hash",
                             grave,@"grave",
                             fort,@"fort",
                             voicepack,@"voicepack",
                             flag,@"flag",
                             hedgehogs,@"hedgehogs",
                             nil];
    [hedgehogs release];

    NSString *teamFile = [[NSString alloc] initWithFormat:@"%@/%@.plist", teamsDirectory, nameWithoutExt];

    [theTeam writeToFile:teamFile atomically:YES];
    [teamFile release];
    [theTeam release];
}

#pragma mark Weapons
+(void) createWeaponNamed:(NSString *)nameWithoutExt {
    [CreationChamber createWeaponNamed:nameWithoutExt ofType:0];
}

+(void) createWeaponNamed:(NSString *)nameWithoutExt ofType:(NSInteger) type {
    NSString *weaponsDirectory = WEAPONS_DIRECTORY();

    if (![[NSFileManager defaultManager] fileExistsAtPath: weaponsDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:weaponsDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:NULL];
    }

    NSInteger ammolineSize = HW_getNumberOfWeapons();
    NSString *qt, *prob, *delay, *crate;
    switch (type) {
        default: //default
            qt = [[NSString alloc] initWithBytes:AMMOLINE_DEFAULT_QT length:ammolineSize encoding:NSUTF8StringEncoding];
            prob = [[NSString alloc] initWithBytes:AMMOLINE_DEFAULT_PROB length:ammolineSize encoding:NSUTF8StringEncoding];
            delay = [[NSString alloc] initWithBytes:AMMOLINE_DEFAULT_DELAY length:ammolineSize encoding:NSUTF8StringEncoding];
            crate = [[NSString alloc] initWithBytes:AMMOLINE_DEFAULT_CRATE length:ammolineSize encoding:NSUTF8StringEncoding];
            break;
        case 1:  //crazy
            qt = [[NSString alloc] initWithBytes:AMMOLINE_CRAZY_QT length:ammolineSize encoding:NSUTF8StringEncoding];
            prob = [[NSString alloc] initWithBytes:AMMOLINE_CRAZY_PROB length:ammolineSize encoding:NSUTF8StringEncoding];
            delay = [[NSString alloc] initWithBytes:AMMOLINE_CRAZY_DELAY length:ammolineSize encoding:NSUTF8StringEncoding];
            crate = [[NSString alloc] initWithBytes:AMMOLINE_CRAZY_CRATE length:ammolineSize encoding:NSUTF8StringEncoding];
            break;
        case 2:  //pro mode
            qt = [[NSString alloc] initWithBytes:AMMOLINE_PROMODE_QT length:ammolineSize encoding:NSUTF8StringEncoding];
            prob = [[NSString alloc] initWithBytes:AMMOLINE_PROMODE_PROB length:ammolineSize encoding:NSUTF8StringEncoding];
            delay = [[NSString alloc] initWithBytes:AMMOLINE_PROMODE_DELAY length:ammolineSize encoding:NSUTF8StringEncoding];
            crate = [[NSString alloc] initWithBytes:AMMOLINE_PROMODE_CRATE length:ammolineSize encoding:NSUTF8StringEncoding];
            break;
        case 3:  //shoppa
            qt = [[NSString alloc] initWithBytes:AMMOLINE_SHOPPA_QT length:ammolineSize encoding:NSUTF8StringEncoding];
            prob = [[NSString alloc] initWithBytes:AMMOLINE_SHOPPA_PROB length:ammolineSize encoding:NSUTF8StringEncoding];
            delay = [[NSString alloc] initWithBytes:AMMOLINE_SHOPPA_DELAY length:ammolineSize encoding:NSUTF8StringEncoding];
            crate = [[NSString alloc] initWithBytes:AMMOLINE_SHOPPA_CRATE length:ammolineSize encoding:NSUTF8StringEncoding];
            break;
        case 4:  //clean slate
            qt = [[NSString alloc] initWithBytes:AMMOLINE_CLEAN_QT length:ammolineSize encoding:NSUTF8StringEncoding];
            prob = [[NSString alloc] initWithBytes:AMMOLINE_CLEAN_PROB length:ammolineSize encoding:NSUTF8StringEncoding];
            delay = [[NSString alloc] initWithBytes:AMMOLINE_CLEAN_DELAY length:ammolineSize encoding:NSUTF8StringEncoding];
            crate = [[NSString alloc] initWithBytes:AMMOLINE_CLEAN_CRATE length:ammolineSize encoding:NSUTF8StringEncoding];
            break;
        case 5:  //minefield
            qt = [[NSString alloc] initWithBytes:AMMOLINE_MINES_QT length:ammolineSize encoding:NSUTF8StringEncoding];
            prob = [[NSString alloc] initWithBytes:AMMOLINE_MINES_PROB length:ammolineSize encoding:NSUTF8StringEncoding];
            delay = [[NSString alloc] initWithBytes:AMMOLINE_MINES_DELAY length:ammolineSize encoding:NSUTF8StringEncoding];
            crate = [[NSString alloc] initWithBytes:AMMOLINE_MINES_CRATE length:ammolineSize encoding:NSUTF8StringEncoding];
            break;
        case 6:  //thinking with portals
            qt = [[NSString alloc] initWithBytes:AMMOLINE_PORTALS_QT length:ammolineSize encoding:NSUTF8StringEncoding];
            prob = [[NSString alloc] initWithBytes:AMMOLINE_PORTALS_PROB length:ammolineSize encoding:NSUTF8StringEncoding];
            delay = [[NSString alloc] initWithBytes:AMMOLINE_PORTALS_DELAY length:ammolineSize encoding:NSUTF8StringEncoding];
            crate = [[NSString alloc] initWithBytes:AMMOLINE_PORTALS_CRATE length:ammolineSize encoding:NSUTF8StringEncoding];
            break;
    }

    NSDictionary *theWeapon = [[NSDictionary alloc] initWithObjectsAndKeys: qt,@"ammostore_initialqt",
                               prob,@"ammostore_probability", delay,@"ammostore_delay", crate,@"ammostore_crate", nil];
    [qt release];
    [prob release];
    [delay release];
    [crate release];

    NSString *weaponFile = [[NSString alloc] initWithFormat:@"%@/%@.plist", weaponsDirectory, nameWithoutExt];
    [theWeapon writeToFile:weaponFile atomically:YES];
    [weaponFile release];
    [theWeapon release];
}

#pragma mark Schemes
+(void) createSchemeNamed:(NSString *)nameWithoutExt {
    [CreationChamber createSchemeNamed:nameWithoutExt ofType:0];
}

+(void) createSchemeNamed:(NSString *)nameWithoutExt ofType:(NSInteger) type {
    NSString *schemesDirectory = SCHEMES_DIRECTORY();

    if (![[NSFileManager defaultManager] fileExistsAtPath: schemesDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:schemesDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:NULL];
    }

    // load data to get the size of the arrays and their default values
    NSArray *basicSettings = [[NSArray alloc] initWithContentsOfFile:BASICFLAGS_FILE()];
    NSMutableArray *basicArray  = [[NSMutableArray alloc] initWithCapacity:[basicSettings count]];
    for (NSDictionary *basicDict in basicSettings)
        [basicArray addObject:[basicDict objectForKey:@"default"]];
    [basicSettings release];

    NSArray *mods = [[NSArray alloc] initWithContentsOfFile:GAMEMODS_FILE()];
    NSMutableArray *gamemodArray= [[NSMutableArray alloc] initWithCapacity:[mods count]];
    for (int i = 0; i < [mods count]; i++)
        [gamemodArray addObject:[NSNumber numberWithBool:NO]];
    [mods release];

    switch (type) {
        default: // default
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 1:  // pro mode
            [basicArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:15]];
            [basicArray replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:0]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:14 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 2:  // shoppa
            [basicArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:30]];
            [basicArray replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:50]];
            [basicArray replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:1]];
            [basicArray replaceObjectAtIndex:8 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:9 withObject:[NSNumber numberWithInt:25]];
            [basicArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:0]];
            [gamemodArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:14 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:15 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:19 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 3:  // clean slate
            [gamemodArray replaceObjectAtIndex:6 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:18 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:19 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 4:  // minefield
            [basicArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:50]];
            [basicArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:30]];
            [basicArray replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:10 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:80]];
            [basicArray replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:0]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:14 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:15 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 5:  // barrel mayhem
            [basicArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:30]];
            [basicArray replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:10 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:40]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:14 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 6:  // tunnel hogs
            [basicArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:30]];
            [basicArray replaceObjectAtIndex:9 withObject:[NSNumber numberWithInt:3]];
            [basicArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:10]];
            [basicArray replaceObjectAtIndex:12 withObject:[NSNumber numberWithInt:10]];
            [basicArray replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:10]];
            [gamemodArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:14 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:15 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:16 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 7:  // fort mode
            [basicArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:0]];
            [gamemodArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:10 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 8:  // timeless
            [basicArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:100]];
            [basicArray replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:0]];
            [basicArray replaceObjectAtIndex:9 withObject:[NSNumber numberWithInt:30]];
            [basicArray replaceObjectAtIndex:10 withObject:[NSNumber numberWithInt:5]];
            [basicArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:3]];
            [basicArray replaceObjectAtIndex:12 withObject:[NSNumber numberWithInt:10]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:20 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 9:  // thinking with portals
            [basicArray replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:2]];
            [basicArray replaceObjectAtIndex:8 withObject:[NSNumber numberWithInt:25]];
            [basicArray replaceObjectAtIndex:10 withObject:[NSNumber numberWithInt:4]];
            [basicArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:5]];
            [basicArray replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:5]];
            [gamemodArray replaceObjectAtIndex:9 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            break;
        case 10: // king mode
            [gamemodArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithBool:YES]];
            [gamemodArray replaceObjectAtIndex:12 withObject:[NSNumber numberWithBool:YES]];
            break;
    }

    NSMutableDictionary *theScheme = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      basicArray,@"basic",
                                      gamemodArray,@"gamemod",
                                      nil];
    [gamemodArray release];
    [basicArray release];

    NSString *schemeFile = [[NSString alloc] initWithFormat:@"%@/%@.plist", schemesDirectory, nameWithoutExt];
    
    [theScheme writeToFile:schemeFile atomically:YES];
    [schemeFile release];
    [theScheme release];
}

@end
