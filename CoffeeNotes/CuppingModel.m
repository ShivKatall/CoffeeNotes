//
//  Cupping.m
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/24/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "CuppingModel.h"

@implementation CuppingModel

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.cuppingNameOrOrigin    = [aDecoder decodeObjectForKey:@"cuppingNameOrOrigin"];
        self.cuppingRoaster         = [aDecoder decodeObjectForKey:@"cuppingRoaster"];
        self.location               = [aDecoder decodeObjectForKey:@"location"];
        self.cuppingDate            = [aDecoder decodeObjectForKey:@"cuppingDate"];
        self.roastDate              = [aDecoder decodeObjectForKey:@"roastDate"];
        self.brewingMethod          = [aDecoder decodeObjectForKey:@"brewingMethod"];
        self.cuppingRating          = [aDecoder decodeObjectForKey:@"cuppingRating"];
        self.image                  = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"image"]];
        self.cuppingNotes           = [aDecoder decodeObjectForKey:@"cuppingNotes"];

    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.cuppingNameOrOrigin   forKey:@"cuppingNameOrOrigin"];
    [aCoder encodeObject:self.cuppingRoaster        forKey:@"cuppingRoaster"];
    [aCoder encodeObject:self.location              forKey:@"location"];
    [aCoder encodeObject:self.location              forKey:@"location"];
    [aCoder encodeObject:self.cuppingDate           forKey:@"cuppingDate"];
    [aCoder encodeObject:self.roastDate             forKey:@"roastDate"];
    [aCoder encodeObject:self.brewingMethod         forKey:@"brewingMethod"];
    [aCoder encodeObject:self.cuppingRating         forKey:@"cuppingRating"];
    [aCoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"image"];
    [aCoder encodeObject:self.cuppingNotes          forKey:@"cuppingNotes"];
}

@end
