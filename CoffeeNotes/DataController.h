//
//  DataController.h
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/28/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coffee.h"
#import "Cupping.h"

@interface DataController : NSObject

@property (strong, nonatomic) NSMutableArray *coffees;
@property (weak, nonatomic) NSManagedObjectContext *objectContext;

// Init Methods
+ (DataController *)sharedController;
+ (NSString *)applicationDocumentsDirectory;

// Management Methods
- (NSArray *)fetchAllCoffees;
//-(NSArray *)fetchAllCuppingsForCoffee:(Coffee *)coffee;

// Calculation Methods
- (NSNumber *)averageRatingFromCuppingRatingInCoffee:(Coffee *)coffee;

// Sorting Methods
//- (void)sortByCoffeeNameOrOrigin;
//- (void)sortByCuppingDateInCoffee:(Coffee *)coffee;

+ (NSArray *)cuppingsSortedByDateForCoffee:(Coffee *)coffee;

// Temporary/Test Methods
- (void)seedInitialDataWithCompletion:(void (^)())block;



- (NSString *)createStringFromDate:(NSDate *)date;

- (UIImage *)mostRecentImageInCoffee:(Coffee *)coffee;

@end
