/*
 * Hedgewars-iOS, a Hedgewars port for iOS devices
 * Copyright (c) 2009-2010 Vittorio Giovara <vittorio.giovara@gmail.com>
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
 * File created on 25/10/2011.
 */


#import "ExtraCategories.h"
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>


@implementation UIScreen (safe)

-(CGFloat) safeScale {
    CGFloat theScale = 1.0f;
    if ([self respondsToSelector:@selector(scale)])
         theScale = [self scale];
    return theScale;
}

@end


@implementation UITableView (backgroundColor)

-(void) setBackgroundColorForAnyTable:(UIColor *) color {
    if ([self respondsToSelector:@selector(backgroundView)]) {
        UIView *backView = [[UIView alloc] initWithFrame:self.frame];
        backView.backgroundColor = color;
        self.backgroundView = backView;
        [backView release];
        self.backgroundColor = [UIColor clearColor];
    } else
        self.backgroundColor = color;
}

@end


@implementation UIColor (HWColors)

+(UIColor *)darkYellowColor {
    return [UIColor colorWithRed:(CGFloat)0xFE/255 green:(CGFloat)0xC0/255 blue:0 alpha:1];
}

+(UIColor *)lightYellowColor {
    return [UIColor colorWithRed:(CGFloat)0xF0/255 green:(CGFloat)0xD0/255 blue:0 alpha:1];
}

+(UIColor *)darkBlueColor {
    return [UIColor colorWithRed:(CGFloat)0x0F/255 green:0 blue:(CGFloat)0x42/255 alpha:1];
}

// older devices don't get any transparency for performance reasons
+(UIColor *)darkBlueColorTransparent {
    return [UIColor colorWithRed:(CGFloat)0x0F/255
                           green:0
                            blue:(CGFloat)0x55/255
                           alpha:IS_NOT_POWERFUL([HWUtils modelType]) ? 1 : 0.6f];
}

+(UIColor *)blackColorTransparent {
    return [UIColor colorWithRed:0
                           green:0
                            blue:0
                           alpha:IS_NOT_POWERFUL([HWUtils modelType]) ? 1 : 0.65f];
}

@end


@implementation UILabel (quickStyle)

-(UILabel *)initWithFrame:(CGRect)frame andTitle:(NSString *)title {
    return [self initWithFrame:frame
                      andTitle:title
               withBorderWidth:1.5f
               withBorderColor:[UIColor darkYellowColor]
           withBackgroundColor:[UIColor darkBlueColor]];
}

-(UILabel *)initWithFrame:(CGRect)frame andTitle:(NSString *)title  withBorderWidth:(CGFloat) borderWidth {
    return [self initWithFrame:frame
                      andTitle:title
               withBorderWidth:borderWidth
               withBorderColor:[UIColor darkYellowColor]
           withBackgroundColor:[UIColor darkBlueColorTransparent]];
}

-(UILabel *)initWithFrame:(CGRect)frame andTitle:(NSString *)title  withBorderWidth:(CGFloat) borderWidth
          withBorderColor:(UIColor *)borderColor withBackgroundColor:(UIColor *)backColor{
    UILabel *theLabel = [self initWithFrame:frame];
    theLabel.backgroundColor = backColor;

    if (title != nil) {
        theLabel.text = title;
        theLabel.textColor = [UIColor lightYellowColor];
        theLabel.textAlignment = UITextAlignmentCenter;
        theLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]*80/100];
    }

    [theLabel.layer setBorderWidth:borderWidth];
    [theLabel.layer setBorderColor:borderColor.CGColor];
    [theLabel.layer setCornerRadius:8.0f];
    [theLabel.layer setMasksToBounds:YES];

    return theLabel;
}

@end


@implementation NSString (MD5)

-(NSString *)MD5hash {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5],
            result[6], result[7], result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end
