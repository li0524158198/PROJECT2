//
//  BIDCellImageView.h
//  PhotoAlbum2
//
//  Created by Mctu on 13-1-13.
//  Copyright (c) 2013年 Mctu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDCellImageView : UIImageView
{
    CGPoint _point;
    CGPoint _center;
    NSInteger _index;
}
@property(nonatomic,retain) UIImage *image;
@property CGPoint point;
@property CGPoint center;
@property NSInteger index;
@end
