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

typedef NS_ENUM(NSInteger, OccupyType) {
    OccupyTypeEmpty = 0,
    OccupyTypeUser,
    OccupyTypeAI ,
    OccupyTypeUnknown,
};

@interface KWPointData : NSObject

@property (nonatomic, strong) GobangPoint *p;
@property (nonatomic, assign) int count;

- (id)initWithPoint:(GobangPoint *)point count:(int)count;

@end

@interface KWOmni : NSObject

// 当前所有落子点的信息
@property (nonatomic, strong) NSMutableArray *curBoard;
// 代表用户的类型 用户下一步最有可能落子的地方
@property (nonatomic, assign) OccupyType oppoType;
// 代表AI的类型 下一步落子最优的
@property (nonatomic, assign) OccupyType myType;

- (id)initWithArr:(NSMutableArray *)arr opp:(OccupyType)opp my:(OccupyType)my;
// xType类型下从pp点开始寻找num连珠
- (BOOL)isStepEmergent:(GobangPoint *)pp Num:(int)num type:(OccupyType)xType;

@end

@interface GobangAI : NSObject

+ (GobangPoint *)geablog:(NSMutableArray *)board type:(OccupyType)type;
+ (GobangPoint *)SeraphTheGreat:(NSMutableArray *)board type:(OccupyType)type;

@end

NS_ASSUME_NONNULL_END
