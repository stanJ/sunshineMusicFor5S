//
//  LXCMusicPlayerViewController.h
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCMusicPlayerViewController : UIViewController

@property (copy, nonatomic) NSString *songName;

- (void)playMusicWithURL:(NSURL *)url andLyricFileName:(NSString *)lyricFileName;

@end
