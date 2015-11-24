//
//  LXCTabBarViewController.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/6.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCTabBarViewController.h"
#import "LXCAddMoodViewController.h"

@interface LXCTabBarViewController ()

@end

@implementation LXCTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"stanJ到此一游");
    // Do any additional setup after loading the view.
}

- (IBAction)addNewMood:(UIBarButtonItem *)sender {
    
    NSOperationQueue * q = [[NSOperationQueue alloc]init];
    
    [q addOperationWithBlock:^{
        NSLog(@"耗时操作...%@",[NSThread currentThread]);
        
        //获取storyboard: 通过bundle根据storyboard的名字来获取我们的storyboard,
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        //由storyboard根据myView的storyBoardID来获取我们要切换的视图
        LXCAddMoodViewController *addMoodViewControll = [storyboard instantiateViewControllerWithIdentifier:@"addMoodViewController"];
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            NSLog(@"更新UI...%@",[NSThread currentThread]);
            
            [self.navigationController pushViewController:addMoodViewControll animated:YES];
            
        }];
        
    }];

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
