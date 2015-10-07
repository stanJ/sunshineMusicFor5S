//
//  LXCNavigationBarTitleView.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCNavigationBarTitleView.h"

@implementation LXCNavigationBarTitleView

-(instancetype)initWithViewController:(UIViewController *)vc andTitle:(NSString *)title
{
    self = [super initWithFrame:CGRectMake(vc.view.frame.size.width/2 - 100, 20,200 , 44)];
    
    if(self)
    {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"Heiti TC - Bold" size:18];
        self.titleLabel.textColor = [UIColor blueColor];
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

+ (instancetype)navigationBarTitleViewWithViewController:(UIViewController *)vc andTitle:(NSString *)title
{
    return [[LXCNavigationBarTitleView alloc]initWithViewController:vc andTitle:title];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}


@end
