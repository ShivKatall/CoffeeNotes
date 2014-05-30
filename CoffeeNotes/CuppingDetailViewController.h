//
//  CuppingDetailViewController.h
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/25/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coffee.h"
#import "Cupping.h"
#import "DataController.h"

@interface CuppingDetailViewController : UIViewController

// models
@property (strong, nonatomic) Cupping *selectedCupping;

@end
