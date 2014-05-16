//
//  HistoryItem.h
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.24..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface HistoryItem : NSManagedObject

@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, readwrite) float latitude;
@property (nonatomic, readwrite) float longitude;
@end
