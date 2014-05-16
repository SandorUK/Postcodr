//
//  main.m
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.23..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PDAppDelegate.h"

int main(int argc, char * argv[])
{
    /*@autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PDAppDelegate class]));
    }*/
    
    // Accomodate for testing
    @autoreleasepool {
        BOOL runningTests = NSClassFromString(@"XCTestCase") != nil;
        if(!runningTests)
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([PDAppDelegate class]));
        }
        else
        {
            return UIApplicationMain(argc, argv, nil, @"TestAppDelegate");
        }
    }
}
