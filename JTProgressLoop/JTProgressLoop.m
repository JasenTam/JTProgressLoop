//
//  JTProgressLoop.m
//  JTProgressLoop
//
//  Created by 谭振杰 on 2017/8/28.
//  Copyright © 2017年 谭振杰. All rights reserved.
//

#import "JTProgressLoop.h"

@interface JTProgressLoop ()

/** 进度条背景 */
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UIImageView *backgroundImageView;
/** 进度条 */
@property (nonatomic, weak) UIView *progressView;
@property (nonatomic, weak) UIImageView *progressImageView;

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat loopWidth;

@end

@implementation JTProgressLoop

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self _setup];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.radius = MIN(width, height) / 2;
    CGFloat diameter = self.radius * 2;
    
    CGFloat bgViewX = (width - diameter) / 2;
    CGFloat bgViewY = (height - diameter) / 2;
    self.backgroundView.frame = CGRectMake(bgViewX, bgViewY, diameter, diameter);
    self.backgroundView.layer.cornerRadius = self.radius;
    
    self.backgroundImageView.frame = self.backgroundView.bounds;
    
    CGFloat progressViewX = (width - diameter) / 2;
    CGFloat progressViewY = (height - diameter) / 2;
    CGFloat progressViewWH = diameter;
    if (self.loopImage) {
        progressViewWH = MIN(self.loopImage.size.width, self.loopImage.size.height);
        progressViewX = (width - progressViewWH) / 2;
        progressViewY = (height - progressViewWH) / 2;
    }
    self.progressView.frame = CGRectMake(progressViewX, progressViewY, progressViewWH, progressViewWH);
    self.progressView.layer.cornerRadius = self.radius;
    
    self.progressImageView.frame = self.progressView.frame;
    
    if (_customView) {
        
        CGFloat customViewRadius = self.radius;
        CGFloat customViewX = (width - customViewRadius * 2) / 2;
        CGFloat customViewY = (height - customViewRadius * 2) / 2;
        self.customView.frame = CGRectMake(customViewX, customViewY, customViewRadius * 2, customViewRadius * 2);
    }
}

#pragma mark - 公共方法

/** 重新绘画进度条 */
- (void)_refreshProgressImage {
    
    UIImage *image = nil;
    // 有图片优先使用图片
    if (self.loopImage) {
        image = self.loopImage;
    } else {
        // 没有图片就用颜色生成图片使用
        if (self.loopColor) {
            image = [self _creatImageWithColor:self.loopColor size:self.progressImageView.bounds.size];
        } else {
            image = [self _creatImageWithColor:[UIColor greenColor] size:self.progressImageView.bounds.size];
        }
    }
    
    self.progressImageView.image = [self _clipImage:image];
}

- (void)_refreshBackgroundImage {
    
    UIImage *image = nil;
    // 有图片优先使用图片
    if (self.loopBgImage) {
        image = self.loopBgImage;
    } else {
        // 没有图片就用颜色生成图片使用
        if (self.loopBgColor) {
            image = [self _creatImageWithColor:self.loopBgColor size:self.bounds.size];
        } else {
            image = [self _creatImageWithColor:[UIColor greenColor] size:self.bounds.size];
        }
    }
    
    self.backgroundImageView.image = [self _clipImage:image progress:1.0];
}

/** 裁剪图片 */
- (UIImage *)_clipImage:(UIImage *)image {
    
    return [self _clipImage:image progress:self.progress];
}
- (UIImage *)_clipImage:(UIImage *)image progress:(CGFloat)progress {
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil) {
        return nil;
    }
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    [self _drawProgressLoopWithContext:ctx iamge:image progress:progress];
    
    CGContextClip(ctx);
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), [image CGImage]);
    
    UIImage *destImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return destImg;
}

/** 画进度条 */
- (void)_drawProgressLoopWithContext:(CGContextRef)ctx iamge:(UIImage *)image progress:(CGFloat)progress {
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    //坐标系转换
    CGContextTranslateCTM(ctx, 0, height);
    CGContextScaleCTM(ctx, 1, -1);
    
    CGPoint center = CGPointMake(width / 2, height / 2);
    CGFloat radius = MIN(width, height) / 2;
    
    CGFloat startX = center.x + cos(self.startAngle) * radius;
    CGFloat startY = center.y + sin(self.startAngle) * radius;
    CGFloat startInsideX = center.x + cos(self.startAngle) * (radius - self.loopWidth);
    CGFloat startInsideY = center.y + sin(self.startAngle) * (radius - self.loopWidth);
    
    // 获取当前进度的位置
    CGFloat progressAngle = [self _getProgressAngle:progress];
    CGFloat progressInsideX = center.x + cos(progressAngle) * (radius - self.loopWidth);
    CGFloat progressInsideY = center.y + sin(progressAngle) * (radius - self.loopWidth);
    
    CGContextMoveToPoint(ctx, startInsideX, startInsideY);
    CGContextAddLineToPoint(ctx, startX, startY);
    CGContextAddArc(ctx, center.x, center.y, radius, self.startAngle, progressAngle, self.clockwise);
    CGContextAddLineToPoint(ctx, progressInsideX, progressInsideY);
    CGContextAddArc(ctx, center.x, center.y, radius - self.loopWidth, progressAngle, self.startAngle, !self.clockwise);
}

/** 获取当前进度的角度 */
- (CGFloat)_getProgressAngle:(CGFloat)progress {
    
    // 计算角度范围
    CGFloat maxAngle = [self _getMaxAngle];
    
    // 获取当前进度的位置
    CGFloat progressAngle = self.clockwise ? self.startAngle - progress * maxAngle : self.startAngle + progress * maxAngle;
    
    return progressAngle;
}

/** 计算进度条最大角度范围 */
- (CGFloat)_getMaxAngle {
    
    
    CGFloat biggerAngle = self.clockwise ? self.startAngle : self.endAngle;
    CGFloat smallerAngle = self.clockwise ? self.endAngle : self.startAngle;
    
    // 结束角度比开始角度大的情况
    while (biggerAngle <= smallerAngle) {
        biggerAngle = biggerAngle + M_PI * 2;
    }
    
    CGFloat maxAngle = biggerAngle - smallerAngle;
    // 防止最大角度大于360度
    while (maxAngle > M_PI * 2) {
        maxAngle = maxAngle - M_PI * 2;
    }
    
    return maxAngle;
}

/** 生成一张纯色图片 */
- (UIImage *)_creatImageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return nil;
    }
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 初始化方法

- (void)_setup {
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.radius = MIN(width, height) / 2;
    
    [self _setupBackgroundView];
    [self _setupProgressView];
    
    self.loopBgColor = [UIColor blackColor];
}

- (void)_setupProgressView {
    UIView *progressView = [UIView new];
    progressView.clipsToBounds = YES;
    [self addSubview:progressView];
    self.progressView = progressView;
    
    UIImageView *progressImageView = [[UIImageView alloc] init];
    [self addSubview:progressImageView];
    self.progressImageView = progressImageView;
}

- (void)_setupBackgroundView {
    UIView *backgroundView = [UIView new];
    backgroundView.clipsToBounds = YES;
    [self addSubview:backgroundView];
    self.backgroundView = backgroundView;
    
    UIImageView *backgroundImageView = [UIImageView new];
    [self addSubview:backgroundImageView];
    self.backgroundImageView = backgroundImageView;
}

#pragma mark - getter & setter

- (UIView *)customView {
    if (_customView == nil) {
        CGFloat customViewRadius = self.radius;
        CGFloat customViewX = (self.bounds.size.width - customViewRadius * 2) / 2;
        CGFloat customViewY = (self.bounds.size.height - customViewRadius * 2) / 2;
        
        _customView = [[UIView alloc] initWithFrame:CGRectMake(customViewX, customViewY, customViewRadius * 2, customViewRadius * 2)];
        [self addSubview:_customView];
    }
    
    return _customView;
}

- (CGFloat)loopWidth {
    
    return _loopWidth > 0 ? _loopWidth : MIN(self.bounds.size.width, self.bounds.size.height) * 0.1;
}

- (void)setLoopColor:(UIColor *)loopColor {
    _loopColor = loopColor;
    
    [self _refreshProgressImage];
}

- (void)setLoopBgColor:(UIColor *)loopBgColor {
    _loopBgColor = loopBgColor;
    
    [self _refreshBackgroundImage];
}

- (void)setLoopImage:(UIImage *)loopImage {
    _loopImage = loopImage;
    
    [self _refreshProgressImage];
}

- (void)setLoopBgImage:(UIImage *)loopBgImage {
    _loopBgImage = loopBgImage;
    
    [self _refreshBackgroundImage];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    [self _refreshProgressImage];
}

- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = startAngle;
    
    [self _refreshProgressImage];
    [self _refreshBackgroundImage];
}

- (void)setEndAngle:(CGFloat)endAngle {
    _endAngle = endAngle;
    
    [self _refreshProgressImage];
    [self _refreshBackgroundImage];
}

- (void)setClockwise:(BOOL)clockwise {
    _clockwise = clockwise;
    
    [self _refreshProgressImage];
    [self _refreshBackgroundImage];
}

@end
