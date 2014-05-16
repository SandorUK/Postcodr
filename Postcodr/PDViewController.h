//
//  PDViewController.h
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.23..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDGeoCoder.h"

@interface PDViewController : UIViewController<UIViewControllerTransitioningDelegate>{
    NSDictionary *_previousResult;
    PDGeoCoder *_geoCoder;
    UIView *_tutorialView;
}
@property (strong, nonatomic) NSDictionary *previousResult;
@property (strong, nonatomic) IBOutlet UILabel *lblPostcode;
@property (strong, nonatomic) IBOutlet UILabel *lblLocality;
@property (strong, nonatomic) IBOutlet UIButton *btnHistory;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
