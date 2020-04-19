//
//  GobangPoint.m
//  gobangDemo
//
//  Created by 志良潘 on 2020/4/16.
//  Copyright © 2020 志良潘. All rights reserved.
//

#import "GobangPoint.h"

@implementation GobangPoint

- (id)initPointWithX:(NSInteger)x y:(NSInteger)y {
    self = [self init];
    if (self) {
        self.x = x;
        self.y = y;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.x = -1;
        self.y = -1;
    }
    return self;
}

@end
