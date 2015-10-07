//
//  LXCMusicPlayer.h
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSAudioStream.h"

@interface LXCMusicPlayer : NSObject

@property (nonatomic,strong)FSAudioStream * audioStream;

+(instancetype)musicPlayer;
-(void)playWithURL:(NSURL *)url;

@end
