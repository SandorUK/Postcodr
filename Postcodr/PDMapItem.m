//
//  PDMapItem.m
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.05.08..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import "PDMapItem.h"

@implementation PDMapItem
@synthesize title;
@synthesize subtitle;
@synthesize coordinate;

- (id)initWithHistoryItem:(HistoryItem*)item{
    self = [super init];
    if(self)
    {
        self.coordinate = CLLocationCoordinate2DMake(item.latitude, item.longitude);
        self.title = item.postcode;
        self.subtitle = item.locationName;
    }
    return self;
}


- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate2D{
    self = [super init];
    if(self)
    {
        self.coordinate = CLLocationCoordinate2DMake(coordinate2D.latitude, coordinate2D.longitude);
    }
    return self;
}
@end
