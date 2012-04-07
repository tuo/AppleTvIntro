//
//  BIDAppDelegate.h
//  AppleTvIntro
//
//  Created by Tuo Huang on 04/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BIDRootViewController;

@interface BIDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BIDRootViewController *viewController;

@end