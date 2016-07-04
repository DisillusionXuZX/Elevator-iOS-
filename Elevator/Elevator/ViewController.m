//
//  ViewController.m
//  Question
//
//  Created by xuzx on 16/6/25.
//  Copyright © 2016年 xuzx. All rights reserved.
///Users/xuzx/Downloads/LiftTest/LiftTest/Base.lproj/Main.storyboard

#import "ViewController.h"
#import "ElevatorView.h"

@interface ViewController ()
//当前电梯所在层数
@property (atomic, assign)NSInteger levelNum;
//存储上行方向需要到达的楼层的数组
@property (atomic, strong)NSMutableArray *upLevelArray;
//存储下行方向需要到达的楼层的数组
@property (atomic, strong)NSMutableArray *downLevelArray;
//当前电梯的状态
@property (atomic, assign)ElevatorStatus status;
//存储每一层电梯的view的数组
@property (nonatomic, strong)NSMutableArray *elevatorViewArray;
//定时器
@property (nonatomic, strong)NSTimer *timer;
//存储当前电梯运行方向(上行、下行、停止)
@property (atomic, assign)Direction direction;
//判断电梯是否需要重置时间
@property (atomic, assign)BOOL resetTime;

@end

@implementation ViewController

- (NSMutableArray *)elevatorViewArray{
    if(_elevatorViewArray == nil){
        _elevatorViewArray = [NSMutableArray array];
    }
    return _elevatorViewArray;
}

//点击电梯内的开关键
- (IBAction)openOrCloseDoor:(id)sender {
    ElevatorView *currentElevatorView = (ElevatorView *)self.elevatorViewArray[LevelCount - self.levelNum - 1];
    ElevatorView *upElevatorView = nil;
    ElevatorView *bottomElevatorView = nil;
    if(LevelCount - self.levelNum - 2 >= 0){
        upElevatorView = (ElevatorView *)self.elevatorViewArray[LevelCount - self.levelNum - 2];
    }
    if(self.levelNum > 0){
        bottomElevatorView = (ElevatorView *)self.elevatorViewArray[LevelCount - self.levelNum];
    }
    UIButton *button = (UIButton *)sender;
    BOOL open = (button.tag == 1);
    switch (self.status) {
        case Up:
            
            break;
            
        case Down:
            
            break;
            
        case Stopping:
            if(open){
                self.status = OpenningDoor;
            }
            break;
            
        case OpenningDoor:
            if(open){
                //重新计时，状态不变
                self.resetTime = YES;
                self.status = OpenningDoor;
                [currentElevatorView doorOpen];
            }
            
            break;
            
        case Waiting:
            if(open){
                //重新计时，状态变为Openning
                self.resetTime = YES;
                self.status = OpenningDoor;
                [currentElevatorView doorOpen];
            }else{
                self.status = ClosingDoor;
                //开启关门动画
                [currentElevatorView doorClose];
            }
            
            break;
            
        case ClosingDoor:
            if(open){
                //重新计时，状态变为Openning，开启开门动画
                [currentElevatorView doorOpen];
                self.resetTime = YES;
                self.status = OpenningDoor;
            }
            
            break;
            
        default:
            break;
    }
    
}

//点击电梯内的楼层数
- (IBAction)numberOfElevator:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = YES;
    NSInteger levelNumber = button.tag % 9;
    if(levelNumber >= self.levelNum){
        [self elevatorRun:levelNumber inside:YES up:YES];
    }
    else{
        [self elevatorRun:levelNumber inside:YES up:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化self.upLevelArray
    self.upLevelArray = [NSMutableArray array];
    //初始化self.downLevelArray
    self.downLevelArray = [NSMutableArray array];
    //初始电梯停的层数为0
    self.levelNum = 0;
    //初始电梯状态为停止状态
    self.status = Stopping;
    //初始方向为停止
    self.direction = Stop;
    //设置重置时间为否
    self.resetTime = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"up" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"down" object:nil];
    
    
    
    //添加NSTimer
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(notifyElevatorChanged) userInfo:nil repeats:YES];
    self.timer = timer;

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    //添加View
    [self setupUpView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

//点击各楼层的上下按钮调用的方法
- (void)receiveNotification:(NSNotification *)notification{
    NSString *string = notification.userInfo[@"tag"];
    UIButton *button = notification.userInfo[@"button"];
    button.selected = YES;
    NSInteger tag = 8 - [string integerValue] % 9;
    if(tag > self.levelNum){
        [self elevatorRun:tag inside:NO up:YES];
    }else{
        [self elevatorRun:tag inside:NO up:NO];
    }
}

//点击楼层数按钮调用的方法
- (void)elevatorRun:(NSInteger)levelNum inside:(BOOL)inside up:(BOOL)up{
    NSInteger levelNumber = levelNum % 9;
    switch (self.status) {
        case Up:
                if(up){
                    [self.upLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }else{
                    [self.downLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }
            break;
            
        case Down:
                if(up){
                    [self.upLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }else{
                    [self.downLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }
            break;
            
        case Stopping:
            if(self.levelNum == levelNumber){
                if(inside){
                    [self cancelSelectedWithLevelNumber:levelNumber];
                    break;
                }
                self.status = OpenningDoor;
            }else{
                if(up){
                    [self.upLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }else{
                    [self.downLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }
            }
            break;
            
        case OpenningDoor:
            if(self.levelNum == levelNumber){
                if(inside){
                    break;
                }else{
                    //重置开门时间，status不变
                    self.resetTime = YES;
                    self.status = OpenningDoor;
                }
            }else{
                if(up){
                    [self.upLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }else{
                    [self.downLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }
            }
            break;
            
        case Waiting:
            if(self.levelNum == levelNumber){
                if(inside){
                    break;
                }else{
                    //重置开门时间，status变为Openning
                    self.resetTime = YES;
                    self.status = OpenningDoor;
                }
            }else{
                if(up){
                    [self.upLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }else{
                    [self.downLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }
            }
            break;
            
        case ClosingDoor:
            if(self.levelNum == levelNumber){
                if(inside){
                    break;
                }else{
                    //重置开门时间，status变为Openning
                    self.resetTime = YES;
                    self.status = OpenningDoor;
                    
                }
            }else{
                if(up){
                    [self.upLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }else{
                    [self.downLevelArray addObjectWithoutDuplicated:[NSString stringWithFormat:@"%ld", levelNumber]];
                }
            }
            break;
            
        default:
            break;
    }
}


//通知电梯响应的方法
- (void)notifyElevatorChanged{
    if(self.elevatorViewArray.count == 0){
        self.status = Stopping;
        self.direction = Stop;
        return;
    }
    [self checkWrongState];
    ElevatorView *currentElevatorView = (ElevatorView *)self.elevatorViewArray[LevelCount - self.levelNum - 1];
    ElevatorView *upElevatorView = nil;
    ElevatorView *bottomElevatorView = nil;
    if(LevelCount - self.levelNum - 2 >= 0){
        upElevatorView = (ElevatorView *)self.elevatorViewArray[LevelCount - self.levelNum - 2];
    }
    if(self.levelNum > 0){
        bottomElevatorView = (ElevatorView *)self.elevatorViewArray[LevelCount - self.levelNum];
    }
    switch (self.status) {
        case Up:
            currentElevatorView.elevatorView.hidden = YES;
            currentElevatorView.door.hidden = YES;
            self.levelNum ++;
            if([self.upLevelArray containsObject:[NSString stringWithFormat:@"%ld", self.levelNum]]){
                self.status = OpenningDoor;
                [self.upLevelArray removeObject:[NSString stringWithFormat:@"%ld", self.levelNum]];
            }
            upElevatorView.elevatorView.hidden = NO;
            upElevatorView.door.hidden = NO;
            
            break;
            
        case Down:
            currentElevatorView.elevatorView.hidden = YES;
            currentElevatorView.door.hidden = YES;
            self.levelNum --;
            if([self.downLevelArray containsObject:[NSString stringWithFormat:@"%ld", self.levelNum]]){
                self.status = OpenningDoor;
                [self.downLevelArray removeObject:[NSString stringWithFormat:@"%ld", self.levelNum]];
            }
            bottomElevatorView.elevatorView.hidden = NO;
            bottomElevatorView.door.hidden = NO;
            
            break;
            
        case Stopping:
            if (([self getMaxNumInArray:self.upLevelArray] < self.levelNum) || ([self getMaxNumInArray:self.downLevelArray] < self.levelNum)) {
                self.status = Down;
                self.direction = Downward;
            }else if(([self getMinNumInArray:self.upLevelArray] > self.levelNum) || ([self getMinNumInArray:self.downLevelArray] > self.levelNum)){
                self.status = Up;
                self.direction = Upward;
            }
            break;
            
        case OpenningDoor:
            [self cancelSelectedWithLevelNumber:self.levelNum];
            if (self.resetTime) {
                self.status = OpenningDoor;
                self.resetTime = NO;
                break;
            }
            [currentElevatorView doorOpen];
            if(self.direction == Upward){
                if((self.upLevelArray.count == 0) && ((([self getMaxNumInArray:self.downLevelArray] < self.levelNum)) && (self.downLevelArray.count > 0))){
                    self.direction = Downward;
                }else if((self.upLevelArray.count == 0) && (self.downLevelArray.count == 0)){
                    self.direction = Stop;
                }else{
                    self.direction = Upward;
                }
            }else if(self.direction == Downward){
                if((([self getMinNumInArray:self.upLevelArray] > self.levelNum) && (self.upLevelArray.count > 0)) && (self.downLevelArray.count == 0)){
                    self.direction = Upward;
                }else if((self.upLevelArray.count == 0) && (self.downLevelArray.count == 0)){
                    self.direction = Stop;
                }else{
                    self.direction = Downward;
                }
            }
            self.status = Waiting;
            break;
            
        case Waiting:
            self.status = ClosingDoor;
            
            break;
            
        case ClosingDoor:
            [currentElevatorView doorClose];
            if (self.direction == Upward) {
                self.status = Up;
            }else if(self.direction == Downward){
                self.status = Down;
            }else{
                self.status = Stopping;
            }
            break;
            
        default:
            break;
    }
}

- (NSInteger)getMaxNumInArray:(NSMutableArray *)array{
    if(array.count == 0){
        return self.levelNum;
    }
    NSInteger max = [(NSString *)array[0] integerValue];
    for (NSString *num in array) {
        if([num integerValue] > max){
            max = [num integerValue];
        }
    }
    return max;
}

- (NSInteger)getMinNumInArray:(NSMutableArray *)array{
    if(array.count == 0){
        return self.levelNum;
    }
    NSInteger min = [(NSString *)array[0] integerValue];
    for (NSString *num in array) {
        if([num integerValue] < min){
            min = [num integerValue];
        }
    }
    return min;
}

//添加View的方法:
//添加上部分的View
- (void)setupUpView{
    CGFloat originY = 20;
    
    for (int i = 0; i < LevelCount; i++) {
        ElevatorView *view = [[ElevatorView alloc] initWithFrame:CGRectMake(0, (originY + (i * 40.0)), [UIScreen mainScreen].bounds.size.width, 40)];
        if(i == 0){
            view.upButton.hidden = YES;
        }
        if(i == LevelCount - 1){
            view.downButton.hidden = YES;
        }
        if(i != LevelCount - 1){
            view.elevatorView.hidden = YES;
            view.door.hidden = YES;
        }
        view.tag = i + 9;
        [self.view addSubview:view];
        [self.elevatorViewArray addObject:view];
    }
}

//获取每层电梯的数字按钮的view，取消选中状态
- (void)cancelSelectedWithLevelNumber:(NSInteger)levelNumber{
    ElevatorView *levelView = (ElevatorView *)[self.view viewWithTag:(17 - levelNumber)];
    UIButton *insideButton = (UIButton *)[self.view viewWithTag:(18 + levelNumber)];
    if (levelView.upButton.selected == YES) {
        levelView.upButton.selected = NO;
    }
    if (levelView.downButton.selected == YES) {
        levelView.downButton.selected = NO;
    }
    if (insideButton.selected == YES) {
        insideButton.selected = NO;
    }
}

//由于操作问题可能导致错误情况发生(比如上行数组中的最大元素却小于当前楼层数)，所以要修正
- (void)checkWrongState{
    if((self.upLevelArray.count > 0) && ([self getMaxNumInArray:self.upLevelArray] < self.levelNum)){
        for (NSString *str in self.upLevelArray) {
            [self.downLevelArray addObjectWithoutDuplicated:str];
        }
        [self.upLevelArray removeAllObjects];
    }
    if((self.downLevelArray.count > 0) && ([self getMinNumInArray:self.downLevelArray] > self.levelNum)){
        for (NSString *str in self.downLevelArray) {
            [self.upLevelArray addObjectWithoutDuplicated:str];
        }
        [self.downLevelArray removeAllObjects];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
