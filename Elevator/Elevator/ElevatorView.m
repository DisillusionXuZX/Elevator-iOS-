//
//  ElevatorView.m
//  Question
//
//  Created by xuzx on 16/6/25.
//  Copyright © 2016年 xuzx. All rights reserved.
//

#import "ElevatorView.h"

@implementation ElevatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //添加向上的按钮
        UIButton *upButton = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect upButtonFrame = CGRectMake(frame.origin.x, 0, frame.size.width * 0.2, frame.size.height);
        upButton.frame = upButtonFrame;
        [upButton setTitle:@"向上" forState:UIControlStateNormal];
        [upButton addTarget:self action:@selector(touchUpButton:) forControlEvents:UIControlEventTouchUpInside];
        
        //添加向下的按钮
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect downButtonFrame = CGRectMake(frame.size.width * 0.8, 0, frame.size.width * 0.2, frame.size.height);
        downButton.frame = downButtonFrame;
        [downButton setTitle:@"向下" forState:UIControlStateNormal];
        [downButton addTarget:self action:@selector(touchDownButton:) forControlEvents:UIControlEventTouchUpInside];
        
        //添加电梯view
        UIView *elevatorView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width * 0.3, 0, frame.size.width * 0.4, frame.size.height)];
        elevatorView.backgroundColor = [UIColor blueColor];
        
        //添加电梯门view
        UIView *door = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width * 0.475, 0, frame.size.width * 0.05, frame.size.height)];
        door.backgroundColor = [UIColor blackColor];
        
        self.upButton = upButton;
        self.downButton = downButton;
        self.elevatorView = elevatorView;
        self.door = door;
        
        [self addSubview:self.upButton];
        [self addSubview:self.downButton];
        [self addSubview:self.elevatorView];
        [self addSubview:self.door];
    }
    return self;
}

- (void)touchUpButton:(UIButton *)button{
    NSString *tag = [NSString stringWithFormat:@"%ld", self.tag];
    NSDictionary *dict = @{@"tag":tag, @"button":button};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"up" object:self userInfo:dict];
}

- (void)touchDownButton:(UIButton *)button{
    NSString *tag = [NSString stringWithFormat:@"%ld", self.tag];
    NSDictionary *dict = @{@"tag":tag, @"button":button};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"down" object:self userInfo:dict];
}

- (void)doorOpen{
    [self.layer removeAllAnimations];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.door.frame = CGRectMake(self.frame.size.width * 0.3, 0, self.frame.size.width * 0.4, self.frame.size.height);
    }];
    
}

- (void)doorClose{
    [self.layer removeAllAnimations];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.door.frame = CGRectMake(self.frame.size.width * 0.475, 0, self.frame.size.width * 0.05, self.frame.size.height);
    }];
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
