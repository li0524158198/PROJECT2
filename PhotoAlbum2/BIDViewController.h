//
//  BIDViewController.h
//  PhotoAlbum2
//
//  Created by Mctu on 13-1-13.
//  Copyright (c) 2013年 Mctu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDPhotosView.h"
#import "BIDCellImageView.h"
#import "BIDShowsViewController.h"


@interface BIDViewController : UIViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate >
@property(nonatomic,retain) NSArray *arrPhotos;
@property(nonatomic,retain) NSArray *arrCellViews;
@property(nonatomic,retain) BIDPhotosView *photesView;
@property(nonatomic,retain) BIDCellImageView  *cellImageView;
@property(nonatomic,retain) UIScrollView * scrollView;
@end
