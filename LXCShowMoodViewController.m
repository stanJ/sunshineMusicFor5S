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
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation LXCShowMoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"那时的你";
    
    self.titleTextField.text = self.moodTitle;
    self.moodContentTextView.text = self.moodContent;
}
- (IBAction)editEnabled:(UIButton *)sender {
    
    self.titleTextField.enabled = YES;
    self.moodContentTextView.userInteractionEnabled = YES;
    
    self.saveButton.hidden = NO;
}

- (IBAction)saveChange:(UIButton *)sender {
    
    BOOL nothing = YES;
    
    //判断输入的歌名是否为空
    for (NSInteger i = 0; i < self.moodContentTextView.text.length; i++)
    {
        char ch = [self.moodContentTextView.text characterAtIndex:i];
        
        if (ch != ' ')
        {
            nothing = NO;
            break;
        }
    }
    
    if (self.moodContentTextView.text.length == 0 || nothing){
        
        UIAlertController *deleteAlertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"心情内容不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我知道啦" style:UIAlertActionStyleDefault handler:nil];
        
        [deleteAlertController addAction:cancelAction];
        
        [self presentViewController:deleteAlertController animated:YES completion:nil];
    }
    else {
        
        NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        NSString *moodFilePath = [NSString stringWithFormat:@"%@/moodFiles/%@", sandBoxPath, self.moodFileName];
        
        
        NSString *moodString = [NSString stringWithFormat:@"%@&&%@", self.titleTextField.text, self.moodContentTextView.text];
        
        if ([moodString writeToFile:moodFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            
            NSLog(@"心情写入文件成功");
            
        } else {
            
            NSLog(@"心情写入文件失败");
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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
