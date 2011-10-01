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
 * File created on 20/04/2010.
 */


#import "SquareButtonView.h"
#import <QuartzCore/QuartzCore.h>


@implementation SquareButtonView
@synthesize colorArray, selectedColor, ownerDictionary;

-(id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        colorIndex = -1;
        selectedColor = 0;

        self.colorArray = [HWUtils teamColors];

        // set the color to the first available one
        [self nextColor];

        // this makes the button round and nice with a border
        [self.layer setCornerRadius:7.0f];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:2];
        [self.layer setBorderColor:[[UIColor darkYellowColor] CGColor]];

        // this changes the color at button press
        [self addTarget:self action:@selector(nextColor) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void) nextColor {
    colorIndex++;

    if (colorIndex >= [colorArray count])
        colorIndex = 0;

    NSUInteger color = [[self.colorArray objectAtIndex:colorIndex] unsignedIntValue];
    self.backgroundColor = [UIColor colorWithRed:((color & 0x00FF0000) >> 16)/255.0f
                                           green:((color & 0x0000FF00) >> 8)/255.0f
                                            blue: (color & 0x000000FF)/255.0f
                                           alpha:1.0f];

    [ownerDictionary setObject:[NSNumber numberWithInt:color] forKey:@"color"];
}

-(void) selectColor:(NSUInteger) color {
    if (color != selectedColor) {
        selectedColor = color;
        colorIndex = [self.colorArray indexOfObject:[NSNumber numberWithUnsignedInt:color]];

        self.backgroundColor = [UIColor colorWithRed:((color & 0x00FF0000) >> 16)/255.0f
                                               green:((color & 0x0000FF00) >> 8)/255.0f
                                                blue: (color & 0x000000FF)/255.0f
                                               alpha:1.0f];
    }
}

-(void) dealloc {
    releaseAndNil(ownerDictionary);
    releaseAndNil(colorArray);
    [super dealloc];
}


@end
