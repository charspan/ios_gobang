//
//  GobangAI.h
//  gobangDemo
//
//  Created by 志良潘 on 2020/4/15.
//  Copyright © 2020 志良潘. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GobangPoint.h"

NS_ASSUME_NONNULL_BEGIN

// 枚举棋盘落子类型
typedef NS_ENUM(NSInteger, OccupyType) {
    OccupyTypeEmpty = 0, // 空点
    OccupyTypeUser, // 用户点
    OccupyTypeAI , // AI点
    OccupyTypeUnknown // 未知点
};

@interface Robot : NSObject

// 当前所有落子点的信息（用户点，AI点，空点）
@property (nonatomic, strong) NSMutableArray *curBoard;
// 用户类型（用户角度进行思考）
@property (nonatomic, assign) OccupyType oppoType;
// AI类型（AI角度进行思考）
@property (nonatomic, assign) OccupyType myType;
// 初始化机器人，传入棋盘数据
- (id)initWithArr:(NSMutableArray *)places;
// 从xType类型进行思考：从pp点开始上下左右寻找是否存在一个空点，落子后形成num连珠
- (BOOL)isStepEmergent:(GobangPoint *)pp Num:(int)num type:(OccupyType)xType;

@end

@interface GobangAI : NSObject

// 寻找AI的最优落子点
+ (GobangPoint *)searchBestPoint:(NSMutableArray *)places;

@end

NS_ASSUME_NONNULL_END
