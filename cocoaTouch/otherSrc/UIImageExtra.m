//
//  UIImageExtra.m
//  HedgewarsMobile
//
//  Created by Vittorio on 08/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIImageExtra.h"


@implementation UIImage (extra)
 
-(UIImage *)scaleToSize:(CGSize) size {
  // Create a bitmap graphics context
  // This will also set it as the current context
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
    // create a contex of size of the background image
    return [self mergeWith:secondImage atPoint:secondImagePoint atSize:self.size];
}

-(UIImage *)mergeWith:(UIImage *)secondImage atPoint:(CGPoint) secondImagePoint atSize:(CGSize) resultingSize {
    UIGraphicsBeginImageContext(resultingSize);
    
    // drav the background image
    [self drawAtPoint:CGPointMake(0,0)];
    
    // draw the image on top of the first image
    [secondImage drawAtPoint:secondImagePoint];
    
    // create an image from the current contex (not thread safe)
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free drawing contex
    UIGraphicsEndImageContext();
    
    // return the resulting autoreleased image
    return resultImage;
}

-(id) initWithContentsOfFile:(NSString *)path andCutAt:(CGRect) rect {
    // load image from path
    UIImage *image = [[UIImage alloc] initWithContentsOfFile: path];
    
    if (nil != image) {
        // get its CGImage representation with a give size
        CGImageRef cgImgage = CGImageCreateWithImageInRect([image CGImage], rect);
    
        // clean memory
        [image release];
    
        // create a UIImage from the CGImage (memory must be allocated already)
        UIImage *sprite = [self initWithCGImage:cgImgage];
    
        // clean memory
        CGImageRelease(cgImgage);

        // return resulting image
        return sprite;
    } else {
        NSLog(@"initWithContentsOfFile: andCutAt: FAILED");
        return nil;
    }
}

-(UIImage *)convertImageToGrayScale:(UIImage *)image {
  // Create image rectangle with current image width/height
  CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
 
  // Grayscale color space
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
 
  // Create bitmap content with current image size and grayscale colorspace
  CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
 
  // Draw image into current context, with specified rectangle
  // using previously defined context (with grayscale colorspace)
  CGContextDrawImage(context, imageRect, [image CGImage]);
 
  // Create bitmap image info from pixel data in current context
  CGImageRef imageRef = CGBitmapContextCreateImage(context);
 
  // Create a new UIImage object  
  UIImage *newImage = [UIImage imageWithCGImage:imageRef];
 
  // Release colorspace, context and bitmap information
  CGColorSpaceRelease(colorSpace);
  CGContextRelease(context);
  CFRelease(imageRef);
 
  // Return the new grayscale image
  return newImage;
}
 
@end
