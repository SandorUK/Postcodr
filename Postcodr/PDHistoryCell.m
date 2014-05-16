//
//  PDHistoryCell.m
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.28..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import "PDHistoryCell.h"

@implementation PDHistoryCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithHistoryItem:(HistoryItem*)item{
    
    [self.lblPostcode setText:item.postcode];
    [self.lblLocality setText:item.locationName];
    [self.lblTimestamp setText:[self formTimestampString:item.timestamp]];
    
    [self.lblPostcode setFont:[UIFont fontWithName:kGlobalFontName size:24.0f]];
    [self.lblLocality setFont:[UIFont fontWithName:kGlobalFontName size:15.0f]];
    [self.lblTimestamp setFont:[UIFont fontWithName:kGlobalFontName size:14.0f]];
    
    [self.lblPostcode setTextColor:colorSpecialYellow];
    [self.lblLocality setTextColor:colorSpecialYellow];
    [self.lblTimestamp setTextColor:colorSpecialYellow];
    
    [self setBackgroundColor:colorRAL3002];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = colorREDSelect;
    bgColorView.layer.cornerRadius = 8;
    bgColorView.layer.masksToBounds = YES;
    [self setSelectedBackgroundView:bgColorView];
}

- (NSString*)formTimestampString:(NSDate*)dateToProcess{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    
    NSString *theDate = [dateFormat stringFromDate:dateToProcess];
    NSString *theTime = [timeFormat stringFromDate:dateToProcess];
    
    return [NSString stringWithFormat:@"%@ %@", theDate, theTime];
}

@end
