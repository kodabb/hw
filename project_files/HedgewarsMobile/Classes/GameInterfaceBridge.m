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
 * File created on 18/04/2011.
 */


#import "GameInterfaceBridge.h"
#import "EngineProtocolNetwork.h"
#import "OverlayViewController.h"
#import "StatsPageViewController.h"
#import "AudioManagerController.h"
#import "ObjcExports.h"

@implementation GameInterfaceBridge

-(id) initWithController:(id) viewController {
    if (self = [super init]) {
    }
    return self;
}

-(void) dealloc {
    [super dealloc];
}

#pragma mark -
// main routine for calling the actual game engine
-(void) engineLaunchOn:(NSInteger) ipcPort withArgument:(NSString *)path {
    const char *gameArgs[11];
    CGFloat width, height;
    CGFloat screenScale = [[UIScreen mainScreen] safeScale];
    NSString *ipcString = [[NSString alloc] initWithFormat:@"%d",ipcPort];
    NSString *localeString = [[NSString alloc] initWithFormat:@"%@.txt", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

    if (IS_DUALHEAD()) {
        CGRect screenBounds = [[[UIScreen screens] objectAtIndex:1] bounds];
        width = screenBounds.size.width;
        height = screenBounds.size.height;
    } else {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        width = screenBounds.size.height;
        height = screenBounds.size.width;
    }

    NSString *horizontalSize = [[NSString alloc] initWithFormat:@"%d", (int)(width * screenScale)];
    NSString *verticalSize = [[NSString alloc] initWithFormat:@"%d", (int)(height * screenScale)];
    NSString *rotation = [[NSString alloc] initWithString:@"0"];

    NSString *modelId = [HWUtils modelType];
    NSInteger tmpQuality;
    if ([modelId hasPrefix:@"iPhone1"] || [modelId hasPrefix:@"iPod1,1"] || [modelId hasPrefix:@"iPod2,1"])     // = iPhone and iPhone 3G or iPod Touch or iPod Touch 2G
        tmpQuality = 0x00000001 | 0x00000002 | 0x00000008 | 0x00000040;                 // rqLowRes | rqBlurryLand | rqSimpleRope | rqKillFlakes
    else if ([modelId hasPrefix:@"iPhone2"] || [modelId hasPrefix:@"iPod3"])                                    // = iPhone 3GS or iPod Touch 3G
        tmpQuality = 0x00000002 | 0x00000040;                                           // rqBlurryLand | rqKillFlakes
    else if ([modelId hasPrefix:@"iPad1"] || [modelId hasPrefix:@"iPod4"])                                      // = iPad 1G or iPod Touch 4G
        tmpQuality = 0x00000002;                                                        // rqBlurryLand
    else                                                                                                        // = everything else
        tmpQuality = 0;                                                                 // full quality

    // disable tooltips on iPhone
    if (IS_IPAD() == NO)
        tmpQuality = tmpQuality | 0x00000400;

    // prevents using an empty nickname
    NSString *username = [settings objectForKey:@"username"];
    if ([username length] == 0)
        username = [NSString stringWithFormat:@"MobileUser-%@",ipcString];

    gameArgs[ 0] = [ipcString UTF8String];                                                      //ipcPort
    gameArgs[ 1] = [horizontalSize UTF8String];                                                 //cScreenWidth
    gameArgs[ 2] = [verticalSize UTF8String];                                                   //cScreenHeight
    gameArgs[ 3] = [[NSString stringWithFormat:@"%d",tmpQuality] UTF8String];                   //quality
    gameArgs[ 4] = "en.txt";//[localeString UTF8String];                                        //cLocaleFName
    gameArgs[ 5] = [username UTF8String];                                                       //UserNick
    gameArgs[ 6] = [[[settings objectForKey:@"sound"] stringValue] UTF8String];                 //isSoundEnabled
    gameArgs[ 7] = [[[settings objectForKey:@"music"] stringValue] UTF8String];                 //isMusicEnabled
    gameArgs[ 8] = [[[settings objectForKey:@"alternate"] stringValue] UTF8String];             //cAltDamage
    gameArgs[ 9] = [rotation UTF8String];                                                       //rotateQt
    gameArgs[10] = ([HWUtils gameType] == gtSave) ? [path UTF8String] : NULL;                   //recordFileName

    [verticalSize release];
    [horizontalSize release];
    [rotation release];
    [localeString release];
    [ipcString release];

    [HWUtils setGameStatus:gsLoading];

    // this is the pascal function that starts the game
    Game(gameArgs);
}

// prepares the controllers for hosting a game
-(void) prepareEngineOn:(NSString *)pathOrNil withOptions:(NSDictionary *)optionsOrNil {
    EngineProtocolNetwork *proto = [[EngineProtocolNetwork alloc] init];
    NSInteger ipcPort = [proto spawnThread:pathOrNil withOptions:optionsOrNil];

    CGRect theFrame = [[UIScreen mainScreen] bounds];
    UIWindow *thisWindow = [[HedgewarsAppDelegate sharedAppDelegate] uiwindow];
    // we add a black view hiding the background
    UIView *blackView = [[UIView alloc] initWithFrame:theFrame];
    [thisWindow addSubview:blackView];
    blackView.opaque = YES;
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0;

    // when dual screen we apply a little transition
    if (IS_DUALHEAD()) {
        [UIView beginAnimations:@"fade out" context:NULL];
        [UIView setAnimationDuration:1];
        blackView.alpha = 1;
        [UIView commitAnimations];
    } else
        blackView.alpha = 1;

    // keep track of uncompleted games
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:pathOrNil forKey:@"savedGamePath"];
    [userDefaults synchronize];

    [AudioManagerController pauseBackgroundMusic];

    // SYSTEMS ARE GO!!
    [self engineLaunchOn:ipcPort withArgument:pathOrNil];
    
    // remove completed games notification
    [userDefaults setObject:@"" forKey:@"savedGamePath"];
    [userDefaults synchronize];

    // now we can remove the cover with a transition
    blackView.frame = theFrame;
    blackView.alpha = 1;
    [UIView beginAnimations:@"fade in" context:NULL];
    [UIView setAnimationDuration:1];
    blackView.alpha = 0;
    [UIView commitAnimations];
    [blackView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
    [blackView release];

    // the overlay is not needed any more and can be removed
    [[OverlayViewController mainOverlay] removeOverlay];

    [AudioManagerController playBackgroundMusic];
}

// set up variables for a local game
-(void) startLocalGame:(NSDictionary *)withOptions {
    [HWUtils setGameType:gtLocal];

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd '@' HH.mm"];
    NSString *savePath = [[NSString alloc] initWithFormat:@"%@%@.hws",SAVES_DIRECTORY(),[outputFormatter stringFromDate:[NSDate date]]];
    [outputFormatter release];

    // in the rare case in which a savefile with the same name exists the older one must be removed (or it gets corrupted)
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath])
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];

    [self prepareEngineOn:savePath withOptions:withOptions];
    [savePath release];
}

// set up variables for a save game
-(void) startSaveGame:(NSString *)atPath {
    [HWUtils setGameType:gtSave];
    [self prepareEngineOn:atPath withOptions:nil];
}

-(void) startMissionGame:(NSString *)withScript {
    [HWUtils setGameType:gtMission];

    NSString *missionPath = [[NSString alloc] initWithFormat:@"escript Missions/Training/%@.lua",withScript];
    NSDictionary *missionLine = [[NSDictionary alloc] initWithObjectsAndKeys:missionPath,@"mission_command",nil];
    [missionPath release];

    [self prepareEngineOn:nil withOptions:missionLine];
    [missionLine release];
}

/*
-(void) gameHasEndedWithStats:(NSArray *)stats {
    // wrap this around a retain/realse to prevent being deallocated too soon
    [self retain];
    // display stats page if there is something to display
    if (stats != nil) {
        StatsPageViewController *statsPage = [[StatsPageViewController alloc] initWithStyle:UITableViewStyleGrouped];
        statsPage.statsArray = stats;
        statsPage.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        if ([statsPage respondsToSelector:@selector(setModalPresentationStyle:)])
            statsPage.modalPresentationStyle = UIModalPresentationPageSheet;

        [self.parentController presentModalViewController:statsPage animated:YES];
        [statsPage release];
    }

    // can remove the savefile if the replay has ended
    if ([HWUtils gameType] == gtSave)
        [[NSFileManager defaultManager] removeItemAtPath:self.savePath error:nil];
    [self release];
}
*/

@end
