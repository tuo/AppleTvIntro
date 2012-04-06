//
//  BIDViewController.m
//  AppleTvIntro
//
//  Created by Tuo Huang on 04/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
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

    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1/1000.0;
    self.view.layer.sublayerTransform = transform;

    int i = 0;
    float posX = MARGIN;
    float posY = MARGIN;
    for (;i < 12;)
    {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        CAShapeLayer *layer = [CAShapeLayer layer];
        CGRect rect = CGRectMake(posX, posY, COVER_W, COVER_H);

        layer.frame = rect;
        layer.contents = (__bridge id)img.CGImage;
//        /layer.path = CGPathCreateWithEllipseInRect(rect, nil);


//        layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
//        layer.borderWidth = 5.0;
//        layer.shadowOffset = CGSizeMake(0, 3);
//        layer.shadowOpacity = 0.7;

        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.frame =  CGRectMake(0, 0, COVER_W, COVER_H);;
        const CGRect layerBounds = CGRectMake(0, 0, rect.size.width, rect.size.height);
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint topLeft = layerBounds.origin;
        CGPoint bottomLeft = CGPointMake(0.0, CGRectGetHeight(layerBounds));
        CGPoint bottomRight = CGPointMake(CGRectGetWidth(layerBounds), CGRectGetHeight(layerBounds));
        CGPoint topRight = CGPointMake(CGRectGetWidth(layerBounds), 0);

        int offset = 10.0;
        CGPoint topMiddle = CGPointMake(CGRectGetWidth(layerBounds)/2, offset);
        CGPoint bottomMiddle = CGPointMake(CGRectGetWidth(layerBounds)/2, CGRectGetHeight(layerBounds) - offset);


        [path moveToPoint:topLeft];
        [path addQuadCurveToPoint:topRight controlPoint:topMiddle];
        [path addLineToPoint:bottomRight];
        [path addQuadCurveToPoint:bottomLeft controlPoint:bottomMiddle];
        [path addLineToPoint:topLeft];
        [path closePath];

        mask.path = path.CGPath;
        mask.masksToBounds = YES;

        layer.mask = mask;
        UIColor *fillColor = [UIColor colorWithHue:0.584 saturation:0.8 brightness:0.9 alpha:1.0];

        layer.fillColor = fillColor.CGColor;
        [self.view.layer addSublayer:layer];



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