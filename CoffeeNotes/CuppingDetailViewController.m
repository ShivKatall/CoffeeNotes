//
//  CuppingDetailViewController.m
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/25/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "CuppingDetailViewController.h"
#import "AddOrEditCuppingViewController.h"
#import <AXRatingView/AXRatingView.h>

@interface CuppingDetailViewController ()

// labels and text fields
@property (weak, nonatomic) IBOutlet UILabel *nameOrOriginLabel;
@property (weak, nonatomic) IBOutlet UILabel *roasterLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuppingDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roastDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *brewingMethodLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;


// views
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet AXRatingView *ratingView;

@end


@implementation CuppingDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // labels
    _nameOrOriginLabel.text         = _selectedCoffee.nameOrOrigin;
    _roasterLabel.text              = _selectedCoffee.roaster;
    _locationLabel.text             = _selectedCupping.location;
    _cuppingDateLabel.text          = [[DataController sharedController] createStringFromDate:_selectedCupping.cuppingDate];
    _roastDateLabel.text            = [[DataController sharedController] createStringFromDate:_selectedCupping.roastDate];
    if (!_selectedCupping.roastDate){
        _roastDateLabel.text = @" ";
    }
    
    _brewingMethodLabel.text        = _selectedCupping.brewingMethod;
    _notesTextView.text            = _selectedCupping.cuppingNotes;
    _notesTextView.editable        = NO;
    
    
    // views and imageViews
    
    _photoImageView.layer.cornerRadius = 11;
    _photoImageView.layer.masksToBounds = YES;
    
    if (_selectedCupping.photo) {
        _photoImageView.image           = _selectedCupping.photo;
    }
    
    _notesTextView.layer.cornerRadius = 11;
    
    [_ratingView sizeToFit];
    [_ratingView setStepInterval:0.5];
    [_ratingView setUserInteractionEnabled:NO];
    
    _ratingView.value = _selectedCupping.rating.floatValue;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditCuppingSegue"]) {
        AddOrEditCuppingViewController *destination = segue.destinationViewController;
        destination.editableCupping = _selectedCupping;
        destination.selectedCoffee = _selectedCoffee;
    }
}

@end
