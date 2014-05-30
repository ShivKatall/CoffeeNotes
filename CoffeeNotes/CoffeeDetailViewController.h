//
//  CoffeeDetailViewController.h
//  CoffeeNotes
//
//  Created by Cole Bratcher on 4/25/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coffee.h"
#import "Cupping.h"

@class DataController;
@class CoffeeModel;
@class CuppingModel;


@interface CoffeeDetailViewController : UIViewController

// models
@property (nonatomic, strong) Coffee *selectedCoffee;

@end
