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
 * File created on 08/04/2010.
 */


#import "UIImageExtra.h"


@implementation UIImage (extra)

CGFloat getScreenScale(void) {
    float scale = 1.0f;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        scale = [[UIScreen mainScreen] scale];
    return scale;
}

-(UIImage *)scaleToSize:(CGSize) size {
    DLog(@"warning - this is a very expensive operation, you should avoid using it");

    // Create a bitmap graphics context; this will also set it as the current context
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size, NO, getScreenScale());
    else
        UIGraphicsBeginImageContext(size);

    // Draw the scaled image in the current context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];

    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    // Pop the current context from the stack
    UIGraphicsEndImageContext();

    // Return our new scaled image (autoreleased)
    return scaledImage;
}

-(UIImage *)mergeWith:(UIImage *)secondImage atPoint:(CGPoint) secondImagePoint {
    if (secondImage == nil) {
        DLog(@"Warning, secondImage == nil");
        return self;
    }
    CGFloat screenScale = getScreenScale();
    int w = self.size.width * screenScale;
    int h = self.size.height * screenScale;
    
    if (w == 0 || h == 0) {
        DLog(@"Can have 0 dimesions");
        return self;
    }
    
    // Create a bitmap graphics context; this will also set it as the current context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    // draw the two images in the current context
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width*screenScale, self.size.height*screenScale), [self CGImage]);
    CGContextDrawImage(context, CGRectMake(secondImagePoint.x*screenScale, secondImagePoint.y*screenScale, secondImage.size.width*screenScale, secondImage.size.height*screenScale), [secondImage CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *resultImage;
    if ([self respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
        resultImage = [UIImage imageWithCGImage:imageRef scale:screenScale orientation:UIImageOrientationUp];
    else
        resultImage = [UIImage imageWithCGImage:imageRef];

    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
   
    return resultImage;
}

-(id) initWithContentsOfFile:(NSString *)path andCutAt:(CGRect) rect {
    // load image from path
    UIImage *image = [[UIImage alloc] initWithContentsOfFile: path];

    if (nil != image) {
        // get its CGImage representation with a give size
        CGImageRef cgImage = CGImageCreateWithImageInRect([image CGImage], rect);

        // clean memory
        [image release];

        // create a UIImage from the CGImage (memory must be allocated already)
        UIImage *sprite = [self initWithCGImage:cgImage];

        // clean memory
        CGImageRelease(cgImage);

        // return resulting image
        return sprite;
    } else {
        DLog(@"error - image == nil");
        return nil;
    }
}

-(UIImage *)cutAt:(CGRect) rect {
    CGImageRef cgImage = CGImageCreateWithImageInRect([self CGImage], rect);

    UIImage *res = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    return res;
}

-(UIImage *)convertToGrayScale {
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);

    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, colorSpace, kCGImageAlphaNone);

    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [self CGImage]);

    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);

    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];

    // Release colorspace, context and bitmap information
    CFRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Return the new grayscale image
    return newImage;
}

// by http://iphonedevelopertips.com/cocoa/how-to-mask-an-image.html turned into a category by koda
-(UIImage*) maskImageWith:(UIImage *)maskImage {
    // prepare the reference image
    CGImageRef maskRef = [maskImage CGImage];

    // create the mask using parameters of the mask reference
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);

    // create an image in the current context
    CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
    CGImageRelease(mask);

    UIImage* retImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);

    return retImage;
}

// by http://blog.sallarp.com/iphone-uiimage-round-corners/ turned into a category by koda
void addRoundedRectToPath(CGContextRef context, CGRect rect, CGFloat ovalWidth, CGFloat ovalHeight) {
    CGFloat fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

-(UIImage *)makeRoundCornersOfSize:(CGSize) sizewh {
    CGFloat cornerWidth = sizewh.width;
    CGFloat cornerHeight = sizewh.height;
    CGFloat screenScale = getScreenScale();
    CGFloat w = self.size.width * screenScale;
    CGFloat h = self.size.height * screenScale;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);

    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, w, h);
    addRoundedRectToPath(context, rect, cornerWidth, cornerHeight);
    CGContextClosePath(context);
    CGContextClip(context);

    CGContextDrawImage(context, CGRectMake(0, 0, w, h), [self CGImage]);

    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    UIImage *newImage;
    if ([self respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
        newImage = [UIImage imageWithCGImage:imageMasked scale:screenScale orientation:UIImageOrientationUp];
    else
        newImage = [UIImage imageWithCGImage:imageMasked];

    CGImageRelease(imageMasked);

    return newImage;
}

// by http://www.sixtemia.com/journal/2010/06/23/uiimage-negative-color-effect/
-(UIImage *)convertToNegative {
    UIGraphicsBeginImageContext(self.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height));
    // create an image from the current contex (not thread safe)
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+(UIImage *)whiteImage:(CGSize) ofSize {
    CGFloat w = ofSize.width;
    CGFloat h = ofSize.height;
    DLog(@"w: %f, h: %f", w, h);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);

    CGContextBeginPath(context);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context,CGRectMake(0,0,ofSize.width,ofSize.height));

    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    UIImage *bkgImg = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return bkgImg;
}

@end
