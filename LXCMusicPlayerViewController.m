//
//  LXCMusicPlayerViewController.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCMusicPlayerViewController.h"
#import "LXCNavigationBarTitleView.h"
#import "FSAudioStream.h"
#import "LXCMusicPlayer.h"

@interface LXCMusicPlayerViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UISlider *playProgressSlider;
@property (weak, nonatomic) IBOutlet UILabel *playTimeInfoLabel;
@property (weak, nonatomic) IBOutlet UITableView *lyricTableView;
@property (weak, nonatomic) IBOutlet UILabel *noLyricLabel;
@property (weak, nonatomic) IBOutlet UIButton *palyPauseButton;

@property (copy, nonatomic) NSString *lyricFileName;
@property (strong, nonatomic) NSMutableDictionary *lyricContentDictionary;
@property (strong, nonatomic) NSMutableArray *lyricTimeForRows;
@property (strong, nonatomic) NSTimer *updateUITimer;
@property (strong, nonatomic) FSAudioStream *audioStream;
@property (assign, nonatomic) NSInteger currentLyricRowIndex;
@property (assign, nonatomic) BOOL findLyric;
@property (strong, nonatomic)NSArray *musicFileNames;


@end

@implementation LXCMusicPlayerViewController

//懒加载
- (NSArray *)musicFileNames{
    
    if (!_musicFileNames) {
        
        _musicFileNames = [NSArray array];
    }
    
    return _musicFileNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.songName = @"用心聆听每一句歌词";
    
    self.findLyric = NO;
    self.playingMusicIndex = -1;
    self.updateUITimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
}

- (void)initMusicFile{
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *musicFilePath = [NSString stringWithFormat:@"%@/musicFiles", sandBoxPath];
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    
    self.musicFileNames = [fileManage contentsOfDirectoryAtPath:musicFilePath error:nil];
    
    if (self.musicFileNames.count > 0) {
        
        for (NSString *fileName in self.musicFileNames) {
            
            NSLog(@"%@", fileName);
        }
    } else {
        
        NSLog(@"没有本地音乐");
    }

}

- (IBAction)playPauseControl:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
//        if (!self.audioStream.isPlaying) {
//            
//            [self.audioStream play];
//        }
        
        [self.audioStream play];
        
        [sender setImage:[UIImage imageNamed:@"btn_playing_pause_normal.png"] forState:UIControlStateNormal];
        
    } else {
        
//        if (self.audioStream.isPlaying) {
//            
//            [self.audioStream pause];
//        }
        
        [self.audioStream pause];
        
        [sender setImage:[UIImage imageNamed:@"btn_playing_play_normal.png"] forState:UIControlStateNormal];
    }
}

- (void)playMusicWithIndex:(NSInteger)index{
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *musicFilePath = [NSString stringWithFormat:@"%@/musicFiles/%@", sandBoxPath,[self.musicFileNames objectAtIndex:index]];
    
    NSURL *musicUrl = [NSURL fileURLWithPath:musicFilePath];
    NSString *lyricFileName = [[[self.musicFileNames objectAtIndex:index]componentsSeparatedByString:@"-"]lastObject];
    
    NSArray *lyricFileNameSubArray = [lyricFileName componentsSeparatedByString:@"."];
    NSString *newLyricFileName = [NSString stringWithFormat:@"%@.lrc", [lyricFileNameSubArray objectAtIndex:0]];
    
    self.songName = [[[self.musicFileNames objectAtIndex:index]componentsSeparatedByString:@"-"]firstObject];
    
    NSOperationQueue *opQueue = [[NSOperationQueue alloc]init];
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        
        [self playMusicWithURL:musicUrl andLyricFileName:newLyricFileName];
        
    }];
    
    [opQueue addOperation:blockOp];
}

- (IBAction)playPreSong:(UIButton *)sender {
    
    [self initMusicFile];
    
    if (self.musicFileNames.count > 0) {
        
        if (self.playingMusicIndex < 0) {
            
            self.playingMusicIndex = 0;

        } else {
            
            if (self.playingMusicIndex - 1 >= 0) {
                
                self.playingMusicIndex -= 1;
                
            } else {
                
                self.playingMusicIndex = self.musicFileNames.count - 1;
            }
        }
        
        [self playMusicWithIndex:self.playingMusicIndex];
    }
}

- (IBAction)playNextSong:(UIButton *)sender {
    
    [self initMusicFile];
    
    if (self.musicFileNames.count > 0) {
        
        if (self.playingMusicIndex < 0) {
            
            self.playingMusicIndex = 0;
            
        } else {
            
            if (self.playingMusicIndex + 1 < self.musicFileNames.count) {
                
                self.playingMusicIndex += 1;
                
            } else {
                
                self.playingMusicIndex =  0;
            }
        }
        
        [self playMusicWithIndex:self.playingMusicIndex];
    }
}


- (IBAction)dragPlaySlider:(UISlider *)sender {
    
    FSStreamPosition pos;
    pos.position = self.playProgressSlider.value;
    [self.audioStream seekToPosition:pos];
}

- (void)viewWillAppear:(BOOL)animated{
    
    LXCNavigationBarTitleView *navigatiionBarTitleView = (LXCNavigationBarTitleView *)self.tabBarController.navigationItem.titleView;
    [navigatiionBarTitleView setTitle:self.songName];
}

- (void)playMusicWithURL:(NSURL *)url andLyricFileName:(NSString *)lyricFileName{
    
    self.currentLyricRowIndex = 0;
    
    self.findLyric = NO;
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        LXCNavigationBarTitleView *navigatiionBarTitleView = (LXCNavigationBarTitleView *)self.tabBarController.navigationItem.titleView;
        [navigatiionBarTitleView setTitle:self.songName];
        
        LXCMusicPlayer *musicPlayer = [LXCMusicPlayer musicPlayer];
        self.audioStream = musicPlayer.audioStream;
        
        if (self.audioStream.isPlaying) {
            
            [self.audioStream stop];
        }

        self.audioStream = [[FSAudioStream alloc]initWithUrl:url];
        self.audioStream.onFailure =^(FSAudioStreamError error,NSString *description)
        {
            NSLog(@"播放过程中发生错误，错误信息：%@",description);
        };
        
        self.audioStream.onCompletion=^()
        {
            NSLog(@"播放完成!");
        };
        
        [self.audioStream play];
        
        
        self.lyricFileName = lyricFileName;
        
        self.lyricTableView.hidden = YES;
        self.noLyricLabel.hidden = NO;
        
//        if ([self parseLyric]) {
//            
//            self.findLyric = YES;
//            self.lyricTableView.hidden = NO;
//            self.noLyricLabel.hidden = YES;
//            [self.lyricTableView reloadData];
//            
//        } else{
//            
//            self.lyricTableView.hidden = YES;
//            self.noLyricLabel.hidden = NO;
//        }
        
    }];
    
//    self.updateUITimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
}

- (void)updateUI{
    
    
    //LXCMusicPlayer *musicPlayer = [LXCMusicPlayer musicPlayer];
    //self.audioStream = musicPlayer.audioStream;
    
    if (self.audioStream.isPlaying) {
        
        [self.palyPauseButton setImage:[UIImage imageNamed:@"btn_playing_pause_normal.png"] forState:UIControlStateNormal];
        
    } else {
        
        [self.palyPauseButton setImage:[UIImage imageNamed:@"btn_playing_play_normal.png"] forState:UIControlStateNormal];
    }

    FSStreamPosition cur = self.audioStream.currentTimePlayed;
    FSStreamPosition end = self.audioStream.duration;
    
    self.playProgressSlider.value = cur.position;
    
    self.playTimeInfoLabel.text = [NSString stringWithFormat:@"%02i:%02i/%02i:%02i",cur.minute, cur.second,end.minute, end.second];
    
    if (!self.findLyric) {
        
        if ([self parseLyric]) {
            
            self.findLyric = YES;
            self.lyricTableView.hidden = NO;
            self.noLyricLabel.hidden = YES;
            [self.lyricTableView reloadData];
        }
    }
    
    //如果有歌词就刷新歌词
    if (self.findLyric) {
        
        for (NSInteger i = 0; i < self.lyricTimeForRows.count - 1; i++) {
            
            NSString *timeInRow = [self.lyricTimeForRows objectAtIndex:i];
            NSArray *timeSubArray = [timeInRow componentsSeparatedByString:@":"];
            NSInteger minutes = [[timeSubArray firstObject]integerValue];
            NSInteger seconds = [[timeSubArray lastObject]integerValue];
            NSInteger timeInSeconds = minutes * 60 + seconds;
            
            NSString *nextTimeInRow = [self.lyricTimeForRows objectAtIndex:i+1];
            NSArray *nextTimeSubArray = [nextTimeInRow componentsSeparatedByString:@":"];
            NSInteger nextMinutes = [[nextTimeSubArray firstObject]integerValue];
            NSInteger nextSeconds = [[nextTimeSubArray lastObject]integerValue];
            NSInteger nextTimeInSeconds = nextMinutes * 60 + nextSeconds;
            
            NSInteger currentSeconds = cur.minute * 60 + cur.second;
            
            if (currentSeconds >= timeInSeconds && currentSeconds < nextTimeInSeconds) {
                
                self.currentLyricRowIndex = i;
                
//                if ((nextTimeInSeconds - currentSeconds) <= 1) {
//                    
//                    self.currentLyricRowIndex = i + 1;
//                }
            }
        }
        
        //使被选中的行移到中间
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentLyricRowIndex inSection:0];
        [self.lyricTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        [self.lyricTableView reloadData];
    }
    
}

- (BOOL)parseLyric{
    
    NSString *sandBoxCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *lyricFilePath = [NSString stringWithFormat:@"%@/lyricFiles/%@", sandBoxCachePath, self.lyricFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:lyricFilePath]) {
        
        self.lyricContentDictionary = [[NSMutableDictionary alloc]init];
        self.lyricTimeForRows = [NSMutableArray array];
        
        //这里有坑啊！！！下载的lrc歌词文件要用这种编码
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        //得到歌词内容
        NSString *lyricContent = [NSString stringWithContentsOfFile:lyricFilePath encoding:encoding error:nil];
        
        NSArray *lyricSubInRows = [lyricContent componentsSeparatedByString:@"\n"];
        
        for (NSInteger i = 0; i < lyricSubInRows.count; i++) {
            
            NSString *lyricInRow = [lyricSubInRows objectAtIndex:i];
            
            NSArray *lyricInRowSubArray = [lyricInRow componentsSeparatedByString:@"]"];
            
            NSString *lyricContentInRow = [lyricInRowSubArray lastObject];
            
            if (lyricInRowSubArray.count >= 2 && lyricContentInRow.length > 0) {
                
                if (lyricInRowSubArray.count == 2) {
                    
                    NSString *lyricTimeInRow = [lyricInRowSubArray firstObject];
                    lyricTimeInRow = [lyricTimeInRow substringWithRange:NSMakeRange(1, 5)];
                    
                    [self.lyricContentDictionary setObject:lyricContentInRow forKey:lyricTimeInRow];
                    [self.lyricTimeForRows addObject:lyricTimeInRow];
                    
                } else if (lyricInRowSubArray.count > 2 && lyricContentInRow.length > 0){
                    
                    for (NSInteger j = 0; j < lyricInRowSubArray.count - 1; j++) {
                        
                        NSString *lyricTimeInRow = [lyricInRowSubArray objectAtIndex:j];
                        lyricTimeInRow = [lyricTimeInRow substringWithRange:NSMakeRange(1, 5)];
                        
                        [self.lyricContentDictionary setObject:lyricContentInRow forKey:lyricTimeInRow];
                        [self.lyricTimeForRows addObject:lyricTimeInRow];
                    }
                }
            }
        }
        
        if (self.lyricTimeForRows.count > 0) {
            
            //重新对歌词时间进行排序，用来解决多个时间点共用同一行歌词
            [self.lyricTimeForRows sortUsingComparator: ^NSComparisonResult (NSString *str1, NSString *str2)
             {
                 NSInteger timeSec1 = [[str1 substringWithRange:NSMakeRange(0, 2)]integerValue]*60 + [[str1 substringWithRange:NSMakeRange(3, 2)]integerValue];
                 
                 NSInteger timeSec2 = [[str2 substringWithRange:NSMakeRange(0, 2)]integerValue]*60 + [[str2 substringWithRange:NSMakeRange(3, 2)]integerValue];
                 
                 NSNumber *number1 = [NSNumber numberWithInteger:timeSec1];
                 NSNumber *number2 = [NSNumber numberWithInteger:timeSec2];
                 
                 return [number1 compare:number2];
             }];
        }
        
        return YES;
        
    } else {
        
        NSLog(@"歌词文件不存在！");
        
        return NO;
    }
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.lyricTimeForRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *lyricCellInRow = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    //设置选中样式
    lyricCellInRow.selectionStyle = UITableViewCellSelectionStyleNone;
    
    lyricCellInRow.textLabel.textAlignment = NSTextAlignmentCenter;
    lyricCellInRow.textLabel.textColor = [UIColor blueColor];
    
    NSString *lyricTimeKey = [self.lyricTimeForRows objectAtIndex:indexPath.row];
    NSString *lyricInRow = [self.lyricContentDictionary objectForKey:lyricTimeKey];
    
    lyricCellInRow.textLabel.text = lyricInRow;
    
    if (indexPath.row == self.currentLyricRowIndex) {
        
        lyricCellInRow.textLabel.textColor = [UIColor redColor];
        lyricCellInRow.textLabel.font = [UIFont systemFontOfSize:20];
        
    } else {
        
        lyricCellInRow.textLabel.textColor = [UIColor blueColor];
        lyricCellInRow.textLabel.font = [UIFont systemFontOfSize:16];
    }
    
    lyricCellInRow.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return lyricCellInRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == self.currentLyricRowIndex) {
        
        return 50;
        
    } else {
        
        return 35;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
