//
//  overlayViewController.m
//  HedgewarsMobile
//
//  Created by Vittorio on 16/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OverlayViewController.h"
#import "SDL_uikitappdelegate.h"
#import "PascalImports.h"
#import "CGPointUtils.h"
#import "SDL_mouse.h"
#import "SDL_config_iphoneos.h"
#import "InGameMenuViewController.h"
#import "CommodityFunctions.h"

#define HIDING_TIME_DEFAULT [NSDate dateWithTimeIntervalSinceNow:2.7]
#define HIDING_TIME_NEVER   [NSDate dateWithTimeIntervalSinceNow:10000]
#define doDim()             [dimTimer setFireDate:HIDING_TIME_DEFAULT]
#define doNotDim()          [dimTimer setFireDate:HIDING_TIME_NEVER]

#define CONFIRMATION_TAG 5959
#define ANIMATION_DURATION 0.25
#define removeConfirmationInput()   [[self.view viewWithTag:CONFIRMATION_TAG] removeFromSuperview]; 

@implementation OverlayViewController
@synthesize popoverController, popupMenu;

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    return rotationManager(interfaceOrientation);
}

-(void) didRotate:(NSNotification *)notification {  
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGRect usefulRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    UIView *sdlView = [[[UIApplication sharedApplication] keyWindow] viewWithTag:12345];
    
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            sdlView.transform = CGAffineTransformMakeRotation(degreesToRadian(0));
            self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
            HW_setLandscape(YES);
            break;
        case UIDeviceOrientationLandscapeRight:
            sdlView.transform = CGAffineTransformMakeRotation(degreesToRadian(180));
            self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
            HW_setLandscape(YES);
            break;
        /*
        case UIDeviceOrientationPortrait:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                sdlView.transform = CGAffineTransformMakeRotation(degreesToRadian(270));
                self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(0));
                [self chatAppear];
                HW_setLandscape(NO);
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                sdlView.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
                self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(180));
                [self chatAppear];
                HW_setLandscape(NO);
            }
            break;
        */
        default:
            break;
    }
    self.view.frame = usefulRect;
    //sdlView.frame = usefulRect;
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark View Management
-(void) viewDidLoad {
    isPopoverVisible = NO;
    self.view.alpha = 0;
    self.view.center = CGPointMake(self.view.frame.size.height/2.0, self.view.frame.size.width/2.0);
    
    // set initial orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIView *sdlView = [[[UIApplication sharedApplication] keyWindow] viewWithTag:12345];
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            sdlView.transform = CGAffineTransformMakeRotation(degreesToRadian(0));
            self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
            break;
        case UIDeviceOrientationLandscapeRight:
            sdlView.transform = CGAffineTransformMakeRotation(degreesToRadian(180));
            self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
            break;
    }
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    dimTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:6]
                                        interval:1000
                                          target:self
                                        selector:@selector(dimOverlay)
                                        userInfo:nil
                                         repeats:YES];
    
    // add timer too runloop, otherwise it doesn't work
    [[NSRunLoop currentRunLoop] addTimer:dimTimer forMode:NSDefaultRunLoopMode];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    [UIView beginAnimations:@"showing overlay" context:NULL];
    [UIView setAnimationDuration:1];
    self.view.alpha = 1;
    [UIView commitAnimations];
    
    // find the sdl window we're on
    SDL_VideoDevice *_this = SDL_GetVideoDevice();
    SDL_VideoDisplay *display = &_this->displays[0];
    sdlwindow = display->windows;
}

/* these are causing problems at reloading so let's remove 'em
-(void) viewDidUnload {
    [dimTimer invalidate];
    self.popoverController = nil;
    self.popupMenu = nil;
    [super viewDidUnload];
    MSG_DIDUNLOAD();
}

-(void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    if (popupMenu.view.superview == nil) 
        popupMenu = nil;
    MSG_MEMCLEAN();
}
*/

-(void) dealloc {
    [popupMenu release];
    [popoverController release];
    // dimTimer is autoreleased
    [super dealloc];
}

#pragma mark -
#pragma mark Overlay actions and members
// nice transition for dimming, should be called only by the timer himself
-(void) dimOverlay {
    if (isGameRunning) {
        [UIView beginAnimations:@"overlay dim" context:NULL];
        [UIView setAnimationDuration:0.6];
        self.view.alpha = 0.2;
        [UIView commitAnimations];
    }
}

// set the overlay visible and put off the timer for enough time
-(void) activateOverlay {
    self.view.alpha = 1;
    doNotDim();
}

// dim the overlay when there's no more input for a certain amount of time
-(IBAction) buttonReleased:(id) sender {
    if (!isGameRunning)
        return;
    
    UIButton *theButton = (UIButton *)sender;
    
    switch (theButton.tag) {
        case 0:
        case 1:
        case 2:
        case 3:
            HW_walkingKeysUp();
            break;
        case 4:
        case 5:
        case 6:
            HW_otherKeysUp();
            break;
        default:
            NSLog(@"Nope");
            break;
    }

    doDim();
}

// issue certain action based on the tag of the button 
-(IBAction) buttonPressed:(id) sender {
    [self activateOverlay];
    if (isPopoverVisible) {
        [self dismissPopover];
    }
    
    if (!isGameRunning)
        return;
    
    UIButton *theButton = (UIButton *)sender;
    
    switch (theButton.tag) {
        case 0:
            HW_walkLeft();
            break;
        case 1:
            HW_walkRight();
            break;
        case 2:
            HW_aimUp();
            break;
        case 3:
            HW_aimDown();
            break;
        case 4:
            HW_shoot();
            break;
        case 5:
            HW_jump();
            break;
        case 6:
            HW_backjump();
            break;
        case 7:
            HW_tab();
            break;
        case 10:
            removeConfirmationInput();
            [self showPopover];
            break;
        case 11:
            removeConfirmationInput();
            HW_ammoMenu();
            break;
        default:
            DLog(@"Nope");
            break;
    }
}

// present a further check before closing game
-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex {
    if ([actionSheet cancelButtonIndex] != buttonIndex)
        HW_terminate(NO);
    else
        HW_pause();     
}

// show up a popover containing a popupMenuViewController; we hook it with setPopoverContentSize
// on iphone instead just use the tableViewController directly (and implement manually all animations)
-(IBAction) showPopover{
    isPopoverVisible = YES;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (popupMenu == nil) 
            popupMenu = [[InGameMenuViewController alloc] initWithStyle:UITableViewStylePlain];
        if (popoverController == nil) {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:popupMenu];
            [popoverController setPopoverContentSize:CGSizeMake(220, 170) animated:YES];
            [popoverController setPassthroughViews:[NSArray arrayWithObject:self.view]];
        }

        [popoverController presentPopoverFromRect:CGRectMake(1000, 0, 220, 32)
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                         animated:YES];
    } else {
        if (popupMenu == nil) {
            popupMenu = [[InGameMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
            popupMenu.view.backgroundColor = [UIColor clearColor];
            popupMenu.view.frame = CGRectMake(480, 0, 200, 170);
        }
        [self.view addSubview:popupMenu.view];
        
        [UIView beginAnimations:@"showing popover" context:NULL];
        [UIView setAnimationDuration:0.35];
        popupMenu.view.frame = CGRectMake(280, 0, 200, 170);
        [UIView commitAnimations];
    }
    popupMenu.tableView.scrollEnabled = NO;
}

// on ipad just dismiss it, on iphone transtion to the right
-(void) dismissPopover {
    if (YES == isPopoverVisible) {
        isPopoverVisible = NO;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [popoverController dismissPopoverAnimated:YES];
        } else {
            [UIView beginAnimations:@"hiding popover" context:NULL];
            [UIView setAnimationDuration:0.35];
            popupMenu.view.frame = CGRectMake(480, 0, 200, 170);
            [UIView commitAnimations];
        
            [popupMenu.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.35];
        }
        [self buttonReleased:nil];
    }
}

-(void) textFieldDoneEditing:(id) sender{
    [sender resignFirstResponder];
}


#pragma mark -
#pragma mark Custom touch event handling
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    UITouch *first, *second;
    
    // hide in-game menu
    if (isPopoverVisible)
        [self dismissPopover];
    
    // remove keyboard from the view
    if (SDL_iPhoneKeyboardIsShown(sdlwindow))
        SDL_iPhoneKeyboardHide(sdlwindow);
    
    // reset default dimming
    doDim();
    
    switch ([allTouches count]) {
        case 1:            
            removeConfirmationInput();
            if (2 == [[[allTouches allObjects] objectAtIndex:0] tapCount])
                HW_zoomReset();
            break;
        case 2:                
            // pinching
            first = [[allTouches allObjects] objectAtIndex:0];
            second = [[allTouches allObjects] objectAtIndex:1];
            initialDistanceForPinching = distanceBetweenPoints([first locationInView:self.view], [second locationInView:self.view]);
            break;
        default:
            break;
    }
}

    //if (currentPosition.y < screen.size.width - 130 || (currentPosition.x > 130 && currentPosition.x < screen.size.height - 130)) {

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect screen = [[UIScreen mainScreen] bounds];
    NSSet *allTouches = [event allTouches];
    CGPoint currentPosition = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.view];
    
    switch ([allTouches count]) {
        case 1:
            // if we're in the menu we just click in the point
            if (HW_isAmmoOpen()) {
                HW_setCursor(HWX(currentPosition.x), HWY(currentPosition.y));
                // this click doesn't need any wrapping because the ammoMenu already limits the cursor
                HW_click();
            } else 
                // if weapon requires a further click, ask for tapping again
                if (HW_isWeaponRequiringClick()) {
                    // here don't have to wrap thanks to isCursorVisible magic
                    HW_setCursor(HWX(currentPosition.x), HWY(currentPosition.y));
                    
                    // draw the button at the last touched point (which is the current position)
                    UIButton *tapAgain = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    tapAgain.frame = CGRectMake(currentPosition.x - 90, currentPosition.y + 15, 180, 30);
                    tapAgain.tag = CONFIRMATION_TAG;
                    tapAgain.alpha = 0;
                    [tapAgain addTarget:self action:@selector(sendHWClick) forControlEvents:UIControlEventTouchUpInside];
                    [tapAgain setTitle:NSLocalizedString(@"Tap again to confirm",@"from the overlay") forState:UIControlStateNormal];
                    [self.view addSubview:tapAgain];
                    
                    // animation ftw!
                    [UIView beginAnimations:@"inserting button" context:NULL]; 
                    [UIView setAnimationDuration:ANIMATION_DURATION];
                    [self.view viewWithTag:CONFIRMATION_TAG].alpha = 1;
                    [UIView commitAnimations];
                    
                    // keep the overlay active, or the button will fade
                    doNotDim();
                }
            break;
        case 2:
            HW_allKeysUp();
            break;
        default:
            DLog(@"too many touches");
            break;
    }
    
    initialDistanceForPinching = 0;
}

-(void) sendHWClick {
    HW_click();
    removeConfirmationInput();
    doDim();
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect screen = [[UIScreen mainScreen] bounds];
    NSSet *allTouches = [event allTouches];
    
    UITouch *touch, *first, *second;

    switch ([allTouches count]) {
        case 1:
            touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint currentPosition = [touch locationInView:self.view];

            if (HW_isAmmoOpen()) {
                // moves the cursor around
                HW_setCursor(HWX(currentPosition.x), HWY(currentPosition.y));
            } else {
                DLog(@"x: %f y: %f -> X:%d Y:%d", currentPosition.x, currentPosition.y, HWX(currentPosition.x), HWY(currentPosition.y));
                HW_setCursor(HWX(currentPosition.x), HWY(currentPosition.y));
            }
            break;
        case 2:
            first = [[allTouches allObjects] objectAtIndex:0];
            second = [[allTouches allObjects] objectAtIndex:1];
            CGFloat currentDistanceOfPinching = distanceBetweenPoints([first locationInView:self.view], [second locationInView:self.view]);
            const int pinchDelta = 40;
            
            if (0 != initialDistanceForPinching) {
                if (currentDistanceOfPinching - initialDistanceForPinching > pinchDelta) {
                    HW_zoomIn();
                    initialDistanceForPinching = currentDistanceOfPinching;
                }
                else if (initialDistanceForPinching - currentDistanceOfPinching > pinchDelta) {
                    HW_zoomOut();
                    initialDistanceForPinching = currentDistanceOfPinching;
                }
            } else 
                initialDistanceForPinching = currentDistanceOfPinching;
            
            break;
        default:
            break;
    }
}


// called from AddProgress and FinishProgress (respectively)
void startSpinning() {
    isGameRunning = NO;
    CGRect screen = [[UIScreen mainScreen] bounds];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.tag = 987654;
    indicator.center = CGPointMake(screen.size.width/2 - 118, screen.size.height/2);
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:12345] addSubview:indicator];
    [indicator release];
}

void stopSpinning() {
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[[[[UIApplication sharedApplication] keyWindow] viewWithTag:12345] viewWithTag:987654];
    [indicator stopAnimating];
    isGameRunning = YES;
}

void clearView() {
    UIWindow *theWindow = [[UIApplication sharedApplication] keyWindow];
    UIButton *theButton = (UIButton *)[theWindow viewWithTag:CONFIRMATION_TAG];
    [UIView beginAnimations:@"remove button" context:NULL];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    theButton.alpha = 0;
    [UIView commitAnimations];
    [theWindow performSelector:@selector(removeFromSuperview) withObject:theButton afterDelay:0.3];
}

@end
