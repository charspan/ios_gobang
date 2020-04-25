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

// 定义横竖各有多少个可落子的点
const NSInteger piecesNumber = 14;
// 边缘
const NSInteger boderSize = 2;
// 线的宽度
const CGFloat lineWidth = 1.000000;
// 是否调试
const BOOL debug = true;

// 这个view负责展示和智能逻辑

@interface GobangView ()

// 标志为，标志是否是玩家正在下棋
@property (nonatomic, assign) BOOL isPlayerPlaying;
// 记录所有的位置状态
@property (nonatomic, strong) NSMutableArray *places;
// 记录所有在棋盘上的棋子(方便重置游戏时清理棋盘上的棋子显示)
@property (nonatomic, strong) NSMutableArray *chesses;
//// 记录五子连珠后对应的五个棋子
//@property (nonatomic, strong) NSMutableArray *holders;
// 指示AI最新一步所在的位置
@property (nonatomic, strong) UIView *redDot;
// 每个小正方形的边长
@property (nonatomic, assign) float squareLength;
// 保存用户所有下棋步骤
@property (nonatomic, strong) NSMutableArray *userSteps;

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
    // 初始化frame
    self = [super initWithFrame:frame];
    // 初始化每个小正方形的边长
    self.squareLength = self.frame.size.width / (piecesNumber + 1);
    if (self) {
        // 设置棋盘背景颜色
        self.backgroundColor = [UIColor colorWithRed:230.0 / 255.0 green:192.0 / 255.0 blue:148.0 /255.0 alpha:1.0];
        // 初始化当前落子点标记
        self.redDot = [[UIView alloc] initWithFrame:CGRectMake(self.squareLength / 8, self.squareLength / 8, self.squareLength / 4, self.squareLength / 4)];
        // 设备颜色
        self.redDot.backgroundColor = [UIColor redColor];
        // 设置圆角
        self.redDot.layer.cornerRadius = self.squareLength / 8;
        // YES:剪裁超出父视图范围的子视图部分,NO:不剪裁子视图。
        self.redDot.clipsToBounds = NO;
        // 画一组横线和竖线
        for (int i = 0; i < piecesNumber + boderSize; i++) {
            if(debug) {
                // 显示横线编号
                UILabel *xLable = [[UILabel alloc]initWithFrame:CGRectMake(-5, i * self.squareLength - 10, self.squareLength, self.squareLength)];
                xLable.text = [NSString stringWithFormat:@"%d",i];
                xLable.font = [UIFont systemFontOfSize:12];
                [self addSubview:xLable];
            }
            
            // 初始化横线，起始坐标为(0, i * self.squareLength)，宽度是当前frame的宽度，高度是lineWidth
            UIView *horizonLine = [[UIView alloc] initWithFrame:CGRectMake(0, i * self.squareLength, frame.size.width, lineWidth)];
            // 定义横线颜色为黑色
            horizonLine.backgroundColor = [UIColor blackColor];
            // 添加到主界面以显示出来
            [self addSubview:horizonLine];
            
            if (debug) {
               // 显示竖线编号
               UILabel *yLable = [[UILabel alloc]initWithFrame:CGRectMake(i * self.squareLength - 5, -10, self.squareLength, self.squareLength)];
               yLable.text = [NSString stringWithFormat:@"%d",i];
               yLable.font = [UIFont systemFontOfSize:12];
               [self addSubview:yLable];
            }
            
            // 初始化竖线，起始坐标为(i * self.squareLength, 0)，宽度是lineWidth，高度是当前frame的宽度
            UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(i * self.squareLength, 0, lineWidth, frame.size.width)];
            // 定义竖线颜色为黑色
            verticalLine.backgroundColor = [UIColor blackColor];
            // 添加到主界面以显示出来
            [self addSubview:verticalLine];
        }
        // 初始化所有位置状态，设置棋盘逻辑值，全部为可落子点（空点）
        self.places = [NSMutableArray array];
        for (int i = 0; i < piecesNumber + boderSize; i++) {
            NSMutableArray *child = [NSMutableArray array];
            for (int j = 0; j < piecesNumber + boderSize; j++) {
                [child addObject:@(OccupyTypeEmpty)];
            }
            [self.places addObject:child];
        }
        // 初始化所有在棋盘上的棋子view（为空的NSMutableArray）
        self.chesses = [NSMutableArray array];
//        // 记录五子连珠后对应的五个棋子
//        self.holders = [NSMutableArray array];
        self.userSteps = [NSMutableArray array];
    }
    return self;
}

// 苹果原生api--接收界面手势信息
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 用户点击后，设置界面不可点击，再处理点击事件
    self.userInteractionEnabled = NO;
    // 标志是玩家在下棋
    self.isPlayerPlaying = YES;
    // 获取触摸信息
    UITouch *touch = [touches anyObject];
    // 获取触摸位置
    CGPoint point = [touch locationInView:self];
    // 申明离点击位置最近的两条线（一横一竖），h 代表横线编号，v 代表竖线编号，编号顺序从左到右，从上到下，从0开始编号
    // 通过坐标距离来计算v和h,触摸点x、y坐标加0.5倍的小正方形边长再除小正方形边长取整
    NSUInteger x = (point.x + self.squareLength / 2) / self.squareLength;
    NSUInteger y = (point.y + self.squareLength / 2) / self.squareLength;
    NSLog(@"用户触摸坐标，(%tu, %tu)", x, y);
    // 判断当前点是否为空点（用户点击了已落子的点），点击无效不做处理
    if ([self.places[x][y] integerValue] != OccupyTypeEmpty) {
        self.userInteractionEnabled = YES;
        return;
    }
    // 初始化用户点击的点
    GobangPoint *clickPoint = [[GobangPoint alloc] initPointWithX:x y:y];
    [self.userSteps addObject:clickPoint];
    // 判断用户落子是否失败
    if ([self move:clickPoint] == FALSE) {
        // 显示AI获胜
        [self win:OccupyTypeAI];
        return;
    }
    // 判断用户落子后是否获胜(形成5子连珠)
    if ([self checkVictory:OccupyTypeUser] == OccupyTypeUser) {
        // 显示用户获胜
        [self win:OccupyTypeUser];
        return;
    }
    // 初始化AI落子点
   GobangPoint *robotPoint = [GobangAI searchBestPoint:self.places];
    // 判断AI落子是否失败
    if ([self move:robotPoint] == FALSE) {
        [self win:OccupyTypeUser];
        return;
    }
    // 判断AI落子后是否获胜(形成5子连珠)
    if ([self checkVictory:OccupyTypeAI] == OccupyTypeAI) {
        // 显示AI获胜
        [self win:OccupyTypeAI];
        return;
    }
    // 点击事件处理完成后，设置界面允许点击
    self.userInteractionEnabled = YES;
}

// 获取当前点的状态（被用户占领、被AI占领、空点、位置点）
- (OccupyType)getPointType:(GobangPoint*)point {
    // 判断点是否在棋盘内
    if ((point.x >= 0 && point.x < piecesNumber + boderSize) && (point.y >= 0 && point.y < piecesNumber + boderSize)) {
        // 获取第x条竖线上的棋盘状态
        NSMutableArray *arr = self.places[point.x];
        // 获取第x条竖线和第y横线交点的状态，即(x,y)的状态
        return [arr[point.y] integerValue];
    }
    // 点不在棋盘内，则返回位置状态
    return OccupyTypeUnknown;
}

// 对point点向四周遍历，判断是否能形成5子连珠
- (OccupyType)checkNode:(GobangPoint*)point {
    // 获取当前点的状态（被用户占领、被AI占领、空点）
    OccupyType currentType = [self getPointType:point];
    // 先假设能形成5子连珠，获胜
    BOOL victory = TRUE;
    // 判断横向是否有5子连珠
    for (int i = 1; i < 5; i++) {
        GobangPoint *nextP = [[GobangPoint alloc]initPointWithX:point.x + i y:point.y];
        // 下一个点不是当前玩家占领，则无法形成5子连珠
        if ([self getPointType:nextP] != currentType) {
            victory = FALSE;
            break;
        }
    }
    // 存在五子连珠，返回当前点状态
    if (victory) {
        return currentType;
    }
    // 判断纵向是否有5子连珠
    victory = TRUE;
    for (int i = 1; i < 5; i++) {
        GobangPoint *nextP = [[GobangPoint alloc]initPointWithX:point.x y:point.y + i];
        // 下一个点不是当前玩家占领，则无法形成5子连珠
        if ([self getPointType:nextP] != currentType) {
            victory = false;
            break;
        }
    }
    // 存在五子连珠，返回当前点状态
    if (victory) {
        return currentType;
    }
    // 判断右下是否有5子连珠
    victory = TRUE;
    for (int i = 1; i < 5; i++) {
        GobangPoint *nextP = [[GobangPoint alloc]initPointWithX:point.x + i y:point.y + i];
        // 下一个点不是当前玩家占领，则无法形成5子连珠
        if ([self getPointType:nextP] != currentType) {
            victory = false;
            break;
        }
    }
    // 存在五子连珠，返回当前点状态
    if (victory) {
        return currentType;
    }
    // 判断左下是否有5子连珠
    victory = TRUE;
    for (int i = 1; i < 5; i++) {
        GobangPoint *nextP = [[GobangPoint alloc]initPointWithX:point.x - i y:point.y + i];
        // 下一个点不是当前玩家占领，则无法形成5子连珠
        if ( [self getPointType:nextP] != currentType) {
            victory = false;
            break;
        }
    }
    // 存在五子连珠，返回当前点状态
    if (victory) {
        return currentType;
    }
    // 横向、纵向、右下、左下都没有五子连珠，返回当前点状态为空
    return OccupyTypeEmpty;
}

// 检查type方是否胜利
- (OccupyType)checkVictory:(OccupyType)type {
    // 从左到右，从上到下遍历棋盘所有点，寻找五子连珠
    for (int i = 0; i < piecesNumber + boderSize; i++) {
        for (int j = 0; j < piecesNumber + boderSize; j++) {
            // 初始化棋盘点(i,j)
            GobangPoint *gobangPoint = [[GobangPoint alloc]initPointWithX:i y:j];
            // 检查该店是否形成了5子连珠
            OccupyType winType = [self checkNode:gobangPoint];
            // 判断当前点有没有形成5子连珠
            if (winType == OccupyTypeEmpty) {
                // 没有形成5子连珠，则继续遍历下一个点
                continue;
            } else {
                // 形成了5子连珠，返回胜利方type
                return winType;
            }
        }
    }
    // 整个棋盘都没有五子连珠，返回空类型
    return OccupyTypeEmpty;
}

// 在p点落子
- (BOOL)move:(GobangPoint *)point {
    // 如果point点不在棋盘上，返回落子失败
    if (point.x < 0 || point.x >= piecesNumber + 2 || point.y < 0 || point.y >= piecesNumber + 2) {
        return false;
    }
    // 获取第x竖线的落子情况
    NSMutableArray *xLineStatus = self.places[point.x];
    // 获取第x竖线第y横线交点的落子情况（坐标(x,y)的落子情况）
    OccupyType xyStatus = [xLineStatus[point.y] integerValue];
    // 如果(x,y)点不可落子,返回落子失败
    if (xyStatus != OccupyTypeEmpty) {
        return FALSE;
    }
    // 标记(x,y)点被当前玩家(用户或者AI)占领
    [xLineStatus replaceObjectAtIndex:point.y withObject:self.isPlayerPlaying ? @(OccupyTypeUser) : @(OccupyTypeAI)];
    // 创建一个棋子
    UIImageView *piece = [[UIImageView alloc] initWithFrame:CGRectMake(point.x * self.squareLength - self.squareLength / 4, point.y * self.squareLength - self.squareLength / 4, self.squareLength / 2, self.squareLength / 2)];
    // 清除背景颜色（透明背景）
    piece.backgroundColor = [UIColor clearColor];
    // 设置棋子颜色，用户：黑色，AI:白色
    piece.image = [UIImage imageNamed:self.isPlayerPlaying ? @"black" : @"white"];
    // 设置圆角
    piece.layer.cornerRadius = self.squareLength / 4;
    // YES:剪裁超出父视图范围的子视图部分,NO:不剪裁子视图。
    piece.clipsToBounds = YES;
    // 将棋子显示出来
    [self addSubview:piece];
    // 将落子点标记从上一个落子点中移除
    [self.redDot removeFromSuperview];
    // 将落子点标记和当前落子点绑定显示
    [piece addSubview:self.redDot];
    // 记录当前落子view信息
    [self.chesses addObject:piece];
    // 检查棋盘是否已被下满棋子，判断双方谁的连珠数量最多
    
    // 标记下一个下棋的玩家
    self.isPlayerPlaying = !self.isPlayerPlaying;
    // 返回落子成功
    return TRUE;
}

// type方获得胜利时出现动画的效果
- (void)win:(OccupyType)type {
    // 有一方获胜时先设置界面不可点击
    self.userInteractionEnabled = NO;
    // 设置提示标签高度
    NSInteger labelHeight = 50;
    // 创建一个标签用于显示获胜或失败信息
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - labelHeight) / 2, self.frame.size.width, labelHeight)];
    // 设置标签圆角
    label.layer.cornerRadius = labelHeight / 2;
    // 设备标签边框颜色
    label.layer.borderColor = [[UIColor blackColor] CGColor];
    // 设置标签边框宽度
    label.layer.borderWidth = 5;
    // 设置标签字体大小
    label.font = [UIFont systemFontOfSize:38];
    // 显示标签
    [self addSubview:label];
    // 自适应宽度
    label.adjustsFontSizeToFitWidth = YES;
    // 设置透明度为0，隐藏标签
    label.alpha = 0;
    // 设置文本居中
    label.textAlignment = NSTextAlignmentCenter;
    // 根据获胜方类型，设置提示信息
    label.text = type == OccupyTypeAI ? @"您输了～嘿嘿嘿" : @"您赢了~真棒！！";
    // 调试模式打印用户点击历史
    if (debug) {
        for (GobangPoint *object in self.userSteps) {
            NSLog(@"依次点击:（%d,%d)", (int)object.x,(int)object.y);
        }
    }
    // 设置提示动画
    // 0.5秒完成显示label，
    [UIView animateWithDuration:0.5 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        // 标签显示1秒后，0.5秒隐藏标签
        // UIViewAnimationOptionCurveEaseInOut 时间曲线函数，缓入缓出，中间快，其他可选值：https://www.cnblogs.com/xiaobajiu/p/4084747.html
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            // 将提示标签移除
            [label removeFromSuperview];
            // 重置游戏
            [self reset];
        }];
    }];
}

// 重新开始游戏方法
- (void)reset {
    // 设置界面可点击
    self.userInteractionEnabled = YES;
    // 移除所有棋子view的显示
    for (UIView *view in self.chesses) {
        [view removeFromSuperview];
    }
    // 移除现有棋盘棋子view信息
    [self.chesses removeAllObjects];
    // 重置棋盘位置占用信息，设置棋盘逻辑值，全部为可落子点（空点）
    self.places = [NSMutableArray array];
    for (int i = 0; i < piecesNumber + boderSize; i ++) {
        NSMutableArray *child = [NSMutableArray array];
        for (int j = 0; j < piecesNumber + boderSize; j ++) {
            [child addObject:@(OccupyTypeEmpty)];
        }
        [self.places addObject:child];
    }
    // 移除用户操作步骤记录
    [self.userSteps removeAllObjects];
}

@end
