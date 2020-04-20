//
//  GobangAI.m
//  gobangDemo
//
//  Created by 志良潘 on 2020/4/15.
//  Copyright © 2020 志良潘. All rights reserved.
//

#import "GobangAI.h"

static NSInteger kBoardSize = 14;

@implementation Robot

- (id)initWithArr:(NSMutableArray *)places {
    self = [self init];
    if (self) {
        self.curBoard = places;
        self.oppoType = OccupyTypeUser;
        self.myType = OccupyTypeAI;
    }
    return self;
}

// 检查落子点是否可用
- (BOOL)checkPoint:(GobangPoint *)point {
    // 如果一个点的X Y 坐标都大于等于0且小于棋盘大小时才认为可用
    if ((point.x >= 0 && point.x < kBoardSize + 2) && (point.y >= 0 && point.y < kBoardSize + 2)) {
        return YES;
    }
    return NO;
}

// 从左到右，从上往下获取下一个点(最终会超出棋盘范围，临界点是(0, kBoardSize+2))
- (GobangPoint *)getNextPoint:(GobangPoint *)point {
    // 判断当前行有没有遍历完
    if(point.x + 1 < kBoardSize + 2) {
        // 没有遍历完，返回当前行的下一个点
        return [[GobangPoint alloc]initPointWithX:point.x + 1 y:point.y];
    }
    // 遍历完了，返回下一行的第一个点
    return [[GobangPoint alloc]initPointWithX:0 y:point.y+1];
}

// 以type的角度观察场上形势，从point点开始横向遍历，寻找是否有threshold连珠并且落子后可以形成num连珠的点
- (GobangPoint *)horizontal:(GobangPoint *)point type:(OccupyType)type num:(int)num thre:(int)threshold {
    // 判断当前点是否可用
    if (![self checkPoint:point]) {
        // 不可用返回当前点
        return point;
    }
    // 初始化横向type类型的棋子个数为0
    int count = 0;
    // 设置solution为我们需要的点
    GobangPoint *solution = [[GobangPoint alloc] init];
    // 寻找横向(从(x,y)到(x + num - 1, y))type类型的棋子个数
    for(int i = 0; i < num; i++) {
        // 当前坐标
        NSInteger x = point.x + i, y = point.y;
        // 当前点是否可用
        if (x < kBoardSize + 2) {
            // 判断下一个点是否也是type类型
            if([self.curBoard[x][y] integerValue] == type) {
                // 是，连珠数量加1
                count++;
                // 继续遍历下一个点
                continue;
            }
            // 找到一个空点落子后可能形成num连珠
            if([self.curBoard[x][y] integerValue] == OccupyTypeEmpty) {
                // 标记solution是否已找到
                if (solution.x != -1) {
                    continue;
                }
                // 给solution点赋值
                solution.x = x;
                solution.y = y;
            }
        }
    }
    // 找到了满足连珠条件的可用点
    if(count >= threshold && [self checkPoint:solution]) {
        return solution;
    }
    // 否则以递归的方式向后一个点进行遍历
    return [self horizontal:[self getNextPoint:point] type:type num:num thre:threshold];
}

// 以type的角度观察场上形势，从point点开始纵向遍历，寻找是否有threshold连珠并且落子后可以形成num连珠的点
- (GobangPoint *)vertical:(GobangPoint *)point type:(OccupyType)type num:(int)num thre:(int)threshold {
    // 判断当前点是否可用
    if (![self checkPoint:point]) {
        // 不可用返回当前点
        return point;
    }
    // 初始化纵向type类型的棋子个数为0
    int count = 0;
    // 设置solution为我们需要的点
    GobangPoint *solution = [[GobangPoint alloc] init];
    // 寻找纵向(从(x,y)到(x, y + num - 1))type类型的棋子个数
    for(int i = 0; i < num; i++){
        // 当前坐标
        NSInteger x = point.x, y = point.y + i;
        // 当前点是否可用
        if (y < kBoardSize + 2) {
            // 判断下一个点是否也是type类型
            if([self.curBoard[x][y] integerValue] == type){
                count++;
                continue;
            }
            // 找到一个空点落子后可能形成num连珠
            if([self.curBoard[x][y] integerValue] == OccupyTypeEmpty) {
               // 标记solution是否已找到
                if (solution.x != -1) {
                    continue;
                }
                // 给solution点赋值
                solution.x = x;
                solution.y = y;
            }
        }
    }
    // 找到了满足连珠条件的可用点
    if(count >= threshold && [self checkPoint:solution]) {
        return solution;
    }
    // 否则以递归的方式向后一个点进行遍历
    return [self vertical:[self getNextPoint:point] type:type num:num thre:threshold];
}

// 以type的角度观察场上形势，从point点开始右下向遍历，寻找是否有threshold连珠并且落子后可以形成num连珠的点
- (GobangPoint *)rightDown:(GobangPoint *)point type:(OccupyType)type num:(int)num thre:(int)threshold {
    // 判断当前点是否可用
    if (![self checkPoint:point]) {
        // 不可用返回当前点
        return point;
    }
    // 初始化右下type类型的棋子个数为0
    int count = 0;
    // 设置solution为我们需要的点
    GobangPoint *solution = [[GobangPoint alloc] init];
    // 寻找右下(从(x,y)到(x + num - 1, y + num - 1))type类型的棋子个数
    for(int i = 0; i < num; i++) {
        // 当前坐标
        NSInteger x = point.x + i,y = point.y + i;
        // 当前点是否可用
        if ((point.x + i < kBoardSize + 2) && (point.y + i < kBoardSize + 2)) {
            // 判断下一个点是否也是type类型
            if(([self.curBoard[x][y] integerValue] == type)) {
                count++;
                continue;
            }
            // 找到一个空点落子后可能形成num连珠
            if([self.curBoard[x][y] integerValue] == OccupyTypeEmpty) {
                // 标记solution是否已找到
                if (solution.x != -1) {
                    continue;
                }
                // 给solution点赋值
                solution.x = x;
                solution.y = y;
            }
        }
    }
    // 找到了满足连珠条件的可用点
    if(count >= threshold && [self checkPoint:solution]) {
        return solution;
    }
    // 否则以递归的方式向后一个点进行遍历
    return [self rightDown:[self getNextPoint:point] type:type num:num thre:threshold];
}

// 以type的角度观察场上形势，从point点开始向左下方遍历，寻找是否有threshold连珠并且落子后可以形成num连珠的点
- (GobangPoint *)leftDown:(GobangPoint *)point type:(OccupyType)type num:(int)num thre:(int)threshold {
    // 判断当前点是否可用
    if (![self checkPoint:point]) {
        // 不可用返回当前点
        return point;
    }
    // 初始化左下type类型的棋子个数为0
    int count = 0;
    // 设置solution为我们需要的点
    GobangPoint *solution = [[GobangPoint alloc] init];
    // 寻找左下(从(x,y)到(x - num + 1, y + num - 1))type类型的棋子个数
    for(int i = 0; i < num; i++) {
        // 当前坐标
        NSInteger x = point.x - i, y = point.y + i;
        // 当前点是否可用
        if ((point.x - i >= 0) && (point.y + i < kBoardSize + 2)) {
            // 判断下一个点是否也是type类型
            if(([self.curBoard[x][y] integerValue] == type)) {
                count++;
                continue;
            }
            // 找到一个空点落子后可能形成num连珠
            if([self.curBoard[x][y] integerValue] == OccupyTypeEmpty) {
                // 标记solution是否已找到
                if (solution.x != -1) {
                    continue;
                }
                // 给solution点赋值
                solution.x = x;
                solution.y = y;
            }
        }
    }
    // 找到了满足连珠条件的可用点
    if(count >= threshold && [self checkPoint:solution]) {
        return solution;
    }
    // 否则以递归的方式向后一个点进行遍历
    return [self leftDown:[self getNextPoint:point] type:type num:num thre:threshold];
}

// 从type类型进行思考,包含point点(可能的最优落子点)的num连珠两端是否都可落子
- (BOOL)isStepEmergent:(GobangPoint *)point Num:(int)num type:(OccupyType)type {
//    NSLog(@"isStepEmergent point(%d, %d) num = %d type = %d",(int)point.x,(int)point.y,num,(int)type);
    // 判断当前点是否可用
    if (![self checkPoint:point]) {
        // 不可用返回两端没有可用的落子点
        return FALSE;
    }
    // 零点特殊处理
    if (point.x == 0 && point.y == 0) {
        return TRUE;
    }
    // 横向检查
    GobangPoint *startPoint = [[GobangPoint alloc]initPointWithX:point.x - 1 y:point.y];
    // 如果相邻的落子点不可用
    if (![self checkPoint:startPoint]) {
        startPoint.x = point.x;
    }
    GobangPoint *endPoint = [[GobangPoint alloc]initPointWithX:point.x + 1 y:point.y];
    // 如果相邻的落子点不可用
    if (![self checkPoint:endPoint]) {
        endPoint.x = point.x;
    }
    // 获取两个端点(端点为敌方点或者空点)
    for (int i = 0; startPoint.x >= 0 && [self.curBoard[startPoint.x][startPoint.y] integerValue] == type; i++) {
        startPoint.x = startPoint.x - 1;
    }
    for (int i = 0; endPoint.x < kBoardSize + 2 && [self.curBoard[endPoint.x][endPoint.y] integerValue] == type; i++) {
        endPoint.x = endPoint.x + 1;
    }
    // 判断端点是否在棋盘上且两点距离大于num
    if ([self checkPoint:startPoint] && [self checkPoint:endPoint] && endPoint.x - startPoint.x > num) {
        if ([self.curBoard[startPoint.x][startPoint.y] integerValue] == OccupyTypeEmpty && [self.curBoard[endPoint.x][endPoint.y] integerValue] == OccupyTypeEmpty) {
//            NSLog(@"endPoint(%d, %d),startPoint(%d, %d),",(int)endPoint.x,(int)endPoint.y,(int)startPoint.x,(int)startPoint.y);
            return TRUE;
        }
    }
    // 纵向检查
    startPoint = [[GobangPoint alloc]initPointWithX:point.x y:point.y - 1];
    if (![self checkPoint:startPoint]) {
        startPoint.y = point.y;
    }
    endPoint = [[GobangPoint alloc]initPointWithX:point.x y:point.y + 1];
    if (![self checkPoint:endPoint]) {
        startPoint.y = point.y;
    }
    // 获取两个端点(端点为敌方点或者空点)
    for (int i = 0; startPoint.y >= 0 && [self.curBoard[startPoint.x][startPoint.y] integerValue] == type; i++) {
        startPoint.y = startPoint.y - 1;
    }
    for (int i = 0; endPoint.y < kBoardSize + 2 && [self.curBoard[endPoint.x][endPoint.y] integerValue] == type; i++) {
        endPoint.y = endPoint.y + 1;
    }
    // 判断端点是否在棋盘上且两点距离大于num
    if ([self checkPoint:startPoint] && [self checkPoint:endPoint] && endPoint.y - startPoint.y > num) {
        // 判断端点是否都为空点
        if ([self.curBoard[startPoint.x][startPoint.y] integerValue] == OccupyTypeEmpty && [self.curBoard[endPoint.x][endPoint.y] integerValue] == OccupyTypeEmpty) {
            return TRUE;
        }
    }
    // 右上左下检查
    startPoint = [[GobangPoint alloc]initPointWithX:point.x + 1 y:point.y - 1];
    if (![self checkPoint:startPoint]) {
        startPoint.x = point.x;
        startPoint.y = point.y;
    }
    endPoint = [[GobangPoint alloc]initPointWithX:point.x - 1 y:point.y + 1];
    if (![self checkPoint:endPoint]) {
        endPoint.x = point.x;
        endPoint.y = point.y;
    }
    // 获取两个端点(端点为敌方点或者空点)
    for (int i = 0; startPoint.y >= 0 && startPoint.x < kBoardSize + 2 && [self.curBoard[startPoint.x][startPoint.y] integerValue] == type; i++) {
        startPoint.x = startPoint.x + 1;
        startPoint.y = startPoint.y - 1;
    }
    for (int i = 0; endPoint.x >= 0 && endPoint.y < kBoardSize + 2 && [self.curBoard[endPoint.x][endPoint.y] integerValue] == type; i++) {
        endPoint.x = endPoint.x - 1;
        endPoint.y = endPoint.y + 1;
    }
    // 判断端点是否在棋盘上且两点距离大于num
    if ([self checkPoint:startPoint] && [self checkPoint:endPoint] && endPoint.y - startPoint.y > num) {
        // 判断端点是否都为空点
        if ([self.curBoard[startPoint.x][startPoint.y] integerValue] == OccupyTypeEmpty && [self.curBoard[endPoint.x][endPoint.y] integerValue] == OccupyTypeEmpty) {
            return TRUE;
        }
    }
    // 左上右下检查
    startPoint = [[GobangPoint alloc]initPointWithX:point.x - 1 y:point.y - 1];
    if (![self checkPoint:startPoint]) {
        startPoint.x = point.x;
        startPoint.y = point.y;
    }
    endPoint = [[GobangPoint alloc]initPointWithX:point.x + 1 y:point.y + 1];
    if (![self checkPoint:endPoint]) {
        endPoint.x = point.x;
        endPoint.y = point.y;
    }
    // 获取两个端点(端点为敌方点或者空点)
    for (int i = 0; startPoint.x >= 0 && startPoint.y >= 0 && [self.curBoard[startPoint.x][startPoint.y] integerValue] == type; i++) {
        startPoint.x = startPoint.x - 1;
        startPoint.y = startPoint.y - 1;
    }
    for (int i = 0; endPoint.x < kBoardSize + 2 && endPoint.y < kBoardSize + 2 && [self.curBoard[endPoint.x][endPoint.y] integerValue] == type; i++) {
        endPoint.x = endPoint.x + 1;
        endPoint.y = endPoint.y + 1;
    }
    // 判断端点是否在棋盘上且两点距离大于num
    if ([self checkPoint:startPoint] && [self checkPoint:endPoint] && endPoint.y - startPoint.y > num) {
        // 判断端点是否都为空点
        if ([self.curBoard[startPoint.x][startPoint.y] integerValue] == OccupyTypeEmpty && [self.curBoard[endPoint.x][endPoint.y] integerValue] == OccupyTypeEmpty) {
            return TRUE;
        }
    }
    return FALSE;
}

// 以type的角度观察场上形势，从（startX,startXY）点开始遍历，寻找是否有threshold连珠并且落子后可以形成num子连珠的点
- (GobangPoint *)nextStep:(OccupyType)type num:(int)num thre:(int)threshold x:(int)startX y:(int)startY {
    // 初始化搜索起始点
    GobangPoint *search = [[GobangPoint alloc] initPointWithX:startX y:startY];
    // 从四个方向上(横向、纵向、右下、左下)寻找落子后能形成num连珠的点
    // 横向可能形成num连珠的点
    GobangPoint *horizontalPoint = [self horizontal:search type:type num:num thre:threshold];
    // 纵向可能形成num连珠的点
    GobangPoint *verticalPoint = [self vertical:search type:type num:num thre:threshold];
    // 右下可能形成num连珠的点
    GobangPoint *rightDownPoint = [self rightDown:search type:type num:num thre:threshold];
    // 左下可能形成num连珠的点
    GobangPoint *leftDownPoint = [self leftDown:search type:type num:num thre:threshold];
    if (horizontalPoint.y < kBoardSize + 2) {
        NSLog(@"type=%d,在horizontalPoint(%d,%d)点落子可以形成%d连珠",(int) type,(int)horizontalPoint.x, (int)horizontalPoint.y,num);
    }
    if (verticalPoint.y < kBoardSize + 2) {
        NSLog(@"type=%d,在verticalPoint(%d,%d)点落子可以形成%d连珠",(int) type,(int)verticalPoint.x, (int)verticalPoint.y,num);
    }
    if (rightDownPoint.y < kBoardSize + 2) {
        NSLog(@"type=%d,在rightDownPoint(%d,%d)点落子可以形成%d连珠",(int) type,(int)rightDownPoint.x, (int)rightDownPoint.y,num);
    }
    if (leftDownPoint.y < kBoardSize + 2) {
        NSLog(@"type=%d,在leftDownPoint(%d,%d)点落子可以形成%d连珠",(int) type,(int)leftDownPoint.x, (int)leftDownPoint.y,num);
    }
    // 是否五子连珠
    if(num == 5) {
        // 横向上找到可形成五子连珠的点
        if([self checkPoint:horizontalPoint]) {
            return horizontalPoint;
        }
        // 纵向上找到可形成五子连珠的点
        if([self checkPoint:verticalPoint]) {
            return verticalPoint;
        }
        // 右下上找到可形成五子连珠的点
        if([self checkPoint:rightDownPoint]) {
            return rightDownPoint;
        }
        // 左下横向上找到可形成五子连珠的点
        if([self checkPoint:leftDownPoint]) {
            return leftDownPoint;
        }
    } else {
        // 保存当前最优落子点(横向)
        GobangPoint *tempPoint = [[GobangPoint alloc]initPointWithX:horizontalPoint.x y:horizontalPoint.y];
        // 当前落子点可用
        if (tempPoint.y < kBoardSize + 2) {
            //
            while([self checkPoint:horizontalPoint] && ![self isStepEmergent:horizontalPoint Num:num type:type]) {
                horizontalPoint = [self horizontal:[self getNextPoint:horizontalPoint] type:type num:num thre:threshold];
            }
            // 在找到threshold连续的点并且两侧可以落子后，返回该点
            if([self isStepEmergent:tempPoint Num:num type:type]) {
                NSLog(@"horizontal type=%d,在tempPoint(%d,%d)点落子可以形成%d连珠",(int) type,(int)tempPoint.x, (int)tempPoint.y,num);
                return tempPoint;
            } else {
                NSLog(@"horizontal type=%d,在tempPoint(%d,%d)点落子后形成%d连珠，但是两端不为空点 ",(int) type,(int)tempPoint.x, (int)tempPoint.y,num);
            }
        }
        // 保存当前最优落子点(纵向)
        tempPoint = [[GobangPoint alloc]initPointWithX:verticalPoint.x y:verticalPoint.y];
        // 当前落子点可用
        if (tempPoint.y < kBoardSize + 2) {
            while([self checkPoint:verticalPoint] && ![self isStepEmergent:verticalPoint Num:num type:type]) {
                verticalPoint = [self vertical:[self getNextPoint:verticalPoint] type:type num:num thre:threshold];
            }
            // 在找到threshold连续的点并且两侧可以落子后，返回该点
            if([self isStepEmergent:verticalPoint Num:num type:type]) {
                NSLog(@"vertical type=%d,在tempPoint(%d,%d)点落子可以形成%d连珠",(int) type,(int)tempPoint.x, (int)tempPoint.y,num);
                return tempPoint;
            } else {
                NSLog(@"vertical type=%d,在tempPoint(%d,%d)点落子后形成%d连珠，但是两端不为空点 ",(int) type,(int)tempPoint.x, (int)tempPoint.y,num);
            }
        }
        // 保存当前最优落子点(右下)
        tempPoint = [[GobangPoint alloc]initPointWithX:rightDownPoint.x y:rightDownPoint.y];
        // 当前落子点可用
        if (tempPoint.y < kBoardSize + 2) {
            while([self checkPoint:rightDownPoint] && ![self isStepEmergent:rightDownPoint Num:num type:type]) {
                rightDownPoint = [self rightDown:[self getNextPoint:rightDownPoint] type:type num:num thre:threshold];
            }
            // 在找到threshold连续的点并且两侧可以落子后，返回该点
            if([self isStepEmergent:rightDownPoint Num:num type:type]) {
                NSLog(@"rightDown type=%d,在tempPoint(%d,%d)点落子可以形成%d连珠",(int) type,(int)tempPoint.x, (int)tempPoint.y,num);
                return tempPoint;
            } else {
                NSLog(@"rightDown type=%d,在tempPoint(%d,%d)点落子后形成%d连珠，但是两端不为空点 ",(int) type,(int)tempPoint.x, (int)tempPoint.y,num);
            }
        }
        // 保存当前最优落子点(左下)
        tempPoint = [[GobangPoint alloc]initPointWithX:leftDownPoint.x y:leftDownPoint.y];
        // 当前落子点可用
        if (tempPoint.y < kBoardSize + 2) {
            while([self checkPoint:leftDownPoint] && ![self isStepEmergent:leftDownPoint Num:num type:type]) {
                leftDownPoint = [self leftDown:[self getNextPoint:leftDownPoint] type:type num:num thre:threshold];
            }
            // 在找到threshold连续的点并且两侧可以落子后，返回该点
            if([self isStepEmergent:leftDownPoint Num:num type:type]) {
                NSLog(@"leftDown type=%d,在tempPoint(%d,%d)点落子可以形成%d连珠",(int) type,(int)tempPoint.x, (int)tempPoint.y,num);
                return tempPoint;
            } else {
                NSLog(@"leftDown type=%d,在tempPoint(%d,%d)点落子后形成%d连珠，但是两端不为空点 ",(int) type,(int)tempPoint.x, (int)tempPoint.y,num);
            }
        }
    }
    // 都没有找到的话，返回一个不可用的点
    GobangPoint * invalid = [[GobangPoint alloc] init];
    return invalid;
}

@end

@implementation GobangAI

+ (GobangPoint *)searchBestPoint:(NSMutableArray *)places {
    // 初始化KWOmni
    Robot *robot = [[Robot alloc] initWithArr:places];
    // 申明最优的落子点
    GobangPoint *bestPoint;
    // 定义连珠数量
    int num = 5;
    // 从能实现五连珠一直找到能实现2连珠的落子点
    while(num > 1) {
        // 在AI的角度寻找能实现num连珠的点
        bestPoint = [robot nextStep:robot.myType num:num thre:num - 1 x:0 y:0];
        // 找到了可用的最优点，返回该点
        if([robot checkPoint:bestPoint]) {
               return bestPoint;
        }
        // 在用户的角度寻找能实现num连珠的点
        bestPoint = [robot nextStep:robot.oppoType num:num thre:num - 1 x:0 y:0];
        // 找到了可用的最优点，返回该点
        if([robot checkPoint:bestPoint]) {
            return bestPoint;
        }
        num--;
    }
    // 如果什么都没有则返回不可用的点
    GobangPoint *sad = [[GobangPoint alloc] init];
    return sad;
}

@end
