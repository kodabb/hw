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
 * File created on 08/01/2010.
 */


#import "MainMenuViewController.h"
#import "CreationChamber.h"
#import "PascalImports.h"
#import "GameConfigViewController.h"
#import "SplitViewRootController.h"
#import "AboutViewController.h"
#import "SavedGamesViewController.h"
#import "RestoreViewController.h"
#import "Appirater.h"
#import "ServerSetup.h"

@implementation MainMenuViewController
@synthesize gameConfigViewController, settingsViewController, aboutViewController, savedGamesViewController, restoreViewController;

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    return rotationManager(interfaceOrientation);
}

// check if some configuration files are already set; if they are present it means that the current copy must be updated
-(void) createNecessaryFiles {
    NSString *resourcesDir = [[NSBundle mainBundle] resourcePath];
    DLog(@"Creating necessary files");
    
    // SAVES - just delete and overwrite
    if ([[NSFileManager defaultManager] fileExistsAtPath:SAVES_DIRECTORY()])
        [[NSFileManager defaultManager] removeItemAtPath:SAVES_DIRECTORY() error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:SAVES_DIRECTORY() withIntermediateDirectories:NO attributes:nil error:NULL];
    
    // SETTINGS - nsuserdefaults ftw
    createSettings();

    // TEAMS - update exisiting teams with new format
    if ([[NSFileManager defaultManager] fileExistsAtPath:TEAMS_DIRECTORY()] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:TEAMS_DIRECTORY()
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
        // we copy teams only the first time because it's unlikely that newer ones are going to be added
        NSString *baseTeamsDir = [[NSString alloc] initWithFormat:@"%@/Settings/Teams/",resourcesDir];
        for (NSString *str in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:baseTeamsDir error:NULL]) {
            NSString *sourceFile = [baseTeamsDir stringByAppendingString:str];
            NSString *destinationFile = [TEAMS_DIRECTORY() stringByAppendingString:str];
            [[NSFileManager defaultManager] removeItemAtPath:destinationFile error:NULL];
            [[NSFileManager defaultManager] copyItemAtPath:sourceFile toPath:destinationFile error:NULL];
        }
        [baseTeamsDir release];
    }
    // merge not needed as format rarely changes

    // SCHEMES - always overwrite and delete custom ones
    if ([[NSFileManager defaultManager] fileExistsAtPath:SCHEMES_DIRECTORY()] == YES)
        [[NSFileManager defaultManager] removeItemAtPath:SCHEMES_DIRECTORY() error:NULL];
    NSString *baseSchemesDir = [[NSString alloc] initWithFormat:@"%@/Settings/Schemes/",resourcesDir];
    [[NSFileManager defaultManager] copyItemAtPath:baseSchemesDir toPath:SCHEMES_DIRECTORY() error:NULL];
    [baseSchemesDir release];

    // WEAPONS - always overwrite
    if ([[NSFileManager defaultManager] fileExistsAtPath:WEAPONS_DIRECTORY()] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath:WEAPONS_DIRECTORY()
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    createWeaponNamed(@"Default", 0);
    createWeaponNamed(@"Crazy", 1);
    createWeaponNamed(@"Pro Mode", 2);
    createWeaponNamed(@"Shoppa", 3);
    createWeaponNamed(@"Clean Slate", 4);
    createWeaponNamed(@"Minefield", 5);
    createWeaponNamed(@"Thinking with Portals", 6);
    // merge not needed because weapons not present in the set are 0ed by GameSetup
}

#pragma mark -
-(void) viewDidLoad {
    [super viewDidLoad];

    // get the app's version
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];

    // get the version number that we've been tracking
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *trackingVersion = [userDefaults stringForKey:@"HedgeVersion"];

    if ([[userDefaults objectForKey:@"music"] boolValue])
        [HedgewarsAppDelegate playBackgroundMusic];

    if (trackingVersion == nil || [trackingVersion isEqualToString:version] == NO) {
        // remove any reminder of previous games as saves are going to be wiped out
        [userDefaults setObject:@"" forKey:@"savedGamePath"];
        // update the tracking version with the new one
        [userDefaults setObject:version forKey:@"HedgeVersion"];

        [userDefaults synchronize];
        [self createNecessaryFiles];
    }

    // prompt for restoring any previous game
    NSString *saveString = [userDefaults objectForKey:@"savedGamePath"];
    if (saveString != nil && [saveString isEqualToString:@""] == NO) {
        if (self.restoreViewController == nil) {
            NSString *xibName = [@"RestoreViewController-" stringByAppendingString:(IS_IPAD() ? @"iPad" : @"iPhone")];
            RestoreViewController *restored = [[RestoreViewController alloc] initWithNibName:xibName bundle:nil];
            if ([restored respondsToSelector:@selector(setModalPresentationStyle:)])
                restored.modalPresentationStyle = UIModalPresentationFormSheet;
            self.restoreViewController = restored;
            [restored release];
        }
        [self performSelector:@selector(presentModalViewController:animated:) withObject:self.restoreViewController afterDelay:0.3];
    } else {
        // let's not prompt for rating when app crashed >_>
        [Appirater appLaunched];
    }


    /*
    ServerSetup *setup = [[ServerSetup alloc] init];
    if (isNetworkReachable()) {
        DLog(@"network is reachable");
        [NSThread detachNewThreadSelector:@selector(serverProtocol)
                                 toTarget:setup
                               withObject:nil];
    }
    [setup release];
    */
}


#pragma mark -
-(IBAction) switchViews:(id) sender {
    UIButton *button = (UIButton *)sender;
    UIAlertView *alert;
    NSString *xib = nil;
    NSString *debugStr = nil;

    playSound(@"clickSound");
    switch (button.tag) {
        case 0:
            if (nil == self.gameConfigViewController) {
                xib = IS_IPAD() ? nil : @"GameConfigViewController";

                GameConfigViewController *gcvc = [[GameConfigViewController alloc] initWithNibName:xib bundle:nil];
                gcvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                self.gameConfigViewController = gcvc;
                [gcvc release];
            }

            [self presentModalViewController:self.gameConfigViewController animated:YES];
            break;
        case 2:
            if (nil == self.settingsViewController) {
                SplitViewRootController *svrc = [[SplitViewRootController alloc] initWithNibName:nil bundle:nil];
                svrc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                self.settingsViewController = svrc;
                [svrc release];
            }

            [self presentModalViewController:self.settingsViewController animated:YES];
            break;
        case 3:
#ifdef DEBUG
            if ([[NSFileManager defaultManager] fileExistsAtPath:DEBUG_FILE()])
                debugStr = [[NSString alloc] initWithContentsOfFile:DEBUG_FILE()];
            else
                debugStr = [[NSString alloc] initWithString:@"Here be log"];
            UITextView *scroll = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
            scroll.text = debugStr;
            [debugStr release];
            scroll.editable = NO;

            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:scroll action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor blackColor];
            btn.frame = CGRectMake(self.view.frame.size.height-70, 0, 70, 70);
            [scroll addSubview:btn];
            [self.view addSubview:scroll];
            [scroll release];
#else
            debugStr = debugStr; // prevent compiler warning
            if (nil == self.aboutViewController) {
                AboutViewController *about = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
                about.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                if ([about respondsToSelector:@selector(setModalPresentationStyle:)])
                     about.modalPresentationStyle = UIModalPresentationFormSheet;
                self.aboutViewController = about;
                [about release];
            }
            [self presentModalViewController:self.aboutViewController animated:YES];
#endif
            break;
        case 4:
            if (nil == self.savedGamesViewController) {
                SavedGamesViewController *savedgames = [[SavedGamesViewController alloc] initWithNibName:@"SavedGamesViewController" bundle:nil];
                savedgames.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                if ([savedgames respondsToSelector:@selector(setModalPresentationStyle:)])
                    savedgames.modalPresentationStyle = UIModalPresentationPageSheet;
                self.savedGamesViewController = savedgames;
                [savedgames release];
            }
            
            [self presentModalViewController:self.savedGamesViewController animated:YES];
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

-(void) viewDidUnload {
    self.gameConfigViewController = nil;
    self.settingsViewController = nil;
    self.aboutViewController = nil;
    self.savedGamesViewController = nil;
    self.restoreViewController = nil;
    MSG_DIDUNLOAD();
    [super viewDidUnload];
}

-(void) didReceiveMemoryWarning {
    if (self.settingsViewController.view.superview == nil)
        self.settingsViewController = nil;
    if (self.gameConfigViewController.view.superview == nil)
        self.gameConfigViewController = nil;
    if (self.aboutViewController.view.superview == nil)
        self.aboutViewController = nil;
    if (self.savedGamesViewController.view.superview == nil)
        self.savedGamesViewController = nil;
    if (self.restoreViewController.view.superview == nil)
        self.restoreViewController = nil;
    MSG_MEMCLEAN();
    [super didReceiveMemoryWarning];
}

-(void) dealloc {
    releaseAndNil(settingsViewController);
    releaseAndNil(gameConfigViewController);
    releaseAndNil(aboutViewController);
    releaseAndNil(savedGamesViewController);
    releaseAndNil(restoreViewController);
    [super dealloc];
}

@end
