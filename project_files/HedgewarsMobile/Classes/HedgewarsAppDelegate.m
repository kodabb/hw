/*
 * Hedgewars-iOS, a Hedgewars port for iOS devices
 * Copyright (c) 2009-2012 Vittorio Giovara <vittorio.giovara@gmail.com>
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
 * File created on 13/03/2012.
 */


#import "HedgewarsAppDelegate.h"
#import "MainMenuViewController.h"
#import "ObjcExports.h"
#include <unistd.h>


@implementation SDLUIKitDelegate (customDelegate)

+(NSString *)getAppDelegateClassName {
    return @"HedgewarsAppDelegate";
}

@end

@implementation HedgewarsAppDelegate
@synthesize mainViewController, uiwindow;

#pragma mark -
#pragma mark AppDelegate methods
-(id) init {
    if (self = [super init]){
        mainViewController = nil;
        uiwindow = nil;
    }
    return self;
}

-(void) dealloc {
    [mainViewController release];
    [uiwindow release];
    [super dealloc];
}

// override the direct execution of SDL_main to allow us to implement our own frontend
-(void) postFinishLaunch {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    self.uiwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSString *controllerName = (IS_IPAD() ? @"MainMenuViewController-iPad" : @"MainMenuViewController-iPhone");
    self.mainViewController = [[MainMenuViewController alloc] initWithNibName:controllerName bundle:nil];

    [self.uiwindow addSubview:self.mainViewController.view];
    [self.mainViewController release];
    self.uiwindow.backgroundColor = [UIColor blackColor];
    [self.uiwindow makeKeyAndVisible];
}

-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [HWUtils releaseCache];
    // don't stop music if it is playing
    if ([HWUtils isGameLaunched]) {
        [AudioManagerController releaseCache];
        HW_memoryWarningCallback();
    }
    MSG_MEMCLEAN();
    // don't clean mainMenuViewController here!!!
}

// true multitasking with sdl works only on 4.2 and above; we close the game to avoid a black screen at return
-(void) applicationWillResignActive:(UIApplication *)application {
    if ([HWUtils isGameLaunched] && [[[UIDevice currentDevice] systemVersion] floatValue] < 4.2f)
         HW_terminate(NO);

    [super applicationWillResignActive:application];
}

@end
