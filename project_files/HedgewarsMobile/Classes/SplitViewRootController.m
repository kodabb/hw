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
 * File created on 27/03/2010.
 */


#import "SplitViewRootController.h"
#import "MasterViewController.h"
#import "CommodityFunctions.h"

@implementation SplitViewRootController
@synthesize activeController, splitViewRootController;

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return rotationManager(interfaceOrientation);
}


-(void) viewDidLoad {
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(0, 0, rect.size.height, rect.size.width);

    if (IS_IPAD()) {
        // the contents on the right of the splitview, setting targetController to nil to avoid creating the table
        MasterViewController *rightController = [[MasterViewController alloc] init];
        rightController.targetController = nil;
        UINavigationController *rightNavController = [[UINavigationController alloc] initWithRootViewController:rightController];
        [rightController release];

        // the contens on the left of the splitview, setting targetController that will receive push/pop actions
        MasterViewController *leftController = [[MasterViewController alloc] init];
        leftController.targetController = rightNavController.topViewController;
        UINavigationController *leftNavController = [[UINavigationController alloc] initWithRootViewController:leftController];
        [leftController release];

        self.activeController = rightNavController;
        self.splitViewRootController = [[UISplitViewController alloc] init];
        self.splitViewRootController.delegate = nil;
        self.splitViewRootController.view.frame = CGRectMake(0, 0, rect.size.height, rect.size.width);
        self.splitViewRootController.viewControllers = [NSArray arrayWithObjects: leftNavController, rightNavController, nil];
        [leftNavController release];
        [rightNavController release];

        // add view to main controller
        [self.view addSubview:self.splitViewRootController.view];
    } else {
        MasterViewController *mainController = [[MasterViewController alloc] init];
        mainController.targetController = nil;
        mainController.view.frame = CGRectMake(0, 0, rect.size.height, rect.size.width);
        [self.view addSubview:mainController.view];
        // here setting activeController is not needed as the event is kept active by the uitabbarcontroller
    }

    [super viewDidLoad];
}

#pragma mark -
#pragma mark Memory management
-(void) didReceiveMemoryWarning {
    if (self.splitViewRootController.view.superview == nil)
        self.splitViewRootController = nil;
    if (self.activeController.view.superview == nil)
        self.activeController = nil;
    MSG_MEMCLEAN();
    [super didReceiveMemoryWarning];
}

-(void) viewDidUnload {
    self.activeController = nil;
    self.splitViewRootController = nil;
    MSG_DIDUNLOAD();
    [super viewDidUnload];
}

-(void) dealloc {
    releaseAndNil(activeController);
    releaseAndNil(splitViewRootController);
    [super dealloc];
}


#pragma mark -
#pragma mark additional methods as we're using a UINavigationController programmatically
// see http://davidebenini.it/2009/01/03/viewwillappear-not-being-called-inside-a-uinavigationcontroller/
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.activeController viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.activeController viewWillDisappear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    [self.activeController viewDidAppear:animated];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidUnload];
    [self.activeController viewDidDisappear:animated];
}


@end
