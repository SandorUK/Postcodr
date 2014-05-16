//
//  PDGeoCodingProvider.m
//
//  Created by Sandor Kolotenko on 2013.09.20..
//  Copyright (c) 2013 Sandor Kolotenko. All rights reserved.
//

#import "PDGeoCoder.h"
#import <CoreLocation/CoreLocation.h>
#import "TestFlight.h"

@implementation PDGeoCoder
@synthesize locationManager = _locationManager;
@synthesize blockComplete;
bool operationcompleted = NO;

- (id)init{
    self = [super init];
    
    if (self != nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
    }
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    //We have got the new location, stop updating.
    [self.locationManager stopUpdatingLocation];
    
    //Do the reverse geocoding
    CLLocation *lastLocation = [locations lastObject];
    
    [self getPostcodeFromLocation:lastLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [self.locationManager stopUpdatingLocation];
#ifdef TESTFLIGHT
    TFLog(@"Location Manager error %@", error);
#endif
    // Create userInfo dictionary for error
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow"
            case kCLErrorDenied:
                [details setValue:NSLocalizedString(@"Allow access to location services.",
                                                    @"Allow access to location services.")
                           forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:@"geo"
                                            code:1
                                        userInfo:details];
                break;
            case kCLErrorNetwork:
                [details setValue:NSLocalizedString(@"Location services network error.",
                                                    @"Location services network error.")
                           forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:@"geo"
                                            code:2
                                        userInfo:details];
                
                break;
            case kCLErrorLocationUnknown:
                [details setValue:NSLocalizedString(@"Unable to get your location.",
                                                    @"Unable to get your location.")
                           forKey:NSLocalizedDescriptionKey];

                error = [NSError errorWithDomain:@"geo"
                                            code:3
                                        userInfo:details];
                break;
            default:
                break;
        }
        
    } else {
        //Notify everybody we have an issue with geocoder
        [details setValue:NSLocalizedString(@"Something went wrong. Try again.",
                                            @"Something went wrong. Try again.")
                   forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"geo"
                                    code:4
                                userInfo:details];
    }
    
    
    self.blockComplete(error, nil);
}

- (void)getPostcodeFromCurrentLocation{
    // Update the location before doing reverse geocoding;
    [self.locationManager startUpdatingLocation];
    CLLocation *location = self.locationManager.location;
#ifdef TESTFLIGHT
    TFLog(@"Current Location %f, %f", location.coordinate.latitude, location.coordinate.longitude);
#endif
}

- (void)getPostcodeFromLocation:(CLLocation*)location{
    // Update the location before doing reverse geocoding;
#ifdef TESTFLIGHT
    TFLog(@"Location to process %f, %f", location.coordinate.latitude, location.coordinate.longitude);
#endif
    // Do the reverse geocoding
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
            if (error.code == 1009) {
                [details setValue:NSLocalizedString(@"No Internet connection.",
                                                    @"No Internet connection.")
                           forKey:NSLocalizedDescriptionKey];

                
            }
            else{
                [details setValue:NSLocalizedString(@"Check Location Services and connection.",
                                                    @"Check Location Services and connection.")
                           forKey:NSLocalizedDescriptionKey];
            }
            error = [NSError errorWithDomain:@"geo"
                                        code:7
                                    userInfo:details];
            self.blockComplete(error, nil);
            return;
        }
        
#ifdef TESTFLIGHT
        TFLog(@"Received placemarks: %@", placemarks);
#endif
        CLPlacemark* aPlacemark = [placemarks lastObject];
        NSString *postalCode = aPlacemark.postalCode;
        NSString *locationName = aPlacemark.locality;
        
        // Do additonal check whether we are in the UK
        if ([kUKISOCountryCode isEqualToString:aPlacemark.ISOcountryCode]) {
             NSString *secondaryPostalCode = [self getPostcodeForUK:location];
             if ([secondaryPostalCode length] > [postalCode length]) {
                 postalCode = secondaryPostalCode;
             }
         }
        
        if ([postalCode length] == 0) {
            if (aPlacemark.locality) {
                postalCode = aPlacemark.locality;
                locationName = aPlacemark.locality;
            }
            else{
                postalCode = NSLocalizedString(@"LOST", @"LOST");
                locationName = NSLocalizedString(@"Middle Earth", @"Middle Earth");
            }
        }
        
        // Notify everybody we have an updated location
        NSDictionary *locationResultDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                  postalCode, kPostalCode,
                                                  locationName, kLocationName,
                                                  [NSNumber numberWithFloat:aPlacemark.location.coordinate.longitude], kLongitude,
                                                  [NSNumber numberWithFloat:aPlacemark.location.coordinate.latitude], kLatitude,
                                                  nil];
        
        self.blockComplete(nil, locationResultDictionary);
    }];
    
}

- (NSString*)getPostcodeForUK:(CLLocation*)location{
    
    //http://uk-postcodes.com/latlng/51.47452170,-0.02298480.json
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:
                             [NSString stringWithFormat:kUKPostcodesURL,
                               location.coordinate.latitude,
                               location.coordinate.longitude]]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // Getting the data
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    if (!error && responseData) {
        // JSON parse
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        NSString *postcode = [json objectForKey:@"postcode"];
        if (postcode) {
            return postcode;
        }
        else{
            return @"";
        }
    }
    else{
        return @"";
    }
}

- (void)getLocationFromAddress:(NSString*)address{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
#ifdef TESTFLIGHT
    TFLog(@"Geocoding for Address: %@\n", address);
#endif
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark* aPlacemark = [placemarks lastObject];
#ifdef TESTFLIGHT
            TFLog(@"Received placemarks: %@", placemarks);
#endif
            CLLocation *locationToSend = aPlacemark.location;
            
            if (locationToSend == Nil) {
                CLCircularRegion * region = (CLCircularRegion*)aPlacemark.region;
                locationToSend = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
            }
            
            // Notify everybody we have an updated location
            NSDictionary *locationResultDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: locationToSend, kLocation, nil];
            
            self.blockComplete(nil, locationResultDictionary);
        }
        else
        {
#ifdef TESTFLIGHT
            TFLog(@"Geocoding error: %@", [error localizedDescription]);
#endif
            self.blockComplete(error, nil);
        }
    }];
}
@end
