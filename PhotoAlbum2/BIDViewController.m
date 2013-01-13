//
//  BIDViewController.m
//  PhotoAlbum2
//
//  Created by Mctu on 13-1-13.
//  Copyright (c) 2013年 Mctu. All rights reserved.
//
#define kPhotoNum 50
#define kmNumber 5
#define kCellWith 150
#define kCellHeith  100
#define kGapWith 20
#define kGapHeight 10
//#define knNumber 
#import "BIDViewController.h"
//
@interface BIDViewController ()
@property(nonatomic,retain) UIImageView *monkeyImageView;
@property(nonatomic,retain) UIPinchGestureRecognizer * pinchGesture;
@property(nonatomic,retain) UIPanGestureRecognizer * panGesture;
@property(nonatomic,retain) UIRotationGestureRecognizer *rotationGesture;
@property(nonatomic,retain) UITapGestureRecognizer *tapGetesture;

@end

@implementation BIDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self initPhotos];
    [self initPhotosView];
    
    [self.view addSubview:self.photesView];
}
-(void) initPhotosView
{
    self.photesView = [[[BIDPhotosView alloc]initWithFrame:[[UIScreen mainScreen] bounds]]autorelease];
    
    [self addPhotos];
}

-(void) addPhotos
{
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
        BIDCellImageView *cellImageView = [[BIDCellImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        
        cellPoint.x = i%kmNumber *(kCellWith + kGapWith);
        cellPoint.y = i/kmNumber *(kCellHeith + kGapHeight);
        cellImageView.frame = CGRectMake(cellPoint.x, cellPoint.y, cellSize.width, cellSize.height);
        cellImageView.userInteractionEnabled = YES;
        [self addGesture:cellImageView];
        
        [self.photesView addSubview:cellImageView];
        [cellImageView release];        
    }
}

-(void) addGesture:(UIImageView *)imageView
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

    [imageView addGestureRecognizer:self.pinchGesture];
    [imageView addGestureRecognizer:self.panGesture];
    [imageView addGestureRecognizer:self.rotationGesture];
    [imageView addGestureRecognizer:self.tapGetesture];
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
-(void)pinchGestureAction:(UIPinchGestureRecognizer *) gesture
{
    NSLog(@"pich");
    gesture.view.transform = CGAffineTransformScale(gesture.view.transform,gesture.scale,gesture.scale);
    gesture.scale = 1;
}

-(void)panGestureAction:(UIPanGestureRecognizer *) gesture
{
    NSLog(@"panch");
    CGPoint oldPoint = CGPointMake(gesture.view.center.x, gesture.view.center.y);
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
    gesture.view.transform = CGAffineTransformScale(gesture.view.transform, 2, 2);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return  YES;
}
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
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
