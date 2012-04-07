//
//  BIDViewController.m
//  AppleTvIntro
//
//  Created by Tuo Huang on 04/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BIDRootViewController.h"
#import "CoverFlowView.h"
#define COVER_W 225
#define COVER_H 225 * 0.8
#define MARGIN 25
#define GAP 15
#define COLS 7

@interface BIDRootViewController ()
- (void)renderGrid;

@end

@implementation BIDRootViewController{
    NSMutableArray *_imageLayers;
}
@synthesize imagesView;
@synthesize coverFlowView;

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
    
    //    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    //                                        rotationAndPerspectiveTransform.m34 = 1.0 / -500;

    CATransform3D rotationAndPerspectiveTransform = CATransform3DMakeRotation(0, 0.2, 1, 0);
    //rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.2, 1, 0, 0);
    float zDistance = 500;
    rotationAndPerspectiveTransform.m34 = 1.0 / -zDistance;
    
    
    [[self.imagesView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.imagesView.layer.sublayerTransform = rotationAndPerspectiveTransform;
    self.imagesView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.imagesView.layer.borderWidth = 2;

    NSMutableArray *animationZoomOuts = [[NSMutableArray alloc] init];


    _imageLayers = [[NSMutableArray alloc] init];

    int i = 0;
    float posX = MARGIN;
    float posY = MARGIN;


    float posZ ;
    for (;i < 30;)
    {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        CAShapeLayer *layer = [CAShapeLayer layer];
        [_imageLayers addObject:layer];
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
        int offset ;
        if ( i% COLS == COLS / 2){
            offset = 0;
        }else {
            offset = abs((COLS/2 - i % COLS)) * 2;
        }
        
        //        if (i % COLS == 1 || i % COLS == 2)
        //            offset = 2;
        
        
        layer.zPosition = -800;
        CGPoint topMiddle = CGPointMake(CGRectGetWidth(layerBounds)/2  , offset);
        CGPoint bottomMiddle = CGPointMake(CGRectGetWidth(layerBounds)/2  , CGRectGetHeight(layerBounds) - offset);
        
        [path moveToPoint:topLeft];
        [path addQuadCurveToPoint:topRight controlPoint:topMiddle];
        [path addLineToPoint:bottomRight];
        [path addLineToPoint:bottomLeft];
        //[path addQuadCurveToPoint:bottomLeft controlPoint:bottomMiddle];
        [path addLineToPoint:topLeft];
        [path closePath];
        
        mask.path = path.CGPath;
        mask.masksToBounds = YES;
        
        layer.mask = mask;
        UIColor *fillColor = [UIColor colorWithHue:0.584 saturation:0.8 brightness:0.9 alpha:1.0];
        
        layer.fillColor = fillColor.CGColor;
        [self.imagesView.layer addSublayer:layer];
        
        
        CGFloat h,s,b,a;
        
        
        [[UIColor redColor] getHue:&h saturation:&s brightness:&b alpha:&a];
        CGFloat tb = b * ( 1 - i * 0.1 ); // scale from 100% - 65% brightness
        
        UIColor *topColor = [UIColor colorWithHue:h saturation:s brightness:tb alpha:a];
        
        layer.borderColor = topColor.CGColor;
        //layer.borderWidth = 2;
        
        //         if (i == 4){
        //             posZ = CGRectGetWidth(rect) * sinf(4.0f * M_PI / 180.0f);
        //                         NSLog(@"PSOZ sin : %f,  cos: %f", posZ, CGRectGetWidth(rect) * cosf(5.0f * M_PI / 180.0f));
        //
        //                           CATransform3D transform3D = CATransform3DRotate(rotationAndPerspectiveTransform, -4.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        //                         layer.transform = transform3D;
        //
        //         }
        
        
        int posx = CGRectGetWidth(rect) * (1 - cosf((COLS/2 + 1 - i% COLS ) * M_PI / 180.0f)) + GAP - 2;
        if ( i % COLS == 0)
            posx = 0;
        

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
                    animation.toValue = [NSNumber numberWithInt: posZ + 200];
        //animation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x - 400, layer.position.y -100)];
                    animation.fillMode = kCAFillModeForwards;
                    animation.duration = 1;
                    animation.repeatCount = MAXFLOAT;
                    animation.autoreverses = YES;
                    animation.removedOnCompletion = NO;
                    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        [animationZoomOuts addObject:animation];
        CATransform3D transform3D= CATransform3DTranslate(rotationAndPerspectiveTransform, -posx , 0.0, 0);
        transform3D= CATransform3DTranslate(transform3D, -300 , -300, 0);
        transform3D= CATransform3DTranslate(transform3D, 0 , 0.0, -posZ);
        transform3D = CATransform3DRotate(transform3D, (COLS/2 - i% COLS) * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        posZ += CGRectGetWidth(rect) * sinf((COLS/2 - i% COLS) * M_PI / 180.0f);
        //            /layer.mask = nil;
        layer.transform = transform3D;



        
        //        if(i % COLS == 0){
        //            posZ = CGRectGetWidth(rect) * sinf(5.0f * M_PI / 180.0f);
        //            NSLog(@"PSOZ sin : %f,  cos: %f", posZ, CGRectGetWidth(rect) * cosf(5.0f * M_PI / 180.0f));
        //
        //              CATransform3D transform3D = CATransform3DRotate(rotationAndPerspectiveTransform, 5.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        //            layer.transform = transform3D;
        //
        ////             CATransform3D transform = CATransform3DMakeRotation(15 * M_PI /180, 0, -1.0, 0);
        ////            layer.transform = transform;
        //            //CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, -z);
        //            //    self.topHalfLayer.transform = CATransform3DRotate(transform, topAngle, 1.0, 0.0, 0.0);
        //            //    self.bottomHalfLayer.transform = CATransform3DRotate(transform, bottomAngle, 1.0, 0.0, 0.0);
        //        }
        //        if (i % COLS == 1){
        //            int posx = CGRectGetWidth(rect) * (1 - cosf(5.0f * M_PI / 180.0f));
        //            CATransform3D transform3D= CATransform3DTranslate(rotationAndPerspectiveTransform, -(posx + MARGIN - 2) , 0.0, 0);
        //            transform3D= CATransform3DTranslate(transform3D, 0 , 0.0, -posZ);
        //            transform3D = CATransform3DRotate(transform3D, 2.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        //            posZ += CGRectGetWidth(rect) * sinf(2.0f * M_PI / 180.0f);
        ////            /layer.mask = nil;
        //            layer.transform = transform3D;
        //
        //        }
        //        if (i % COLS==2){
        //            int posx = CGRectGetWidth(rect) * (1 - cosf(5.0f * M_PI / 180.0f));
        //            CATransform3D transform3D= CATransform3DTranslate(rotationAndPerspectiveTransform, -(MARGIN + 18) , 0.0, -posZ);
        //            transform3D = CATransform3DRotate(transform3D, -2.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        //            layer.transform = transform3D;
        //            posZ -= CGRectGetWidth(rect) * sinf(2.0f * M_PI / 180.0f);
        //
        //        }
        //        if(i % COLS== 3){
        //
        //
        //                        int posx = CGRectGetWidth(rect) * (1 - cosf(5.0f * M_PI / 180.0f));
        //
        //            CATransform3D transform3D= CATransform3DTranslate(rotationAndPerspectiveTransform, -(2 * MARGIN + 10 ) , 0.0, -posZ);
        //            transform3D = CATransform3DRotate(transform3D, -5.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        //                        layer.transform = transform3D;
        //
        //
        //
        //        }
        
        
        
        
        posX += GAP+COVER_W;
        i++;
        
        if (i%COLS==0)
        {
            posX = MARGIN;
            posY += GAP+COVER_H;
        }
    }
    
    //[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, posY+GAP+COVER_H)];




    for (int i = 0; i < animationZoomOuts.count; i++) {
            CALayer *imageLayer = [_imageLayers objectAtIndex:i];
            CABasicAnimation *animation = [animationZoomOuts objectAtIndex:i];
       // [imageLayer addAnimation:animation forKey:@"aniamionLayer"];
    }



//        animation = [CABasicAnimation animationWithKeyPath:@"frame.origin.x"];
//        animation.toValue = [NSNumber numberWithInt:400];
//        animation.fillMode = kCAFillModeForwards;
//        animation.duration = 4;
//        animation.repeatCount = 10;
//        animation.autoreverses = YES;
//
//    for (CALayer *iLayer in _imageLayers){
//            [iLayer addAnimation:animation forKey:@"aniamionLayer1"];
//        }
//

    //[self performSelector:@selector(translateTo) withObject:nil afterDelay:1];


    self.coverFlowView.backgroundColor = [UIColor lightGrayColor];


    NSMutableArray *sourceImages = [NSMutableArray arrayWithCapacity:30];
    for (int i = 0; i <30 ; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        [sourceImages addObject:image];
    }

    //CoverFlowView *coverFlowView = [CoverFlowView coverFlowViewWithFrame: frame andImages:_arrImages sidePieces:6 sideScale:0.35 middleScale:0.6];
    CoverFlowView *coverFlowView = [CoverFlowView coverFlowViewWithFrame:self.coverFlowView.bounds andImages:sourceImages sideImageCount:10 sideImageScale:0.55 middleImageScale:0.8];
    [self.coverFlowView addSubview:coverFlowView];
}

- (void)translatoBackZ {
   //To change the template use AppCode | Preferences | File Templates.
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
    animation.toValue = [NSNumber numberWithInt:- 400];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 1;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    for (CALayer *iLayer in _imageLayers){

        [iLayer addAnimation:animation forKey:@"a1niamionLayer"];
    }
}

- (void)translateTo {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.imagesView.layer .position.x - 400, self.imagesView.layer.position.y )];
        animation.fillMode = kCAFillModeForwards;
        animation.duration = 1;
        animation.repeatCount =1;
        animation.autoreverses = NO;
        animation.removedOnCompletion = NO;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        //for (CALayer *iLayer in _imageLayers){
            [self.imagesView.layer addAnimation:animation forKey:@"aniamionLayer1"];
        //}
   // [self performSelector:@selector(translatoBackZ) withObject:nil afterDelay:1];
}




- (void)viewDidUnload
{
    [self setImagesView:nil];
    [self setCoverFlowView:nil];
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