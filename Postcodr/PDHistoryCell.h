//
//  PDHistoryCell.h
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.28..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryItem.h"

@interface PDHistoryCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *lblPostcode;
@property (nonatomic, strong) IBOutlet UILabel *lblTimestamp;
@property (nonatomic, strong) IBOutlet UILabel *lblLocality;
@property (nonatomic, strong) IBOutlet UIButton *btnShare;
- (void)setupWithHistoryItem:(HistoryItem*)item;
@end
