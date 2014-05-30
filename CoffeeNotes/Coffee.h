//
//  Coffee.h
//  CoffeeNotes
//
//  Created by Cole Bratcher on 5/16/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cupping;

@interface Coffee : NSManagedObject

@property (nonatomic, retain) NSNumber * averageRating;
@property (nonatomic, retain) id mostRecentPhoto;
@property (nonatomic, retain) NSString * nameOrOrigin;
@property (nonatomic, retain) NSString * roaster;
@property (nonatomic, retain) NSSet *cuppings;
//@property (nonatomic, retain) NSData *thumbnail;
@end

@interface Coffee (CoreDataGeneratedAccessors)

- (void)addCuppingsObject:(Cupping *)value;
- (void)removeCuppingsObject:(Cupping *)value;
- (void)addCuppings:(NSSet *)values;
- (void)removeCuppings:(NSSet *)values;

@end
