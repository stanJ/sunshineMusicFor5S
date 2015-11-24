//
//  LXCMusicPlayer.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCMusicPlayer.h"

static LXCMusicPlayer * musicPlayer = nil;

@implementation LXCMusicPlayer

+(instancetype)musicPlayer
{
    if(!musicPlayer)
    {
        musicPlayer = [LXCMusicPlayer new];
    }
    
    return musicPlayer;
}

//根据网络链接播放音乐
-(void)playWithURL:(NSURL *)url
{
    [self.audioStream stop];
    
    self.audioStream = [[FSAudioStream alloc]initWithUrl:url];
    self.audioStream.onFailure=^(FSAudioStreamError error,NSString *description)
    {
        NSLog(@"播放过程中发生错误，错误信息：%@",description);
    };
    
    self.audioStream.onCompletion=^()
    {
        NSLog(@"播放完成!");
        NSLog(@"hello");
    };
    
    [self.audioStream play];
}

@end
