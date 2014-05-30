//
//  ViewController.m
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/24/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "CoffeesViewController.h"
#import "CoffeeDetailViewController.h"
#import "CoffeeCell.h"
#import "Coffee.h"
#import "AppDelegate+CoreDataContext.h"

@interface CoffeesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end


@implementation CoffeesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _coffeesTableView.delegate      = self;
    _coffeesTableView.dataSource    = self;
    
}

- (NSArray *)coffees
{
    return [[DataController sharedController] fetchAllCoffees];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DataController sharedController] seedInitialDataWithCompletion:^{
        
        [_coffeesTableView reloadData];


    }];


}


#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"CoffeeDetailSegue"]) {
        CoffeeDetailViewController *destination = segue.destinationViewController;
        NSIndexPath *indexPath      = [_coffeesTableView indexPathForSelectedRow];
        destination.selectedCoffee  = [self coffees][indexPath.row];
    }
}

-(IBAction)addCoffeeExitSegue:(UIStoryboardSegue *)sender
{
    // Empty method for Exit Segue functionality.
}

- (IBAction)deleteCoffeeSegue:(UIStoryboardSegue *)sender
{
    // Empty method for Exit Segue functionality.
}

#pragma mark - UITableViewDelegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DataController sharedController] fetchAllCoffees].count;
}

- (void)configureCell:(CoffeeCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    [(UIImageView *)cell.accessoryView setImage:[UIImage imageNamed:@"right-arrow@2x"]];

    Coffee *coffee      = [[[DataController sharedController] fetchAllCoffees] objectAtIndex:indexPath.row];
    
    cell.coffeeCellNameOrOriginLabel.text   = [NSString stringWithFormat:@"%@", coffee.nameOrOrigin];
    cell.coffeeCellRoasterLabel.text        = [NSString stringWithFormat:@"%@", coffee.roaster];
    
    [cell.coffeeCellAverageRating sizeToFit];
    [cell.coffeeCellAverageRating setStepInterval:0.5];
    [cell.coffeeCellAverageRating setUserInteractionEnabled:NO];
    
    cell.coffeeCellAverageRating.value = [[[DataController sharedController]averageRatingFromCuppingRatingInCoffee:coffee]floatValue];
    if (![[[DataController sharedController]averageRatingFromCuppingRatingInCoffee:coffee]floatValue]) {
        cell.coffeeCellAverageRating.value = 0.0;
    }
    
    cell.coffeeCellImage.image = coffee.photo;
    cell.coffeeCellImage.layer.cornerRadius = 11;
    cell.coffeeCellImage.layer.masksToBounds = YES;
}

-(CoffeeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoffeeCell *cell    = [tableView dequeueReusableCellWithIdentifier:@"CoffeeCell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

@end





/* 
 delete me if no longer needed, use this code if you need to seed alot of coffees into core data
 //        for (int i=0; i<100; i++) {
 //            Coffee *oldCoffee = i % 2 ? [_coffees firstObject] : [_coffees lastObject];
 //            _managedObjectContext = oldCoffee.managedObjectContext;
 //            Coffee *newCoffee = [self newCopyOfCoffee:oldCoffee withNonce:[NSString stringWithFormat:@"#%d", i]];
 //            NSLog(@"Created New Coffee: %@", newCoffee.nameOrOrigin);
 //        }
 
 //- (Coffee *)newCopyOfCoffee:(Coffee *)oldCoffee withNonce:(NSString *)nonce
 //{
 //    Coffee *newCoffee;
 //    Cupping *oldCupping = [[oldCoffee.cuppings allObjects] firstObject];
 //
 //    newCoffee = [NSEntityDescription insertNewObjectForEntityForName:@"Coffee" inManagedObjectContext:_managedObjectContext];
 //
 //    newCoffee.nameOrOrigin  = [oldCoffee.nameOrOrigin stringByAppendingString:nonce];
 //    newCoffee.roaster       = [oldCoffee.roaster stringByAppendingString:nonce];
 //
 //    NSError *error;
 //
 //    // New Cupping Stuff
 //    Cupping *newCupping         = [NSEntityDescription insertNewObjectForEntityForName:@"Cupping" inManagedObjectContext:_managedObjectContext];
 //    newCupping.location         = oldCupping.location;
 //    newCupping.cuppingDate      = oldCupping.cuppingDate;
 //
 //    newCupping.roastDate        = oldCupping.roastDate;
 //    newCupping.brewingMethod    = oldCupping.brewingMethod;
 //
 //    newCupping.rating               = oldCupping.rating;
 //    newCupping.photo                = oldCupping.photo;
 //    newCupping.cuppingNotes         = [oldCupping.cuppingNotes stringByAppendingString:nonce];
 //
 //    newCupping.coffee = newCoffee;
 //
 //    [_managedObjectContext save:&error];
 //
 //    if (error) {
 //        NSLog(@"Error Duplicating Objects for Seed");
 //        return nil;
 //    } else {
 //        return newCoffee;
 //    }
 //}

 */