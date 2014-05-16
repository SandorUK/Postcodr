//
//  PDMapItem.h
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.05.08..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "HistoryItem.h"

@interface PDMapItem : NSObject <MKAnnotation>
@property (nonatomic,   copy) NSString * title;
@property (nonatomic,   copy) NSString * subtitle;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate2D;
- (id)initWithHistoryItem:(HistoryItem*)item;
@end
