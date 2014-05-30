//
//  Cupping.h
//  CoffeeNotes
//
//  Created by Cole Bratcher on 5/16/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coffee;

@interface Cupping : NSManagedObject

@property (nonatomic, retain) NSString * brewingMethod;
@property (nonatomic, retain) NSDate * cuppingDate;
@property (nonatomic, retain) NSString * cuppingNotes;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * nameOrOrigin;
@property (nonatomic, retain) id photo;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * roastDate;
@property (nonatomic, retain) NSString * roaster;
@property (nonatomic, retain) Coffee *coffee;
//@property (nonatomic, retain) NSData *thumbnail;
@end
