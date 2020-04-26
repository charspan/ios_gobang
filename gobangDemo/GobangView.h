//
//  GobangView.h
//  gobangDemo
//
//  Created by 志良潘 on 2020/4/14.
//  Copyright © 2020 志良潘. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GobangView : UIView

// 定义一个属性字符串
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
