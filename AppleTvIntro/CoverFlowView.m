//
//  Created by tuo on 4/1/12.
//
// to change "templates" to "placeholder"
//

#import "CoverFlowView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#define DISTNACE_TO_MAKE_MOVE_FOR_SWIPE 60

@interface CoverFlowView ()

@end


@implementation CoverFlowView {
@private

    NSMutableArray *_images;
    NSMutableArray *_imageLayers;
    NSMutableArray *_templateLayers;
    int _currentRenderingImageIndex;
    UIPageControl *_pageControl;
    int _sideVisibleImageCount;
    CGFloat _sideVisibleImageScale;
    CGFloat _middleImageScale;
    CALayer *_rootLayer;
    NSArray *_rawImageLayers;
    CGSize _layerSize;

    UIPanGestureRecognizer *_gestureRecognizer;
}


@synthesize images = _images;
@synthesize imageLayers = _imageLayers;
@synthesize templateLayers = _templateLayers;
@synthesize currentRenderingImageIndex = _currentRenderingImageIndex;
@synthesize pageControl = _pageControl;
@synthesize sideVisibleImageCount = _sideVisibleImageCount;
@synthesize sideVisibleImageScale = _sideVisibleImageScale;
@synthesize middleImageScale = _middleImageScale;
@synthesize rootLayer = _rootLayer;
@synthesize rawImageLayers = _rawImageLayers;
@synthesize gestureRecognizer = _gestureRecognizer;


+ (id)coverFlowViewWithFrame:(CGRect)frame andImages:(NSMutableArray *)rawImages sideImageCount:(int)sideCount sideImageScale:(CGFloat)sideImageScale middleImageScale:(CGFloat)middleImageScale {
    CoverFlowView *flowView = [[CoverFlowView alloc] initWithFrame:frame];

    flowView.sideVisibleImageCount = sideCount;
    flowView.sideVisibleImageScale = sideImageScale;
    flowView.middleImageScale = middleImageScale;

    //default set middle image to the first image in the source images array
    flowView.currentRenderingImageIndex = 6;

    flowView.images = [NSMutableArray arrayWithArray:rawImages];
    flowView.imageLayers = [[NSMutableArray alloc] initWithCapacity:flowView.sideVisibleImageCount* 2 + 1];
    flowView.templateLayers = [[NSMutableArray alloc] initWithCapacity:(flowView.sideVisibleImageCount + 1)* 2 + 1];

    //register the pan gesture to figure out whether user has intention to move to next/previous image
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:flowView action:@selector(handleGesture:)];
    [flowView addGestureRecognizer:gestureRecognizer];

    //now almost setup
    //[flowView setupTemplateLayers];

    //[flowView setupImages];

    //[flowView addPageControl];

    return flowView;
}


   //register the pan gesture to figure out whether user has intention to move to next/previous image
- (void)addGestureRecognizer:(UIView *)view  {
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [view addGestureRecognizer:self.gestureRecognizer];
}

+ (id)coverFlowInView:(UIView *)view andImages:(NSMutableArray *)rawImages sideImageCount:(int)sideCount sideImageScale:(CGFloat)sideImageScale middleImageScale:(CGFloat)middleImageScale {
    CoverFlowView *flowView = [[CoverFlowView alloc] init];

    flowView.sideVisibleImageCount = sideCount;
    flowView.sideVisibleImageScale = sideImageScale;
    flowView.middleImageScale = middleImageScale;

    //default set middle image to the first image in the source images array
    flowView.currentRenderingImageIndex = 3;

    flowView.images = [NSMutableArray arrayWithArray:rawImages];
    flowView.imageLayers = [[NSMutableArray alloc] initWithCapacity:flowView.sideVisibleImageCount* 2 + 1];
    flowView.templateLayers = [[NSMutableArray alloc] initWithCapacity:(flowView.sideVisibleImageCount + 1)* 2 + 1];




    //now almost setup
    //[flowView setupTemplateLayers];

    //[flowView setupImages];

    //[flowView addPageControl];

    flowView.rootLayer = view.layer;
    return flowView;
  //To change the template use AppCode | Preferences | File Templates.

}
- (void)removeLayerFromSuper:(CALayer *)layerToBeRemoved {
    [layerToBeRemoved removeFromSuperlayer];
}

- (void)adjustReflectionBounds:(CALayer *)layer scale:(CGFloat)scale {
// set originLayer's reflection bounds
    CALayer *reflectLayer = (CALayer*)[layer.sublayers objectAtIndex:0];
    [self scaleBounds:reflectLayer x:scale y:scale];
    // set originLayer's reflection bounds
    [self scaleBounds:reflectLayer.mask x:scale y:scale];
    // set originLayer's reflection bounds
    [self scaleBounds:(CALayer*)[reflectLayer.sublayers objectAtIndex:0] x:scale y:scale];
    // set originLayer's reflection position
    reflectLayer.position = CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height*1.5);
    // set originLayer's mask position
    reflectLayer.mask.position = CGPointMake(reflectLayer.bounds.size.width/2, reflectLayer.bounds.size.height/2);
    // set originLayer's reflection position
    ((CALayer*)[reflectLayer.sublayers objectAtIndex:0]).position = CGPointMake(reflectLayer.bounds.size.width/2, reflectLayer.bounds.size.height/2);
}

- (void)moveOneStep:(BOOL)isSwipingToLeftDirection {
    //when move the first/last image,disable moving
    if ((self.currentRenderingImageIndex == 0 && !isSwipingToLeftDirection) || (self.currentRenderingImageIndex == self.images.count -1 && isSwipingToLeftDirection))
        return;

    int offset = isSwipingToLeftDirection ?  -1 : 1;
    int indexOffsetFromImageLayersToTemplates = (self.currentRenderingImageIndex - self.sideVisibleImageCount < 0) ? (self.sideVisibleImageCount + 1 + offset - self.currentRenderingImageIndex) : 1 + offset;
    for (int i = 0; i < self.imageLayers.count; i++) {
        CALayer *originLayer = [self.imageLayers objectAtIndex:i];
        CALayer *targetTemplate = [self.templateLayers objectAtIndex: i + indexOffsetFromImageLayersToTemplates];

        [CATransaction setAnimationDuration:1];
        originLayer.position = targetTemplate.position;
        originLayer.zPosition = targetTemplate.zPosition;
        originLayer.transform = targetTemplate.transform;
        //set originlayer's bounds

        CGFloat scale = 1.0f;
        if (i + indexOffsetFromImageLayersToTemplates - 1 == self.sideVisibleImageCount) {
            scale = self.middleImageScale  / self.sideVisibleImageScale;
        } else if (((i + indexOffsetFromImageLayersToTemplates - 1 == self.sideVisibleImageCount - 1) && isSwipingToLeftDirection) ||
                ((i + indexOffsetFromImageLayersToTemplates - 1 == self.sideVisibleImageCount + 1) && !isSwipingToLeftDirection)) {
            scale = self.sideVisibleImageScale / self.middleImageScale;
        }

        originLayer.bounds = CGRectMake(0, 0, originLayer.bounds.size.width * scale, originLayer.bounds.size.height * scale);
        [self adjustReflectionBounds:originLayer scale:scale];

    }

    if (isSwipingToLeftDirection){
        //when current rendering index  >= sidecout
        if(self.currentRenderingImageIndex >= self.sideVisibleImageCount){
            CALayer *removeLayer = [self.imageLayers objectAtIndex:0];
            [self.imageLayers removeObject:removeLayer];
            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
                        [fadeOut setToValue:[NSNumber numberWithFloat:0.0]];
                        [fadeOut setDuration:0.5f];
                        [removeLayer addAnimation:fadeOut forKey:@"fadeout"];
                        [self performSelector:@selector(removeLayerFromSuper:) withObject:removeLayer afterDelay:0.5f];
        }
        int num = self.images.count - self.sideVisibleImageCount - 1;
        if (self.currentRenderingImageIndex < num){
            UIImage *candidateImage = [self.images objectAtIndex:self.currentRenderingImageIndex  + self.sideVisibleImageCount + 1];
            CALayer *candidateLayer = [CALayer layer];
            candidateLayer.contents = (__bridge id)candidateImage.CGImage;
            CGFloat scale = self.sideVisibleImageScale;
            candidateLayer.bounds = CGRectMake(0, 0, candidateImage.size.width * scale, candidateImage.size.height * scale);
            [self.imageLayers addObject:candidateLayer];

            CALayer *template = [self.templateLayers objectAtIndex:self.templateLayers.count - 2];
            candidateLayer.position = template.position;
            candidateLayer.zPosition = template.zPosition;
            candidateLayer.transform = template.transform;

            //show the layer
            [self showImageAndReflection:candidateLayer];
        }

    }else{//if the right, then move the rightest layer and insert one to left (if left is full)

        //when to remove rightest, only when image in the rightest is indeed sitting in the template  imagelayer's rightes
        if (self.currentRenderingImageIndex + self.sideVisibleImageCount <= self.images.count -1) {
            CALayer *removeLayer = [self.imageLayers lastObject];
            [self.imageLayers removeObject:removeLayer];
            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
                        [fadeOut setToValue:[NSNumber numberWithFloat:0.0]];
                        [fadeOut setDuration:0.5f];
                        [removeLayer addAnimation:fadeOut forKey:@"fadeout"];
                        [self performSelector:@selector(removeLayerFromSuper:) withObject:removeLayer afterDelay:0.5f];
        }

        //check out whether we need to add layer to left, only when (currentIndex - sideCount > 0)
        if (self.currentRenderingImageIndex > self.sideVisibleImageCount){
            UIImage *candidateImage = [self.images objectAtIndex:self.currentRenderingImageIndex - 1 - self.sideVisibleImageCount];
            CALayer *candidateLayer = [CALayer layer];
            candidateLayer.contents = (__bridge id)candidateImage.CGImage;
            CGFloat scale = self.sideVisibleImageScale;
            candidateLayer.bounds = CGRectMake(0, 0, candidateImage.size.width * scale, candidateImage.size.height * scale);
            [self.imageLayers insertObject:candidateLayer atIndex:0];

            CALayer *template = [self.templateLayers objectAtIndex:1];
            candidateLayer.position = template.position;
            candidateLayer.zPosition = template.zPosition;
            candidateLayer.transform = template.transform;

            //show the layer
            [self showImageAndReflection:candidateLayer];
        }

    }
    //update index if you move to right, index--
    self.currentRenderingImageIndex = isSwipingToLeftDirection ? self.currentRenderingImageIndex + 1 : self.currentRenderingImageIndex - 1;

}

- (void)scaleBounds:(CALayer*)layer x:(CGFloat)scaleWidth y:(CGFloat)scaleHeight
{
    layer.bounds = CGRectMake(0, 0, layer.bounds.size.width*scaleWidth, layer.bounds.size.height*scaleHeight);
}

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer {

   if (recognizer.state == UIGestureRecognizerStateChanged){
       //get offset
       CGPoint offset = [recognizer translationInView:recognizer.view];
       if (abs(offset.x) > DISTNACE_TO_MAKE_MOVE_FOR_SWIPE) {
           BOOL isSwipingToLeftDirection = (offset.x > 0) ? NO :YES;
           [self newMoveOneStep:isSwipingToLeftDirection];
           [recognizer setTranslation:CGPointZero inView:recognizer.view];
       }
   }

}





- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        //set up perspective
//        CATransform3D transformPerspective = CATransform3DIdentity;
//                        transformPerspective.m34 = -1.0 / 500.0;
//                        self.layer.sublayerTransform = transformPerspective;
    }

    return self;
}

-(void)setupTemplateLayers {
    CGFloat centerX = _rootLayer.bounds.size.width/2;
    CGFloat centerY = _rootLayer.bounds.size.height -  300/2 ;

    //the angle to rotate
    CGFloat leftRadian = M_PI/5;
    CGFloat rightRadian = -M_PI/5;

    //gap between images in side
    CGFloat gapAmongSideImages = 100.0f;

    //gap between middle one and neigbour(this word is so hard to type wrong: WTF)
    CGFloat gapBetweenMiddleAndSide = 150.0f;

    //setup the layer templates
    //let's start from left side
    const CGFloat sideLayerWidth = _layerSize.width * self.sideVisibleImageScale;
    const CGFloat sideLayerHeight = _layerSize.height * self.sideVisibleImageScale;

    for(int i = 0; i <= self.sideVisibleImageCount; i++){

        CAReplicatorLayer *contanerLayer = [CAReplicatorLayer layer];
        [contanerLayer setContentsScale:[[UIScreen mainScreen] scale]];
        contanerLayer.bounds = CGRectMake(0,0, sideLayerWidth, sideLayerHeight * 1.5);
        contanerLayer.position = CGPointMake(centerX - gapBetweenMiddleAndSide - gapAmongSideImages * (self.sideVisibleImageCount - i), centerY - 100);
        contanerLayer.anchorPoint = CGPointMake(0.5, 0.33); //1/3
        contanerLayer.anchorPoint = CGPointMake(0.5, 0); //1/3
        contanerLayer.instanceCount = 2;
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DScale(transform, 1.0, -1.0, 1.0);
        transform = CATransform3DTranslate(transform, 0, -_layerSize.height * self.sideVisibleImageScale * 2, 1.0);
            //transform = CATransform3DTranslate(transform, 0, 100, 1.0);
        contanerLayer.instanceTransform = transform;
        contanerLayer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
        contanerLayer.zPosition = (i - self.sideVisibleImageCount - 1) * 10;
        contanerLayer.masksToBounds =  YES;

       CALayer *layer = [CALayer layer];
//       layer.position = CGPointMake(centerX - gapBetweenMiddleAndSide - gapAmongSideImages * (self.sideVisibleImageCount - i), centerY);
//       layer.zPosition = (i - self.sideVisibleImageCount - 1) * 10;
//       layer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
//       layer.bounds = CGRectMake(0,0, _layerSize.width * self.sideVisibleImageScale, _layerSize.height * self.sideVisibleImageScale);
//       [layer setValue:[NSNumber numberWithFloat:self.sideVisibleImageScale] forKey:@"scale"];
//
        [layer setAnchorPoint:CGPointMake(0, 0)];
         //layer.zPosition = (i - self.sideVisibleImageCount - 1) * 10;
         //layer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
       layer.bounds = CGRectMake(0,0, sideLayerWidth, sideLayerHeight);
       [layer setValue:[NSNumber numberWithFloat:self.sideVisibleImageScale] forKey:@"scale"];


        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        [gradientLayer setColors:[NSArray arrayWithObjects:(__bridge id)[[UIColor clearColor] colorWithAlphaComponent:0.25].CGColor, [UIColor blackColor].CGColor, nil]];
          [gradientLayer setBounds:CGRectMake(0, 0, layer.frame.size.width, sideLayerHeight * 0.5)];
          [gradientLayer setAnchorPoint:CGPointMake(0.5, 0)];
          [gradientLayer setPosition:CGPointMake(contanerLayer.frame.origin.x + (contanerLayer.frame.size.width)/2 ,
                  contanerLayer.frame.origin.y + sideLayerHeight + 1.0)];
          //[gradientLayer setZPosition:(layer.zPosition + 1)];
        gradientLayer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);

      [contanerLayer addSublayer:layer];
      [self.rootLayer addSublayer:contanerLayer];
      [self.rootLayer addSublayer:gradientLayer];


        [self.templateLayers addObject:contanerLayer];
    }

    //middle


    CAReplicatorLayer *contanerLayer = [CAReplicatorLayer layer];
    [contanerLayer setContentsScale:[[UIScreen mainScreen] scale]];
    contanerLayer.bounds = CGRectMake(0,0, _layerSize.width * self.middleImageScale, _layerSize.height * self.middleImageScale * 1.5);
    contanerLayer.position = CGPointMake(centerX, centerY-100);
    contanerLayer.anchorPoint = CGPointMake(0.5, 0); //1/3
    contanerLayer.instanceCount = 2;
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DScale(transform, 1.0, -1.0, 1.0);
    transform = CATransform3DTranslate(transform, 0, -_layerSize.height * self.middleImageScale * 2, 1.0);
    contanerLayer.instanceTransform = transform;
    //contanerLayer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
    contanerLayer.zPosition = 0;
    contanerLayer.masksToBounds =  YES;



   CALayer *layer = [CALayer layer];
//       layer.position = CGPointMake(centerX - gapBetweenMiddleAndSide - gapAmongSideImages * (self.sideVisibleImageCount - i), centerY);
//       layer.zPosition = (i - self.sideVisibleImageCount - 1) * 10;
//       layer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
//       layer.bounds = CGRectMake(0,0, _layerSize.width * self.sideVisibleImageScale, _layerSize.height * self.sideVisibleImageScale);
//       [layer setValue:[NSNumber numberWithFloat:self.sideVisibleImageScale] forKey:@"scale"];
//
   //layer.position = CGPointMake(contanerLayer.bounds.size.width/2,contanerLayer.bounds.size.height/2);
     //layer.zPosition = (i - self.sideVisibleImageCount - 1) * 10;
     //layer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
   layer.bounds = CGRectMake(0,0, _layerSize.width * self.middleImageScale, _layerSize.height * self.middleImageScale);
    [layer setAnchorPoint:CGPointMake(0, 0)];




    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setColors:[NSArray arrayWithObjects:(__bridge id)[[UIColor clearColor] colorWithAlphaComponent:0.25].CGColor, [UIColor blackColor].CGColor, nil]];

        [gradientLayer setBounds:CGRectMake(0, 0, layer.frame.size.width, _layerSize.height * self.middleImageScale * 0.5)];
        [gradientLayer setAnchorPoint:CGPointMake(0.5, 0)];
        [gradientLayer setPosition:CGPointMake(contanerLayer.frame.origin.x + (contanerLayer.frame.size.width)/2 ,
                contanerLayer.frame.origin.y + _layerSize.height * self.middleImageScale + 1.0)];
        //[gradientLayer setZPosition:(layer.zPosition + 1)];


    [contanerLayer addSublayer:layer];
    [self.rootLayer addSublayer:contanerLayer];
    [self.rootLayer addSublayer:gradientLayer];


    [self.templateLayers addObject:contanerLayer];


    //right
    for(int i = 0; i <= self.sideVisibleImageCount; i++){


        CAReplicatorLayer *contanerLayer = [CAReplicatorLayer layer];
        [contanerLayer setContentsScale:[[UIScreen mainScreen] scale]];
        contanerLayer.bounds = CGRectMake(0,0, sideLayerWidth, sideLayerHeight * 1.5);
        contanerLayer.position = CGPointMake(centerX + gapBetweenMiddleAndSide + gapAmongSideImages * i, centerY - 100);
        contanerLayer.anchorPoint = CGPointMake(0.5, 0); //1/3
        contanerLayer.instanceCount = 2;
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DScale(transform, 1.0, -1.0, 1.0);
        transform = CATransform3DTranslate(transform, 0, -sideLayerHeight * 2, 1.0);
            //transform = CATransform3DTranslate(transform, 0, 100, 1.0);
        contanerLayer.instanceTransform = transform;
        contanerLayer.transform = CATransform3DMakeRotation(rightRadian, 0, 1, 0);
        contanerLayer.zPosition = (i + 1) * -10;
        contanerLayer.masksToBounds = YES;

       CALayer *layer = [CALayer layer];
//       layer.position = CGPointMake(centerX - gapBetweenMiddleAndSide - gapAmongSideImages * (self.sideVisibleImageCount - i), centerY);
//       layer.zPosition = (i - self.sideVisibleImageCount - 1) * 10;
//       layer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
//       layer.bounds = CGRectMake(0,0, _layerSize.width * self.sideVisibleImageScale, _layerSize.height * self.sideVisibleImageScale);
//       [layer setValue:[NSNumber numberWithFloat:self.sideVisibleImageScale] forKey:@"scale"];
//
        [layer setAnchorPoint:CGPointMake(0, 0)];
         //layer.zPosition = (i - self.sideVisibleImageCount - 1) * 10;
         //layer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
       layer.bounds = CGRectMake(0,0, sideLayerWidth, sideLayerHeight);
       [layer setValue:[NSNumber numberWithFloat:self.sideVisibleImageScale] forKey:@"scale"];


        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            [gradientLayer setColors:[NSArray arrayWithObjects:(__bridge id)[[UIColor clearColor] colorWithAlphaComponent:0.25].CGColor, [UIColor blackColor].CGColor, nil]];

            [gradientLayer setBounds:CGRectMake(0, 0, layer.frame.size.width, sideLayerHeight * 0.5)];
            [gradientLayer setAnchorPoint:CGPointMake(0.5, 0)];
            [gradientLayer setPosition:CGPointMake(contanerLayer.frame.origin.x + (contanerLayer.frame.size.width)/2 ,
                    contanerLayer.frame.origin.y + sideLayerHeight + 1.0)];
            //[gradientLayer setZPosition:(layer.zPosition + 1)];
        gradientLayer.transform = CATransform3DMakeRotation(rightRadian, 0, 1, 0);

        [contanerLayer addSublayer:layer];
        [self.rootLayer addSublayer:contanerLayer];
        [self.rootLayer addSublayer:gradientLayer];


        [self.templateLayers addObject:contanerLayer];

    }

    //for (int i = 1; i < self.templateLayers.count - 1; i ++){
        //[self.rootLayer addSublayer:[self.templateLayers objectAtIndex:i]];

   // }
}

- (void)setupImages{
    // setup the visible area, and start index and end index
    int startingImageIndex = (self.currentRenderingImageIndex - self.sideVisibleImageCount <= 0) ? 0 : self.currentRenderingImageIndex - self.sideVisibleImageCount;
    int endImageIndex = (self.currentRenderingImageIndex + self.sideVisibleImageCount < self.images.count )  ? (self.currentRenderingImageIndex + self.sideVisibleImageCount) : (self.images.count -1 );

    //step2: set up images that ready for rendering
    for (int i = startingImageIndex; i <= endImageIndex; i++) {
       UIImage *image = [self.images objectAtIndex:i];
       CALayer *imageLayer = [CALayer layer];
       imageLayer.contents = (__bridge id)image.CGImage;
       CGFloat scale = (i == self.currentRenderingImageIndex) ? self.middleImageScale : self.sideVisibleImageScale;
       imageLayer.bounds = CGRectMake(0, 0, image.size.width * scale, image.size.height*scale);
       [self.imageLayers addObject:imageLayer];
    }

    //step3 : according to templates, set its geometry info to corresponding image layer
    //1 means the extra layer in templates layer
    //damn mathmatics
    int indexOffsetFromImageLayersToTemplates = (self.currentRenderingImageIndex - self.sideVisibleImageCount < 0) ? (self.sideVisibleImageCount + 1 - self.currentRenderingImageIndex) : 1;
    for (int i = 0; i < self.imageLayers.count; i++) {
        CALayer *correspondingTemplateLayer = [self.templateLayers objectAtIndex:(i + indexOffsetFromImageLayersToTemplates)];
        CALayer *imageLayer = [self.imageLayers objectAtIndex:i];
        imageLayer.position = correspondingTemplateLayer.position;
        imageLayer.zPosition = correspondingTemplateLayer.zPosition;
        imageLayer.transform = correspondingTemplateLayer.transform;
        //show its reflections
        [self showImageAndReflection:imageLayer];
    }
}

// 添加layer及其“倒影”
- (void)showImageAndReflection:(CALayer*)layer
{
    // 制作reflection
    CALayer *reflectLayer = [CALayer layer];
    reflectLayer.contents = layer.contents;
    reflectLayer.bounds = layer.bounds;
    reflectLayer.position = CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height*1.5);
    reflectLayer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);

    // 给该reflection加个半透明的layer
    CALayer *blackLayer = [CALayer layer];
    blackLayer.backgroundColor = [UIColor blackColor].CGColor;
    blackLayer.bounds = reflectLayer.bounds;
    blackLayer.position = CGPointMake(blackLayer.bounds.size.width/2, blackLayer.bounds.size.height/2);
    blackLayer.opacity = 0.6;
    [reflectLayer addSublayer:blackLayer];

    // 给该reflection加个mask
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.bounds = reflectLayer.bounds;
    mask.position = CGPointMake(mask.bounds.size.width/2, mask.bounds.size.height/2);
    mask.colors = [NSArray arrayWithObjects:
                   (__bridge id)[UIColor clearColor].CGColor,
                   (__bridge id)[UIColor whiteColor].CGColor, nil];
    mask.startPoint = CGPointMake(0.5, 0.35);
    mask.endPoint = CGPointMake(0.5, 1.0);
    reflectLayer.mask = mask;

    // 作为layer的sublayer
    [layer addSublayer:reflectLayer];
    // 加入UICoverFlowView的sublayers
    [self.rootLayer addSublayer:layer];
}

- (void)addPageControl {


}


- (int)getIndexForMiddle {

    return 0;
}

-(NSArray *)getTemplateLayers{
    return [NSArray arrayWithArray:_templateLayers];
}

- (void)setImageSources:(NSArray *)sImages {
    self.images = sImages;

}


- (void)setSourceImageLayers:(NSMutableArray *)sourceImageLayers {
    self.rawImageLayers = [NSArray arrayWithArray:sourceImageLayers];
}


- (void)setupImagesWithSourceLayers{
    // setup the visible area, and start index and end index
    self.currentRenderingImageIndex = self.rawImageLayers.count/2;
    int startingImageIndex = (self.currentRenderingImageIndex - self.sideVisibleImageCount <= 0) ? 0 : self.currentRenderingImageIndex - self.sideVisibleImageCount;
    int endImageIndex = (self.currentRenderingImageIndex + self.sideVisibleImageCount < self.images.count )  ? (self.currentRenderingImageIndex + self.sideVisibleImageCount) : (self.images.count -1 );
    NSLog(@"start current image index: %d, and count: %d , ", self.currentRenderingImageIndex, self.rawImageLayers.count);
    //step2: set up images that ready for rendering
//    for (int i = startingImageIndex; i <= endImageIndex; i++) {
//       UIImage *image = [self.images objectAtIndex:i];
//       CALayer *imageLayer = [CALayer layer];
//       imageLayer.contents = (__bridge id)image.CGImage;
//       CGFloat scale = (i == self.currentRenderingImageIndex) ? self.middleImageScale : self.sideVisibleImageScale;
//       imageLayer.bounds = CGRectMake(0, 0, image.size.width * scale, image.size.height*scale);
//       [self.imageLayers addObject:imageLayer];
//    }
//
//    //step3 : according to templates, set its geometry info to corresponding image layer
//    //1 means the extra layer in templates layer
//    //damn mathmatics
//    int indexOffsetFromImageLayersToTemplates = (self.currentRenderingImageIndex - self.sideVisibleImageCount < 0) ? (self.sideVisibleImageCount + 1 - self.currentRenderingImageIndex) : 1;
//    for (int i = 0; i < self.imageLayers.count; i++) {
//        CALayer *correspondingTemplateLayer = [self.templateLayers objectAtIndex:(i + indexOffsetFromImageLayersToTemplates)];
//        CALayer *imageLayer = [self.imageLayers objectAtIndex:i];
//        imageLayer.position = correspondingTemplateLayer.position;
//        imageLayer.zPosition = correspondingTemplateLayer.zPosition;
//        imageLayer.transform = correspondingTemplateLayer.transform;
//        //show its reflections
//        [self showImageAndReflection:imageLayer];
//    }
}


- (void)newMoveOneStep:(BOOL)isSwipingToLeftDirection {
    NSLog(@"current image index: %d, and count: %d , and swipe to left: %d", self.currentRenderingImageIndex, self.rawImageLayers.count, isSwipingToLeftDirection);
    //when move the first/last image,disable moving
    if ((self.currentRenderingImageIndex == 0 && !isSwipingToLeftDirection) || (self.currentRenderingImageIndex == self.rawImageLayers.count -1 && isSwipingToLeftDirection))
        return;

    int offset = isSwipingToLeftDirection ?  1 : -1;
    NSLog(@"allowed");
    NSMutableArray *visibleTemplateLayers = [[NSMutableArray alloc] init];
    for (int k = 0; k <self.templateLayers.count; k++) {

        int indexInImage =  (self.currentRenderingImageIndex - self.sideVisibleImageCount ) -1 + k;
        if (indexInImage == self.currentRenderingImageIndex){

        }
        CALayer *templateLayer = [self.templateLayers objectAtIndex:k];

        if (indexInImage + offset > self.rawImageLayers.count - 1 || indexInImage + offset < 0)   {

//            ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).opacity = 0.0;
//                        ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = nil;
            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [fadeOut setToValue:[NSNumber numberWithFloat:0.0]];
            [fadeOut setDuration:0.5f];
             [fadeOut setRemovedOnCompletion:NO];
              [(CALayer *)[templateLayer.sublayers objectAtIndex:0] addAnimation:fadeOut forKey:@"fadeout"];
            ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = nil;

        }else{
            CALayer *newLayer = [self.rawImageLayers objectAtIndex:indexInImage + offset];

            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [fadeOut setToValue:[NSNumber numberWithFloat:1.0]];
            [fadeOut setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [fadeOut setDuration:0.5f];
             [fadeOut setRemovedOnCompletion:NO];
              [(CALayer *)[templateLayer.sublayers objectAtIndex:0] addAnimation:fadeOut forKey:@"fadeout"];


            CGPoint newPosition = CGPointMake(templateLayer.position.x, templateLayer.position.y + ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).bounds.size.height/2);

            newLayer.position = newPosition;
            newLayer.zPosition = templateLayer.zPosition;
            newLayer.transform = templateLayer.transform;
            newLayer.bounds = ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).bounds;
            newLayer.bounds =CGRectZero;


            //((CALayer *)[templateLayer.sublayers objectAtIndex:0]).opacity = 1.0;
            if (k == 0 || k == self.templateLayers.count -1 )
                ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = nil;
            else
                ((CALayer *)[templateLayer.sublayers objectAtIndex:0]).contents = newLayer.contents;

        }

    }
//    for (int i = self.currentRenderingImageIndex - self.sideVisibleImageCount - 1; i <= self.currentRenderingImageIndex + self.sideVisibleImageCount + 1; i++) {
//
//        if (i > self.rawImageLayers.count - 1 || i < 0)   {
//            continue;
//        }
//
//
//        int indexInTemplate = i - (self.currentRenderingImageIndex - self.sideVisibleImageCount - 1);
//        CALayer *originLayer = [self.rawImageLayers objectAtIndex:i];
//        CALayer *targetTemplate;
//        BOOL isVisible = NO;
//        NSLog(@"i : %d , indexTempalte: %d, offset: %d, template count: %d", i, indexInTemplate, offset, self.templateLayers.count);
//        if (indexInTemplate + offset <= 0)
//            targetTemplate = [self.templateLayers objectAtIndex: 0];
//        else if (indexInTemplate + offset >= self.templateLayers.count - 1)
//            targetTemplate = [self.templateLayers lastObject];
//        else{
//            NSLog(@"index + offset: %d", indexInTemplate + offset);
//            targetTemplate = [self.templateLayers objectAtIndex: indexInTemplate + offset];
//            isVisible = YES;
//        }
//
//        float endOpacity = isVisible ? 1.0 : 0.0;
//
//        CGPoint newPosition = CGPointMake(targetTemplate.position.x, targetTemplate.position.y + ((CALayer *)[targetTemplate.sublayers objectAtIndex:0]).bounds.size.height/2);
//        [CATransaction setAnimationDuration:1];
//        originLayer.position = newPosition;
//        originLayer.zPosition = targetTemplate.zPosition;
//        originLayer.transform = targetTemplate.transform;
//        originLayer.bounds = ((CALayer *)[targetTemplate.sublayers objectAtIndex:0]).bounds;
//        originLayer.opacity = endOpacity;
//        originLayer.bounds =CGRectZero;
//        ((CALayer *)[targetTemplate.sublayers objectAtIndex:0]).contents = originLayer.contents;
//        ((CALayer *)[targetTemplate.sublayers objectAtIndex:0]).opacity = endOpacity;
//        [CATransaction commit];
//
//        [visibleTemplateLayers addObject:targetTemplate];
//
////        CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
////        [fadeOut setToValue:[NSNumber numberWithFloat:endOpacity]];
////        [fadeOut setDuration:0.5f];
////        [fadeOut setRemovedOnCompletion:NO];
////        [originLayer addAnimation:fadeOut forKey:@"fadeout"];
//
//
//
//        //set originlayer's bounds
//
////        CGFloat scale = 1.0f;
////        if (i + indexInTemplate == self.currentRenderingImageIndex) {
////            scale = self.middleImageScale  / self.sideVisibleImageScale;
////        }else if (i == self.currentRenderingImageIndex){
////            scale = self.sideVisibleImageScale / self.middleImageScale;
////        }
////        else if (((i + indexOffsetFromImageLayersToTemplates - 1 == self.sideVisibleImageCount - 1) && isSwipingToLeftDirection) ||
////                ((i + indexOffsetFromImageLayersToTemplates - 1 == self.sideVisibleImageCount + 1) && !isSwipingToLeftDirection)) {
////            scale = self.sideVisibleImageScale / self.middleImageScale;
////        }
//
//        //originLayer.bounds = CGRectMake(0, 0, originLayer.bounds.size.width * scale, originLayer.bounds.size.height * scale);
//        //[self adjustReflectionBounds:originLayer scale:scale];
//
//    }


    self.currentRenderingImageIndex = isSwipingToLeftDirection ? self.currentRenderingImageIndex + 1 : self.currentRenderingImageIndex - 1;
    NSLog(@"after current image index: %d", self.currentRenderingImageIndex);
//    if (isSwipingToLeftDirection){
//        //when current rendering index  >= sidecout
//        if(self.currentRenderingImageIndex >= self.sideVisibleImageCount){
//            CALayer *removeLayer = [self.imageLayers objectAtIndex:0];
//            [self.imageLayers removeObject:removeLayer];
//            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
//                        [fadeOut setToValue:[NSNumber numberWithFloat:0.0]];
//                        [fadeOut setDuration:0.5f];
//                        [removeLayer addAnimation:fadeOut forKey:@"fadeout"];
//                        [self performSelector:@selector(removeLayerFromSuper:) withObject:removeLayer afterDelay:0.5f];
//        }
//        int num = self.images.count - self.sideVisibleImageCount - 1;
//        if (self.currentRenderingImageIndex < num){
//            UIImage *candidateImage = [self.images objectAtIndex:self.currentRenderingImageIndex  + self.sideVisibleImageCount + 1];
//            CALayer *candidateLayer = [CALayer layer];
//            candidateLayer.contents = (__bridge id)candidateImage.CGImage;
//            CGFloat scale = self.sideVisibleImageScale;
//            candidateLayer.bounds = CGRectMake(0, 0, candidateImage.size.width * scale, candidateImage.size.height * scale);
//            [self.imageLayers addObject:candidateLayer];
//
//            CALayer *template = [self.templateLayers objectAtIndex:self.templateLayers.count - 2];
//            candidateLayer.position = template.position;
//            candidateLayer.zPosition = template.zPosition;
//            candidateLayer.transform = template.transform;
//
//            //show the layer
//            [self showImageAndReflection:candidateLayer];
//        }
//
//    }else{//if the right, then move the rightest layer and insert one to left (if left is full)
//
//        //when to remove rightest, only when image in the rightest is indeed sitting in the template  imagelayer's rightes
//        if (self.currentRenderingImageIndex + self.sideVisibleImageCount <= self.images.count -1) {
//            CALayer *removeLayer = [self.imageLayers lastObject];
//            [self.imageLayers removeObject:removeLayer];
//            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
//                        [fadeOut setToValue:[NSNumber numberWithFloat:0.0]];
//                        [fadeOut setDuration:0.5f];
//                        [removeLayer addAnimation:fadeOut forKey:@"fadeout"];
//                        [self performSelector:@selector(removeLayerFromSuper:) withObject:removeLayer afterDelay:0.5f];
//        }
//
//        //check out whether we need to add layer to left, only when (currentIndex - sideCount > 0)
//        if (self.currentRenderingImageIndex > self.sideVisibleImageCount){
//            UIImage *candidateImage = [self.images objectAtIndex:self.currentRenderingImageIndex - 1 - self.sideVisibleImageCount];
//            CALayer *candidateLayer = [CALayer layer];
//            candidateLayer.contents = (__bridge id)candidateImage.CGImage;
//            CGFloat scale = self.sideVisibleImageScale;
//            candidateLayer.bounds = CGRectMake(0, 0, candidateImage.size.width * scale, candidateImage.size.height * scale);
//            [self.imageLayers insertObject:candidateLayer atIndex:0];
//
//            CALayer *template = [self.templateLayers objectAtIndex:1];
//            candidateLayer.position = template.position;
//            candidateLayer.zPosition = template.zPosition;
//            candidateLayer.transform = template.transform;
//
//            //show the layer
//            [self showImageAndReflection:candidateLayer];
//        }
//
//    }
    //update index if you move to right, index--


}

- (void)setNormalImageSizeForLayer:(CGSize)size {
    _layerSize = CGSizeMake(size.width, size.height);
}

@end