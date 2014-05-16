//
//  PDAppDelegate.h
//  Postcodr
//
//  Created by Sandor Kolotenko on 2014.04.23..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PDAppDelegate : UIResponder <UIApplicationDelegate>
{
    AVAudioPlayer *audioPlayerObj;
}
@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)playSoundWithFile:(NSString*)fileNameWithExtension;
- (BOOL)isFirstLaunch;
@end
