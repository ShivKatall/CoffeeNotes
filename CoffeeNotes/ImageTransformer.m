//
//  ImageTransformer.m
//  CoffeeNotes
//
//  Created by Cole Bratcher on 5/8/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "ImageTransformer.h"
#import "UIImage+Scaling.h"

@implementation ImageTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    return UIImageJPEGRepresentation(value, .5);
}

- (id)reverseTransformedValue:(id)value
{
    return [[UIImage alloc] initWithData:value];
}

@end
