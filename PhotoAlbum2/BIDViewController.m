//
//  BIDViewController.m
//  PhotoAlbum2
//
//  Created by Mctu on 13-1-13.
//  Copyright (c) 2013年 Mctu. All rights reserved.
//
#define kPhotoNum 50
#define kmNumber 7
#define KMaxVerNumber
#define kMaxHorNumber 6
#define kCellWith 150
#define kCellHeith  100
#define kGapWith 20
#define kGapHeight 10
#define kGapTop  10
#define kGapLeft 10
//#define knNumber
#import "BIDViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BIDShowsViewController.h"
#import "BIDPublicMethod.h"
//
@interface BIDViewController ()
@property float gCellWith;
@property float gCellHeight;
@property float gGapWith;
@property float gGapHeight;
@property float gCurWith;
@property float gCurHeight;
@property NSInteger gMaxHorNumber;
@property NSInteger gMaxVerNumber;
@property(nonatomic,retain) UIImageView *monkeyImageView;
@property(nonatomic,retain) UIPinchGestureRecognizer * pinchGesture;
@property(nonatomic,retain) UIPanGestureRecognizer * panGesture;
@property(nonatomic,retain) UIRotationGestureRecognizer *rotationGesture;
@property(nonatomic,retain) UITapGestureRecognizer *tapGetesture;

@property(nonatomic,retain) BIDShowsViewController *showScrollView;

@end

@implementation BIDViewController

- (void)dealloc
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
    
    if(_monkeyImageView)
    {
        [_monkeyImageView release];
        _monkeyImageView = nil;
    }
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //    [self initPhotos];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotate:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    //**//
    self.photesView = [[[BIDPhotosView alloc]initWithFrame:[[UIScreen mainScreen] bounds]]autorelease];
    [self.photesView setBackgroundColor:[UIColor yellowColor]];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.scrollView.bounces = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor greenColor];
    
    //**//
    NSMutableArray *mutarr = [[NSMutableArray alloc]initWithCapacity:kPhotoNum];
    NSInteger i;
    for (i = 1; i <= kPhotoNum; i++)
    {
        [mutarr addObject:[NSString stringWithFormat:@"image%03d.jpg",i]];
    }
    self.arrPhotos = [mutarr copy];
    [mutarr release];
    
    //**//
    NSMutableArray *mutarrView = [[NSMutableArray alloc]initWithCapacity:kPhotoNum];
    for (i = 0; i < [self.arrPhotos count]; i++)
    {
        NSString *imageName = [self.arrPhotos objectAtIndex:i];
        BIDCellImageView *cellImageView = [self cellwithImageName:imageName];
        cellImageView.userInteractionEnabled = YES;
        [self addGesture:cellImageView withViewController:self];
        
        /*加图片边框*/
        cellImageView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        cellImageView.layer.borderWidth = 5.0;
        cellImageView.index = i;
        
        [mutarrView addObject:cellImageView];
        [cellImageView release];
    }
    self.arrCellViews = [mutarrView copy];
    [mutarrView release];
    
    
    [self reLoadCell:self.view.frame];
    [self.view addSubview:self.photesView];
    
    if (!self.showScrollView)
    {
        self.showScrollView = [[[BIDShowsViewController alloc]initWithFrame:self.view.frame]autorelease];
        
    }
}



-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
    
}

- (void)rotate:(NSNotification *)notification
{
    
    NSLog(@"The view's frame is %@",NSStringFromCGRect(self.view.frame));
    NSLog(@"The userInfo is %@",notification.userInfo);
    
    CGRect rect = self.view.frame;
    if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait)
    {
        NSLog(@"The view's frame UIInterfaceOrientationPortrait is %@",NSStringFromCGRect(rect));
        [self reLoadCell:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    }
    else if ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft)
    {
        NSLog(@"The view's frame UIInterfaceOrientationLandscapeLeft is %@",NSStringFromCGRect(rect));
        [self reLoadCell:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    }
    else if ([UIDevice currentDevice].orientation ==
             UIInterfaceOrientationLandscapeRight)
    {
        NSLog(@"The view's frame UIInterfaceOrientationLandscapeRight is %@",NSStringFromCGRect(rect));
        [self reLoadCell:CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width)];
        
    }
    else if ([UIDevice currentDevice].orientation ==
             UIDeviceOrientationPortraitUpsideDown)
    {
        NSLog(@"The view's frame UIDeviceOrientationPortraitUpsideDown is %@",NSStringFromCGRect(rect));
        [self reLoadCell:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"OrientationChange" object:nil];
}



- (void) reLoadCell:(CGRect)rect
{
    [self calcWith:rect.size];
    [self changCellViewSize:self.scrollView];
    [self.photesView addSubview:self.scrollView];
    
    [self.photesView setFrame:CGRectMake(self.photesView.frame.origin.x, self.photesView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    NSLog(@"The view's frame is %@",NSStringFromCGRect(self.view.frame));
    NSLog(@"The view's frame photoView is %@",NSStringFromCGRect(self.photesView.frame));
    NSLog(@"The view's frame scrollView is %@",NSStringFromCGRect(self.scrollView.frame));
    NSLog(@"The view's frame contentsize is %@",NSStringFromCGSize(self.scrollView.contentSize));
}


- (void) calcWith:(CGSize) size
{
    _gMaxHorNumber = 7;
    _gMaxVerNumber = 3;
    _gCellWith = size.width / (_gMaxHorNumber + 1);
    _gCellHeight = size.height / (_gMaxVerNumber +1);
    _gGapWith = _gCellWith / (_gMaxHorNumber + 1);
    _gGapHeight = _gCellHeight / (_gMaxVerNumber +1);
    
}


-(BIDCellImageView *) cellwithImageName:(NSString *) imageName
{
    BIDCellImageView *cellImageView = [[[BIDCellImageView alloc]initWithImage:[UIImage imageNamed:imageName]]autorelease];
    return cellImageView;
}

#pragma mark -
#pragma mark change cell size

- (void)changCellViewSize:(UIScrollView *)parantView
{
    NSInteger i;
    CGPoint cellPoint = CGPointMake(0, 0);
    for (i = 0; i < [self.arrCellViews count]; i++)
    {
        BIDCellImageView *cellImageView = [self.arrCellViews objectAtIndex:i];
        cellPoint = [self calcPhotoPosition:i];
        cellImageView.frame = CGRectMake(cellPoint.x, cellPoint.y, _gCellWith, _gCellHeight);
        [parantView addSubview:cellImageView];
    }
    CGSize contentSize = [self calcScrowViewContentSize:i];
    parantView.contentSize = contentSize;
}

- (CGPoint)calcPhotoPosition:(NSInteger) index
{
    CGPoint point;
    point.x = index % _gMaxHorNumber *(_gCellWith + _gGapWith) + _gGapWith;
    point.y = index / _gMaxHorNumber *(_gCellHeight + _gGapHeight) + _gGapHeight;
    return  point;
}

- (CGSize)calcScrowViewContentSize:(NSInteger) index
{
    CGSize contentSize;
    contentSize.width = _gMaxHorNumber * (_gCellWith + _gGapWith);
    if( index % _gMaxVerNumber == 0)
    {
        contentSize.height = (_gCellHeight + _gGapHeight)* (index /_gMaxHorNumber) + _gGapHeight;
    }
    else
    {
        contentSize.height = (_gCellHeight + _gGapHeight)* (index /_gMaxHorNumber + 1) + _gGapHeight;
    }
    return contentSize;
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

-(void) initPhotos
{
    self.monkeyImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monkey.png"]]autorelease];
    self.monkeyImageView.userInteractionEnabled = YES;
    
    self.pinchGesture = [[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureAction:)]autorelease];
    self.pinchGesture.delegate = self;
    
    self.panGesture = [[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)] autorelease];
    self.panGesture.delegate = self;
    
    
    self.rotationGesture = [[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureAction:)] autorelease];
    self.rotationGesture.delegate = self;
    
    self.tapGetesture = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGetestureAction:)] autorelease];
    self.tapGetesture.delegate = self;
    self.tapGetesture.numberOfTapsRequired = 2;
    self.tapGetesture.numberOfTouchesRequired = 1;
    
    //    [self.view addSubview:self.monkeyImageView];
    [self.monkeyImageView addGestureRecognizer:self.pinchGesture];
    [self.monkeyImageView addGestureRecognizer:self.panGesture];
    [self.monkeyImageView addGestureRecognizer:self.rotationGesture];
    [self.monkeyImageView addGestureRecognizer:self.tapGetesture];
    
    
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
    [self.showScrollView.view setFrame:self.view.frame];
    
    [self.view addSubview:self.showScrollView.view];
    
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
