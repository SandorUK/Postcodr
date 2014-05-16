//
//  PDHistoryViewController.h
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.24..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PDHistoryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>
{
    NSArray *_items;
    UIView  *_footerView;
}
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *lblNoHistory;
@end
