//
//  PDHistoryViewController.m
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.24..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import "PDHistoryViewController.h"
#import <CoreData/CoreData.h>
#import "HistoryItem.h"
#import "PDHistoryCell.h"
#import "PDAppDelegate.h"
#import "PDMapItem.h"
#import <ALAlertBanner.h>
#import "TestFlight.h"

@interface PDHistoryViewController ()

@end

static NSString *CellIdentifier = @"HistoryCell";
@implementation PDHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    PDAppDelegate* delegate     = [UIApplication sharedApplication].delegate;
    self.managedObjectContext   = [delegate managedObjectContext];
    
    [self setTitle:NSLocalizedString(@"Postcode History", @"Postcode History")];
  
    [self.tableView.layer setCornerRadius:8.0f];
    [self.tableView setBackgroundColor:colorRAL3002];
    [self.view setBackgroundColor:colorRAL3002];
    
    // Setup back button appearance
    [self.btnBack addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBack setTitleColor:colorSpecialYellow forState:UIControlStateNormal];
    [self.btnBack.titleLabel setFont:[UIFont fontWithName:kGlobalFontName size:18.0f]];
    [self.btnBack.titleLabel setText:NSLocalizedString(@"Back", @"Back")];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    // Make corners of map rounded
    [self.mapView.layer setCornerRadius:8.0f];
    
    // Setup swipe gesture recognizer
    self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(goBack)];
    self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:self.swipeGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated{
    [self listHistoryItems];
    [self.tableView reloadData];
    [self.navigationController setNavigationBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)listHistoryItems{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HistoryItem"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
     NSArray *rawItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
     _items = [rawItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *firstDate = [(HistoryItem*)obj1 timestamp];
        NSDate *secondDate = [(HistoryItem*)obj2 timestamp];
        return [secondDate compare:firstDate];
    }];
    
    if ([_items count] == 0) {
        [self.lblNoHistory setHidden:NO];
        [self.lblNoHistory setFont:[UIFont fontWithName:kGlobalFontName size:18.0f]];
        [self.lblNoHistory setTextColor:colorSpecialYellow];
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            [self.lblNoHistory setNumberOfLines:2];
            [self.lblNoHistory setText:NSLocalizedString(@"No postcode history. Please enable location services.", @"No postcode history. Please enable location services.")];
        }
        
        [self.view bringSubviewToFront:self.lblNoHistory];
        
    }
    else{
        [self.lblNoHistory setHidden:YES];

        HistoryItem *itemToShow = [_items firstObject];
        [self showItemOnMap:itemToShow];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifdef TESTFLIGHT
    [TestFlight passCheckpoint:@"History View"];
#endif
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDHistoryCell *cell = (PDHistoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    HistoryItem *item = [_items objectAtIndex:indexPath.row];
    [cell setupWithHistoryItem:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryItem *item = [_items objectAtIndex:indexPath.row];
#ifdef TESTFLIGHT
    TFLog(@"Selected item for %@ in  %@", item.postcode, item.locationName);
#endif
    // Play sound
    [((PDAppDelegate*)[UIApplication sharedApplication].delegate) playSoundWithFile:@"select.wav"];
    
    [self showItemOnMap:item];
}

- (void)showItemOnMap:(HistoryItem*)item{
    // Define span for map: how much area will be shown
    MKCoordinateSpan span;
    span.latitudeDelta = 0.051;
    span.longitudeDelta = 0.051;
    
    // Define starting point for map
    CLLocationCoordinate2D start;
    start.latitude = item.latitude;
    start.longitude = item.longitude;
    
    // Create region, consisting of span and location
    MKCoordinateRegion region;
    region.span = span;
    region.center = start;
    
    [self.mapView setRegion:region animated:YES];
    
    // Add an annotation
    PDMapItem *annotation = [[PDMapItem alloc] initWithHistoryItem:item];
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                  self.tableView.frame.size.width,
                                                                  25.0f)];
    if ([_items count] > 7) {
        [_footerView setBackgroundColor:colorSpecialYellow];
        [_footerView.layer setCornerRadius:8.0f];
        
        UILabel *lblFooter = [[UILabel alloc] initWithFrame:_footerView.frame];
        [lblFooter setFont:[UIFont fontWithName:kGlobalFontName size:13.0f]];
        [lblFooter setTextColor:colorRAL3002];
        [lblFooter setTextAlignment:NSTextAlignmentCenter];
        [lblFooter setText:NSLocalizedString(@"Scroll for more", @"Scroll for more")];
        [_footerView addSubview:lblFooter];
        return _footerView;
    }
    else{
        return _footerView;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat direction = (indexPath.row % 2 > 0) ? 1 : -1;
    cell.transform = CGAffineTransformMakeTranslation(cell.bounds.size.width * direction, 0);
    [UIView animateWithDuration:0.25 animations:^{
        cell.transform = CGAffineTransformIdentity;
    }];
    
    if([indexPath row] >= [_items count] - 1){
        [UIView animateWithDuration:0.5
                              delay:0.25
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _footerView.alpha = 0;
                         }completion:^(BOOL finished){
                             [_footerView setHidden:YES];
                         }];
    }
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 25.0f;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
    [ALAlertBanner alertBannerForView:self.view
                                style:ALAlertBannerStyleFailure
                             position:ALAlertBannerPositionTop
                                title:NSLocalizedString(@"Oops. Map failure.", @"Oops. Map failure.")];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKAnnotationView *annView = [[MKAnnotationView alloc ] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    [annView setImage:[UIImage imageNamed:@"pin"]];
    annView.canShowCallout = YES;
    return annView;
}

- (void)goBack{
    // Play page turning sound
    [((PDAppDelegate*)[UIApplication sharedApplication].delegate) playSoundWithFile:@"paper.wav"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
