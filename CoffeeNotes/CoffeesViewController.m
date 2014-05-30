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

@property (nonatomic, weak) Coffee *coffee;
@property (nonatomic, strong) NSArray *coffees;
@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;

@end


@implementation CoffeesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _coffeesTableView.delegate      = self;
    _coffeesTableView.dataSource    = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[DataController sharedController] seedInitialDataWithCompletion:^{
        
        _coffees = [[DataController sharedController] fetchAllCoffees];
        
        [_coffeesTableView reloadData];
    }];
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"CoffeeDetailSegue"]) {
        CoffeeDetailViewController *destination = segue.destinationViewController;
        NSIndexPath *indexPath      = [_coffeesTableView indexPathForSelectedRow];
        destination.selectedCoffee  = _coffees[indexPath.row];
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
    return _coffees.count;
}

-(CoffeeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoffeeCell *cell    = [tableView dequeueReusableCellWithIdentifier:@"CoffeeCell" forIndexPath:indexPath];
    
    cell.accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [(UIImageView *)cell.accessoryView setImage:[UIImage imageNamed:@"right-arrow@2x"]];
    
    Coffee *coffee      = [_coffees objectAtIndex:indexPath.row];
    
    cell.coffeeCellNameOrOriginLabel.text   = [NSString stringWithFormat:@"%@", coffee.nameOrOrigin];
    cell.coffeeCellRoasterLabel.text        = [NSString stringWithFormat:@"%@", coffee.roaster];
    
    [cell.coffeeCellAverageRating sizeToFit];
    [cell.coffeeCellAverageRating setStepInterval:0.5];
    [cell.coffeeCellAverageRating setUserInteractionEnabled:NO];
    
    cell.coffeeCellAverageRating.value = [[[DataController sharedController]averageRatingFromCuppingRatingInCoffee:coffee]floatValue];
    if (![[[DataController sharedController]averageRatingFromCuppingRatingInCoffee:coffee]floatValue]) {
        cell.coffeeCellAverageRating.value = 0.0;
    }
    
    coffee.mostRecentPhoto = [[DataController sharedController]mostRecentImageInCoffee:coffee];
    if (coffee.mostRecentPhoto) {
        cell.coffeeCellImage.image = coffee.mostRecentPhoto;
    }
    
    cell.coffeeCellImage.layer.cornerRadius = 11;
    cell.coffeeCellImage.layer.masksToBounds = YES;
    
    return cell;
}

@end
