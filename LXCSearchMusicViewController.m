//
//  LXCSearchMusicViewController.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/2.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCSearchMusicViewController.h"
#import "LXCNavigationBarTitleView.h"
#import "LXCSearchMusicFromInternet.h"
#import "LXCMusicPlayerViewController.h"

@interface LXCSearchMusicViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *inputSongNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *inputSingerNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *searchMusicTableView;

@property (strong, nonatomic) NSMutableArray *lyricLinks;
@property (strong, nonatomic) NSMutableArray *musicLinks;

@end

@implementation LXCSearchMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LXCNavigationBarTitleView *navigationTitleView = [LXCNavigationBarTitleView navigationBarTitleViewWithViewController:self andTitle:@"寻找属于自己的音乐"];
    self.tabBarController.navigationItem.titleView = navigationTitleView;
    
    self.musicLinks = [NSMutableArray array];
    self.lyricLinks = [NSMutableArray array];
    
    self.searchMusicTableView.hidden = YES;
    
    self.searchButton.layer.borderColor = self.searchButton.backgroundColor.CGColor;
    self.searchButton.layer.borderWidth = 1.0;
    self.searchButton.layer.cornerRadius = 7.5;
    self.searchButton.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    LXCNavigationBarTitleView *navigatiionBarTitleView = (LXCNavigationBarTitleView *)self.tabBarController.navigationItem.titleView;
    [navigatiionBarTitleView setTitle:@"寻找属于自己的音乐"];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark search music
- (IBAction)searchMusic:(id)sender {
    
    BOOL nothing = YES;
    
    //判断输入的歌名是否为空
    for (NSInteger i = 0; i < self.inputSongNameTextField.text.length; i++)
    {
        char ch = [self.inputSongNameTextField.text characterAtIndex:i];
        
        if (ch != ' ')
        {
            nothing = NO;
            break;
        }
    }

    if (self.inputSongNameTextField.text.length == 0 || nothing){
        
        UIAlertController *deleteAlertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"歌名不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我知道啦" style:UIAlertActionStyleDefault handler:nil];
        
        [deleteAlertController addAction:cancelAction];
        
        [self presentViewController:deleteAlertController animated:YES completion:nil];
        
        return;
    }

    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [self.musicLinks removeAllObjects];
    [self.lyricLinks removeAllObjects];
    
    NSOperationQueue * q = [[NSOperationQueue alloc]init];
    
    [q addOperationWithBlock:^{
        NSLog(@"耗时操作...%@",[NSThread currentThread]);
        
        LXCSearchMusicFromInternet *searchMusicFromInternet = [LXCSearchMusicFromInternet searchMusicFromInternetWithSongName:self.inputSongNameTextField.text andSingerName:self.inputSingerNameTextField.text];
        
        [NSThread sleepForTimeInterval:2.0];
        
        self.musicLinks = searchMusicFromInternet.musicLinks;
        self.lyricLinks = searchMusicFromInternet.lyricLinks;
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            if (self.searchMusicTableView.hidden) {
                
                self.searchMusicTableView.hidden = NO;
            }
            
            
            [self.searchMusicTableView reloadData];
        }];

        
    }];
    
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.musicLinks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * searchMusicCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    searchMusicCell.textLabel.text = self.inputSongNameTextField.text;
    
    NSString *lyricString = [self.lyricLinks objectAtIndex:indexPath.row];
    
    if ([lyricString isEqualToString:@"noLyric"]) {
        
        searchMusicCell.detailTextLabel.text = @"没有找到歌词";
        
    } else {
        
        searchMusicCell.detailTextLabel.text = @"有歌词";
    }
    
    
    
    return searchMusicCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LXCMusicPlayerViewController *musicPlayerViewController = [self.tabBarController.viewControllers objectAtIndex:2];
    
    NSString *musicLink = [self.musicLinks objectAtIndex:indexPath.row];
    NSString *lyricLink = [self.lyricLinks objectAtIndex:indexPath.row];
    
    dispatch_queue_t downloadMusicQueue = dispatch_queue_create("downloadMusic", DISPATCH_QUEUE_SERIAL);
    dispatch_async(downloadMusicQueue, ^{
        
        [self downloadMusicWithMusicLink:[NSURL URLWithString:musicLink] andLyricLink:[NSURL URLWithString:lyricLink]];
    });
    
    
    NSArray *lyricLinkSubStrings = [lyricLink componentsSeparatedByString:@"/"];
    
    musicPlayerViewController.songName = self.inputSongNameTextField.text;
    musicPlayerViewController.playingMusicIndex = -1;
    
    NSOperationQueue *opQueue = [[NSOperationQueue alloc]init];
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        
        [musicPlayerViewController playMusicWithURL:[NSURL URLWithString:musicLink] andLyricFileName:[lyricLinkSubStrings lastObject]];
        
    }];
    
    [opQueue addOperation:blockOp];
    
//    [musicPlayerViewController playMusicWithURL:[NSURL URLWithString:musicLink] andLyricFileName:[lyricLinkSubStrings lastObject]];
    
    self.tabBarController.selectedIndex = 2;
}

- (void)createMusicDirectory{
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *musicFileDirectory = [NSString stringWithFormat:@"%@/musicFiles", sandBoxPath];
    NSString *lyricFileDirectory = [NSString stringWithFormat:@"%@/lyricFiles", sandBoxPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:musicFileDirectory]) {
        
        if ([fileManager createDirectoryAtPath:musicFileDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            NSLog(@"创建音乐文件夹成功！");
            
        } else {
            
            NSLog(@"创建音乐文件夹失败！");
        }
    } else {
        
        NSLog(@"音乐目录已经存在");
    }
    
    if (![fileManager fileExistsAtPath:lyricFileDirectory]) {
        
        if ([fileManager createDirectoryAtPath:lyricFileDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            NSLog(@"创建歌词文件夹成功！");
            
        } else {
            
            NSLog(@"创建歌词文件夹失败！");
        }
    } else {
        
        NSLog(@"歌词目录已经存在");
    }

}

- (void)downloadMusicWithMusicLink:(NSURL *)musicUrl andLyricLink:(NSURL *)lyricUrl{
    
    [self createMusicDirectory];
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *lyricFileName = @"noLyric";
    if (![[lyricUrl absoluteString]isEqualToString:@"noLyric"]) {
        lyricFileName = [[[lyricUrl absoluteString]componentsSeparatedByString:@"/"]lastObject];
    }
    
    NSString *lyricFilePath = [NSString stringWithFormat:@"%@/lyricFiles/%@", sandBoxPath, lyricFileName];
    
    NSString *lyricID = @"noLyric";
    if (![lyricFileName isEqualToString:@"noLyric"]) {
        
        lyricID = [[lyricFileName componentsSeparatedByString:@"."]firstObject];
    }
    
    NSString *singerName = self.inputSingerNameTextField.text;
    
    BOOL nothing = YES;
    
    //判断输入的歌名是否为空
    for (NSInteger i = 0; i < self.inputSingerNameTextField.text.length; i++)
    {
        char ch = [self.inputSingerNameTextField.text characterAtIndex:i];
        
        if (ch != ' ')
        {
            nothing = NO;
            break;
        }
    }
    
    if (self.inputSingerNameTextField.text.length == 0 || nothing){
        
        singerName = @"未知歌手";
    }
    
    NSString *musicFileName = [NSString stringWithFormat:@"%@-%@-%@.mp3", self.inputSongNameTextField.text, singerName, lyricID];
    NSString *musicFilePath = [NSString stringWithFormat:@"%@/musicFiles/%@", sandBoxPath, musicFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSData *musicData = [NSData dataWithContentsOfURL:musicUrl];
    NSData *lyricData = [NSData dataWithContentsOfURL:lyricUrl];
    
    if ([fileManager fileExistsAtPath:musicFilePath]) {
        
        NSLog(@"音乐文件已经存在，不需要下载");
        
    } else {
        
        if ([musicData writeToFile:musicFilePath atomically:YES]) {
            
            NSLog(@"音乐下载完成");
            
        } else {
            
            NSLog(@"音乐下载失败");
        }
    }
    
    
    if (![lyricFileName isEqualToString:@"noLyric"]) {
        
        if (![fileManager fileExistsAtPath:lyricFilePath]) {
            
            
            if ([lyricData writeToFile:lyricFilePath atomically:YES]) {
                
                NSLog(@"歌词下载完成");
                
            } else {
                
                NSLog(@"歌词下载失败");
            }
            
        } else {
            
            NSLog(@"歌词文件已经存在，不需要下载");
        }
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
