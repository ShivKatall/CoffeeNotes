//
//  UIImage+Scaling.m
//  CoffeeNotes
//
//  Created by Cole Bratcher on 5/29/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "UIImage+Scaling.h"
@import CoreGraphics;
@import Accelerate;
#import <float.h>

@implementation UIImage (Scaling)
- (UIImage *)resizedImage:(CGSize)newSize {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self vImageScaledImageWithSize:newSize transpose:drawTransposed];
}

- (UIImage *)vImageScaledImageWithSize:(CGSize)newSize transpose:(BOOL)transpose
{
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    
    if (transpose) {
        newRect = transposedRect;
    }
    
    CGSize desiredSize = newRect.size;
    UIImage *scaledImage = nil;
    
    // Convert UIImage to array of bytes in ARGB8888 pixel format
    CGImageRef sourceRef = [self CGImage];
    NSUInteger sourceWidth = CGImageGetWidth(sourceRef);
    NSUInteger sourceHeight = CGImageGetHeight(sourceRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *sourceData = (unsigned char*)calloc(sourceHeight * sourceWidth * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger sourceBytesPerRow = bytesPerPixel * sourceWidth;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(sourceData, sourceWidth, sourceHeight,
                                                 bitsPerComponent, sourceBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    
    if (context == NULL){
        NSString *errorReason = [NSString stringWithFormat:@"vImageScale source context ref null"];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self, @"sourceImage",
                                   [NSValue valueWithCGSize:newSize], @"destSize",
                                   nil];
        NSLog(@"%@: %@", errorReason, errorInfo);
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, sourceWidth, sourceHeight), sourceRef);
    CGContextRelease(context);
    
    NSUInteger destWidth = (NSUInteger)desiredSize.width;
    NSUInteger destHeight = (NSUInteger)desiredSize.height;
    NSUInteger destBytesPerRow = bytesPerPixel * destWidth;
    unsigned char *destData = (unsigned char*)calloc(destHeight * destWidth * 4, sizeof(unsigned char));
    
    // Create vImage_Buffers for both arrays
    vImage_Buffer src = {
        .data = sourceData,
        .height = sourceHeight,
        .width = sourceWidth,
        .rowBytes = sourceBytesPerRow
    };
    
    vImage_Buffer dest = {
        .data = destData,
        .height = destHeight,
        .width = destWidth,
        .rowBytes = destBytesPerRow
    };
    
    // Resize image
    vImage_Error err = vImageScale_ARGB8888(&src, &dest, NULL, kvImageNoAllocate + kvImageHighQualityResampling);
    CGContextRef destContext = CGBitmapContextCreate(destData, destWidth, destHeight,
                                                     bitsPerComponent, destBytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    if (destContext == NULL){
        NSString *errorReason = [NSString stringWithFormat:@"vImageScale destination context ref null"];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self, @"sourceImage",
                                   [NSValue valueWithCGSize:newSize], @"destSize",
                                   nil];
        NSLog(@"%@: %@", errorReason, errorInfo);
    }
    
    free(sourceData);
    
    CGImageRef destRef = CGBitmapContextCreateImage(destContext);
    scaledImage = [UIImage imageWithCGImage:destRef];
    free(destData);
    
    CGImageRelease(destRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(destContext);
    
    // Error handling
    if (err != kvImageNoError) {
        NSString *errorReason = [NSString stringWithFormat:@"vImageScale returned error code %zd", err];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self, @"sourceImage",
                                   [NSValue valueWithCGSize:newSize], @"destSize",
                                   nil];
        
        NSException *exception = [NSException exceptionWithName:@"HighQualityImageScalingFailureException" reason:errorReason userInfo:errorInfo];
        
        @throw exception;
    }
    
    return scaledImage;
}

@end