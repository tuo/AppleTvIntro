//
//  BIDViewController.m
//  AppleTvIntro
//
//  Created by Tuo Huang on 04/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BIDViewController.h"
#define COVER_W 225
#define COVER_H 225 * 0.8
#define MARGIN 25
#define GAP 15
#define COLS 4

@interface BIDViewController ()
- (void)renderGrid;

@end

@implementation BIDViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self renderGrid];

}

- (void) renderGrid
{

    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    int i = 0;
    float posX = MARGIN;
    float posY = MARGIN;
    for (;i < 12;)
    {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        CGRect rectEnd = CGRectMake(posX, posY, COVER_W, COVER_H);
        imageView.frame = rectEnd;
        [self.view addSubview:imageView];



        posX += GAP+COVER_W;
        i++;

        if (i%COLS==0)
        {
            posX = MARGIN;
            posY += GAP+COVER_H;
        }
    }

    //[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, posY+GAP+COVER_H)];


}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end