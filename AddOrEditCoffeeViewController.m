//
//  NueueCoffeeViewController.m
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/26/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "AddOrEditCoffeeViewController.h"
#import "Coffee.h"
#import "Cupping.h"
#import "DataController.h"
#import "CoffeesViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "CoffeeDatePickerViewController.h"
#import <AXRatingView/AXRatingView.h>
#import "UIColor+ColorScheme.h"



@interface AddOrEditCoffeeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>

// textFields and textViews
@property (weak, nonatomic) IBOutlet UITextField *roasterTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *brewingMethodTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

// buttons
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteCoffeeButton;


// views and imageViews
@property (weak, nonatomic) IBOutlet UIScrollView *addOrEditCoffeeScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet AXRatingView *coffeeCuppingRatingView;

// other
@property (strong, nonatomic) UIActionSheet *addOrChangePhotoActionSheet;
@property (nonatomic) BOOL usingCamera;
@property (nonatomic) BOOL dateNotNeeded;
@property (nonatomic) BOOL imageChanged;

@end


@implementation AddOrEditCoffeeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    _nameOrOriginTextField.delegate     = self;
    _roasterTextField.delegate          = self;
    _locationTextField.delegate         = self;
    _brewingMethodTextField.delegate    = self;
    _notesTextView.delegate             = self;
    _dateNotNeeded                      = NO;
    _imageChanged                       = NO;
    
    if (_editableCoffee) {
        _nameOrOriginTextField.text                         = _editableCoffee.nameOrOrigin;
        _roasterTextField.text                              = _editableCoffee.roaster;
        _locationTextField.enabled                          = NO;
        _chooseCuppingDateButton.enabled                    = NO;
        _chooseRoastDateButton.enabled                      = NO;
        
        _brewingMethodTextField.enabled                     = NO;
        _notesTextView.editable                             = NO;
        _deleteCoffeeButton.enabled                         = YES;
        [_deleteCoffeeButton setBackgroundColor:[UIColor darkSalmonColor]];
        _deleteCoffeeButton.layer.cornerRadius = 11;
        _coffeeCuppingRatingView.enabled                    = NO;
        _dateNotNeeded                                      = YES;
        
        
        [_chooseRoastDateButton setTitle:@" " forState:UIControlStateDisabled];
        [_chooseCuppingDateButton setTitle:@" " forState:UIControlStateDisabled];
        
        _saveBarButton.enabled          = (_nameOrOriginTextField.text.length > 0) && ((_cuppingDateHolder != nil) || (_dateNotNeeded == YES));
        _mainViewSaveButton.enabled     = (_nameOrOriginTextField.text.length > 0) && ((_cuppingDateHolder != nil) || (_dateNotNeeded == YES));
    }
    
    _notesTextView.layer.cornerRadius = 11;
    
    _photoImageView.layer.cornerRadius = 11;
    _photoImageView.layer.masksToBounds = YES;

    
    [_coffeeCuppingRatingView sizeToFit];
    [_coffeeCuppingRatingView setStepInterval:0.5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    _addOrChangePhotoActionSheet = nil;
}


#pragma mark - UITextField and UITextView Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _nameOrOriginTextField) {
        [_addOrEditCoffeeScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (textField == _roasterTextField) {
        [_addOrEditCoffeeScrollView setContentOffset:CGPointMake(0, _roasterTextField.frame.origin.y - 100) animated:YES];
    } else if (textField == _locationTextField) {
        [_addOrEditCoffeeScrollView setContentOffset:CGPointMake(0, _locationTextField.frame.origin.y - 100) animated:YES];
    } else if (textField == _brewingMethodTextField) {
        [_addOrEditCoffeeScrollView setContentOffset:CGPointMake(0, _brewingMethodTextField.frame.origin.y - 100) animated:YES];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == _notesTextView) {
        [_addOrEditCoffeeScrollView setContentOffset:CGPointMake(0, _notesTextView.frame.origin.y - 100) animated:YES];
    }
}

- (void)textFieldDidChange:(NSNotification *)note
{
    _saveBarButton.enabled = (_nameOrOriginTextField.text.length > 0) && ((_cuppingDateHolder != nil) || (_dateNotNeeded == YES));
    _mainViewSaveButton.enabled = (_nameOrOriginTextField.text.length > 0) && ((_cuppingDateHolder != nil) || (_dateNotNeeded == YES));
}

// Button title did change method.

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddCoffeeExitSegue"])
    {
        if (!_editableCoffee) {
            _editableCoffee = [NSEntityDescription insertNewObjectForEntityForName:@"Coffee"
                                                            inManagedObjectContext:[DataController sharedController].objectContext];
        }
        
        _editableCoffee.nameOrOrigin  = _nameOrOriginTextField.text;
        _editableCoffee.roaster       = _roasterTextField.text;
        
        NSError *error;
        
        // New Cupping Stuff
        Cupping *newCupping         = [NSEntityDescription insertNewObjectForEntityForName:@"Cupping" inManagedObjectContext:[DataController sharedController].objectContext];
        newCupping.location         = _locationTextField.text;
        newCupping.cuppingDate      = _cuppingDateHolder;
        
        newCupping.roastDate        = _roastDateHolder;
        newCupping.brewingMethod    = _brewingMethodTextField.text;
        
        NSNumber *numberFromFloatValue  = [[NSNumber alloc]initWithFloat:_coffeeCuppingRatingView.value];
       
        newCupping.rating               = numberFromFloatValue;
       
        if (_imageChanged == YES) {
            newCupping.photo                = _photoImageView.image;
            _imageChanged = NO;
        }
        
        newCupping.cuppingNotes         = _notesTextView.text;
        newCupping.coffee = _editableCoffee;
        
        [[DataController sharedController].objectContext save:&error];
        
        CoffeesViewController *destination = segue.destinationViewController;
        [destination.coffeesTableView reloadData];
        
    } else if ([segue.identifier isEqualToString:@"PickCuppingDateFromCoffee"]) {
        
        CoffeeDatePickerViewController *destination = segue.destinationViewController;
        destination.segueKey = @"PickCuppingDateFromCoffee";
        
    } else if ([segue.identifier isEqualToString:@"PickRoastDateFromCoffee"]) {
        
        CoffeeDatePickerViewController *destination = segue.destinationViewController;
        destination.segueKey = @"PickRoastDateFromCoffee";
    }
}

-(IBAction)CoffeeDatePickerExitSegue:(UIStoryboardSegue *)sender
{
    // Empty method for Exit Segue functionality.
}


#pragma mark - IBActions

-(IBAction)addOrChangePhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _addOrChangePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:@"Delete Photo"
                                                          otherButtonTitles:@"Take Photo",@"Choose Photo", nil];
        
    } else {
        
        _addOrChangePhotoActionSheet  = [[UIActionSheet alloc] initWithTitle:@"Photos"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                      destructiveButtonTitle:@"Delete Photo"
                                                           otherButtonTitles:@"Choose Photo", nil];
    }
    [_addOrChangePhotoActionSheet showInView:self.view];
}

- (IBAction)deleteCoffeeButtonPressed:(id)sender
{
    if ([self.deleteCoffeeButton isEnabled]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Are you sure you want to delete this coffee and all its cuppings?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Delete", nil];
        
        [alertView show];
    }
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
        
        self.usingCamera = YES;
        
        sourceType = UIImagePickerControllerSourceTypeCamera;
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Choose Photo" ]) {
        
        self.usingCamera = NO;
        
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    } else {
        
        return;
    }
    
    _imageChanged = YES;
    [self showPickerWithSourceType:sourceType];
}


#pragma mark - UIImagePicker Delegate Methods

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = sourceType;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (NSString *)docsDirectory
{
    NSURL *docsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask] firstObject];
    return docsURL.path;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Completed");
        self.photoImageView.image = editedImage;
        
        if (self.usingCamera)
        {
            
            ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
            if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
                [assetsLibrary writeImageToSavedPhotosAlbum:editedImage.CGImage
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
        } }];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        
        [_editableCoffee.managedObjectContext deleteObject:_editableCoffee];
        
        [self performSegueWithIdentifier:@"DeleteCoffeeSegue" sender:self];
    }
}


@end
