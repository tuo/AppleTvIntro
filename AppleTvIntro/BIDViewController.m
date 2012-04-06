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

    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                                        rotationAndPerspectiveTransform.m34 = 1.0 / -500;

    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.view.layer.sublayerTransform = rotationAndPerspectiveTransform;

    int i = 0;
    float posX = MARGIN;
    float posY = MARGIN;

    float posZ ;
    for (;i < 12;)
    {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        CAShapeLayer *layer = [CAShapeLayer layer];
        CGRect rect = CGRectMake(posX, posY, COVER_W, COVER_H);

        layer.frame = rect;
        layer.anchorPoint = CGPointMake(0, 0.0);
        layer.position = CGPointMake(posX, posY);
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
        int offset = 4.0;
        if (i == 1 || i == 2)
         offset = 2;

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


           CGFloat h,s,b,a;


            [[UIColor redColor] getHue:&h saturation:&s brightness:&b alpha:&a];
            CGFloat tb = b * ( 1 - i * 0.1 ); // scale from 100% - 65% brightness

            UIColor *topColor = [UIColor colorWithHue:h saturation:s brightness:tb alpha:a];

        layer.borderColor = topColor.CGColor;
        //layer.borderWidth = 2;




        if(i == 0){
            posZ = CGRectGetWidth(rect) * sinf(5.0f * M_PI / 180.0f);
            NSLog(@"PSOZ sin : %f,  cos: %f", posZ, CGRectGetWidth(rect) * cosf(5.0f * M_PI / 180.0f));

              CATransform3D transform3D = CATransform3DRotate(rotationAndPerspectiveTransform, 5.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            layer.transform = transform3D;

//             CATransform3D transform = CATransform3DMakeRotation(15 * M_PI /180, 0, -1.0, 0);
//            layer.transform = transform;
            //CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, -z);
            //    self.topHalfLayer.transform = CATransform3DRotate(transform, topAngle, 1.0, 0.0, 0.0);
            //    self.bottomHalfLayer.transform = CATransform3DRotate(transform, bottomAngle, 1.0, 0.0, 0.0);
        }
        if (i == 1){
            int posx = CGRectGetWidth(rect) * (1 - cosf(5.0f * M_PI / 180.0f));
            CATransform3D transform3D= CATransform3DTranslate(rotationAndPerspectiveTransform, -(MARGIN - 4) , 0.0, -posZ);
            transform3D = CATransform3DRotate(transform3D, 2.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            posZ += CGRectGetWidth(rect) * sinf(2.0f * M_PI / 180.0f);
//            /layer.mask = nil;
            layer.transform = transform3D;

        }
        if (i==2){
            int posx = CGRectGetWidth(rect) * (1 - cosf(5.0f * M_PI / 180.0f));
            CATransform3D transform3D= CATransform3DTranslate(rotationAndPerspectiveTransform, -(MARGIN + 18) , 0.0, -posZ);
            transform3D = CATransform3DRotate(transform3D, -2.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            layer.transform = transform3D;
            posZ -= CGRectGetWidth(rect) * sinf(2.0f * M_PI / 180.0f);

        }
        if(i == 3){


                        int posx = CGRectGetWidth(rect) * (1 - cosf(5.0f * M_PI / 180.0f));

            CATransform3D transform3D= CATransform3DTranslate(rotationAndPerspectiveTransform, -(2 * MARGIN + 10 ) , 0.0, -posZ);
            transform3D = CATransform3DRotate(transform3D, -5.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
                        layer.transform = transform3D;



        }




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