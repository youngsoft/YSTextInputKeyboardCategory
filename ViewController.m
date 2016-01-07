//
//  ViewController.m
//  YSTextInputKeyboardCategory
//
//  Created by apple on 16/1/7.
//  Copyright (c) 2016年 youngsoft. All rights reserved.
//

#import "ViewController.h"
#import "UIView+YSTextInputKeyboard.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldG;
@property (weak, nonatomic) IBOutlet UITextField *textFieldH;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //实现键盘的弹出和隐藏，基本不需要编写一句代码。
    
    //通过offset的设置可以设置偏移量。
    self.textFieldG.kbMoving.offset = 200;
    
    //你也可以通过设置一个具体的移动的视图而不是默认的父视图
    self.textFieldG.kbMoving.kbMovingView = self.view;
    
    self.textFieldH.kbMoving.offset = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
