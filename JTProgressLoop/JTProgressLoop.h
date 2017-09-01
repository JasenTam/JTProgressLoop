//
//  JTProgressLoop.h
//  JTProgressLoop
//
//  Created by 谭振杰 on 2017/8/28.
//  Copyright © 2017年 谭振杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTProgressLoop : UIView
// 如果设置了背景图片，背景颜色就会失效
@property (nonatomic, strong) UIImage *loopBgImage;
@property (nonatomic, strong) UIColor *loopBgColor;

// 如果设置了圆环图片，圆环颜色就会失效
@property (nonatomic, strong) UIImage *loopImage;
@property (nonatomic, strong) UIColor *loopColor;

/** 0 ~ 1.0 */
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;

/** 是否顺时针方向 */
@property (nonatomic, assign) BOOL clockwise;


@property (nonatomic, strong) UIView *customView;

@end
