//
//  BIDShowsViewController.m
//  PhotoAlbum2
//
//  Created by Mctu on 13-1-20.
//  Copyright (c) 2013年 Mctu. All rights reserved.
//

#define kGapImageWith 0
#import "BIDShowsViewController.h"

@interface BIDShowsViewController ()

@property(nonatomic,retain) UIPinchGestureRecognizer * pinchGesture;
@property(nonatomic,retain) UIPanGestureRecognizer * panGesture;
@property(nonatomic,retain) UIRotationGestureRecognizer *rotationGesture;
@property(nonatomic,retain) UITapGestureRecognizer *tapGetesture;

@property(nonatomic,retain)UIScrollView *showScrollView;
@property(nonatomic,retain)NSMutableSet *recycledPages;
@property(nonatomic,retain)NSMutableSet *visiblePages;
@end

@implementation BIDShowsViewController
@synthesize showScrollView = _showScrollView;
@synthesize recycledPages = _recycledPages;
@synthesize visiblePages = _visiblePages;
- (void) dealloc
{
    if(_pinchGesture)
    {
        [_pinchGesture release];
        _pinchGesture = nil;
    }
    
    if(_panGesture)
    {
        [_panGesture release];
        _panGesture = nil;
    }
    
    if(_rotationGesture)
    {
        [_rotationGesture release];
        _rotationGesture = nil;
    }
    
    if(_tapGetesture)
    {
        [_tapGetesture release];
        _tapGetesture = nil;
    }
    
    if(_showScrollView)
    {
        [_showScrollView release];
        _showScrollView = nil;
    }
    if (_recycledPages) {
        [_recycledPages release];
        _recycledPages = nil;
    }
    
    if (_visiblePages) {
        [_visiblePages release];
        _visiblePages = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        CGRect showScrollViewFrame = frame;
        self.showScrollView = [[[UIScrollView alloc]initWithFrame:showScrollViewFrame]autorelease];
        self.showScrollView.pagingEnabled = YES;
        self.showScrollView.backgroundColor = [UIColor blackColor];
        
        self.showScrollView.contentSize = CGSizeMake(showScrollViewFrame.size.width *[self imageCount], showScrollViewFrame.size.height);
        self.showScrollView.showsHorizontalScrollIndicator = NO;
        self.showScrollView.showsVerticalScrollIndicator = NO;
        self.showScrollView.delegate = self;
        [self.view addSubview:self.showScrollView];
        
        [self addGesture:self.showScrollView withViewController:self];
        
        
        //        [self noUseReuse];
        [self userReuse];
    }
    return self;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"The content of recycledPages is %@",self.recycledPages);
    NSLog(@"The content of visiblePages is %@",self.visiblePages);
    
    [self titlePages];
}

#pragma mark -
#pragma mark reuser image

- (void) userReuse
{
    self.recycledPages = [[[NSMutableSet alloc]init]autorelease];
    self.visiblePages = [[[NSMutableSet alloc]init]autorelease];
    [self titlePages];
    
}

- (void)titlePages
{
    //***********计算哪页是当前显示页面******************//
    CGRect visibleBounds = self.showScrollView.bounds;
    NSInteger firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    NSInteger lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    //**********重用非当前显示页面*****************//
    for (UIImageView *imageView in self.visiblePages)
    {
        if (imageView.tag < firstNeededPageIndex || imageView.tag > lastNeededPageIndex)
        {
            [self.recycledPages addObject:imageView];
            [imageView removeFromSuperview];
        }
    }
    
    [self.visiblePages minusSet:self.recycledPages];
    //***************添加未显示页面*****************//
    for ( NSInteger index = firstNeededPageIndex; index <= lastNeededPageIndex; index++)
    {
        if (![self isDisplayingPageForIndex:index])
        {
            UIImageView *imageView = [self dequeueRecyclePage];
            if (imageView == nil)
            {
                imageView = [[[UIImageView alloc]init]autorelease];
                [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            }
            
            [self reuserConfigurePage:imageView forIndex:index];
            [self.showScrollView addSubview:imageView];
            NSLog(@"%@",imageView.image);
            [self.visiblePages addObject:imageView];
        }
    }
}

- (void)reuserConfigurePage:(UIImageView *)imageView forIndex:(int)index
{
    imageView.tag = index;
    imageView.frame = [self frameForPageAtIndex:index];
    [imageView setImage:[self imageAtIndex:index]];
}

/**
 判断是否为当前显示页面
 @param NSUInteger 判断页数
 @returns 返回判断布尔值
 */
- (BOOL) isDisplayingPageForIndex:(NSUInteger) index
{
    BOOL foundPage = NO;
    for (UIImageView *imageView in self.visiblePages)
    {
        if(imageView.tag == index)
        {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

/**
 返回重用的UIImageView
 */
- (UIImageView *)dequeueRecyclePage
{
    UIImageView *imageView = [self.recycledPages anyObject];
    if (imageView) {
        [[imageView retain]autorelease];
        [self.recycledPages removeObject:imageView];
    }
    return imageView;
}

#pragma mark -
#pragma mark no reuser image


- (void) noUseReuse
{
    for (int i = 0; i < [self imageCount]; i++)
    {
        UIImageView *imageView = [[[UIImageView alloc]init]autorelease];
        [imageView setImage:[self imageAtIndex:i]];
        [self noReuserConfigurePage:imageView forIndex:i];
        [self.showScrollView addSubview:imageView];
    }
}


- (void)noReuserConfigurePage:(UIImageView *)imageView forIndex:(int)index
{
    imageView.frame = [self frameForPageAtIndex:index];
}


#pragma mark -
#pragma mark Image wrangling

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    
    CGRect bounds = self.showScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width = bounds.size.width + kGapImageWith;
    pageFrame.origin.x = bounds.size.width * index;
    return pageFrame;
}


- (NSArray *)imageData {
    static NSArray *__imageData = nil; // only load the imageData array once
    if (__imageData == nil) {
        // read the filenames/sizes out of a plist in the app bundle
        NSString *path = [[NSBundle mainBundle] pathForResource:@"imageData" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:path];
        NSString *error; NSPropertyListFormat format;
        __imageData = [[NSPropertyListSerialization propertyListFromData:plistData
                                                        mutabilityOption:NSPropertyListImmutable
                                                                  format:&format
                                                        errorDescription:&error]
                       retain];
        if (!__imageData) {
            NSLog(@"Failed to read image names. Error: %@", error);
            [error release];
        }
    }
    return __imageData;
}

- (UIImage *)imageAtIndex:(NSUInteger)index {
    
    // use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching our images
    NSString *imageName = [self imageNameAtIndex:index];
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    return [UIImage imageWithContentsOfFile:path];
}

- (NSString *)imageNameAtIndex:(NSUInteger)index {
    NSString *name = nil;
    if (index < [self imageCount]) {
        name = [[self imageData] objectAtIndex:index];
    }
    return name;
}

- (CGSize)imageSizeAtIndex:(NSUInteger)index {
    CGSize size = CGSizeZero;
    
    if (index < [self imageCount])
    {
        UIImage *__image = [[[UIImage alloc]init]autorelease];
        __image = [self imageAtIndex:index];
        size =__image.size;
    }
    return size;
}

- (NSUInteger)imageCount {
    static NSUInteger __count = NSNotFound;  // only count the images once
    if (__count == NSNotFound) {
        __count = [[self imageData] count];
    }
    return __count;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationChanged:) name:nil object:nil];
	// Do any additional setup after loading the view.
}

- (void)orientationChanged:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"OrientationChange"]) {
        self.showScrollView.frame = self.view.bounds;
    }
}

- (void) addGesture:(UIView *)inView withViewController:(id) pViewController
{
    self.pinchGesture = [[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureAction:)]autorelease];
    self.pinchGesture.delegate = pViewController;
    
    self.panGesture = [[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)] autorelease];
    self.panGesture.delegate = pViewController;
    
    self.rotationGesture = [[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureAction:)] autorelease];
    self.rotationGesture.delegate = pViewController;
    
    self.tapGetesture = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGetestureAction:)] autorelease];
    self.tapGetesture.delegate = pViewController;
    self.tapGetesture.numberOfTapsRequired = 2;
    self.tapGetesture.numberOfTouchesRequired = 1;
    
    [inView addGestureRecognizer:self.pinchGesture];
    //[inView addGestureRecognizer:self.panGesture];
    [inView addGestureRecognizer:self.rotationGesture];
    [inView addGestureRecognizer:self.tapGetesture];
}

//- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)pinchGestureAction:(UIPinchGestureRecognizer *) gesture
{
    NSLog(@"pich");
    gesture.view.transform = CGAffineTransformScale(gesture.view.transform,gesture.scale,gesture.scale);
    gesture.scale = 1;
}

-(void)panGestureAction:(UIPanGestureRecognizer *) gesture
{
    NSLog(@"panch");
    //    CGPoint oldPoint = CGPointMake(gesture.view.center.x, gesture.view.center.y);
    CGPoint point = [gesture translationInView:self.view];
    gesture.view.center = CGPointMake(gesture.view.center.x + point.x, gesture.view.center.y + point.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
    
    //    gesture.view.center = oldPoint;
    
}

-(void)rotationGestureAction:(UIRotationGestureRecognizer *) gesture
{
    NSLog(@"rotation");
    gesture.view.transform = CGAffineTransformRotate(gesture.view.transform, gesture.rotation);
    gesture.rotation = 0;
}

-(void)tapGetestureAction:(UITapGestureRecognizer *) gesture
{
    //gesture.view.transform = CGAffineTransformScale(gesture.view.transform, 2, 2);
    NSLog(@"tapGetestureAction");
    [self.view removeFromSuperview];
    self.showScrollView = nil;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return  YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
