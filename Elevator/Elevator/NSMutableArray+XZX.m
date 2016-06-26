//
//  NSMutableArray+XZX.m
//  Question
//
//  Created by xuzx on 16/6/25.
//  Copyright © 2016年 xuzx. All rights reserved.
//

#import "NSMutableArray+XZX.h"

@implementation NSMutableArray (XZX)

- (void)addObjectWithoutDuplicated:(id)anObject{
    if(![self containsObject:anObject]){
        [self addObject:anObject];
    }
}

@end
