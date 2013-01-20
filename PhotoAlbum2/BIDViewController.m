//
//  BIDViewController.m
//  PhotoAlbum2
//
//  Created by Mctu on 13-1-13.
//  Copyright (c) 2013年 Mctu. All rights reserved.
//
#define kPhotoNum 50
#define kmNumber 6
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
    if(_monkeyImageView)
    {
        [_monkeyImageView release];
        _monkeyImageView = nil;
    }
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self initPhotos];
    [self initPhotosView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotate:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    UIScrollView * sc = [[UIScrollView alloc]init];
    sc.bounces = YES;
    sc.delegate = self;
    sc.showsHorizontalScrollIndicator = NO;
    sc.showsVerticalScrollIndicator = YES;
//    sc.contentSize = CGSizeMake(1024, <#CGFloat height#>)
    
    
    [self.view addSubview:self.photesView];
    
    if (!self.showScrollView)
    {
        self.showScrollView = [[[BIDShowsViewController alloc]initWithFrame:self.view.frame]autorelease];
        
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{


}

- (void)rotate:(NSNotification *)notification
{
    NSLog(@"The view's frame is %@",NSStringFromCGRect(self.view.frame));
    NSLog(@"The userInfo is %@",notification.userInfo);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"OrientationChange" object:nil];
}

-(void) initPhotosView
{
    self.photesView = [[[BIDPhotosView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)]autorelease];
    [self addGesture:self.photesView];
    
    UIScrollView * sc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
    sc.bounces = YES;
    sc.delegate = self;
    sc.showsHorizontalScrollIndicator = NO;
    sc.showsVerticalScrollIndicator = YES;
    sc.backgroundColor = [UIColor greenColor];
    self.scrollView = sc;
    [sc release];
    [self addPhotos:self.scrollView];
    
    [self.photesView addSubview:self.scrollView];
}

-(BIDCellImageView *) cellwithImageName:(NSString *) imageName
{
    BIDCellImageView *cellImageView = [[[BIDCellImageView alloc]initWithImage:[UIImage imageNamed:imageName]]autorelease];
    return cellImageView;
}

-(void) addPhotos:(UIScrollView *)parantView
{
    NSLog(@"parantView:%@",parantView);
    NSMutableArray *mutarr = [[NSMutableArray alloc]initWithObjects:@"image001.jpg", nil];
    NSInteger i;
    for (i = 2; i < kPhotoNum; i++)
    {
        [mutarr addObject:[NSString stringWithFormat:@"image%03d.jpg",i]];
    }
    
    self.arrPhotos = [mutarr copy];
    [mutarr release];
    NSLog(@"%@",self.arrPhotos);
    
    CGSize cellSize = CGSizeMake(kCellWith, kCellHeith);
    CGPoint cellPoint = CGPointMake(0, 0);
    for (i = 0; i < [self.arrPhotos count]; i++)
    {
        NSString *imageName = [self.arrPhotos objectAtIndex:i];
        BIDCellImageView *cellImageView = [self cellwithImageName:imageName];
        cellPoint.x = i%kmNumber *(kCellWith + kGapWith) + kGapLeft;
        cellPoint.y = i/kmNumber *(kCellHeith + kGapHeight) +kGapTop;
        
         cellImageView.frame = CGRectMake(cellPoint.x, cellPoint.y, cellSize.width, cellSize.height);
        cellImageView.userInteractionEnabled = YES;
        [self addGesture:cellImageView];
        
        /*加图片边框*/
        cellImageView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        cellImageView.layer.borderWidth = 5.0;
        
        [parantView addSubview:cellImageView];
//        [cellImageView release];        
    }
    parantView.contentSize = CGSizeMake(kmNumber * (kCellWith + kGapWith), (kCellHeith + kGapHeight)* (i/kmNumber) + 1);
}

-(void) addGesture:(UIView *)inView
{
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
