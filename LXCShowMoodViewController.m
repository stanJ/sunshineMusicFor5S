//
//  LXCShowMoodViewController.m
//  LXCSunshineMusicFor5S
//
//  Created by blackmatch on 15/10/6.
//  Copyright © 2015年 blackmatch. All rights reserved.
//

#import "LXCShowMoodViewController.h"

@interface LXCShowMoodViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property (weak, nonatomic) IBOutlet UITextView *moodContentTextView;
@end

@implementation LXCShowMoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"那时的你";
    
    self.titleTextField.text = self.moodTitle;
    self.moodContentTextView.text = self.moodContent;
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
