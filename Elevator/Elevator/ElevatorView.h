//
//  ElevatorView.h
//  Question
//
//  Created by xuzx on 16/6/25.
//  Copyright © 2016年 xuzx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ElevatorView : UIView

@property (nonatomic, strong)UIButton *upButton;

@property (nonatomic, strong)UIButton *downButton;

@property (nonatomic, strong)UIView *door;

@property (nonatomic, strong)UIView *elevatorView;

- (void)doorOpen;

- (void)doorClose;

@end
