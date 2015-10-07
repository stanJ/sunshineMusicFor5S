//
//  LXCNavigationBarTitleView.h
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCNavigationBarTitleView : UIView

@property (strong, nonatomic) UILabel * titleLabel;

- (void)setTitle:(NSString *)title;

- (instancetype)initWithViewController:(UIViewController *)vc andTitle:(NSString *)title;
+ (instancetype)navigationBarTitleViewWithViewController:(UIViewController *)vc andTitle:(NSString *)title;

@end
