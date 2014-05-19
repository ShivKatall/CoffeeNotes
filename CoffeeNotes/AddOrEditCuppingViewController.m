//
//  NewCuppingViewController.m
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/25/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "AddOrEditCuppingViewController.h"
#import "CuppingModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AXRatingView/AXRatingView.h>
#import "AppDelegate.h"
#import "CoffeeDatePickerViewController.h"



@interface AddOrEditCuppingViewController () <UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate>

// labels
@property (weak, nonatomic) IBOutlet UILabel *coffeeNameOrOriginLabel;
@property (weak, nonatomic) IBOutlet UILabel *roasterLabel;

// text fields
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *brewingMethodTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

// views and image views
@property (weak, nonatomic) IBOutlet UIScrollView *addOrEditCuppingScrollView;
@property (weak, nonatomic) IBOutlet AXRatingView *cuppingRatingView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

// other
@property (strong, nonatomic) UIActionSheet *addOrChangePhotoActionSheet;

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@end


@implementation AddOrEditCuppingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate                = [UIApplication sharedApplication].delegate;
    _managedObjectContext               = appDelegate.objectContext;

    _coffeeNameOrOriginLabel.text       = _selectedCoffee.nameOrOrigin;
    _roasterLabel.text                  = _selectedCoffee.roaster;
    
    _locationTextField.delegate         = self;
    _brewingMethodTextField.delegate    = self;
    _notesTextView.delegate             = self;
    _cuppingRatingView.value            = [[[DataController sharedController] averageRatingFromCuppingRatingInCoffee:_selectedCoffee]floatValue];
    if (_editableCupping) {
        
        _locationTextField.text                                 = _editableCupping.location;
        _brewingMethodTextField.text                            = _editableCupping.brewingMethod;
        _notesTextView.text                                     = _editableCupping.cuppingNotes;
        _cuppingRatingView.value                                = _editableCupping.rating.floatValue;
        _deleteCuppingButton.enabled                            = YES;
        _cuppingCuppingDateHolder                               = _editableCupping.cuppingDate;
        _cuppingRoastDateHolder                                 = _editableCupping.roastDate;
        _chooseCuppingDateFromCuppingButton.titleLabel.text     = [[DataController sharedController]createStringFromDate:_cuppingCuppingDateHolder];
        _chooseRoastDateFromCuppingButton.titleLabel.text       = [[DataController sharedController]createStringFromDate:_cuppingRoastDateHolder];
        _mainViewSaveButton.enabled                             = (_cuppingCuppingDateHolder != nil);
        _navigationBarSaveButton.enabled                        = (_cuppingCuppingDateHolder != nil);
        _photoImageView.image                                   = _editableCupping.photo;
    }
    
    [_cuppingRatingView sizeToFit];
    [_cuppingRatingView setStepInterval:0.5];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

-(IBAction)addOrChangePhotoButtonPressed:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.addOrChangePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                         destructiveButtonTitle:@"Delete Photo"
                                                              otherButtonTitles:@"Take Photo",@"Choose Photo", nil];
        
    } else {
        
        self.addOrChangePhotoActionSheet  = [[UIActionSheet alloc] initWithTitle:@"Photos"
                                                                        delegate:self
                                                               cancelButtonTitle:@"Cancel"
                                                          destructiveButtonTitle:@"Delete Photo"
                                                               otherButtonTitles:@"Choose Photo", nil];
    }
    [self.addOrChangePhotoActionSheet showInView:self.view];
}

- (IBAction)deleteCuppingButtonPressed:(id)sender
{
    if ([self.deleteCuppingButton isEnabled]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Are you sure you want to delete this cupping?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Delete", nil];
        [alertView show];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddCuppingSaveExitSegue"])
    {
        Cupping *newCupping;
        
        if (self.editableCupping) {
            newCupping = self.editableCupping;
        } else {
            newCupping = [NSEntityDescription insertNewObjectForEntityForName:@"Cupping" inManagedObjectContext:self.selectedCoffee.managedObjectContext];;
        }
        
        newCupping.location = self.locationTextField.text;
        newCupping.rating = [[NSNumber alloc] initWithFloat:self.cuppingRatingView.value];
        newCupping.brewingMethod = self.brewingMethodTextField.text;
        newCupping.cuppingNotes = self.notesTextView.text;
        newCupping.photo = self.photoImageView.image;
        newCupping.cuppingDate = _cuppingCuppingDateHolder;
        newCupping.roastDate   = _cuppingRoastDateHolder;
        
        NSNumber *numberFromFloatValue = [[NSNumber alloc]initWithFloat:self.cuppingRatingView.value];
        newCupping.rating = numberFromFloatValue;
        
        newCupping.coffee = _selectedCoffee;
        
        NSError *error;
        [_selectedCoffee.managedObjectContext save:&error];
        
    } else if ([segue.identifier isEqualToString:@"PickCuppingDateFromCupping"]) {
        
        CoffeeDatePickerViewController *destination = segue.destinationViewController;
        destination.datePickerDate = self.cuppingCuppingDateHolder;
        destination.segueKey = @"PickCuppingDateFromCupping";
        
    } else if ([segue.identifier isEqualToString:@"PickRoastDateFromCupping"]) {
        CoffeeDatePickerViewController *destination = segue.destinationViewController;
        destination.datePickerDate = self.cuppingRoastDateHolder;
        destination.segueKey = @"PickRoastDateFromCupping";
        
    } else if ([segue.identifier isEqualToString:@"deleteCupping"]) {
        
    }
}

-(IBAction)CuppingDatePickerExitSegue:(UIStoryboardSegue *)sender
{
    // Empty method for Exit Segue functionality.
}

#pragma mark - UITextField and UITextView Methods (Delegate and non-delegate)

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.locationTextField) {
        [self.addOrEditCuppingScrollView setContentOffset:CGPointMake(0, self.locationTextField.frame.origin.y - 100) animated:YES];
    } else if (textField == self.brewingMethodTextField) {
        [self.addOrEditCuppingScrollView setContentOffset:CGPointMake(0, self.brewingMethodTextField.frame.origin.y - 100) animated:YES];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.notesTextView) {
        [self.addOrEditCuppingScrollView setContentOffset:CGPointMake(0, self.notesTextView.frame.origin.y - 100) animated:YES];
    }
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
        
        sourceType = UIImagePickerControllerSourceTypeCamera;
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Choose Photo" ]) {
        
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    } else {
        
        return;
    }
    
    [self showPickerWithSourceType:sourceType];
}

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = sourceType;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePicker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Completed");
        
        self.photoImageView.image = originalImage;
        
        ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
            [assetsLibrary writeImageToSavedPhotosAlbum:originalImage.CGImage
                                            orientation:ALAssetOrientationUp
                                        completionBlock:^(NSURL *assetURL, NSError *error) {
                                            if (error) {
                                                NSLog(@"Error Saving Image: %@", error.localizedDescription);
                                            }
                                        }];
        } else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Save Photo"
                                                                message:@"Authorization status not granted"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else {
            NSLog(@"Authorization Not Determined");
        }
    }];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {

        [_editableCupping.managedObjectContext deleteObject:_editableCupping];
        
        [self performSegueWithIdentifier:@"deleteCupping" sender:self];
    }
}

@end
