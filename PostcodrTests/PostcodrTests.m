//
//  PostcodrTests.m
//  PostcodrTests
//
//  Created by Sandor Kolotenko on 2014.04.23..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PDGeoCoder.h"

//GCD semaphore for block testing
#define SemaphoreSetup(SEM_NAME) dispatch_semaphore_t SEM_NAME = dispatch_semaphore_create(0);

#define SemaphoreSignal(SEM_NAME) dispatch_semaphore_signal(SEM_NAME);

#define SemaphoreWait(SEM_NAME) \
while (dispatch_semaphore_wait(SEM_NAME, DISPATCH_TIME_NOW)) { \
[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode \
beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]]; }

@interface PostcodrTests : XCTestCase
{
    PDGeoCoder *testGeoCoder;
}
@end

@implementation PostcodrTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    testGeoCoder = [[PDGeoCoder alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGeoCoderGeneric
{
    SemaphoreSetup(sem1);
    [testGeoCoder setBlockComplete:^(NSError *error, NSDictionary *result) {
        XCTAssertNil(error, @"Error was returned by geocoder");
        XCTAssertNotNil(result, @"Geocoder result is nil");
        SemaphoreSignal(sem1);
    }];
    
    [testGeoCoder getLocationFromAddress:@"Buckingham Palace, London"];
    SemaphoreWait(sem1);
}

#pragma mark Testing - (void)getPostcodeFromLocation:(CLLocation*)location
- (void)testGeoCoderPostcodeFromLocation
{
    SemaphoreSetup(sem2);
    [testGeoCoder setBlockComplete:^(NSError *error, NSDictionary *result) {
        // Check for errors
        XCTAssertNil(error, @"Error was returned by geocoder");
        XCTAssertNotNil(result, @"Geocoder result is nil");
        
        // Check for the postcode
        NSString* assumedPostalCodeLocation = [result objectForKey:kPostalCode];
        BOOL isExpectedPostcode = [assumedPostalCodeLocation isEqualToString:@"SW1Y 4JL"];
        
        XCTAssertTrue(isExpectedPostcode, @"Wrong postcode for the location provided");
        SemaphoreSignal(sem2);
    }];
    
    [testGeoCoder getPostcodeFromLocation:
     [[CLLocation alloc]
      initWithLatitude:51.5064807f
      longitude:-0.13563915f]];
    SemaphoreWait(sem2);
}

- (void)testGeoCoderPostcodeFromLocation_NEGATIVE
{
    SemaphoreSetup(sem3);
    [testGeoCoder setBlockComplete:^(NSError *error, NSDictionary *result) {
        // Check for errors
        XCTAssertNotNil(error, @"Error was not returned by geocoder when expected");
        XCTAssertNil(result, @"Geocoder result is not empty for negative test");

        SemaphoreSignal(sem3);
    }];
    
    [testGeoCoder getPostcodeFromLocation:
     [[CLLocation alloc]
      initWithLatitude:-390.0f
      longitude:390.0f]];
    SemaphoreWait(sem3);
}

#pragma mark Testing - (void)getLocationFromAddress:(NSString*)address
- (void)testGeoCoderLocationFromAddress
{
    SemaphoreSetup(sem4);
    [testGeoCoder setBlockComplete:^(NSError *error, NSDictionary *result) {
        // Check for errors
        XCTAssertNil(error, @"Error was returned by geocoder");
        XCTAssertNotNil(result, @"Geocoder result is nil");
        
        // Check for the location
        id assumedLocation = [result objectForKey:kLocation];
        BOOL isCLLocation = [assumedLocation isKindOfClass:[CLLocation class]];
        
        XCTAssertTrue(isCLLocation, @"Wrong class is returned for location");
        
        CLLocation *expectedLocation = [[CLLocation alloc] initWithLatitude:51.50413115
                                                                  longitude:-0.01647767];
        
        BOOL isExpectedLocation = ([(CLLocation*)assumedLocation
                                    distanceFromLocation:expectedLocation] < 50);
        XCTAssertTrue(isExpectedLocation, @"Received location is out of acceptable range");
        SemaphoreSignal(sem4);
    }];
    
    [testGeoCoder getLocationFromAddress:@"Canary Wharf, London"];
    SemaphoreWait(sem4);
}

- (void)testGeoCoderLocationFromAddress_NEGATIVE
{
    SemaphoreSetup(sem5);
    [testGeoCoder setBlockComplete:^(NSError *error, NSDictionary *result) {
        // Check for errors
        XCTAssertNotNil(error, @"Error was not returned by geocoder when expected");
        XCTAssertNil(result, @"Geocoder result is not empty for negative test");
        SemaphoreSignal(sem5);
    }];

    
    [testGeoCoder getLocationFromAddress:@""];
    SemaphoreWait(sem5);
}

#pragma mark Testing - (NSString*)getPostcodeForUK:(CLLocation*)location
- (void)testGeoCoderPostcodeForUKLocation
{
    [testGeoCoder setBlockComplete:nil];
    NSString *postcode = [testGeoCoder getPostcodeForUK:
                          [[CLLocation alloc]
                           initWithLatitude:51.5064807f
                           longitude:-0.13563915f]];
    
    XCTAssertTrue([postcode length] > 0, @"Postcode UK is empty for a non-negative test");
    XCTAssertTrue([postcode isEqualToString:@"SW1Y 4JL"], @"Postcode UK returned is not the expected one");
}

- (void)testGeoCoderPostcodeForUK_NEGATIVE
{
    [testGeoCoder setBlockComplete:nil];
    NSString *postcode = [testGeoCoder getPostcodeForUK:
     [[CLLocation alloc]
      initWithLatitude:-390.0f
      longitude:390.0f]];
    
    XCTAssertTrue([postcode length] == 0, @"Postcode UK is not empty for a negative test");
}

@end
