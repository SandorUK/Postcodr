//
//  PDTransitionManager.h
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.05.07..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TransitionStep){
    PDNormal = 0,
    PDModal
};

@interface PDTransitionManager : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) TransitionStep transitionTo;

@end

