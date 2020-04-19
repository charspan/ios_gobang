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

@interface KWPointData : NSObject

@property (nonatomic, strong) GobangPoint *p;
@property (nonatomic, assign) int count;

- (id)initWithPoint:(GobangPoint *)point count:(int)count;

@end

@interface KWOmni : NSObject

// 当前所有落子点的信息（用户点，AI点，空点）
@property (nonatomic, strong) NSMutableArray *curBoard;
// 用户类型（用户角度进行思考）
@property (nonatomic, assign) OccupyType oppoType;
// AI类型（AI角度进行思考）
@property (nonatomic, assign) OccupyType myType;

- (id)initWithArr:(NSMutableArray *)arr opp:(OccupyType)opp my:(OccupyType)my;
// 从xType类型进行思考：从pp点开始上下左右寻找是否存在一个空点，落子后形成num连珠
- (BOOL)isStepEmergent:(GobangPoint *)pp Num:(int)num type:(OccupyType)xType;

@end

@interface GobangAI : NSObject

+ (GobangPoint *)geablog:(NSMutableArray *)board type:(OccupyType)type;
+ (GobangPoint *)SeraphTheGreat:(NSMutableArray *)board type:(OccupyType)type;

@end

NS_ASSUME_NONNULL_END
