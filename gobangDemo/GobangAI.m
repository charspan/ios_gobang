//
//  GobangAI.m
//  gobangDemo
//
//  Created by 志良潘 on 2020/4/15.
//  Copyright © 2020 志良潘. All rights reserved.
//

#import "GobangAI.h"

static NSInteger kBoardSize = 14;

@implementation KWPointData

- (id)init {
    self = [super init];
    if (self) {
        self.p = [[GobangPoint alloc] initPointWithX:-1 y:-1];
        self.count = 0;
    }
    return self;
}

- (id)initWithPoint:(GobangPoint *)point count:(int)ncount {
    self = [self init];
    if (self) {
        self.p = [[GobangPoint alloc] initPointWithX:-1 y:-1];
        self.p.x = point.x;
        self.p.y = point.y;
        self.count = ncount;
    }
    return self;
}

@end

@implementation KWOmni

- (id)init {
    self = [super init];
    if (self) {
        self.oppoType = OccupyTypeEmpty;
        self.myType = OccupyTypeEmpty;
    }
    return self;
}

- (id)initWithArr:(NSMutableArray *)arr opp:(OccupyType)opp my:(OccupyType)my {
    self = [self init];
    if (self) {
        self.curBoard = arr;
        self.oppoType = opp;
        self.myType = my;
    }
    return self;
}

// 从type类型进行思考：从point点开始上下左右寻找是否存在一个空点，落子后形成num连珠
- (BOOL)isStepEmergent:(GobangPoint *)point Num:(int)num type:(OccupyType)type {
    // 设置检查点
    GobangPoint *check = [[GobangPoint alloc] initPointWithX:point.x y:point.y];
    // 判断当前点是否可用
    if (![self checkPoint:check]) {
        return FALSE;
    }
    // 开始进行寻找的点
    GobangPoint *test = [[GobangPoint alloc] initPointWithX:check.x y:check.y];
    // 遍历点的左侧的点
    GobangPoint *testR = [[GobangPoint alloc] initPointWithX:check.x y:check.y];
    // 遍历点的右侧的点
    GobangPoint *testL = [[GobangPoint alloc] initPointWithX:check.x y:check.y];
    // 开始遍历点的正右侧
    testR = [[GobangPoint alloc] initPointWithX:check.x + 1 y:check.y];
    // 开始遍历的点的正左侧
    testL = [[GobangPoint alloc] initPointWithX:check.x - 1 y:check.y];
    // 在相应点向右侧进行遍历，寻找最长的连续距离的点
    for(int i = 1; (test.x+i < kBoardSize+2) && ([self.curBoard[testR.x][testR.y] integerValue] == type); i++) {
        testR = [[GobangPoint alloc] initPointWithX:testR.x + 1 y:testR.y];
    }
    // 在相应点向左侧进行遍历，寻找最长的连续距离的点
    for(int i = 1; (test.x-i >= 0) && ([self.curBoard[(int)testL.x][(int)testL.y] integerValue] == type); i++) {
        testL = [[GobangPoint alloc] initPointWithX:testR.x - 1 y:testR.y];
    }
    // 如果两个点都是可用的
    if ([self checkPoint:testL] && [self checkPoint:testR]) {
        if (testR.x - testL.x >= num) { // 如果两个点之间的距离大于或等于我们需要的距离
            // 并且这段连续距离的两侧都是可以落子的空点
            if ([self.curBoard[testR.x][testR.y] integerValue] == OccupyTypeEmpty && [self.curBoard[testL.x][testL.y] integerValue] == OccupyTypeEmpty) {
                return TRUE;
            }
        }
    }
    testR = [[GobangPoint alloc] initPointWithX:check.x y:check.y + 1]; // 开始遍历点的正下方
    testL = [[GobangPoint alloc] initPointWithX:check.x y:check.y - 1]; // 开始遍历的点的正上方
    
    for(int i = 1; (test.y+i < kBoardSize + 2) && ([self.curBoard[testR.x][testR.y] integerValue] == type); i++) { // 不断向正下方寻找最长连续
        testR.x = testR.x;
        testR.y = testR.y + 1;
    }
    for(int i = 1; (test.y-i >= 0) && ([self.curBoard[testL.x][testL.y] integerValue] == type); i++) { // 不断向正上方寻找最长连续
        testL.x = testL.x;
        testL.y = testL.y - 1;
    }
    if ([self checkPoint:testL]  && [self checkPoint:testR]) {
        if(testR.y - testL.y >= num)
            if([self.curBoard[testR.x][testR.y] integerValue] == OccupyTypeEmpty && [self.curBoard[testL.x][testL.y] integerValue] == OccupyTypeEmpty)
                return true;
    }
    testR.x = check.x + 1; // 开始遍历点的右下方
    testR.y = check.y + 1;
    testL.x = check.x - 1; // 开始遍历点的左上方
    testL.y = check.y - 1;
    // 后面的判断逻辑和上面是相同的 不再赘述
    for(int i = 1; (test.x+i < kBoardSize+2 && test.y+i < kBoardSize) && ([self.curBoard[testR.x][testR.y] integerValue] == type); i++) {
        testR.x = testR.x + 1;
        testR.y = testR.y + 1;
    }
    for(int i = 1; (test.x-i >= 0 && test.y-i >= 0) && ([self.curBoard[testL.x][testL.y] integerValue] == type); i++) {
        testL.x = testL.x - 1;
        testL.y = testL.y - 1;
    }
    if ([self checkPoint:testL] && [self checkPoint:testR]) {
        if(testR.x - testL.x >= num)
            if([self.curBoard[testR.x][testR.y] integerValue] == OccupyTypeEmpty && [self.curBoard[testL.x][testL.y] integerValue] == OccupyTypeEmpty)
                return true;
    }
    testR.x = check.x + 1; // 开始遍历点的右上方
    testR.y = check.y - 1;
    testL.x = check.x - 1; // 开始遍历点的左下方
    testL.y = check.y + 1;
    for(int li = 1; (test.x+li < kBoardSize +2 && test.y-li >= 0) && ([self.curBoard[testR.x][testR.y] integerValue] == type); li++) {
        testR.x = testR.x + 1;
        testR.y = testR.y - 1;
    }
    for(int lii = 1; (test.x-lii >= 0 && test.y+lii < kBoardSize+2) && ([self.curBoard[testL.x][testL.y] integerValue] == type); lii++) {
        testL.x = testL.x - 1;
        testL.y = testL.y + 1;
    }
    if ([self checkPoint:testL] && [self checkPoint:testR]) {
        if(testR.x - testL.x >= num)
            if([self.curBoard[testR.x][testR.y] integerValue] == OccupyTypeEmpty && [self.curBoard[testL.x][testL.y] integerValue] == OccupyTypeEmpty)
                return true;
    }
    return FALSE;
}

// 检查落子点是否可用
- (BOOL)checkPoint:(GobangPoint *)point {
    // 如果一个点的X Y 坐标都大于等于0且小于棋盘大小时才认为可用
    if ((point.x >= 0 && point.x < kBoardSize + 2) && (point.y >= 0 && point.y < kBoardSize + 2)) {
        return YES;
    }
    return NO;
}

// 以xType的角度观察场上形势，从（startX,startXY）点开始遍历，寻找是否有threshold子连珠并且落子后可以形成num子连珠的点
- (GobangPoint *)nextStep:(OccupyType)type num:(int)num thre:(int)threshold x:(int)startX y:(int)startY {
    // 初始化搜索起始点
    GobangPoint *search = [[GobangPoint alloc] initPointWithX:startX y:startY];
    // 从四个方向上(横向、纵向、右下、左下)寻找落子后能形成num连珠的点
    // 横向可能形成num连珠的点
    GobangPoint *hPoint = [self horizontal:search type:type num:num thre:threshold];
    // 纵向可能形成num连珠的点
    GobangPoint *vPoint = [self vertical:search type:type num:num thre:threshold];
    // 右下可能形成num连珠的点
    GobangPoint *rPoint = [self rightDown:search type:type num:num thre:threshold];
    // 左下可能形成num连珠的点
    GobangPoint *lPoint = [self leftDown:search type:type num:num thre:threshold];
    if (hPoint.x != -1){
        NSLog(@"形成%d连珠 %d %d", num, hPoint.x, hPoint.y);
    }
    // 是否五子连珠
    if(num == 5) {
        // 横向上找到可形成五子连珠的点
        if([self checkPoint:hPoint]) {
            return hPoint;
        }
        // 纵向上找到可形成五子连珠的点
        if([self checkPoint:vPoint]) {
            return vPoint;
        }
        // 右下上找到可形成五子连珠的点
        if([self checkPoint:rPoint]) {
            return rPoint;
        }
        // 左下横向上找到可形成五子连珠的点
        if([self checkPoint:lPoint]) {
            return lPoint;
        }
    } else{
        while([self checkPoint:hPoint] && ![self isStepEmergent:hPoint Num:num type:type]){
            //在横向上寻找threshold连续且可以形成num连续的点
            hPoint = [self horizontal:[self getNextPoint:hPoint] type:type num:num thre:threshold];
//            NSLog(@"hPoint1 x = %d, y = %d", (int)hPoint.x, (int)hPoint.y);
        }
        // 在找到threshold连续的点并且两侧可以落子后，返回该点
        if([self isStepEmergent:hPoint Num:num type:type]){
//            NSLog(@"hPoint2 x = %d, y = %d", (int)hPoint.x, (int)hPoint.y);
            return hPoint;
        }
        while([self checkPoint:vPoint] && ![self isStepEmergent:vPoint Num:num type:type]){
            vPoint = [self vertical:[self getNextPoint:vPoint] type:type num:num thre:threshold]; //在竖向上寻找threshold连续且可以形成num连续的点
        }
        if([self isStepEmergent:vPoint Num:num type:type])// 在找到threshold连续的点并且两侧可以落子后，返回该点
            return vPoint;
        
        while([self checkPoint:rPoint] && ![self isStepEmergent:rPoint Num:num type:type]){
            rPoint = [self rightDown:[self getNextPoint:rPoint] type:type num:num thre:threshold]; //在右下向上寻找threshold连续且可以形成num连续的点
        }
        if([self isStepEmergent:rPoint Num:num type:type])// 在找到threshold连续的点并且两侧可以落子后，返回该点
            return rPoint;
    
        while([self checkPoint:lPoint] && ![self isStepEmergent:lPoint Num:num type:type]){
            lPoint = [self leftDown:[self getNextPoint:lPoint] type:type num:num thre:threshold];//在左下向上寻找threshold连续且可以形成num连续的点
        }
        if([self isStepEmergent:lPoint Num:num type:type])// 在找到threshold连续的点并且两侧可以落子后，返回该点
            return lPoint;
    }
    // 都没有找到的话，返回一个不可用的点
    GobangPoint * invalid = [[GobangPoint alloc] init];
    return invalid;
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
        NSLog(@"type=%d,在(%d,%d)点落子可以形成%d连珠",(int) type,(int)solution.x, (int)solution.y,num);
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
        NSLog(@"type=%d,在(%d,%d)点落子可以形成%d连珠",(int) type,(int)solution.x, (int)solution.y,num);
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
        NSLog(@"type=%d,在(%d,%d)点落子可以形成%d连珠",(int) type,(int)solution.x, (int)solution.y,num);
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
        NSLog(@"type=%d,在(%d,%d)点落子可以形成%d连珠",(int) type,(int)solution.x, (int)solution.y,num);
        return solution;
    }
    // 否则以递归的方式向后一个点进行遍历
    return [self leftDown:[self getNextPoint:point] type:type num:num thre:threshold];
}

// 从左到右，从上往下获取下一个点
- (GobangPoint *)getNextPoint:(GobangPoint *)point {
    // 判断当前行有没有遍历完
    if(point.x + 1 < kBoardSize + 2) {
        // 没有遍历完，返回当前行的下一个点
        return [[GobangPoint alloc]initPointWithX:point.x + 1 y:point.y];
    }
    // 遍历完了，返回下一行的第一个点
    return [[GobangPoint alloc]initPointWithX:0 y:point.y+1];
}

@end

@implementation GobangAI

+ (GobangPoint *)geablog:(NSMutableArray *)board type:(OccupyType)type {
    GobangPoint *calibur = [[self class] SeraphTheGreat:board type:type];
    return calibur;
}

+ (GobangPoint *)SeraphTheGreat:(NSMutableArray *)board type:(OccupyType)type {
    // 初始化KWOmni
    KWOmni *omniknight;
    if(type == OccupyTypeUser) {
        // 初始化用户落子点阵（对手为AI）
        omniknight = [[KWOmni alloc] initWithArr:board opp:OccupyTypeAI my:OccupyTypeUser];
    } else {
        // 初始化AI落子点阵（对手为用户）
        omniknight = [[KWOmni alloc] initWithArr:board opp:OccupyTypeUser my:OccupyTypeAI];
    }
    GobangPoint *calibur = [omniknight nextStep:omniknight.myType num:5 thre:4 x:0 y:0];
    if([omniknight checkPoint:calibur]) {
        return calibur;
    }
    calibur = [omniknight nextStep:omniknight.oppoType num:5 thre:4 x:0 y:0];
    if ([omniknight checkPoint:calibur]) {
        return calibur;
    }
    calibur = [omniknight nextStep:omniknight.myType num:4 thre:3 x:0 y:0];
    if([omniknight checkPoint:calibur]) {
        return calibur;
    }
    calibur = [omniknight nextStep:omniknight.oppoType num:4 thre:3 x:0 y:0];
    if ([omniknight checkPoint:calibur]) {
        NSLog(@"对手形成4子连珠");
        return calibur;
    }
    calibur = [omniknight nextStep:omniknight.myType num:3 thre:2 x:0 y:0];
    if([omniknight checkPoint:calibur])
        return calibur;
    calibur = [omniknight nextStep:omniknight.myType num:2 thre:1 x:0 y:0];
    if([omniknight checkPoint:calibur])
        return calibur;
    calibur = [omniknight nextStep:omniknight.oppoType num:3 thre:2 x:0 y:0];
    if ([omniknight checkPoint:calibur]) {
        return calibur;
    }
    calibur = [omniknight nextStep:omniknight.oppoType num:2 thre:1 x:0 y:0];
    if ([omniknight checkPoint:calibur]) {
        return calibur;
    }
    //  如果什么都没有则返回不可用的点
    GobangPoint *sad = [[GobangPoint alloc] initPointWithX:(kBoardSize + 1) / 2 y:(kBoardSize + 1) /2];
    return sad;
}

@end
