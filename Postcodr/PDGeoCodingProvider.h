//
//  GeoCodingProvider.h
//  Reverse geocoder
//
//  Created by Sandor Kolotenko on 2013.09.20..
//  Copyright (c) 2013 Sandor Kolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol PDGeoCodingProvider <NSObject>
@required
@property (nonatomic, copy) void (^blockComplete)(NSError* error, NSDictionary* result);
- (void)getPostcodeFromCurrentLocation;
- (void)getPostcodeFromLocation:(CLLocation*)location;
- (void)getLocationFromAddress:(NSString*)address;
@end
