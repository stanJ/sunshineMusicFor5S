//
//  LXCLocalMusicViewController.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/5.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCLocalMusicViewController.h"
#import "LXCMusicPlayerViewController.h"
#import "LXCNavigationBarTitleView.h"

@interface LXCLocalMusicViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *localMusicTableView;

@property (strong, nonatomic)NSArray *musicFileNames;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation LXCLocalMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.musicFileNames = [NSMutableArray array];
    
    [self initMusicData];
}

- (void)viewWillAppear:(BOOL)animated{
    
    LXCNavigationBarTitleView *navigatiionBarTitleView = (LXCNavigationBarTitleView *)self.tabBarController.navigationItem.titleView;
    [navigatiionBarTitleView setTitle:@"这里有只属于你的音乐"];
    
    [self initMusicData];
    [self.localMusicTableView reloadData];
}

- (void)initMusicData{
    
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


#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.musicFileNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    NSArray *fileNameInArray = [[self.musicFileNames objectAtIndex:indexPath.row]componentsSeparatedByString:@"-"];
    
    if (fileNameInArray.count == 3) {
        
        NSString *songName = [fileNameInArray objectAtIndex:0];
        NSString *singerName = [fileNameInArray objectAtIndex:1];
        NSString *lyricID = [fileNameInArray objectAtIndex:2];
        
        NSString *haveLyric = @"没有歌词";
        
        if (![lyricID isEqualToString:@"noLyric.mp3"]) {
            
            haveLyric = @"有歌词";
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", songName, singerName];
        cell.detailTextLabel.text = haveLyric;

    } else {
        
        cell.textLabel.text = [self.musicFileNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"不规范的文件名";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *musicFileName = [self.musicFileNames objectAtIndex:indexPath.row];
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *musicFilePath = [NSString stringWithFormat:@"%@/musicFiles/%@", sandBoxPath, musicFileName];
    NSURL *musicUrl = [NSURL fileURLWithPath:musicFilePath];
    NSString *lyricFileName = [[[self.musicFileNames objectAtIndex:indexPath.row]componentsSeparatedByString:@"-"]lastObject];
    
    NSArray *lyricFileNameSubArray = [lyricFileName componentsSeparatedByString:@"."];
    NSString *newLyricFileName = [NSString stringWithFormat:@"%@.lrc", [lyricFileNameSubArray objectAtIndex:0]];
    
    NSString *songName = [[[self.musicFileNames objectAtIndex:indexPath.row]componentsSeparatedByString:@"-"]firstObject];
    LXCMusicPlayerViewController *musicPlayerViewController = [self.tabBarController.viewControllers objectAtIndex:2];
    musicPlayerViewController.songName = songName;
    musicPlayerViewController.playingMusicIndex = indexPath.row;
    
    NSOperationQueue *opQueue = [[NSOperationQueue alloc]init];
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        
        [musicPlayerViewController playMusicWithURL:musicUrl andLyricFileName:newLyricFileName];
        
    }];
    
    [opQueue addOperation:blockOp];
    
    self.tabBarController.selectedIndex = 2;
}

- (void)deleteMusicWithFileName:(NSString *)fileName{
    
    NSOperationQueue * q = [[NSOperationQueue alloc]init];
    
    [q addOperationWithBlock:^{
        
        NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        
        NSString *moodFilePath = [NSString stringWithFormat:@"%@/musicFiles/%@", sandBoxPath, fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager removeItemAtPath:moodFilePath error:nil]) {
            
            NSLog(@"删除成功");
            
        } else {
            
            NSLog(@"删除成功");
        }

        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            [self initMusicData];
            [self.localMusicTableView reloadData];
        }];
        
    }];

}

- (IBAction)deleteMusic:(UILongPressGestureRecognizer *)sender {
    
    CGPoint pressPoint = [sender locationInView:self.localMusicTableView];
    NSIndexPath *selectedIndexPath = [self.localMusicTableView indexPathForRowAtPoint:pressPoint];
    
    if (nil != selectedIndexPath) {
        
        NSLog(@"row:%ld", selectedIndexPath.row);
        
        UIAlertController *deleteAlertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"真的要删掉这这首歌？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"留着吧" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删了吧" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            NSString *deleteFileName = [self.musicFileNames objectAtIndex:selectedIndexPath.row];
            
            [self deleteMusicWithFileName:deleteFileName];
            
        }];
        
        [deleteAlertController addAction:cancelAction];
        [deleteAlertController addAction:deleteAction];
        
        [self presentViewController:deleteAlertController animated:YES completion:nil];
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
