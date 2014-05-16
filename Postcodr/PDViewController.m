//
//  PDViewController.m
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.23..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import "PDViewController.h"
#import "PDGeoCoder.h"
#import "HistoryItem.h"
#import "PDAppDelegate.h"
#import "PDTransitionManager.h"
#import "PDHistoryViewController.h"
#import <ALAlertBanner.h>
#import "TestFlight.h"

@interface PDViewController ()
@property (nonatomic, strong) PDTransitionManager *transitionManager;
@end

@implementation PDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.lblPostcode setTextColor:colorSpecialYellow];
    [self.lblPostcode setAdjustsFontSizeToFitWidth:YES];
    [self.lblPostcode setFont:[UIFont fontWithName:kGlobalFontName size:90.0f]];
    
    [self.lblLocality setTextColor:colorSpecialYellow];
    [self.lblLocality setAdjustsFontSizeToFitWidth:YES];
    [self.lblLocality setFont:[UIFont fontWithName:kGlobalFontName size:22.0f]];

    [self setLabelsForPostcode:NSLocalizedString(@"WHERE?", @"WHERE?")
                    andMessage:NSLocalizedString(@"Looking up the postcode, please wait", @"Looking up the postcode, please wait")];
#ifdef DEBUG
    [self setLabelsForPostcode:NSLocalizedString(@"POSTCODR", @"POSTCODR")
                    andMessage:NSLocalizedString(@"Looking up a postcode for you", @"Looking up a postcode for you")];
#endif
    
    // Add show history action
    [self.btnHistory setTitleColor:colorSpecialYellow forState:UIControlStateNormal];
    [self.btnHistory.titleLabel setFont:[UIFont fontWithName:kGlobalFontName size:18.0f]];
    [self.btnHistory.titleLabel setText:NSLocalizedString(@"Your History", @"Your History")];
    [self.btnHistory addTarget:self
                        action:@selector(showHistory)
              forControlEvents:UIControlEventTouchUpInside];
    
    
    // RAL3002 163, 026, 026
    [self.view setBackgroundColor:colorRAL3002];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Setup single tap gesture recognizer for postcode copy
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyPostcode)];
    self.tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    // Setup swipe gesture recognizer for postcode refresh
    self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showHistory)];
    self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.swipeGestureRecognizer];
    
    // Setup transition
    self.transitionManager = [[PDTransitionManager alloc]init];
    
    BOOL isFirstLaunch = [((PDAppDelegate*)[UIApplication sharedApplication].delegate) isFirstLaunch];
    if(isFirstLaunch){
        [self showTutotialOverlay];
    }
    else{
        [self setupGeocoder];
    }
}

- (void)setupGeocoder{
#ifdef TESTFLIGHT
    [TestFlight passCheckpoint:@"Geocoder Setup"];
#endif

    // Setup the geocoder
    _geoCoder = [[PDGeoCoder alloc] init];
    __weak PDViewController *self_ = self;
    [_geoCoder setBlockComplete:^(NSError *error, NSDictionary *result) {
        if (!error && result) {
            NSString *postcode = [result objectForKey:kPostalCode];
            NSString *locality = [result objectForKey:kLocationName];
            
            [self_ setLabelsForPostcode:postcode andMessage:locality];
            
            if ([result isEqualToDictionary:self_.previousResult]) {
                // Same place, nothing to do, but place here additional logic to notify user
            }
            else{
                [self_ saveLocation:result];
            }
            
            // Play sound
            [((PDAppDelegate*)[UIApplication sharedApplication].delegate) playSoundWithFile:@"beep.wav"];
        }
        else{
            
            // Play sound
            [((PDAppDelegate*)[UIApplication sharedApplication].delegate) playSoundWithFile:@"error.wav"];
            
            if ([error.domain isEqualToString:@"geo"] && error.code == 1) {
                if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
                    
                    [self_ setLabelsForPostcode:NSLocalizedString(@"Sorry", @"Sorry")
                                     andMessage:NSLocalizedString(@"please go to System Settings and turn on Location Service.",
                                                                  @"please go to System Settings and turn on Location Service.")];
                }
            }
            else{
                ALAlertBanner* errorBanner = [ALAlertBanner alertBannerForView:self_.view
                                                                         style:ALAlertBannerStyleFailure
                                                                      position:ALAlertBannerPositionTop
                                                                         title:error.localizedDescription];
                [errorBanner show];
                [self_ setLabelsForPostcode:NSLocalizedString(@"LOST", @"LOST")
                                 andMessage:NSLocalizedString(@"An island somewhere in the Pacific Ocean", @"An island somewhere in the Pacific Ocean")];
            }
        }
    }];
}

- (void)setLabelsForPostcode:(NSString*)postcode andMessage:(NSString*)message{
    [UIView animateWithDuration:0.4 animations:^{
        self.lblLocality.alpha = 0.0f;
        self.lblPostcode.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.lblPostcode setText:postcode];
        [self.lblLocality setText:message];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.lblPostcode.alpha = 1.0f;
            self.lblLocality.alpha = 1.0f;
        } completion:^(BOOL finished) {
            NSLog(@"finished transition");
        }];
    }];

}

- (void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
}

#pragma mark Tutorial Overlay
- (void)showTutotialOverlay{
#ifdef TESTFLIGHT
    [TestFlight passCheckpoint:@"Tutorial Displayed"];
#endif
    UITapGestureRecognizer *tapDismissTutorial = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(hideTutorialOverlay)];
    [self.tapGestureRecognizer setEnabled:NO];
    [self.swipeGestureRecognizer setEnabled:NO];
    
    // Setup the overlay view
    _tutorialView = [[UIView alloc] initWithFrame:self.view.frame];
    [_tutorialView addGestureRecognizer:tapDismissTutorial];
    [_tutorialView setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.8f]];
    
    // Setup instructions
    UILabel *lblInstuctions = [[UILabel alloc] initWithFrame:_tutorialView.frame];
    [lblInstuctions setFont:[UIFont fontWithName:kGlobalFontName size:25.0f]];
    [lblInstuctions setNumberOfLines:10];
    [lblInstuctions setTextColor:colorSpecialYellow];
    [lblInstuctions setTextAlignment:NSTextAlignmentCenter];
    
    [lblInstuctions setText:NSLocalizedString(@"Welcome! App usage:\nEnable Location Service for this app\nSwipe this screen to the right to reveal postcode history and map\nDouble tap this screen to copy the postcode\nShake to refresh location\n\nNow tap anywhere",
                                              @"Welcome! App usage:\nEnable Location Service for this app\nSwipe this screen to the right to reveal postcode history and map\nDouble tap this screen to copy the postcode\nShake to refresh location\n\nNow tap anywhere")];
    
    [_tutorialView addSubview:lblInstuctions];
    [self.view addSubview:_tutorialView];
    [self.view bringSubviewToFront:_tutorialView];
}

- (void)hideTutorialOverlay{
    [_tutorialView removeFromSuperview];
    [self.tapGestureRecognizer setEnabled:YES];
    [self.swipeGestureRecognizer setEnabled:YES];

#ifdef TESTFLIGHT
    [TestFlight passCheckpoint:@"Tutorial Dismissed"];
#endif
    
    [self setupGeocoder];
}

#pragma mark React to Shake
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [_geoCoder getPostcodeFromCurrentLocation];
    } 
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshPostcode{
    // Play sound
    [((PDAppDelegate*)[UIApplication sharedApplication].delegate) playSoundWithFile:@"spring.wav"];
    
    [_geoCoder getPostcodeFromCurrentLocation];
}

- (void)copyPostcode{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.lblPostcode.text];
    
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                style:ALAlertBannerStyleSuccess
                             position:ALAlertBannerPositionTop
                                title:NSLocalizedString(@"Postcode copied to pasteboard",
                                                            @"Postcode copied to pasteboard")];
    
    [banner show];
    
    // Play sound
    [((PDAppDelegate*)[UIApplication sharedApplication].delegate) playSoundWithFile:@"spring.wav"];
    
}

#pragma mark History Items
- (void)saveLocation:(NSDictionary*)item{
    PDAppDelegate* delegate     = [UIApplication sharedApplication].delegate;
    self.managedObjectContext   = [delegate managedObjectContext];
    
    HistoryItem *historyItem = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"HistoryItem"
                                      inManagedObjectContext:self.managedObjectContext];
    [historyItem setPostcode:[item objectForKey:kPostalCode]];
    [historyItem setLocationName:[item objectForKey:kLocationName]];
    
    NSNumber *latitudeNumber = [item objectForKey:kLatitude];
    NSNumber *longitudeNumber = [item objectForKey:kLongitude];
    
    [historyItem setLatitude:[latitudeNumber floatValue]];
    [historyItem setLongitude:[longitudeNumber floatValue]];
    [historyItem setTimestamp:[NSDate date]];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
#ifdef TESTFLIGHT
        TFLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
#endif
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HistoryItem"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Hide history button if no history availabe
    int count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (count == 0) {
        [self.btnHistory setHidden:YES];
    }
    
    /*NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Test listing all items from the store
    for (HistoryItem *item in fetchedObjects) {
        NSLog(@"Location: %@", item.locationName);
    }*/
}

#pragma mark - UI interactions

- (void)showHistory{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Prepare history view
    PDHistoryViewController *history = [storyboard instantiateViewControllerWithIdentifier:@"HistoryView"];
    history.transitioningDelegate = self;
    history.modalPresentationStyle = UIModalPresentationCustom;
    
    // Play page turning sound
    [((PDAppDelegate*)[UIApplication sharedApplication].delegate) playSoundWithFile:@"paper.wav"];
    
    // Animate the transition
    [self presentViewController:history animated:YES completion:^{
    }];
}


#pragma mark - UIVieControllerTransitioningDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    self.transitionManager.transitionTo = PDModal;
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionManager.transitionTo = PDNormal;
    return self.transitionManager;
}

@end
