/*
 SDL - Simple DirectMedia Layer
 Copyright (C) 1997-2009 Sam Lantinga
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 Sam Lantinga, mods for Hedgewars by Vittorio Giovara
 slouken@libsdl.org, vittorio.giovara@gmail.com
*/

#import <pthread.h>
#import "SDL_uikitappdelegate.h"
#import "SDL_uikitopenglview.h"
#import "SDL_events_c.h"
#import "jumphack.h"
#import "SDL_video.h"
#import "GameSetup.h"
#import "PascalImports.h"
#import "MainMenuViewController.h"
#import "overlayViewController.h"

#ifdef main
#undef main
#endif

int main (int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"SDLUIKitDelegate");
	[pool release];
	return retVal;
}

@implementation SDLUIKitDelegate
@synthesize uiwindow, window, viewController, overlayController;

// convenience method
+(SDLUIKitDelegate *)sharedAppDelegate {
	// the delegate is set in UIApplicationMain(), which is guaranteed to be called before this method
	return (SDLUIKitDelegate *)[[UIApplication sharedApplication] delegate];
}

-(id) init {
	self = [super init];
	self.uiwindow = nil;
	self.window = NULL;
	self.viewController = nil;
    self.overlayController = nil;
	return self;
}

-(void) dealloc {
	[viewController release];
	[uiwindow release];
	[super dealloc];
}

// main routine for calling the actual game engine
-(IBAction) startSDLgame {
    [viewController disappear];

    // pull out useful configuration info from various files
	GameSetup *setup = [[GameSetup alloc] init];
	[setup startThread:@"engineProtocol"];
	const char **gameArgs = [setup getSettings];
	[setup release];
    
    // overlay with controls, become visible after 2 seconds
    overlayController = [[overlayViewController alloc] initWithNibName:@"overlayViewController" bundle:nil];
    [uiwindow addSubview:overlayController.view];
    
	Game(gameArgs); // this is the pascal fuction that starts the game
    
    free(gameArgs);
    [overlayController.view removeFromSuperview];
    [overlayController release];
    
    [viewController appear];
}

// get a path-to-file string
-(NSString *)dataFilePath:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

// override the direct execution of SDL_main to allow us to implement the frontend (even using a nib)
-(void) applicationDidFinishLaunching:(UIApplication *)application {
	[application setStatusBarHidden:YES animated:NO];
	[application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];  
		
	self.uiwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.uiwindow.backgroundColor = [UIColor blackColor];
	
	self.viewController = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:nil];
	
	// Set working directory to resource path
	[[NSFileManager defaultManager] changeCurrentDirectoryPath: [[NSBundle mainBundle] resourcePath]];

	[uiwindow addSubview:viewController.view];
	[uiwindow makeKeyAndVisible];
	[uiwindow layoutSubviews];
}

-(void) applicationWillTerminate:(UIApplication *)application {
	SDL_SendQuit();
	// hack to prevent automatic termination.  See SDL_uikitevents.m for details
	// have to remove this otherwise game goes on when pushing the home button
	//longjmp(*(jump_env()), 1);
}

-(void) applicationWillResignActive:(UIApplication *)application {
	//NSLog(@"%@", NSStringFromSelector(_cmd));
	SDL_SendWindowEvent(self.window, SDL_WINDOWEVENT_MINIMIZED, 0, 0);
}

-(void) applicationDidBecomeActive:(UIApplication *)application {
	//NSLog(@"%@", NSStringFromSelector(_cmd));
	SDL_SendWindowEvent(self.window, SDL_WINDOWEVENT_RESTORED, 0, 0);
}

@end
