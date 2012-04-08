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
@property (strong, nonatomic) CALayer *galleryLayer;
@property (strong, nonatomic) CALayer *coverFlowLayer;
@end

@implementation BIDRootViewController{
    NSMutableArray *_imageLayers;
@private
    CALayer *_galleryLayer;
    CALayer *_coverFlowLayer;
}
@synthesize imagesView;
@synthesize galleryLayer = _galleryLayer;
@synthesize coverFlowLayer = _coverFlowLayer;


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

    [self.imagesView setBackgroundColor:[UIColor whiteColor]];
    [self.imagesView setBackgroundColor:[UIColor lightGrayColor]];
    self.galleryLayer = [CALayer layer];
    self.coverFlowLayer = [CALayer layer];

    self.galleryLayer.frame = CGRectMake(0, 0, self.imagesView.bounds.size.width, self.imagesView.bounds.size.height - 100);
    self.galleryLayer.frame = self.imagesView.frame;
    self.coverFlowLayer.frame = CGRectMake(0, self.imagesView.bounds.size.height - 100, self.imagesView.bounds.size.width, 100);
    //[self.imagesView.layer addSublayer:self.galleryLayer];
    //[self.imagesView.layer addSublayer:self.coverFlowLayer];

    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = 1.0 / -550;
    //perspective = CATransform3DRotate(perspective, .62, 0, 1, 0);	//
    self.imagesView.layer.sublayerTransform = perspective;

    [self renderGrid];
    
}


- (void) renderGrid
    {

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


            layer.zPosition = -2000;
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
                        animation.repeatCount = 0;
                        animation.autoreverses = YES;
                        animation.autoreverses = YES;
                        animation.removedOnCompletion = NO;
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

            [animationZoomOuts addObject:animation];
            //CATransform3D transform3D= CATransform3DTranslate(rotationAndPerspectiveTransform, -posx , 0.0, 0);
            CATransform3D transform3D= CATransform3DMakeTranslation(-posx , 0.0, 0);
            transform3D= CATransform3DTranslate(transform3D, -300 , -300, 0);
            transform3D= CATransform3DTranslate(transform3D, 0 , 0.0, -posZ);
            transform3D = CATransform3DRotate(transform3D, (COLS/2 - i% COLS) * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            posZ += CGRectGetWidth(rect) * sinf((COLS/2 - i% COLS) * M_PI / 180.0f);
            //            /layer.mask = nil;
            layer.transform = transform3D;
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
          //  NSLog(@"x :%f, y: %f , width: %f, height: %f", imageLayer.frame.origin.x,imageLayer.frame.origin.y,imageLayer.frame.size.width,imageLayer.frame.size.height);
                CABasicAnimation *animation = [animationZoomOuts objectAtIndex:i];
            //if (i == 17){
                animation.toValue = [NSNumber numberWithInt: 0];



//                CATransform3D transform3D= CATransform3DTranslate(imageLayer.transform, 00 , -400, 0);
//                transform3D = CATransform3DScale(transform3D, 0.8, 0.8, 0);
//                imageLayer.transform = transform3D;

               //[imageLayer addAnimation:animation forKey:@"aniamionLayer"];

                //[group setAnimations:<#(NSArray *)anAnimations#>]
//            /}

        }


    //    /[self performSelector:@selector(rotateCameraAngle) withObject:self afterDelay:0.5];

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


        //self.coverFlowView.backgroundColor = [UIColor lightGrayColor];




        [self performSelector:@selector(flyToCoverFlow) withObject:self afterDelay:1];
    }

- (void)flyToCoverFlow{
    NSMutableArray *sourceImages = [NSMutableArray array];
    float width,height;
    for (int i = 0; i < COLS; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        width  = image.size.width;
        height = image.size.height;
        [sourceImages addObject:image];
    }

    CGRect coverFlowFrame = CGRectMake(0, self.imagesView.bounds.size.height - 300, self.imagesView.bounds.size.width, 300);
    //CoverFlowView *coverFlowView = [CoverFlowView coverFlowViewWithFrame: frame andImages:_arrImages sidePieces:6 sideScale:0.35 middleScale:0.6];
    //CoverFlowView *coverFlowView = [CoverFlowView coverFlowViewWithFrame:coverFlowFrame andImages:sourceImages sideImageCount:COLS/2 sideImageScale:0.55 middleImageScale:0.8];
    CoverFlowView *coverFlowView = [CoverFlowView coverFlowInLayer: self.imagesView.layer andImages:sourceImages sideImageCount:3 sideImageScale:0.55 middleImageScale:0.8];

    coverFlowView.layer.sublayerTransform = self.imagesView.layer.sublayerTransform;
    [coverFlowView setupTemplateLayers];

//    coverFlowView.layer.borderColor = [UIColor orangeColor].CGColor;
//    coverFlowView.layer.borderWidth = 2;

    //[coverFlowView setupImages];
//    [self.imagesView addSubview:coverFlowView];

    NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
    for (int j = 0; j < COLS * 2; j++) {
        [selectedImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", j]]];
        CALayer *imgLayer = [_imageLayers objectAtIndex:j];
        CALayer *templateLayer = [[coverFlowView getTemplateLayers] objectAtIndex: 0];
        if (j < [coverFlowView getTemplateLayers].count - 2){
            NSLog(@"j : %i, count: %d", j, [coverFlowView getTemplateLayers].count);
            templateLayer = [[coverFlowView getTemplateLayers] objectAtIndex: j + 1];
        }

            //imgLayer.zPosition = -0;

        float destiZPosition = templateLayer.zPosition;


        float scale = [[templateLayer valueForKey:@"scale"] floatValue];
        NSLog(@"scale: %f", scale);
        //CGPoint newPosition = CGPointMake(templateLayer.position.x -(width/2) + width * (1 - scale)/2,templateLayer.position.y - 150 + height * (1 - scale)/2);
        CGPoint newPosition = templateLayer.position;
        NSLog(@"new template position: %@", [NSValue valueWithCGPoint:newPosition] );

        CATransform3D destiTransform = templateLayer.transform;

            CGFloat yGap = self.imagesView.bounds.size.height - imgLayer.frame.origin.y ;
            CGFloat xGap = templateLayer.frame.origin.x - imgLayer.frame.origin.x ;

//            NSLog(@"%f, %f, %f", self.imagesView.bounds.size.height , imgLayer.frame.origin.y , templateLayer.frame.origin.y);
//        NSLog(@"%f, %f, %f", self.imagesView.bounds.size.width , imgLayer.frame.origin.x, templateLayer.frame.origin.x);
//            NSLog(@"x gap : %f, y gap : %f", xGap, yGap);

        CAAnimationGroup *theGroup = [CAAnimationGroup animation];

        theGroup.duration = 5.0;
        theGroup.repeatCount = 10000;
        theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];


        // Add the animation group to the templateLayer
        CABasicAnimation *zPositionAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
        zPositionAnimation.toValue = [NSNumber numberWithFloat:destiZPosition];
        zPositionAnimation.repeatCount = 0;
        zPositionAnimation.duration = 5;
        zPositionAnimation.autoreverses = NO;
        zPositionAnimation.removedOnCompletion = NO;



//            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frame.origin"];
//            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(templateLayer.frame.origin.x, templateLayer.frame.origin.y + self.imagesView.bounds.size.height)];
//            animation.repeatCount = MAXFLOAT;
//            animation.duration = 2;
//            animation.autoreverses = YES;
//            animation.removedOnCompletion = NO;
//            //[imgLayer addAnimation:animation forKey:nil];

//            CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
//            animation1.toValue = [NSValue valueWithCGSize:CGSizeMake(imgLayer.bounds.size.width * 0.8, imgLayer.bounds.size.height * 0.8)];
//            animation1.repeatCount = MAXFLOAT;
//            animation1.duration = 2;
//            animation1.autoreverses = YES;
//            animation1.removedOnCompletion = NO;
            //[imgLayer addAnimation:animation1 forKey:nil];

        //
            CABasicAnimation *moveDownLayer = [CABasicAnimation animationWithKeyPath:@"position"];
                moveDownLayer.toValue = [NSValue valueWithCGPoint:CGPointMake(templateLayer.frame.origin.x,self.imagesView.bounds.size.height + templateLayer.frame.origin.y)];
                moveDownLayer.toValue = [NSValue valueWithCGPoint:newPosition];
                //moveDownLayer.toValue = [NSValue valueWithCGPoint:CGPointMake(400,100)];
                moveDownLayer.repeatCount = 0;
                moveDownLayer.duration = 5;
                moveDownLayer.autoreverses = NO;
                moveDownLayer.removedOnCompletion = NO;
        //[imgLayer addAnimation:moveDownLayer forKey:nil];

        theGroup.duration = 2;
        theGroup.repeatCount = 0;
        theGroup.autoreverses = NO;
        theGroup.removedOnCompletion = NO;
        theGroup.animations = [NSArray arrayWithObjects:zPositionAnimation, moveDownLayer, nil]; // you can add more
        [imgLayer addAnimation:theGroup forKey:@"zoomAndRotate"];

        imgLayer.bounds = CGRectMake(0,0,width * scale, height * scale);
        imgLayer.position = newPosition;
        imgLayer.zPosition = destiZPosition;
        imgLayer.anchorPoint = templateLayer.anchorPoint;
        imgLayer.transform = destiTransform;
        imgLayer.borderColor = [UIColor redColor].CGColor;
        imgLayer.borderWidth = 0;

        //TODOList: this part need to be delay after animation group
        if (j >= ([coverFlowView getTemplateLayers].count - 2)){
            NSLog(@"hidden yes for j: %d > count: %d" ,j, [coverFlowView getTemplateLayers].count - 2);
            imgLayer.hidden = YES;
        }

    }


    //setImageSources
   //[coverFlowView setupImages];
}

- (void)rotateCameraAngle
{

	[CATransaction setAnimationDuration:2.2];

	CATransform3D t = CATransform3DIdentity;
	t.m34 = 1.0/-500; //Newmans

//	t = CATransform3DRotate(t, 0.09, 0, 0, 1); //Z
	t = CATransform3DRotate(t, .62, 0, 1, 0);	//Y
//	t = CATransform3DRotate(t, 1.44, -1, 0, 0); //X
//
	//t = CATransform3DScale(t, 0.35, 0.35, 1.0);
	//t = CATransform3DTranslate(t, -220, -220, 0);

	self.imagesView.layer.sublayerTransform = t;

//	replicatorEast.transform = CATransform3DMakeTranslation(-440, -440, 0);
//	replicatorWest.transform = CATransform3DMakeTranslation(440, 440, -55);
//
//	[self performSelector:@selector(animateTopOut) withObject:self afterDelay:2.6];
//	[self performSelector:@selector(animateBottomOut) withObject:self afterDelay:2.6];

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