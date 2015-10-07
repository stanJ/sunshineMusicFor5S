//
//  LXCMoodViewController.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/6.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCMoodViewController.h"
#import "LXCNavigationBarTitleView.h"
#import "LXCShowMoodViewController.h"

@interface LXCMoodViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *moodTableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) NSArray *moodFileNames;

@end


@implementation LXCMoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self initMoodData];
}

- (void)viewWillAppear:(BOOL)animated{
    
    LXCNavigationBarTitleView *navigatiionBarTitleView = (LXCNavigationBarTitleView *)self.tabBarController.navigationItem.titleView;
    [navigatiionBarTitleView setTitle:@"来看看你的心情记录吧"];
    
    [self initMoodData];
    [self.moodTableView reloadData];
}

- (void)initMoodData{
    
    self.moodFileNames = [NSArray array];
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *moodFileDirectory = [NSString stringWithFormat:@"%@/moodFiles", sandBoxPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    self.moodFileNames = [fileManager contentsOfDirectoryAtPath:moodFileDirectory error:nil];
    
    if (self.moodFileNames.count > 0) {
        
        NSLog(@"有%ld个心情文件", self.moodFileNames.count);
        
        //yes升序排列，no,降序排列
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
        //对心情文件名进行降序排序
        self.moodFileNames = [self.moodFileNames sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
    } else {
        
        NSLog(@"没有心情文件");
    }
}

- (BOOL)deleteMoodWithFileName:(NSString *)fileName{
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *moodFilePath = [NSString stringWithFormat:@"%@/moodFiles/%@", sandBoxPath, fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager removeItemAtPath:moodFilePath error:nil]) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}

- (IBAction)deleteMood:(UILongPressGestureRecognizer *)sender {
    
    NSLog(@"删除心情");
    
    CGPoint pressPoint = [sender locationInView:self.moodTableView];
    NSIndexPath *selectedIndexPath = [self.moodTableView indexPathForRowAtPoint:pressPoint];
    
    if (nil != selectedIndexPath) {
        
        NSLog(@"row:%ld", selectedIndexPath.row);
        
        UIAlertController *deleteAlertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"真的要删掉这条心情？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"留着吧" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删了吧" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            NSString *deleteFileName = [self.moodFileNames objectAtIndex:selectedIndexPath.row];
            
            if ([self deleteMoodWithFileName:deleteFileName]) {
                
                NSLog(@"删除成功");
                
            } else {
                
                NSLog(@"删除失败");
            }
            
            [self initMoodData];
            [self.moodTableView reloadData];
        }];
        
        [deleteAlertController addAction:cancelAction];
        [deleteAlertController addAction:deleteAction];
        
        [self presentViewController:deleteAlertController animated:YES completion:nil];
    }
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.moodFileNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *moodCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    NSString *fileName = [self.moodFileNames objectAtIndex:indexPath.row];
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *moodFilePath = [NSString stringWithFormat:@"%@/moodFiles/%@", sandBoxPath, fileName];
    
    
    NSString *moodContent = [[NSString alloc]initWithContentsOfFile:moodFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *moodContentSubArray = [moodContent componentsSeparatedByString:@"&&"];
    
    if (moodContentSubArray.count == 2) {
        
        NSString *moodTitle = [moodContentSubArray firstObject];
        NSString *moodcontentString = [moodContentSubArray lastObject];
        if (moodTitle.length > 0) {
            
            moodCell.textLabel.text = moodTitle;
            
        } else {
            
            moodCell.textLabel.text = moodcontentString;
        }
        
    }
    
    NSString *fileNameString = [[fileName componentsSeparatedByString:@"."]firstObject];
    NSString *year = [fileNameString substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [fileNameString substringWithRange:NSMakeRange(4, 2)];
    NSString *day = [fileNameString substringWithRange:NSMakeRange(6, 2)];
    NSString *hour = [fileNameString substringWithRange:NSMakeRange(8, 2)];
    NSString *minute = [fileNameString substringWithRange:NSMakeRange(10, 2)];
    NSString *second = [fileNameString substringWithRange:NSMakeRange(12, 2)];
    
    moodCell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@-%@  %@:%@:%@", year, month, day, hour, minute, second];
    
    return moodCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *fileName = [self.moodFileNames objectAtIndex:indexPath.row];
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *moodFilePath = [NSString stringWithFormat:@"%@/moodFiles/%@", sandBoxPath, fileName];
    
    
    NSString *moodContent = [[NSString alloc]initWithContentsOfFile:moodFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *moodContentSubArray = [moodContent componentsSeparatedByString:@"&&"];
    
    if (moodContentSubArray.count == 2) {
        
        NSString *moodTitle = [moodContentSubArray firstObject];
        NSString *moodcontentString = [moodContentSubArray lastObject];
        
        
        //获取storyboard: 通过bundle根据storyboard的名字来获取我们的storyboard,
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        //由storyboard根据myView的storyBoardID来获取我们要切换的视图
        LXCShowMoodViewController *showMoodViewControll = [storyboard instantiateViewControllerWithIdentifier:@"showMoodViewController"];
        showMoodViewControll.moodTitle = moodTitle;
        showMoodViewControll.moodContent = moodcontentString;
        
        [self.navigationController pushViewController:showMoodViewControll animated:YES];
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
