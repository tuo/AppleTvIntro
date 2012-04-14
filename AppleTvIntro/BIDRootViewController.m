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

- (void)hideImageAndShowSlide:(NSArray *)args;

@property (strong, nonatomic) CALayer *galleryLayer;
@property (strong, nonatomic) CALayer *coverFlowLayer;
@end

@implementation BIDRootViewController{
    NSMutableArray *_imageLayers;
@private
    CALayer *_galleryLayer;
    CALayer *_coverFlowLayer;
    CoverFlowView *coverFlowView;
    NSMutableArray *selectedImages;
    NSMutableArray *selectedImageLayers;
    NSMutableArray *selectedImageLayersBackup;

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
 [self.imagesView setBackgroundColor:[UIColor blackColor]];
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
    const int visibleImageSideCount = 3;
    coverFlowView = [CoverFlowView coverFlowInView: self.imagesView andImages:sourceImages sideImageCount:visibleImageSideCount sideImageScale:0.55 middleImageScale:0.8];

    [coverFlowView setNormalImageSizeForLayer:[UIImage imageNamed: @"1.jpg"].size];
    coverFlowView.layer.sublayerTransform = self.imagesView.layer.sublayerTransform;
    [coverFlowView setupTemplateLayers];

//    coverFlowView.layer.borderColor = [UIColor orangeColor].CGColor;
//    coverFlowView.layer.borderWidth = 2;

    //[coverFlowView setupImages];
//    [self.imagesView addSubview:coverFlowView];

    selectedImages = [[NSMutableArray alloc] init];

    selectedImageLayers = [[NSMutableArray alloc] init];

    selectedImageLayersBackup = [[NSMutableArray alloc] init];

    //pickAndFillInWithSelectedImages
    for (int j = 0; j < COLS * 2; j++) {
        [selectedImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", j]]];
        CALayer *currentImageLayer = [_imageLayers objectAtIndex:j];
        [selectedImageLayers addObject:currentImageLayer];
        CALayer *backup = [CALayer layer];
        backup.bounds = currentImageLayer.bounds;
        backup.position = currentImageLayer.position;
        backup.zPosition = currentImageLayer.zPosition;
        backup.anchorPoint = currentImageLayer.anchorPoint;
        backup.transform = currentImageLayer.transform;
        backup.borderColor = [UIColor redColor].CGColor;
        backup.borderWidth = 0;
        backup.mask = currentImageLayer.mask;
        backup.opacity = currentImageLayer.opacity;
        [selectedImageLayersBackup addObject:backup];
    }

    coverFlowView.currentRenderingImageIndex = selectedImageLayers.count/2;
    for (int k = 0; k < selectedImageLayers.count; k++) {
        CALayer *imgLayer = [selectedImageLayers objectAtIndex:k];

        CALayer *templateLayer;
        int middleIndex = selectedImageLayers.count/2;

        BOOL isVisible = NO;

        //there is no gonna be visible
        if (k < (middleIndex  - visibleImageSideCount)){
            NSLog(@"left invisible index: %d", k);
            templateLayer = [[coverFlowView getTemplateLayers] objectAtIndex: 0];
        }else if (k <= middleIndex + visibleImageSideCount){ //visible
            NSLog(@"middle visible index: %d", k);
            NSLog(@"middle template count: %d,  current index: %d", [coverFlowView getTemplateLayers].count, k - middleIndex + visibleImageSideCount + 1);
            templateLayer = [[coverFlowView getTemplateLayers] objectAtIndex:(k - (middleIndex - visibleImageSideCount) + 1 )];
            isVisible = YES;
        }else{//not visible in right side
            NSLog(@"right invisible index: %d", k);
            templateLayer = [[coverFlowView getTemplateLayers] lastObject];
        }


//        if (j < [coverFlowView getTemplateLayers].count - 2){
//            NSLog(@"j : %i, count: %d", j, [coverFlowView getTemplateLayers].count);
//            templateLayer = [[coverFlowView getTemplateLayers] objectAtIndex: j + 1];
//        }

            //imgLayer.zPosition = -0;

        float destiZPosition = templateLayer.zPosition;


        float scale = [[templateLayer valueForKey:@"scale"] floatValue];
      //  NSLog(@"scale: %f", scale);
        //CGPoint newPosition = CGPointMake(templateLayer.position.x -(width/2) + width * (1 - scale)/2,templateLayer.position.y - 150 + height * (1 - scale)/2);
        CGPoint newPosition = CGPointMake(templateLayer.position.x, templateLayer.position.y + ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).bounds.size.height/2);
        //NSLog(@"new template position: %@", [NSValue valueWithCGPoint:newPosition] );

        CATransform3D destiTransform = templateLayer.transform;

            CGFloat yGap = self.imagesView.bounds.size.height - imgLayer.frame.origin.y ;
            CGFloat xGap = templateLayer.frame.origin.x - imgLayer.frame.origin.x ;

//            NSLog(@"%f, %f, %f", self.imagesView.bounds.size.height , imgLayer.frame.origin.y , templateLayer.frame.origin.y);
//        NSLog(@"%f, %f, %f", self.imagesView.bounds.size.width , imgLayer.frame.origin.x, templateLayer.frame.origin.x);
//            NSLog(@"x gap : %f, y gap : %f", xGap, yGap);



        // Add the animation group to the templateLayer
//        CABasicAnimation *zPositionAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
//        zPositionAnimation.toValue = [NSNumber numberWithFloat:destiZPosition];
//        zPositionAnimation.repeatCount = 0;
//        zPositionAnimation.duration = 5;
//        zPositionAnimation.autoreverses = NO;
//        zPositionAnimation.removedOnCompletion = NO;
//
//            CABasicAnimation *moveDownLayer = [CABasicAnimation animationWithKeyPath:@"position"];
//                moveDownLayer.toValue = [NSValue valueWithCGPoint:CGPointMake(templateLayer.frame.origin.x,self.imagesView.bounds.size.height + templateLayer.frame.origin.y)];
//                moveDownLayer.toValue = [NSValue valueWithCGPoint:newPosition];
//                //moveDownLayer.toValue = [NSValue valueWithCGPoint:CGPointMake(400,100)];
//                moveDownLayer.repeatCount = 0;
//                moveDownLayer.duration = 5;
//                moveDownLayer.autoreverses = NO;
//                moveDownLayer.removedOnCompletion = NO;
//
//        CAAnimationGroup *theGroup = [CAAnimationGroup animation];
//        theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        theGroup.duration = 5;
//        theGroup.repeatCount = 0;
//        theGroup.autoreverses = NO;
//        theGroup.removedOnCompletion = NO;
//        theGroup.animations = [NSArray arrayWithObjects:zPositionAnimation, moveDownLayer, nil]; // you can add more
//        [imgLayer addAnimation:theGroup forKey:@"zoomAndRotate"];
//


        //imgLayer.bounds = CGRectMake(0,0,width * scale, height * scale);
        [CATransaction setAnimationDuration:5];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

        imgLayer.bounds =((CALayer *)[templateLayer.sublayers objectAtIndex:0]).bounds;
        imgLayer.position = newPosition;
        imgLayer.zPosition = destiZPosition;
        imgLayer.anchorPoint = CGPointMake(0.5, 0.5);
        imgLayer.transform = destiTransform;
        imgLayer.borderColor = [UIColor redColor].CGColor;
        imgLayer.borderWidth = 0;
        imgLayer.mask = nil;

        NSArray *args = [[NSArray alloc] initWithObjects:imgLayer, [NSNumber numberWithBool:isVisible], templateLayer,nil];
        [self performSelector:@selector(hideImageAndShowSlide:) withObject:args afterDelay:5];
       // imgLayer.bounds =CGRectZero;


        //TODOList: this part need to be delay after animation group
        //((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = imgLayer.contents;
        if (isVisible == NO){
            //NSLog(@"hidden yes for k: %d > count: %d" ,k, [coverFlowView getTemplateLayers].count - 2);
            //imgLayer.hidden = YES;

            float endOpacity =  0.0;
            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [fadeOut setToValue:[NSNumber numberWithFloat:endOpacity]];
            [fadeOut setDuration:0.5f];
            [fadeOut setRemovedOnCompletion:NO];
            [imgLayer addAnimation:fadeOut forKey:@"fadeout"];
            imgLayer.opacity = endOpacity;

           // ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = nil;
        }

        [CATransaction commit];


    }




   	//[self performSelector:@selector(hideImageLayer) withObject:self afterDelay:1.6];


    [self performSelector:@selector(showRealmages) withObject:self afterDelay:2.6];



}
- (void)hideImageAndShowSlide:(NSArray *)args{
    CALayer *imgLayer = [args objectAtIndex:0];
    BOOL isVisible = [[args objectAtIndex:1] boolValue];
    CALayer *templateLayer = [args objectAtIndex:2];

    [CATransaction setDisableActions:YES];
    imgLayer.bounds =CGRectZero;
    [CATransaction setDisableActions:NO];

    [CATransaction setAnimationDuration:0.5];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];

    if (isVisible)
        ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = imgLayer.contents;
    else
        ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = nil;

    [CATransaction commit];
}


- (void)showRealmages {
    [coverFlowView addGestureRecognizer:self.imagesView];
    //[coverFlowView setImageSources:selectedImages];
    NSLog(@"");
    [coverFlowView setSourceImageLayers:selectedImageLayers];
    [coverFlowView setupImagesWithSourceLayers];
}
-(void)flyBack{
    NSLog(@"flyBack================================================================");

//    for (int k = 0; k < selectedImageLayers.count; k++) {
//
//    [CATransaction setDisableActions:YES];
//     currentImageLayer.bounds =;
//    [CATransaction setDisableActions:NO];
//
//    [CATransaction setAnimationDuration:0.5];
//    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//
//    if (isVisible)
//        ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = imgLayer.contents;
//    else
//        ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = nil;
//
//    [CATransaction commit];
//
//    }
    [CATransaction setDisableActions:YES];
    for (int i = 0; i < coverFlowView.getTemplateLayers.count; i++) {
            int indexInImage =  (coverFlowView.currentRenderingImageIndex - coverFlowView.sideVisibleImageCount ) + i - 1;
            CALayer *template = [coverFlowView.getTemplateLayers objectAtIndex:i];
            if (indexInImage  <= selectedImageLayers.count - 1 && indexInImage   >= 0 && i !=0 && i != coverFlowView.templateLayers.count -1)   {
                CALayer *currentImageLayer = [selectedImageLayers objectAtIndex:indexInImage];
                currentImageLayer.bounds = ((CALayer *)[template.sublayers objectAtIndex:0]).bounds;
                currentImageLayer.opacity = 1.0;
            }



    }
    [CATransaction setDisableActions:NO];

    for (int i = 0; i < coverFlowView.getTemplateLayers.count; i++) {
            CALayer *template = [coverFlowView.getTemplateLayers objectAtIndex:i];

                     CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    [fadeOut setToValue:[NSNumber numberWithFloat:0.0]];
                    [fadeOut setDuration:0.5f];
                     [fadeOut setRemovedOnCompletion:NO];
                       [fadeOut setFillMode:kCAFillModeForwards];
                      [(CALayer *)[template.sublayers objectAtIndex:0] addAnimation:fadeOut forKey:@"fadeout"];

    }

//    [self.imagesView removeGestureRecognizer:coverFlowView.gestureRecognizer];
    [self performSelector:@selector(hideImageLayer) withObject:self afterDelay:1.6];
}



-(void)hideImageLayer{


    [CATransaction setAnimationDuration:5];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

    for (int k = 0; k < selectedImageLayers.count; k++) {
        CALayer *currentImageLayer = [selectedImageLayers objectAtIndex:k];
            CALayer *currentImageLayerBackup = [selectedImageLayersBackup objectAtIndex:k];

        currentImageLayer.bounds = currentImageLayerBackup.bounds;
        currentImageLayer.position = currentImageLayerBackup.position;
        currentImageLayer.zPosition = currentImageLayerBackup.zPosition;
        currentImageLayer.anchorPoint = currentImageLayerBackup.anchorPoint;
        currentImageLayer.transform = currentImageLayerBackup.transform;
        currentImageLayer.borderColor = [UIColor redColor].CGColor;
        currentImageLayer.borderWidth = 0;
        currentImageLayer.mask = currentImageLayerBackup.mask;
        currentImageLayer.opacity = currentImageLayerBackup.opacity;


    }

    [CATransaction commit];

    [self performSelector:@selector(moveDown) withObject:self afterDelay:5];
}

- (void)moveUpCameraAngle
{

    [CATransaction setDisableActions:NO];
	[CATransaction setAnimationDuration:1];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];


	CATransform3D t = CATransform3DIdentity;
	t.m34 = 1.0/-500; //Newmans

//	t = CATransform3DRotate(t, 0.09, 0, 0, 1); //Z
	//t = CATransform3DRotate(t, .62, 0, 1, 0);	//Y
//	t = CATransform3DRotate(t, 1.44, -1, 0, 0); //X
//
	//t = CATransform3DScale(t, 0.35, 0.35, 1.0);
	t = CATransform3DTranslate(t, 0, -220, 0);

	self.imagesView.layer.sublayerTransform = t;

//	replicatorEast.transform = CATransform3DMakeTranslation(-440, -440, 0);
//	replicatorWest.transform = CATransform3DMakeTranslation(440, 440, -55);
//
//	[self performSelector:@selector(animateTopOut) withObject:self afterDelay:2.6];
//	[self performSelector:@selector(animateBottomOut) withObject:self afterDelay:2.6];

    [CATransaction commit];
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


- (IBAction)flyInPressed:(id)sender {
    [CATransaction setDisableActions:NO];
    	[CATransaction setAnimationDuration:2];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

        for(CALayer *layer in _imageLayers){
            CATransform3D transform3D = CATransform3DTranslate(layer.transform, 0, -200, 0);
            layer.transform = transform3D;
        }
        [CATransaction commit];

    [self performSelector:@selector(flyToCoverFlow) withObject:self afterDelay:2];
}

- (IBAction)flyOutPressed:(id)sender {
    [self performSelector:@selector(flyBack) withObject:self afterDelay:1];

}

-(void)moveDown{
    [CATransaction setDisableActions:NO];
    	[CATransaction setAnimationDuration:2];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

        for(CALayer *layer in _imageLayers){
            CATransform3D transform3D = CATransform3DTranslate(layer.transform, 0, 200, 0);
            layer.transform = transform3D;
        }
        [CATransaction commit];
}
@end