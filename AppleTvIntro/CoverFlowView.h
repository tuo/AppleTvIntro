//
//  Created by tuo on 4/1/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


@class CALayer;

@interface CoverFlowView : UIView


//setup numbers of images
@property (nonatomic) int sideVisibleImageCount;

//setup the scale of left/right side and middle one
@property (nonatomic) CGFloat sideVisibleImageScale;
@property (nonatomic) CGFloat middleImageScale;

//source images
@property (nonatomic, retain) NSMutableArray *images;

//images layers, to help remove previous sublayer
@property (nonatomic, retain) NSMutableArray *imageLayers;

//template layers , to pre-locate every geometry info of layer
@property (nonatomic, retain) NSMutableArray *templateLayers;

//index in images for image rendering in the middle of cover flow
@property (nonatomic) int currentRenderingImageIndex;

//show the progress of browser : pagecontrol
@property (nonatomic, retain) UIPageControl *pageControl;

//factory method
@property(nonatomic, strong) CALayer *rootLayer;

+ (id)coverFlowViewWithFrame:(CGRect)frame
                   andImages: (NSMutableArray *)rawImages
              sideImageCount:(int) sideCount
              sideImageScale: (CGFloat) sideImageScale
            middleImageScale: (CGFloat) middleImageScale;

//get index for current image that in the middle in images

+ (id)coverFlowInView:(UIView *)view andImages:(NSMutableArray *)rawImages sideImageCount:(int)sideCount sideImageScale:(CGFloat)sideImageScale middleImageScale:(CGFloat)middleImageScale ;

- (int)getIndexForMiddle;



//setup templates
-(void)setupTemplateLayers;
//setup images
-(void)setupImages;
//remove sublayers (after a certain delay)
-(void)removeLayersAfterSeconds:(id)layerToBeRemoved;
//remove all sublayers
-(void)removeSublayers;
//empty imagelayers
-(void)cleanImageLayers;
//add reflections
-(void)showImageAndReflection:(CALayer *)layer;
//adjust the bounds
-(void)scaleBounds: (CALayer *) layer x:(CGFloat)scaleWidth y:(CGFloat)scaleHeight;
//add uipagecontrol
-(void)addPageControl;

-(NSArray *)getTemplateLayers;

-(void)setImageSources:(NSArray *)images;

@end

