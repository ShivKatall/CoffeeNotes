//
//  DataController.m
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/28/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "DataController.h"
#import "CoffeeCell.h"
#import "CuppingCell.h"
#import "AppDelegate+CoreDataContext.h"
#import "UIImage+Scaling.h"

#define dataSourcePListPath [[DataController applicationDocumentsDirectory] stringByAppendingPathComponent:@"DataSourcePropertyList.plist"]

@interface DataController ()


@end

@implementation DataController


#pragma mark - Init Methods

+(DataController *)sharedController
{
    static dispatch_once_t pred;
    static DataController *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[DataController alloc] init];
    });
    return shared;
}

+(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}


#pragma mark - Management Methods

-(NSArray *)fetchAllCoffees
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Coffee"];
    
    NSError *error;
    
    NSSortDescriptor *nameOrOriginSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nameOrOrigin"
                                                                               ascending:YES
                                                                                selector:@selector(localizedStandardCompare:)];

    [fetchRequest setSortDescriptors:@[nameOrOriginSortDescriptor]];
    
    NSArray *fetchedCoffees = [_objectContext executeFetchRequest:fetchRequest error:&error];

    NSLog(@"Coffee Count: %lu", (unsigned long)fetchedCoffees.count);
    NSLog(@"All Coffees: %@", fetchedCoffees);
    
    return fetchedCoffees;
}

#pragma mark - Calculation Methods

- (NSNumber *)averageRatingFromCuppingRatingInCoffee:(Coffee *)coffee
{
    CGFloat sumOfRatingsInCuppings;
   
   for (Cupping *cupping in coffee.cuppings)
   {
       CGFloat rating = cupping.rating.floatValue;
       sumOfRatingsInCuppings += rating;
   }
    
    return [NSNumber numberWithFloat:sumOfRatingsInCuppings/(CGFloat)coffee.cuppings.count];
}

-(UIImage *)mostRecentImageInCoffee:(Coffee *)coffee
{
    UIImage *coffeeImage = [UIImage imageNamed:@"placeholder"];
    NSURL *docsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                      inDomains:NSUserDomainMask] firstObject];
    NSString *docsDirectory = docsURL.path;
    
    if (coffee.photo) {
        return coffee.photo;
    } else {
        for (Cupping *cupping in coffee.cuppings.allObjects.reverseObjectEnumerator.allObjects) {
            coffeeImage = cupping.photo;
            NSData *imageData = UIImageJPEGRepresentation([cupping.photo resizedImage:CGSizeMake(1024.f, 1024.f)], 0.5);
            NSUUID *imageUUID = [NSUUID UUID];
            NSString *imagePath = [[docsDirectory stringByAppendingPathComponent:imageUUID.UUIDString] stringByAppendingPathExtension:@"jpg"];
            if ([imageData writeToFile:imagePath atomically:YES]) {
                cupping.photoPath = imagePath;
                NSError *error;
                if ([cupping.managedObjectContext save:&error]) {
                    if (error) {
                        NSLog(@"Error Saving Image: %@", error.localizedDescription);
                    } else {
                        return [self mostRecentImageInCoffee:coffee];
                    }
                }
            }
        }
    }
    
    
    return coffeeImage;
}



#pragma mark - Sorting Methods

+ (NSArray *)cuppingsSortedByDateForCoffee:(Coffee *)coffee
{
    NSArray *cuppings = [coffee.cuppings allObjects];
    NSSortDescriptor *cuppingDateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cuppingDate"
                                                                              ascending:YES
                                                                               selector:@selector(compare:)];
    return [cuppings sortedArrayUsingDescriptors:@[cuppingDateSortDescriptor]];
}

#pragma mark - Temporary/Test Methods

- (void)seedInitialDataWithCompletion:(void (^)())block
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate createManagedObjectContext:^(NSManagedObjectContext *context) {
        
        _objectContext = context;
        
//        Coffee *seattleCoffee = [NSEntityDescription insertNewObjectForEntityForName:@"Coffee" inManagedObjectContext:self.objectContext];
//        seattleCoffee.nameOrOrigin = @"Ethiopian Yergecheffe";
//        seattleCoffee.roaster = @"Conduit Coffee";
//        
//        Coffee *kentuckeyCoffee = [NSEntityDescription insertNewObjectForEntityForName:@"Coffee" inManagedObjectContext:self.objectContext];
//        kentuckeyCoffee.nameOrOrigin = @"House Blend";
//        kentuckeyCoffee.roaster = @"Moonshine Coffee Roasters";
//        
//        Coffee *frenchCoffee = [NSEntityDescription insertNewObjectForEntityForName:@"Coffee" inManagedObjectContext:self.objectContext];
//        frenchCoffee.nameOrOrigin = @"French Roast (Obviously)";
//        frenchCoffee.roaster = @"Le Caffee du Chat";
        
        NSError *error;
        
        [_objectContext save:&error];
        
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }
        
        block();
        
    }];

}

-(NSString *)createStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *dateString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    return dateString;
}


@end
