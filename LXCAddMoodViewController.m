//
//  LXCAddMoodViewController.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/6.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCAddMoodViewController.h"

@interface LXCAddMoodViewController ()

@property (weak, nonatomic) IBOutlet UITextField *inputTitleTextField;
@property (weak, nonatomic) IBOutlet UITextView *inputMoodContentTextView;
@property (weak, nonatomic) IBOutlet UIButton *quitEditButton;

@property (weak, nonatomic) IBOutlet UIButton *saveEditButton;

@end

@implementation LXCAddMoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createMoodDirectory];
}

- (NSString *)getMoodFileName{
    
    NSDate *nowDate = [NSDate date];
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [currentCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:nowDate];
    
    return [NSString stringWithFormat:@"%ld%02ld%02ld%02ld%02ld%02ld.txt",[dateComponents year], [dateComponents month], [dateComponents day], [dateComponents hour], [dateComponents minute], [dateComponents second]];
}

- (IBAction)quitEdit:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveEdit:(UIButton *)sender {
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *moodFilePath = [NSString stringWithFormat:@"%@/moodFiles/%@", sandBoxPath, [self getMoodFileName]];
    
    NSString *moodString = [NSString stringWithFormat:@"%@&&%@", self.inputTitleTextField.text, self.inputMoodContentTextView.text];
    
    if ([moodString writeToFile:moodFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        
        NSLog(@"心情写入文件成功");
        
    } else {
        
        NSLog(@"心情写入文件失败");
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createMoodDirectory{
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *moodFileDirectory = [NSString stringWithFormat:@"%@/moodFiles", sandBoxPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:moodFileDirectory]) {
        
        NSLog(@"心情文件夹已存在，不需要创建");
        
    } else {
        
        if ([fileManager createDirectoryAtPath:moodFileDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            
            NSLog(@"心情文件夹创建成功");
            
        } else {
            
            NSLog(@"心情文件夹创建失败");
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
