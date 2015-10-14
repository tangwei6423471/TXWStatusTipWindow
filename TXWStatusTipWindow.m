//
//  TXWStatusTipWindow.m
//  qgzh
//
//  Created by niko on 15/10/13.
//  Copyright © 2015年 jiaodaocun. All rights reserved.
//

#import "TXWStatusTipWindow.h"

#define HEIGHT   20
#define ICON_WIDTH 20
#define TIPMESSAGE_RIGHT_MARGIN 20
#define ICON_RIGHT_MARGIN       5

@interface TXWStatusTipWindow()
@property (nonatomic, copy) NSString *tipsMessage;
@property (nonatomic, strong) UILabel *tipsLbl;
@property (nonatomic, strong) UIImageView *tipsIcon;
@property (nonatomic, strong) NSTimer *hideTimer;

@end

@implementation TXWStatusTipWindow

#pragma mark - init
- (id)init
{
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.windowLevel = UIWindowLevelStatusBar + 10;
        self.backgroundColor = COLOR_MAIN_TABBAR_TEXT;
        
        _tipsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)];
        _tipsIcon.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tipsIcon.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipsIcon];
        
        _tipsLbl = [[UILabel alloc] initWithFrame:self.bounds];
#ifdef NSTextAlignmentRight
        _tipsLbl.textAlignment = NSTextAlignmentCenter;
        _tipsLbl.lineBreakMode = NSLineBreakByTruncatingTail;
#else
        _tipsLbl.textAlignment = 1; // means UITextAlignmentLeft
        _tipsLbl.lineBreakMode = 4; //UILineBreakModeTailTruncation;
#endif
        _tipsLbl.textColor = [UIColor whiteColor];
        _tipsLbl.font = [UIFont systemFontOfSize:12];
        _tipsLbl.backgroundColor = [UIColor clearColor];
        _tipsLbl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubview:_tipsLbl];
        // 旋转屏幕
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
    
    return self;
}


+ (TXWStatusTipWindow *)shareTipWindow // 单例
{
    static TXWStatusTipWindow *shareTipWindowInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareTipWindowInstance = [[self alloc]init];
    });
    return shareTipWindowInstance;
}

#pragma mark - tips method

- (void)showTips:(NSString *)tips
{
    if (_hideTimer) {
        [_hideTimer invalidate];
    }
    
    _tipsIcon.image = nil;
    _tipsIcon.hidden = YES;
    
    CGSize size = [tips sizeWithFont:_tipsLbl.font constrainedToSize:CGSizeMake(320, 30)];
    size.width += TIPMESSAGE_RIGHT_MARGIN;
    if (size.width > self.bounds.size.width - ICON_WIDTH) {
        size.width = self.bounds.size.width - ICON_WIDTH;
    }
    
    _tipsLbl.frame = CGRectMake(self.bounds.size.width - size.width, 0, size.width, self.bounds.size.height);
    _tipsLbl.text = tips;
    
    [self makeKeyAndVisible];
}

- (void)showTips:(NSString *)tips hideAfterDeley:(NSInteger)seconds
{
    [self showTips:tips];
    
    _hideTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(hideTips) userInfo:nil repeats:NO];
}

- (void)showTipsWithImage:(UIImage*)tipsIcon message:(NSString*)message
{
    if (_hideTimer) {
        [_hideTimer invalidate];
    }
    
    CGSize size = [message sizeWithFont:_tipsLbl.font constrainedToSize:self.bounds.size];
    size.width += TIPMESSAGE_RIGHT_MARGIN;
    if (size.width > self.bounds.size.width - ICON_WIDTH) {
        size.width = self.bounds.size.width - ICON_WIDTH;
    }
    
    _tipsLbl.frame = CGRectMake((self.bounds.size.width - size.width - ICON_WIDTH - ICON_RIGHT_MARGIN)/2 + ICON_WIDTH + ICON_RIGHT_MARGIN , 0, size.width, self.bounds.size.height);
    _tipsLbl.text = message;
    
    _tipsIcon.center = CGPointMake((self.bounds.size.width - _tipsLbl.bounds.size.width - ICON_WIDTH - ICON_RIGHT_MARGIN)/2 + ICON_WIDTH, self.bounds.size.height / 2);
    _tipsIcon.image = tipsIcon;
    _tipsIcon.hidden = NO;
    
    [self makeKeyAndVisible];
}

- (void)showTipsWithImage:(UIImage*)tipsIcon message:(NSString*)message hideAfterDelay:(NSInteger)seconds
{
    [self showTipsWithImage:tipsIcon message:message];
    
    _hideTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(hideTips) userInfo:nil repeats:NO];
}

- (void)hideTips
{
    self.hidden = YES;
    [self removeFromSuperview];
}

#pragma mark - updateOrientation notification

- (void)updateOrientation:(NSNotification *)notification
{
    UIInterfaceOrientation newOrientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    NSLog(@"new orientation: %d", newOrientation);
    
    switch (newOrientation) {
        case UIInterfaceOrientationPortrait:
        {
            self.transform = CGAffineTransformIdentity;
            self.frame = CGRectMake(0, 0, Screen_width, HEIGHT);
            
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            // 先转矩阵，坐标系统落在屏幕有右下角，朝上是y，朝左是x
            self.transform = CGAffineTransformMakeRotation(M_PI);
            self.center = CGPointMake(Screen_width / 2, Screen_height - HEIGHT / 2);
            self.bounds = CGRectMake(0, 0, Screen_width, HEIGHT);
            
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        {
            self.transform = CGAffineTransformMakeRotation(-M_PI_2);
            // 这个时候坐标轴已经转了90°，调整x相当于调节竖向调节，y相当于横向调节
            self.center = CGPointMake(HEIGHT / 2, [UIScreen mainScreen].bounds.size.height / 2);
            self.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, HEIGHT);
            
            break;
        }
        case UIInterfaceOrientationLandscapeRight:
        {
            // 先设置transform，在设置位置和大小
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.center = CGPointMake(Screen_width - HEIGHT / 2, Screen_height / 2);
            self.bounds = CGRectMake(0, 0, Screen_height, HEIGHT);
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - life cycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
