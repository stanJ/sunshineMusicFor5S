//
//  LXCSearchMusicFromInternet.h
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXCSearchMusicFromInternet : NSObject<NSURLSessionDataDelegate,NSXMLParserDelegate>

@property (copy, nonatomic) NSString *songName;
@property (copy, nonatomic) NSString *singerName;
@property (copy, nonatomic) NSString *currentElementName;

@property (strong, nonatomic) NSMutableArray *encodeLinks;
@property (strong, nonatomic) NSMutableArray *decodeLinks;
@property (strong, nonatomic) NSMutableArray *lyricLinks;
@property (strong, nonatomic) NSMutableArray *musicLinks;

+ (instancetype)searchMusicFromInternetWithSongName:(NSString *)songName andSingerName:(NSString *)singerName;

@end
