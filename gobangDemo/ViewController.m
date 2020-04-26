//
//  ViewController.m
//  gobangDemo
//
//  Created by 志良潘 on 2020/4/14.
//  Copyright © 2020 志良潘. All rights reserved.
//

#import "ViewController.h"
#import "GobangView.h"

// 设置棋盘左/右边距
const NSInteger margin = 10;

@interface ViewController ()

@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) GobangView *gobangView;
// 游戏标题
@property(nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UITextField *xTF;
@property (nonatomic, strong) UITextField *yTF;
// 跳转
@property(nonatomic, strong) UIButton *btn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btn = [[UIButton alloc]initWithFrame:CGRectMake(150, 50, 60, 40)];
    _btn.backgroundColor =[UIColor redColor];
    [_btn setTitle:@"传值" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [_btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    self.xTF = [[UITextField alloc]initWithFrame:CGRectMake(50, 50, 40, 40)];
    // 文字颜色
    self.xTF.textColor = [UIColor blackColor];
    // 边框
    self.xTF.borderStyle =UITextBorderStyleLine;
    self.xTF.text =  @"0";
    
    self.yTF = [[UITextField alloc]initWithFrame:CGRectMake(100, 50, 40, 40)];
    // 文字颜色
    self.yTF.textColor = [UIColor blackColor];
    // 边框
    self.yTF.borderStyle =UITextBorderStyleLine;
    self.yTF.text =  @"0";
    [self.view addSubview:self.xTF];
    [self.view addSubview:self.yTF];
    [self.view addSubview:self.btn];
    // Do any additional setup after loading the view.
//    UIColor *backgroundColor = [UIColor colorWithRed:230.0 / 255.0 green:192.0 / 255.0 blue:148.0 /255.0 alpha:1.0];
    self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, 50, 200, 100)];
    self.titleLable.text = @"五 子 棋 大 战";
    [self.titleLable setFont:[UIFont systemFontOfSize: 40]];
    self.titleLable.adjustsFontSizeToFitWidth = true;
    [self.view addSubview:self.titleLable];
    // 设置棋盘边长 = 屏幕宽度 - 左右边距
    float squareLength =  self.view.frame.size.width - 2 * margin;
    // 设置屏幕居中显示
    self.gobangView = [[GobangView alloc] initWithFrame:CGRectMake(margin, (self.view.frame.size.height - squareLength) / 2, squareLength, squareLength)];
//    gobandView.backgroundColor = backgroundColor;
    [self.view addSubview:self.gobangView];
    
    self.maskView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.maskView];
    self.maskView.image = [UIImage imageNamed:@"launch"];
    self.maskView.contentMode = UIViewContentModeScaleAspectFill;
    self.maskView.userInteractionEnabled = YES;
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 3 - 86 / 2, self.view.frame.size.height / 2 - 120, 86, 25)];
    [self.maskView addSubview:self.startButton];
    [self.startButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 3 + 86, self.view.frame.size.height / 2 - 120, 86, 25)];
    [self.maskView addSubview:self.stopButton];
    [self.stopButton setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(resetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick {
    self.gobangView.x = self.xTF.text;
    self.gobangView.y = self.yTF.text;
}

- (void)resetButtonPressed:(UIButton *)button {
    // 运行一个不存在的方法,退出界面更加圆滑
    [self performSelector:@selector(exist)];
    abort();
//    [self.gobangView reset];
}

- (void)startButtonPressed:(UIButton *)button {
    [self.maskView removeFromSuperview];
}

@end
