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
 * File created on 30/10/2010.
 */


#import "ObjcExports.h"
#import "OverlayViewController.h"


// cache the grenade time
static NSInteger grenadeTime;
// the reference to the newMenu instance
static OverlayViewController *overlay_instance;

@implementation ObjcExports

+(void) setGrenadeTime:(NSInteger) value {
    grenadeTime = value;
}

+(NSInteger) grenadeTime {
    return grenadeTime;
}

@end


#pragma mark -
#pragma mark functions called by pascal code
BOOL inline isApplePhone() {
    return (IS_IPAD() == NO);
}

void startLoadingIndicator() {
    // this is the first ojbc function called by engine, so we have to initialize some variables here
    overlay_instance = [[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil];
    // in order to get rotation events we have to insert the view inside the first view of the second window
    //TODO: when multihead make sure that overlay is displayed in the touch-enabled window
    [[HWUtils mainSDLViewInstance] addSubview:overlay_instance.view];
    grenadeTime = 2;

    if ([HWUtils gameType] == gtSave) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

        overlay_instance.view.backgroundColor = [UIColor blackColor];
        overlay_instance.view.alpha = 0.75;
        overlay_instance.view.userInteractionEnabled = NO;
    }
    CGPoint center = overlay_instance.view.center;
    CGPoint loaderCenter = ([HWUtils gameType] == gtSave) ? center : CGPointMake(center.x, center.y * 5/3);

    overlay_instance.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    overlay_instance.loadingIndicator.hidesWhenStopped = YES;
    overlay_instance.loadingIndicator.center = loaderCenter;
    overlay_instance.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                         UIViewAutoresizingFlexibleRightMargin |
                                                         UIViewAutoresizingFlexibleTopMargin |
                                                         UIViewAutoresizingFlexibleBottomMargin;
    [overlay_instance.loadingIndicator startAnimating];
    [overlay_instance.view addSubview:overlay_instance.loadingIndicator];
    [overlay_instance.loadingIndicator release];
}

void stopLoadingIndicator() {
    HW_zoomSet(1.7);
    if ([HWUtils gameType] != gtSave) {
        [overlay_instance.loadingIndicator stopAnimating];
        [overlay_instance.loadingIndicator removeFromSuperview];
        [HWUtils setGameStatus:gsInGame];
    }
}

void saveFinishedSynching() {
    [UIView beginAnimations:@"fading from save synch" context:NULL];
    [UIView setAnimationDuration:1];
    overlay_instance.view.backgroundColor = [UIColor clearColor];
    overlay_instance.view.alpha = 1;
    overlay_instance.view.userInteractionEnabled = YES;
    [UIView commitAnimations];

    [overlay_instance.loadingIndicator stopAnimating];
    [overlay_instance.loadingIndicator performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [HWUtils setGameStatus:gsInGame];
}

void clearView() {
    // don't use any engine calls here as this function is called every time the ammomenu is opened
    [UIView beginAnimations:@"remove button" context:NULL];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    overlay_instance.confirmButton.alpha = 0;
    overlay_instance.grenadeTimeSegment.alpha = 0;
    [UIView commitAnimations];

    if (overlay_instance.confirmButton)
        [overlay_instance.confirmButton performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:ANIMATION_DURATION];
    if (overlay_instance.grenadeTimeSegment) {
        [overlay_instance.grenadeTimeSegment performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:ANIMATION_DURATION];
        overlay_instance.grenadeTimeSegment.tag = 0;
    }
    grenadeTime = 2;
}

// dummy function to prevent linkage fail
int SDL_main(int argc, char **argv) {
    return 0;
}
