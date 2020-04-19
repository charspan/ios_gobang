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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIColor *backgroundColor = [UIColor colorWithRed:230.0 / 255.0 green:192.0 / 255.0 blue:148.0 /255.0 alpha:1.0];
    // 设置棋盘边长 = 屏幕宽度 - 左右边距
    float squareLength =  self.view.frame.size.width - 2 * margin;
    // 设置屏幕居中显示
    self.gobangView = [[GobangView alloc] initWithFrame:CGRectMake(margin, (self.view.frame.size.height - squareLength) / 2, squareLength, squareLength)];
//    gobandView.backgroundColor = backgroundColor;
    [self.view addSubview:self.gobangView];
    
//    self.maskView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    [self.view addSubview:self.maskView];
//    self.maskView.image = [UIImage imageNamed:@"launch"];
//    self.maskView.contentMode = UIViewContentModeScaleAspectFill;
//    self.maskView.userInteractionEnabled = YES;
//    
//    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 350, 86, 25)];
//    [self.maskView addSubview:self.startButton];
//    [self.startButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
//    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 350, 86, 25)];
//    [self.maskView addSubview:self.stopButton];
//    [self.stopButton setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
//    [self.stopButton addTarget:self action:@selector(resetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
