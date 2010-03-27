//
//  MainMenuViewController.m
//  hwengine
//
//  Created by Vittorio on 08/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SDL_uikitappdelegate.h"
#import "PascalImports.h"
#import "SplitViewRootController.h"

// in case we don't want SDL_mixer...
//#import "SoundEffect.h"	
//SoundEffect *erasingSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
//SoundEffect *selectSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Select" ofType:@"caf"]];


@implementation MainMenuViewController
@synthesize cover;

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[super dealloc];
}

-(void) viewDidLoad {
    // initialize some files the first time we load the game
	[NSThread detachNewThreadSelector:@selector(checkFirstRun) toTarget:self withObject:nil];
    // listet to request to remove the modalviewcontroller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModalViewController) name: @"dismissModalView" object:nil];

	[super viewDidLoad];
}

// this is called to verify whether it's the first time the app is launched
// if it is it blocks user interaction with an alertView until files are created
-(void) checkFirstRun {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *filePath = [[SDLUIKitDelegate sharedAppDelegate] dataFilePath:@"settings.plist"];
	if (!([[NSFileManager defaultManager] fileExistsAtPath:filePath])) {
		// file not present, means that also other files are absent
		NSLog(@"First time run, creating settings files");
		
		// show a popup with an indicator to make the user wait
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"One-time Preferences Configuration",@"")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
		[alert show];
		[alert release];

		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
		[indicator startAnimating];
		[alert addSubview:indicator];
		[indicator release];
		
		// create settings.plist
		NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] init];
	
		[saveDict setObject:@"" forKey:@"username"];
		[saveDict setObject:@"" forKey:@"password"];
		[saveDict setObject:@"1" forKey:@"music"];
		[saveDict setObject:@"1" forKey:@"sounds"];
		[saveDict setObject:@"0" forKey:@"alternate"];
	
		[saveDict writeToFile:filePath atomically:YES];
		[saveDict release];
		
		// create other files
		
		[alert dismissWithClickedButtonIndex:0 animated:YES];
	}
	[pool release];
	[NSThread exit];
}

#pragma mark -
-(void) appear {
    [[SDLUIKitDelegate sharedAppDelegate].uiwindow addSubview:self.view];
    [self release];
    
    [UIView beginAnimations:@"inserting main controller" context:NULL];
	[UIView setAnimationDuration:1];
	self.view.alpha = 1;
	[UIView commitAnimations];
    
    // this is a silly way to hide the sdl contex that remained active
    if (nil == cover) {
        cover= [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        cover.backgroundColor = [UIColor blackColor];
    }
    [[SDLUIKitDelegate sharedAppDelegate].uiwindow insertSubview:cover belowSubview:self.view];
}

-(void) disappear {
    if (nil != cover)
        [cover release];
    
    [UIView beginAnimations:@"removing main controller" context:NULL];
	[UIView setAnimationDuration:1];
	self.view.alpha = 0;
	[UIView commitAnimations];
    
    [self retain];
    [self.view removeFromSuperview];
}

#pragma mark -
-(IBAction) switchViews:(id) sender {
    UIButton *button = (UIButton *)sender;
    SplitViewRootController *splitViewController;
    UIAlertView *alert;
    
    switch (button.tag) {
        case 0:
            [[SDLUIKitDelegate sharedAppDelegate] startSDLgame];
            break;
        case 2:
            // for now this controller is just to simplify code management
            splitViewController = [[SplitViewRootController alloc] init];
            splitViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentModalViewController:splitViewController animated:YES];
            break;
        default:
            alert = [[UIAlertView alloc] initWithTitle:@"Not Yet Implemented"
                                               message:@"Sorry, this feature is not yet implemented"
                                              delegate:nil
                                     cancelButtonTitle:@"Well, don't worry"
                                     otherButtonTitles:nil];
            [alert show];
            [alert release];
            break;
    }
}

-(void) dismissModalViewController {
    [self dismissModalViewControllerAnimated:YES];
}

@end
