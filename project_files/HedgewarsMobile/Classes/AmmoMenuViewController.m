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
 * File created on 03/10/2010.
 */


#import "AmmoMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CommodityFunctions.h"
#import "UIImageExtra.h"
#import "PascalImports.h"

#define BTNS_PER_ROW         9
#define DEFAULT_DESCRIPTION  IS_IPAD() ? \
                             NSLocalizedString(@"Hold your finger on a weapon to see what it does.\nYou can move this window anywhere on the screen.",@"") : \
                             NSLocalizedString(@"Hold your finger on a weapon to see what it does.\nTap anywhere to dismiss.",@"")

@implementation AmmoMenuViewController
@synthesize imagesArray, buttonsArray, nameLabel, extraLabel, captionLabel, isVisible;

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    return rotationManager(interfaceOrientation);
}

#pragma mark -
#pragma mark view handling
-(void) viewDidLoad {    
    self.view.frame = CGRectMake(0, 0, 480, 320);
    self.view.backgroundColor = [UIColor blackColor];
    self.view.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.view.layer.borderWidth = 1.3f;
    [self.view.layer setCornerRadius:10];
    [self.view.layer setMasksToBounds:YES];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    placingPoint = CGPointMake(-1, -1);

    self.isVisible = NO;
    delay = (uint8_t *)calloc(HW_getNumberOfWeapons(), sizeof(uint8_t));
    HW_getAmmoDelays(delay);

    shouldUpdateImage = (BOOL *)calloc(HW_getNumberOfWeapons(), sizeof(BOOL));

    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated {
    [self updateAmmoVisuals];
    [super viewWillAppear:animated];
}

-(void) appearInView:(UIView *)container {
    [self viewWillAppear:YES];
    [container addSubview:self.view];

    if (placingPoint.x == -1 || placingPoint.y == -1)
        placingPoint = container.center;
    self.view.center = placingPoint;

    self.isVisible = YES;
    if (IS_IPAD() == NO)
        HW_pause();
}

-(void) disappear {
    if (self.isVisible)
        [self.view removeFromSuperview];
    self.isVisible = NO;
    placingPoint = self.view.center;
    if (IS_IPAD() == NO)
        HW_pauseToggle();
}

#pragma mark -
#pragma mark drawing
-(void) loadLabels {
    int x = 12;
    int y = (HW_getNumberOfWeapons()/BTNS_PER_ROW)*44 + 18;
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 200, 20)];
    name.backgroundColor = [UIColor clearColor];
    name.textColor = UICOLOR_HW_YELLOW_BODER;
    name.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    self.nameLabel = name;
    [self.view addSubview:self.nameLabel];
    [name release];

    UILabel *caption = [[UILabel alloc] initWithFrame:CGRectMake(x+200, y, 220, 20)];
    caption.backgroundColor = [UIColor clearColor];
    caption.textColor = [UIColor whiteColor];
    caption.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    caption.adjustsFontSizeToFitWidth = YES;
    caption.minimumFontSize = 8;
    self.captionLabel = caption;
    [self.view addSubview:self.captionLabel];
    [caption release];

    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(x+2, self.view.frame.size.height-50, 415, 53)];
    description.backgroundColor = [UIColor clearColor];
    description.textColor = [UIColor whiteColor];
    description.text = DEFAULT_DESCRIPTION;
    description.font = [UIFont italicSystemFontOfSize:[UIFont systemFontSize]];
    description.adjustsFontSizeToFitWidth = YES;
    description.minimumFontSize = 8;
    description.numberOfLines = 0;
    self.extraLabel = description;
    [self.view addSubview:self.extraLabel];
    [description release];
}

-(void) loadAmmoStuff:(id) object {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *str = [NSString stringWithFormat:@"%@/AmmoMenu/Ammos.png",GRAPHICS_DIRECTORY()];
    UIImage *ammoStoreImage = [[UIImage alloc] initWithContentsOfFile:str];

    NSMutableArray *imgs = [[NSMutableArray alloc] initWithCapacity:HW_getNumberOfWeapons()];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:HW_getNumberOfWeapons()];
    int i, j, e;
    for (i = 0, j = 0, e = 0; i < HW_getNumberOfWeapons(); i++) {
        int x, y;
        float w, radius;
        
        // move utilities aside and make 'em rounded
        if (HW_isWeaponAnEffect(i)) {
            x = 432;
            y = 20 + 48*e++;
            w = 1.5;
            radius = 22;
        } else {
            x = 10+(j%BTNS_PER_ROW)*44;
            y = 10+(j/BTNS_PER_ROW)*44;
            if (j / BTNS_PER_ROW % 2 != 0)
                x += 20;
            w = 1;
            radius = 6;
            j++;
        }

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, y, 40, 40);
        button.tag = i;
        button.layer.borderColor = [UICOLOR_HW_YELLOW_TEXT CGColor];
        button.layer.borderWidth = w;
        [button.layer setCornerRadius:radius];
        [button.layer setMasksToBounds:YES];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonReleased:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonCancelled:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        [button setTitleColor:UICOLOR_HW_YELLOW_TEXT forState:UIControlStateNormal];
        button.titleLabel.backgroundColor = [UIColor blackColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        [button.titleLabel.layer setCornerRadius:3];
        [button.titleLabel.layer setMasksToBounds:YES];
        button.titleLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
        button.titleLabel.layer.borderWidth = 1;
        [self.view addSubview:button];
        [array addObject:button];

        int size = 32*getScreenScale();
        int x_src = ((i*size)/(int)(ammoStoreImage.size.height*getScreenScale()))*size;
        int y_src = (i*size)%(int)(ammoStoreImage.size.height*getScreenScale());
        UIImage *img = [ammoStoreImage cutAt:CGRectMake(x_src, y_src, size, size)];
        [imgs addObject:img];
    }
    [self performSelectorOnMainThread:@selector(setButtonsArray:) withObject:array waitUntilDone:NO];
    [array release];

    [self performSelectorOnMainThread:@selector(setImagesArray:) withObject:imgs waitUntilDone:NO];
    [imgs release];
    [ammoStoreImage release];

    [self performSelectorOnMainThread:@selector(loadLabels) withObject:nil waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(updateAmmoVisuals) withObject:nil waitUntilDone:YES];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)object;
    [spinner stopAnimating];
    [pool drain];
}

-(void) updateAmmoVisuals {
    if (self.buttonsArray == nil || self.imagesArray == nil) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.hidesWhenStopped = YES;
        spinner.center = self.view.center;
        [spinner startAnimating];
        [self.view addSubview:spinner];
        [NSThread detachNewThreadSelector:@selector(loadAmmoStuff:) toTarget:self withObject:spinner];
        [spinner release];
        return;
    }
    
    int *loadout = (int *)calloc(HW_getNumberOfWeapons(), sizeof(int));
    int res = HW_getAmmoCounts(loadout);
    int turns = HW_getTurnsForCurrentTeam();
    
    if (res == 0) {
        self.view.userInteractionEnabled = YES;
        
        for (int i = 0; i < HW_getNumberOfWeapons(); i++) {
            UIButton *button = [self.buttonsArray objectAtIndex:i];
            if (loadout[i] > 0) {
                if (delay[i]-turns >= 0) {
                    button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                    [button setTitle:[NSString stringWithFormat:@" %d ",delay[i]-turns+1] forState:UIControlStateNormal];
                    if (button.currentBackgroundImage == nil || shouldUpdateImage[i] == NO) {
                        UIImage *img = [self.imagesArray objectAtIndex:i];
                        [button setBackgroundImage:[img convertToGrayScale] forState:UIControlStateNormal];
                        shouldUpdateImage[i] = YES;
                    }
                } else {
                    button.layer.borderColor = [UICOLOR_HW_YELLOW_TEXT CGColor];
                    [button setTitle:nil forState:UIControlStateNormal];
                    if (button.currentBackgroundImage == nil || shouldUpdateImage[i] == YES) {
                        UIImage *img = [self.imagesArray objectAtIndex:i];
                        [button setBackgroundImage:img forState:UIControlStateNormal];
                        shouldUpdateImage[i] = NO;
                    }
                }
                button.enabled = YES;
            } else {
                if (button.enabled == YES)
                    [button setBackgroundImage:nil forState:UIControlStateNormal];
                button.layer.borderColor = [[UIColor darkGrayColor] CGColor];
                button.enabled = NO;
                shouldUpdateImage[i] = NO;
            }
        }
    } else {
        self.view.userInteractionEnabled = NO;
    }

    free(loadout);
    loadout = NULL;
}

#pragma mark -
#pragma mark user interaction
-(void) buttonPressed:(id) sender {
    UIButton *theButton = (UIButton *)sender;
    if (self.nameLabel == nil || self.extraLabel == nil)
        [self loadLabels];

    self.nameLabel.text = [NSString stringWithUTF8String:HW_getWeaponNameByIndex(theButton.tag)];
    // description contains a lot of unnecessary stuff, we clean it by removing .|, !| and ?|
    NSString *description = [NSString stringWithUTF8String:HW_getWeaponDescriptionByIndex(theButton.tag)];
    NSArray *elements = [description componentsSeparatedByString:@".|"];
    NSArray *purgedElements = [[elements objectAtIndex:0] componentsSeparatedByString:@"!|"];
    NSArray *morePurgedElements = [[purgedElements objectAtIndex:0] componentsSeparatedByString:@"?|"];
    self.extraLabel.text = [[[morePurgedElements objectAtIndex:0] stringByReplacingOccurrencesOfString:@"|" withString:@" "] stringByAppendingString:@"."];
    if (theButton.currentTitle != nil)
        self.captionLabel.text = NSLocalizedString(@"This weapon is locked",@"");
    else
        self.captionLabel.text = [NSString stringWithUTF8String:HW_getWeaponCaptionByIndex(theButton.tag)];
    
    self.nameLabel.backgroundColor = [UIColor blackColor];
    self.captionLabel.backgroundColor = [UIColor blackColor];
    self.extraLabel.backgroundColor = [UIColor blackColor];

    int y, x = 8;
    // display labels on top for lower buttons
    if (theButton.tag > 41)
        y = 5;
    else
        y = (HW_getNumberOfWeapons()/BTNS_PER_ROW)*40;

    self.nameLabel.frame = CGRectMake(x, y, 200, 20);
    self.captionLabel.frame = CGRectMake(x+200, y, 220, 20);
    self.extraLabel.frame = CGRectMake(x+2, y+20, 415, 53);
}

-(void) buttonCancelled:(id) sender {
    self.nameLabel.text = nil;
    self.extraLabel.text = nil;
    self.captionLabel.text = nil;
    self.extraLabel.backgroundColor = [UIColor clearColor];
    self.captionLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.backgroundColor = [UIColor clearColor];
}

-(void) buttonReleased:(id) sender {
    UIButton *theButton = (UIButton *)sender;
    if (self.nameLabel == nil || self.extraLabel == nil)
        [self loadLabels];

    if (theButton.currentTitle == nil) {
        HW_setWeapon(theButton.tag);
        playSound(@"clickSound");
        if (IS_DUALHEAD() == NO)
            [self disappear];
    }
    [self buttonCancelled:sender];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];

    if (IS_IPAD() && [touches count] == 1) {
        self.view.layer.borderWidth = 3.5;
        currentPoint = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.view];
    }

    if (IS_IPAD() == NO)
        [self disappear];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.view.layer.borderWidth = 1.3;
}

// better window dragging implementation by
// http://iphonedevelopertips.com/graphics/drag-an-image-within-the-bounds-of-superview.html
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (IS_IPAD() && [touches count] == 1) {
        // Get active location upon move
        CGPoint activePoint = [[touches anyObject] locationInView:self.view];

        // Determine new point based on where the touch is now located
        CGPoint newPoint = CGPointMake(self.view.center.x + (activePoint.x - currentPoint.x),
                                       self.view.center.y + (activePoint.y - currentPoint.y));

        // Make sure we stay within the bounds of the parent view
        float midPointX = CGRectGetMidX(self.view.bounds);
        if (newPoint.x > self.view.superview.bounds.size.width  - midPointX)
            newPoint.x = self.view.superview.bounds.size.width - midPointX;
        else if (newPoint.x < midPointX)
            newPoint.x = midPointX;

        float midPointY = CGRectGetMidY(self.view.bounds);
        if (newPoint.y > self.view.superview.bounds.size.height  - midPointY)
            newPoint.y = self.view.superview.bounds.size.height - midPointY;
        else if (newPoint.y < midPointY)
            newPoint.y = midPointY;

        self.view.center = newPoint;
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark -
#pragma mark memory
-(void) didReceiveMemoryWarning {
    self.imagesArray = nil;
    if (self.isVisible == NO)
        self.buttonsArray = nil;
    self.nameLabel = nil;
    self.extraLabel = nil;
    self.captionLabel = nil;
    MSG_MEMCLEAN();
    [super didReceiveMemoryWarning];
}

-(void) viewDidUnload {
    self.imagesArray = nil;
    self.buttonsArray = nil;
    self.nameLabel = nil;
    self.extraLabel = nil;
    self.captionLabel = nil;
    free(delay);
    delay = NULL;
    free(shouldUpdateImage);
    shouldUpdateImage = NULL;
    MSG_DIDUNLOAD();
    [super viewDidUnload];
}

-(void) dealloc {
    releaseAndNil(nameLabel);
    releaseAndNil(extraLabel);
    releaseAndNil(captionLabel);
    releaseAndNil(imagesArray);
    releaseAndNil(buttonsArray);
    [super dealloc];
}

@end
