//
//  GobangPoint.h
//  gobangDemo
//
//  Created by 志良潘 on 2020/4/16.
//  Copyright © 2020 志良潘. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 定义落子的位置
@interface GobangPoint : NSObject

// 落子横坐标
@property (nonatomic, assign) NSInteger x;
// 落子纵坐标
@property (nonatomic, assign) NSInteger y;

- (id)initPointWithX:(NSInteger)x y:(NSInteger)y;

@end

NS_ASSUME_NONNULL_END
