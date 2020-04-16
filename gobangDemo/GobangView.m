//
//  GobangView.m
//  gobangDemo
//
//  Created by 志良潘 on 2020/4/14.
//  Copyright © 2020 志良潘. All rights reserved.
//

// 五子棋界面 -- 一个正方形的棋盘
#import "GobangView.h"
#import "GobangAI.h"

// 定义横竖各有多少个可落子的点（边缘不可落子）
const NSInteger piecesNumber = 14;
// 边缘
const NSInteger boderSize = 2;
// 线的宽度
const CGFloat lineWidth = 0.5;

// 这个view负责展示和智能逻辑

@interface GobangView ()

@property (nonatomic, assign) BOOL isPlayerPlaying; // 标志为，标志是否是玩家正在下棋

@property (nonatomic, strong) NSMutableArray *places; // 记录所有的位置状态
@property (nonatomic, strong) NSMutableArray *chesses; // 记录所有在棋盘上的棋子

@property (nonatomic, strong) NSMutableArray *holders; // 记录五子连珠后对应的五个棋子

@property (nonatomic, strong) UIView *redDot; // 指示AI最新一步所在的位置

@property (nonatomic, strong) UIButton *stopButton;

@end

@implementation GobangView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

// 自定义初始化界面方法
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    // 每个小正方形的边长
    float squareLength = self.frame.size.width / (piecesNumber + 1);
    if (self) {
       self.backgroundColor = [UIColor colorWithRed:230.0 / 255.0 green:192.0 / 255.0 blue:148.0 /255.0 alpha:1.0];
       self.redDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
       self.redDot.backgroundColor = [UIColor redColor];
       self.redDot.layer.cornerRadius = 2.5;
        // 画一组横线
        for (int i = 0; i < piecesNumber + boderSize; i ++) {
            // 初始化横线，起始坐标为(0, i * squareLength)，宽度是当前frame的宽度，高度是lineWidth
            UIView *horizonLine = [[UIView alloc] initWithFrame:CGRectMake(0, i * squareLength, frame.size.width, lineWidth)];
            // 定义横线颜色为黑色
            horizonLine.backgroundColor = [UIColor blackColor];
            // 添加到主界面以显示出来
            [self addSubview:horizonLine];
        }
        // 画一组竖线
        for (int i = 0; i < piecesNumber + boderSize; i ++) {
            // 初始化竖线，起始坐标为(i * squareLength, 0)，宽度是lineWidth，高度是当前frame的宽度
            UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(i * squareLength, 0, lineWidth, frame.size.width)];
            // 定义竖线颜色为黑色
            verticalLine.backgroundColor = [UIColor blackColor];
            // 添加到主界面以显示出来
            [self addSubview:verticalLine];
        }
        self.places = [NSMutableArray array];
        for (int i = 0; i < piecesNumber; i ++) {
            NSMutableArray *chil = [NSMutableArray array];
            for (int j = 0; j < piecesNumber; j ++) {
                [chil addObject:@(OccupyTypeEmpty)];
            }
            [self.places addObject:chil];
        }
        self.chesses = [NSMutableArray array];
        self.holders = [NSMutableArray array];
    }
    return self;
}

// 苹果原生api--接收界面手势信息
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.userInteractionEnabled = NO;
    self.isPlayerPlaying = YES;
    // 获取触摸信息
    UITouch *touch = [touches anyObject];
    // 获取触摸位置
    CGPoint point = [touch locationInView:self];
    // 申明离点击位置最近的两条线（一横一竖），h 代表横线编号，v 代表竖线编号，编号顺序从左到右，从上到下，从0开始编号
    NSUInteger h = 0 , v = 0;
    // 每个小正方形的边长
    float squareLength = self.frame.size.width / (piecesNumber + 1);
//    // 查找h和v方案一
//    // 遍历查找竖线编号
//    for (NSUInteger i = 0; i <= piecesNumber; i ++) {
//        // 触摸点x坐标在第i条竖线和第i+1条竖线之间
//        if (i * squareLength <= point.x && point.x < (i + 1) * squareLength) {
//            // i = 0 就是第一条竖线
//            if (i == 0) {
//                v = 1;
//                break;
//            }
//            // i = piecesNumber 就是最后一条竖线
//            if (i == piecesNumber) {
//                v = piecesNumber;
//                break;
//            }
//            // 判断触摸点x坐标离第i条竖线和第i+1条竖线的那一条最近，离得越近x坐标相减的绝对值越小
//            if (fabs(i * squareLength - point.x) >= fabs((i + 1) * squareLength - point.x)) {
//                v = i + 1;
//                break;
//            } else {
//                v = i;
//                break;
//            }
//        }
//    }
//    // 遍历查找横线编号
//    for (NSUInteger i = 0; i <= piecesNumber; i ++) {
//        // 触摸点y坐标在第i条横线和第i+1条横线之间
//        if (i * squareLength <= point.y && point.y < (i + 1) * squareLength) {
//            // i = 0 就是第一条横线
//            if (i == 0) {
//                h = 1;
//                break;
//            }
//            // i = piecesNumber 就是最后一条横线
//            if (i == piecesNumber) {
//                h = piecesNumber;
//                break;
//            }
//            // 判断触摸点y坐标离第i条横线和第i+1条横线的那一条最近，离得越近y坐标相减的绝对值越小
//            if (fabs(i * squareLength - point.y) >= fabs((i + 1) * squareLength - point.y)) {
//                h = i + 1;
//                break;
//            } else {
//                h = i;
//                break;
//            }
//        }
//    }
//    NSLog(@"第%tu条竖线, 第%tu条横线", v, h);
    // 查找h和v方案二
    // 通过坐标距离来计算v和h,触摸点x、y坐标加0.5倍的小正方形边长除小正方形边长取整
    v = (point.x + squareLength / 2) / squareLength;
    h = (point.y + squareLength / 2) / squareLength;
//    // 边缘不允许落子
//    v = v == 0 ? v + 1 : v;
//    h = h == 0 ? h + 1 : h;
//    v = v == piecesNumber + 1 ? piecesNumber : v;
//    h = h == piecesNumber + 1 ? piecesNumber: h;
    NSLog(@"v=第%tu条竖线, h=第%tu条横线", v, h);
    if (h >= piecesNumber || v >= piecesNumber) {
        NSLog(@"failed!");
        self.userInteractionEnabled = YES;
        return;
    }
    if ([self.places[v][h] integerValue] == 0) {
    } else {
        self.userInteractionEnabled = YES;
        return;
    }
    
    if (h >= piecesNumber || v >= piecesNumber) {
        NSLog(@"failed!");
        self.userInteractionEnabled = YES;
        return;
    }
        
    if ([self.places[v][h] integerValue] == 0) {
        
    } else {
        self.userInteractionEnabled = YES;
        return;
    }
    
    GobangPoint *p;
//        p = [GobangAI geablog:self.places type:OccupyTypeUser];
    p = [[GobangPoint alloc] initPointWith:v y:h];
    if ([self move:p] == FALSE) {
        [self win:OccupyTypeAI];
//        self.userInteractionEnabled = YES;
        return;
    }
    if ([self checkVictory:OccupyTypeUser]== OccupyTypeUser) {
        [self win:OccupyTypeUser];
//        self.userInteractionEnabled = YES;
        return;
    }
    p = [GobangAI geablog:self.places type:OccupyTypeAI];
    if ([self move:p] == FALSE) {
        [self win:OccupyTypeUser];
//        self.userInteractionEnabled = YES;
        return;
    }
    if ([self checkVictory:OccupyTypeAI] == OccupyTypeAI) {
        [self win:OccupyTypeAI];
//        self.userInteractionEnabled = YES;
        return;
    }
    self.userInteractionEnabled = YES;
//    UIImageView *black = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//    black.backgroundColor = [UIColor clearColor];
//    black.image = [UIImage imageNamed:@"black"];
//    [self addSubview:black];
//    black.center = CGPointMake(v * squareLength, h * squareLength);
}

- (OccupyType)getType:(CGPoint)point {
    if ((point.x >= 0 && point.x < piecesNumber) && (point.y >= 0 && point.y < piecesNumber)) {
        NSInteger x = (int)point.x;
        NSMutableArray *arr = self.places[x];
        NSInteger y = (int)point.y;
        return [arr[y] integerValue];
    }
    return OccupyTypeUnknown;
}

- (OccupyType)checkNode:(CGPoint)point { //对个给定的点向四周遍历 看是否能形成5子连珠
    
    OccupyType curType = [self getType:point];
    BOOL vic = TRUE;
    for (int i = 1; i < 5; i ++) {
        CGPoint nextP = CGPointMake(point.x + i, point.y);
        if (point.x + i >= piecesNumber || [self getType:nextP] != curType) {
            vic = FALSE;
            break;
        }
    }
    if (vic == TRUE) {
        return curType;
    }
    vic = TRUE;
    for (int i = 1; i < 5; i++) {
        CGPoint nextP = CGPointMake(point.x, point.y + i);
        if (point.y + i >= piecesNumber || [self getType:nextP] != curType) {
            vic = false;
            break;
        }
    }
    if (vic == TRUE) {
        return curType;
    }
    vic = TRUE;
    for (int i = 1; i < 5; i++) {
        CGPoint nextP = CGPointMake(point.x + i, point.y + i);
        if (point.x + i >= piecesNumber || point.y + i >= piecesNumber || [self getType:nextP] != curType) {
            vic = false;
            break;
        }
    }
    if (vic == TRUE) {
        return curType;
    }
    vic = TRUE;
    for (int i = 1; i < 5; i ++) {
        CGPoint nextP = CGPointMake(point.x - i, point.y + i);
        if (point.x - i < 0 || point.y + i >= piecesNumber || [self getType:nextP] != curType) {
            vic = false;
            break;
        }
    }
    if (vic == TRUE) {
        return curType;
    }
    return OccupyTypeEmpty;
}

- (OccupyType)checkVictory:(OccupyType)type { // 检查是否type方胜利了的方法
    BOOL isFull = TRUE;
    for (int i = 0; i < piecesNumber; i ++) {
        for (int j = 0; j < piecesNumber; j ++) {
            CGPoint p = CGPointMake(i, j);
            OccupyType winType = [self checkNode:p]; // 检查是否形成5子连珠
            if (winType == OccupyTypeUser) {
                return OccupyTypeUser;
            } else if (winType == OccupyTypeAI) {
                return OccupyTypeAI;
            }
            NSMutableArray *arr = self.places[i];
            OccupyType ty = [arr[j] integerValue];
            if (ty == OccupyTypeEmpty) {
                isFull = false;
            }
        }
    }
    if (isFull == TRUE) {
        return type;
    }
    return OccupyTypeEmpty;
}

- (BOOL)move:(GobangPoint *)p { // 向p点进行落子并绘制的方法
    if (p.x < 0 || p.x >= piecesNumber ||
        p.y < 0 || p.y >= piecesNumber) {
        return false;
    }
    
    NSInteger x = p.x;
    NSMutableArray *arr = self.places[x];
    NSInteger y = p.y;
    OccupyType ty = [arr[y] integerValue];
    if (ty == OccupyTypeEmpty) {
        if (self.isPlayerPlaying) {
            [arr replaceObjectAtIndex:y withObject:@(OccupyTypeUser)];
            
            UIImageView *black = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            black.backgroundColor = [UIColor clearColor];
            black.image = [UIImage imageNamed:@"black"];
            black.layer.cornerRadius = 5;
            black.clipsToBounds = YES;
            [self addSubview:black];
//            black.frame = CGRectMake((x + 1) * self.frame.size.width / (piecesNumber + 1) - 5, (y + 1) * self.frame.size.height / (piecesNumber + 1) - 5, 10, 10);
             black.frame = CGRectMake((x ) * self.frame.size.width / (piecesNumber + 1) - 5, (y ) * self.frame.size.height / (piecesNumber + 1) - 5, 10, 10);
            
            [self.chesses addObject:black];
            
        } else {
            [arr replaceObjectAtIndex:y withObject:@(OccupyTypeAI)];
            
            UIImageView *black = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            black.image = [UIImage imageNamed:@"white"];
            black.backgroundColor = [UIColor clearColor];
            black.layer.cornerRadius = 5;
            black.clipsToBounds = YES;
            [self addSubview:black];
            //        black.center = CGPointMake(h * self.frame.size.width / 10, v * self.frame.size.height);
//            black.frame = CGRectMake((p.x + 1) * self.frame.size.width / (piecesNumber + 1) - 5, (p.y + 1) * self.frame.size.height / (piecesNumber + 1) - 5, 10, 10);
            black.frame = CGRectMake((p.x ) * self.frame.size.width / (piecesNumber + 1) - 5, (p.y ) * self.frame.size.height / (piecesNumber + 1) - 5, 10, 10);
            [self.chesses addObject:black];
            
            [self.redDot removeFromSuperview];
            [black addSubview:self.redDot];
            self.redDot.frame = CGRectMake(2.5, 2.5, 5, 5);
        }
        self.isPlayerPlaying = !self.isPlayerPlaying;
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)win:(OccupyType)type { // type方获得胜利时出现动画的效果
    
    self.userInteractionEnabled = NO;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 40) / 2, self.frame.size.width, 45)];
    label.layer.cornerRadius = 5;
    label.layer.borderColor = [[UIColor blackColor] CGColor];
    label.layer.borderWidth = 5;
    label.font = [UIFont systemFontOfSize:38];
    [self addSubview:label];
    label.adjustsFontSizeToFitWidth = YES;
    label.alpha = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    if (OccupyTypeAI == type) {
        label.text = @"您输了～嘿嘿嘿";
        
    } else if (OccupyTypeUser == type) {
        label.text = @"您赢了 太棒！";
        
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [self reset];
            [label removeFromSuperview];
            self.userInteractionEnabled = YES;
        }];
    }];
}

- (void)reset { // 重新开始的方法
    
    self.userInteractionEnabled = YES;
    
    for (UIView *view in self.chesses) {
        [view removeFromSuperview];
    }
    
    [self.chesses removeAllObjects];
    
    self.places = [NSMutableArray array];
    for (int i = 0; i < piecesNumber; i ++) {
        NSMutableArray *chil = [NSMutableArray array];
        for (int j = 0; j < piecesNumber; j ++) {
            [chil addObject:@(OccupyTypeEmpty)];
        }
        [self.places addObject:chil];
    }
}

@end
