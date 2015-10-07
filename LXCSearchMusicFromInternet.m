//
//  LXCSearchMusicFromInternet.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCSearchMusicFromInternet.h"

@implementation LXCSearchMusicFromInternet

- (instancetype)initWithSongName:(NSString *)songName andSingerName:(NSString *)singerName{
    
    self = [super init];
    
    if (self) {
        
        self.songName = songName;
        self.singerName = singerName;
        
        [self createConnectionToInternet];
    }
    
    return self;
}

+ (instancetype)searchMusicFromInternetWithSongName:(NSString *)songName andSingerName:(NSString *)singerName{
    
    return [[LXCSearchMusicFromInternet alloc]initWithSongName:songName andSingerName:singerName];
}

- (void)createConnectionToInternet{
    
    NSString *urlString = nil;
    if (!self.singerName) {
        
        urlString = [NSString stringWithFormat:@"http://box.zhangmen.baidu.com/x?op=12&count=1&title=%@$$$$$$", self.songName];
        
    } else {
        
        urlString = [NSString stringWithFormat:@"http://box.zhangmen.baidu.com/x?op=12&count=1&title=%@$$%@$$$$", self.songName, self.singerName];
    }
    //因为网络请求地址中有中文，所以要改变字符串的编码
    NSString * newUrlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL * searchMusicUrl = [NSURL URLWithString:newUrlString];
    
    NSURLSession *searchMusicSession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [searchMusicSession dataTaskWithURL:searchMusicUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"搜索结果：%@", dataString);
        
        NSXMLParser *searchMusicResultParser = [[NSXMLParser alloc]initWithData:data];
        searchMusicResultParser.delegate = self;
        [searchMusicResultParser parse];
        
    }];
    
    [dataTask resume];
}

#pragma mark NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    
    self.encodeLinks = [NSMutableArray array];
    self.decodeLinks = [NSMutableArray array];
    self.lyricLinks = [NSMutableArray array];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    
    self.currentElementName = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if ([self.currentElementName isEqualToString:@"encode"]) {
        
        [self.encodeLinks addObject:string];
        
    } else if ([self.currentElementName isEqualToString:@"decode"]){
        
        [self.decodeLinks addObject:string];
        
    } else if ([self.currentElementName isEqualToString:@"lrcid"]){
        
        NSString *lyricLink = @"noLyric";
        
        if (![string isEqualToString:@"0"]) {
            
            NSInteger lyricID = [string integerValue];
            
            lyricLink = [NSString stringWithFormat:@"http://box.zhangmen.baidu.com/bdlrc/%ld/%ld.lrc", lyricID/100, lyricID];
        }
        
        [self.lyricLinks addObject:lyricLink];
    }
}

//遍历xml文件中的每一个节点
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
//    if ([elementName isEqualToString:@"url"])
//    {
//        self.isDURL = NO;
//    }
//    else if ([elementName isEqualToString:@"durl"])
//    {
//        self.isDURL =YES;
//    }
//    
//    if ([elementName isEqualToString:@"encode"])
//    {
//        
//        NSString * str = [NSString stringWithString:self.element];
//        NSString * typeStr = nil;
//        
//        if (self.isDURL)
//        {
//            typeStr = @"durl";
//        }
//        else
//        {
//            typeStr = @"url";
//        }
//        
//        if (str.length > 0)
//        {
//            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
//            [dic setObject:str forKey:@"encode"];
//            [dic setObject:typeStr forKey:@"type"];
//            
//            [self.encodeMutableArray addObject:dic];
//        }
//        
//        //NSLog(@"encode: %@",str);
//    }
//    else if([elementName isEqualToString:@"decode"])
//    {
//        NSString * str = [NSString stringWithString:self.element];
//        
//        if (str.length > 0)
//        {
//            [self.decodeMutableArray addObject:str];
//        }
//        
//        //NSLog(@"decode: %@",str);
//    }
//    else if([elementName isEqualToString:@"lrcid"])
//    {
//        NSString * str = [NSString stringWithString:self.element];
//        if (![str isEqualToString:@"0"])
//        {
//            [self.lyricMutableArray addObject:str];
//        }
//    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
    self.musicLinks = [NSMutableArray array];
    
    //删除无效的加密链接
    if (self.decodeLinks.count < self.encodeLinks.count) {
        
        for (NSInteger i = self.encodeLinks.count; i >= self.decodeLinks.count; i--) {
            
            [self.encodeLinks removeObjectAtIndex:i];
        }
    }
    
    NSInteger subIndex = 0;
    for (NSInteger i = 0; i < self.encodeLinks.count; i++) {
        
        NSString *encodeString = [self.encodeLinks objectAtIndex:i];
        
        for (NSInteger j = encodeString.length - 1; j >=0 ; j--) {
            
            NSString *subString = [encodeString substringWithRange:NSMakeRange(j, 1)];
            
            if ([subString isEqualToString:@"/"]) {
                
                subIndex = j;
                break;
            }
        }
        
        NSString *musicLink = [encodeString substringWithRange:NSMakeRange(0, subIndex + 1)];
        
        NSString *fullMusicLink = [NSString stringWithFormat:@"%@%@", musicLink, [self.decodeLinks objectAtIndex:i]];
        [self.musicLinks addObject:fullMusicLink];
    }
}

@end












