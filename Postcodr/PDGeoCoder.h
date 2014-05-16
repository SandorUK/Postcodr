//
//  PDGeoCodingProvider.h
//
//  Created by Sandor Kolotenko on 2013.09.20..
//  Copyright (c) 2013 Sandor Kolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDGeoCodingProvider.h"
#import <CoreLocation/CoreLocation.h>

@interface PDGeoCoder : NSObject <PDGeoCodingProvider, CLLocationManagerDelegate>{
    CLLocationManager *_locationManager;
}

- (void)getPostcodeFromCurrentLocation;
- (void)getPostcodeFromLocation:(CLLocation*)location;
- (void)getLocationFromAddress:(NSString*)address;
- (NSString*)getPostcodeForUK:(CLLocation*)location;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, copy) void (^blockComplete)(NSError* error, NSDictionary* result);
@end
