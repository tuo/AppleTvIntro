//
//  BIDRootViewController.h
//  AppleTvIntro
//
//  Created by Tuo Huang on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDRootViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *imagesView;

- (IBAction)flyInPressed:(id)sender;

- (IBAction)flyOutPressed:(id)sender;
@end
