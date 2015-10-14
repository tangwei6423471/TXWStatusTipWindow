//
//  TXWStatusTipWindow.h
//  qgzh
//
//  Created by niko on 15/10/13.
//  Copyright © 2015年 jiaodaocun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXWStatusTipWindow : UIWindow

+ (TXWStatusTipWindow *)shareTipWindow; // 单例

- (void)showTips:(NSString *)tips;

- (void)showTips:(NSString *)tips hideAfterDeley:(NSInteger)seconds;

- (void)showTipsWithImage:(UIImage*)tipsIcon message:(NSString*)message;

- (void)showTipsWithImage:(UIImage*)tipsIcon message:(NSString*)message hideAfterDelay:(NSInteger)seconds;

- (void)hideTips;
@end
