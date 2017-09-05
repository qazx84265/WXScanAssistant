//
//  WSAMsgSendManager.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/5.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAMsgSendManager.h"
#import "WaveView.h"

//NSString* const WSASendStatusShowNotification = @"wsa.send.show.noti";
//NSString* const WSASendStatusHideNotification = @"wsa.send.hide.noti";

#define Y1               120
#define Y2               (kSCREEN_HEIGHT - 250)
#define Y3               (kSCREEN_HEIGHT - kSendStatusButtonHeight)

@interface WSAMsgSendManager() <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate> {
    BOOL _mIsMessageSending;
    NSUInteger _mMediaCount;
}
@property (nonatomic, strong) NSMutableArray<WSAWechatUserModel*>* users; //扫码用户

@property (nonatomic, strong) NSMutableArray<WSAMessageTargetModel*>* userWaitForSending;//待推送用户，推送完毕，移除

@property (nonatomic, strong) NSMutableArray<WSAMessageTargetModel*>* userSendComplete; //已推送用户，保存最近100条记录
@property (nonatomic, assign) NSUInteger totalUsersToSend; //推送总人数
@property (nonatomic, assign) NSUInteger usersHaveSend;//已推送人数

@property (nonatomic, strong) WaveView* sendingProgressView;
@property (nonatomic, strong) UILabel* sendingStatusLabel;
@property (nonatomic, strong) UITableView* sendingRecordTableView;
@property (nonatomic, strong) UIView* shadowView;
@property (nonatomic, assign) CGFloat offsetY;
@end


@implementation WSAMsgSendManager

- (instancetype)init {
    if (self = [super init]) {
        self.isSendToMale = NO;
        self.isSendToFemale = NO;
        self.isSendToGroup = NO;
        
        _mIsMessageSending = NO;
        _mMediaCount = 0;
    }
    return self;
}

+ (instancetype)defaultManager {
    static dispatch_once_t once;
    static WSAMsgSendManager* ins = nil;
    
    dispatch_once(&once, ^{
        ins = [[WSAMsgSendManager alloc] init];
    });
    
    return ins;
}

- (NSMutableArray<WSAWechatUserModel*>*)users {
    if (!_users) {
        _users = [NSMutableArray new];
    }
    return _users;
}

- (NSMutableArray<WSAMessageTargetModel*>*)userWaitForSending {
    if (!_userWaitForSending) {
        _userWaitForSending = [NSMutableArray new];
    }
    return _userWaitForSending;
}

- (NSMutableArray<WSAMessageTargetModel*>*)userSendComplete {
    if (!_userSendComplete) {
        _userSendComplete = [NSMutableArray new];
//        WSAMessageTargetModel* t1 = [[WSAMessageTargetModel alloc] init];
//        t1.targetNickname = @"好久不见";
//        t1.sendingResult = YES;
//        [_userSendComplete addObject:t1];
//        
//        WSAMessageTargetModel* t2 = [[WSAMessageTargetModel alloc] init];
//        t2.targetNickname = @"Cos";
//        t2.sendingResult = YES;
//        [_userSendComplete addObject:t2];
//        
//        WSAMessageTargetModel* t3 = [[WSAMessageTargetModel alloc] init];
//        t3.targetNickname = @"老司机";
//        t3.sendingResult = NO;
//        t3.sendingErrorDesc = @"用户已取消授权";
//        [_userSendComplete addObject:t3];
//        
//        WSAMessageTargetModel* t4 = [[WSAMessageTargetModel alloc] init];
//        t4.targetNickname = @"纯美个护";
//        t4.sendingResult = YES;
//        [_userSendComplete addObject:t4];
//        
//        WSAMessageTargetModel* t5 = [[WSAMessageTargetModel alloc] init];
//        t5.targetNickname = @"社会你大哥";
//        t5.sendingResult = YES;
//        [_userSendComplete addObject:t5];
//        
//        WSAMessageTargetModel* t6 = [[WSAMessageTargetModel alloc] init];
//        t6.targetNickname = @"forever";
//        t6.sendingResult = YES;
//        [_userSendComplete addObject:t6];
    }
    return _userSendComplete;
}


- (UITableView *)sendingRecordTableView {
    if (!_sendingRecordTableView) {
        _sendingRecordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-50) style:UITableViewStylePlain];
        _sendingRecordTableView.delegate = self;
        _sendingRecordTableView.dataSource = self;
        _sendingRecordTableView.bounces = NO;
        _sendingRecordTableView.backgroundColor = [UIColor ColorWithHexString:@"#FFFAFA"];
        _sendingRecordTableView.userInteractionEnabled = YES;
        _sendingRecordTableView.scrollEnabled = NO; // 让table默认禁止滚动
        _sendingRecordTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _sendingRecordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UISwipeGestureRecognizer* swipe1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipe1.direction = UISwipeGestureRecognizerDirectionDown ; // 设置手势方向
        swipe1.delegate = self;
        [_sendingRecordTableView addGestureRecognizer:swipe1];
        
        UISwipeGestureRecognizer *swipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipe2.direction = UISwipeGestureRecognizerDirectionUp; // 设置手势方向
        swipe2.delegate = self;
        [_sendingRecordTableView addGestureRecognizer:swipe2];
    }
    return _sendingRecordTableView;
}

-(UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [UIColor clearColor];
        _shadowView.frame = CGRectMake(0, kSCREEN_HEIGHT-kSendStatusButtonHeight, kSCREEN_WIDTH, kSCREEN_HEIGHT);
        _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowView.layer.shadowRadius = 10;
        _shadowView.layer.shadowOffset = CGSizeMake(5, 5);
        _shadowView.layer.shadowOpacity = 0.8;
        
    }
    return _shadowView;
}

- (UILabel*)sendingStatusLabel {
    if (!_sendingStatusLabel) {
        _sendingStatusLabel = [[UILabel alloc] init];
        _sendingStatusLabel.textAlignment = NSTextAlignmentCenter;
        _sendingStatusLabel.textColor = [UIColor darkTextColor];
        _sendingStatusLabel.font = [UIFont systemFontOfSize:14.0f];
        _sendingStatusLabel.backgroundColor = [UIColor clearColor];
        _sendingStatusLabel.text = @"推送进度，上拉查看详情";
    }
    return _sendingStatusLabel;
}

- (WaveView*)sendingProgressView {
    if (!_sendingProgressView) {
        _sendingProgressView = [[WaveView alloc] init];
//        _sendingProgressView.firsetWaveColor = [UIColor RandomColor];
//        _sendingProgressView.secondWaveColor = [UIColor RandomColor];
        _sendingProgressView.waveCycle = NO;
        _sendingProgressView.waveViewType = WaveViewTypeRight;
        _sendingProgressView.isDouble = YES;
        _sendingProgressView.waveAmplitude = 5;
    }
    return _sendingProgressView;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userSendComplete.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;  // 去掉选中效果
    
    WSAMessageTargetModel* target = [self.userSendComplete objectAtIndex:indexPath.row];
    cell.textLabel.text = target.targetNickname;
    cell.detailTextLabel.text = target.sendingResult ? @"发送成功" : [NSString stringWithFormat:@"发送失败-%@", target.sendingErrorDesc];
    cell.detailTextLabel.textColor = target.sendingResult ? [UIColor colorWithRed:99 / 256.0 green:229 / 256.0 blue:189 / 256.0 alpha:1] : [UIColor ColorWithHexString:@"#FA8072"];
    
    
    return cell;
}


// ************************
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSendStatusButtonHeight)];
//    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:backgroundView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
//    CAShapeLayer* slayer = [CAShapeLayer layer];
//    slayer.path = path.CGPath;
//    backgroundView.layer.mask = slayer;
    backgroundView.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake((kSCREEN_WIDTH-40)/2.0, 5, 40, 10);
    line.backgroundColor = RGB(205, 205, 205);
    line.layer.cornerRadius = line.height/2;
    line.clipsToBounds = YES;
    [backgroundView addSubview:line];
    
    self.sendingStatusLabel.frame = CGRectMake(0, 16, kSCREEN_WIDTH, 30);
    [backgroundView addSubview:self.sendingStatusLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kSendStatusButtonHeight-2, kSCREEN_WIDTH, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.alpha = 0.5;
    [backgroundView addSubview:lineView];
    
//    self.sendingProgressView.frame = CGRectMake(0, 0, 300, kSendStatusButtonHeight);
//    [backgroundView insertSubview:self.sendingProgressView atIndex:0];
    
    return backgroundView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSendStatusButtonHeight;
}


#pragma mark -- ges
// table可滑动时，swipe默认不再响应 所以要打开
- (void)swipe:(UISwipeGestureRecognizer *)swipe {
    float stopY = 0;     // 停留的位置
    float animateY = 0;  // 做弹性动画的Y
    float margin = 10;   // 动画的幅度
    float offsetY = self.shadowView.frame.origin.y; // 这是上一次Y的位置
    //    NSLog(@"==== === %f == =====",self.vc.table.contentOffset.y);
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        // 当vc.table滑到头 且是下滑时，让vc.table禁止滑动
        if (self.sendingRecordTableView.contentOffset.y == 0) {
            self.sendingRecordTableView.scrollEnabled = NO;
        }
        
        if (offsetY >= Y1 && offsetY < Y2) {
            // 停在y2的位置
            stopY = Y2;
        }else if (offsetY >= Y2 ){
            // 停在y3的位置
            stopY = Y3;
        }else{
            stopY = Y1;
        }
        animateY = stopY + margin;
    }
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        //        NSLog(@"==== up =====");
        
        if (offsetY <= Y2) {
            // 停在y1的位置
            stopY = Y1;
            // 当停在Y1位置 且是上划时，让vc.table不再禁止滑动
            self.sendingRecordTableView.scrollEnabled = YES;
        }else if (offsetY > Y2 && offsetY <= Y3 ){
            // 停在y2的位置
            stopY = Y2;
        }else{
            stopY = Y3;
        }
        animateY = stopY - margin;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.shadowView.frame = CGRectMake(0, animateY, kSCREEN_WIDTH, kSCREEN_HEIGHT);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.shadowView.frame = CGRectMake(0, stopY, kSCREEN_WIDTH, kSCREEN_HEIGHT);
            self.sendingRecordTableView.frame = self.shadowView.bounds;
        }];
    }];
    
    // 记录shadowView在第一个视图中的位置
    self.offsetY = stopY;
}

/**
 返回值为NO  swipe不响应手势 table响应手势
 返回值为YES swipe、table也会响应手势, 但是把table的scrollEnabled为No就不会响应table了
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    // 当table Enabled且offsetY不为0时，让swipe响应
    if (self.sendingRecordTableView.scrollEnabled == YES && self.sendingRecordTableView.contentOffset.y != 0) {
        return NO;
    }
    if (self.sendingRecordTableView.scrollEnabled == YES) {
        return YES;
    }
    return NO;
}


- (BOOL)isSending {
    return _mIsMessageSending;
}

- (NSUInteger)media_count {
    return ++_mMediaCount;
}

#pragma mark -- action


#pragma mark -- msg
- (void)insertUser:(WSAWechatUserModel *)user {
    if (!user) {
        return;
    }
    
    @synchronized (self.users) {
        [self.users addObject:user];
    }
    
    [self startSendMessageToUser:user];
}

- (void)startSendMessageToUser:(WSAWechatUserModel*)user {
    
    dispatch_group_t group = dispatch_group_create();
    //__block WSAWechatUserModel* blockUser = user;
    
    weak(self);
    if (self.isSendToMale || self.isSendToFemale) {
        //-- 获取用户联系人
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NetworkHelper getWechatContactsForUser:user completeHandler:^(NSArray<WSAMessageTargetModel *> *contacts, NSError *error) {
                if (contacts && !error) {
                    strong(self);
                    @synchronized (strongself.users) {
                        for (WSAWechatUserModel* u in strongself.users) {
                            if (![u.username isEqualToString:user.username]) {
                                continue;
                            }
                            
                            NSUInteger limit = [WSAIapVC limitForVersion:[USER_DEFAULT integerForKey:kIAPPurchaseedKey]];
                            NSMutableArray* marr = [NSMutableArray arrayWithArray:u.contacts];
                            for (WSAMessageTargetModel* tg in contacts) {
                                if (marr.count >= limit) {
                                    break;
                                }
                                
                                BOOL exist = NO;
                                for (WSAMessageTargetModel* tt in u.contacts) {
                                    if ([tt.targetUsername isEqualToString:tg.targetUsername]) {
                                        exist = YES;
                                        return ;
                                    }
                                }
                                if (!exist) {
                                    [marr addObject:tg];
                                }
                            }
                            u.contacts = [NSArray arrayWithArray:marr];
                            
                            strongself.totalUsersToSend += u.contacts.count;
                        }
                    }
                }
                dispatch_group_leave(group);
            }];
        });
    }
    
//    if (self.isSendToGroup) {
//        //-- 获取群组
//        dispatch_group_enter(group);
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [NetworkHelper getWechatGroupForUser:user synckey:user.syncKey completeHandler:^(NSArray<WSAMessageTargetModel *> *contacts, id syncKey, NSError *error) {
//                if (contacts && !error) {
//                    strong(self);
//                    @synchronized (strongself.users) {
//                        for (WSAWechatUserModel* u in strongself.users) {
//                            if (![u.username isEqualToString:user.username]) {
//                                continue;
//                            }
//                            
//                            NSMutableArray* marr = [NSMutableArray arrayWithArray:u.contacts];
//                            for (WSAMessageTargetModel* tg in contacts) {
//                                BOOL exist = NO;
//                                for (WSAMessageTargetModel* tt in u.contacts) {
//                                    if ([tt.targetUsername isEqualToString:tg.targetUsername]) {
//                                        exist = YES;
//                                        return ;
//                                    }
//                                }
//                                if (!exist) {
//                                    [marr addObject:tg];
//                                }
//                            }
//                            u.contacts = [NSArray arrayWithArray:marr];
//                        }
//                    }
//                }
//                
//                if (syncKey) {
//                    [NetworkHelper getWechatGroupForUser:user synckey:syncKey completeHandler:^(NSArray<WSAMessageTargetModel *> *contacts, id syncKey, NSError *error) {
//                        if (contacts && !error) {
//                            strong(self);
//                            @synchronized (strongself.users) {
//                                for (WSAWechatUserModel* u in strongself.users) {
//                                    if (![u.username isEqualToString:user.username]) {
//                                        continue;
//                                    }
//                                    
//                                    NSMutableArray* marr = [NSMutableArray arrayWithArray:u.contacts];
//                                    for (WSAMessageTargetModel* tg in contacts) {
//                                        BOOL exist = NO;
//                                        for (WSAMessageTargetModel* tt in u.contacts) {
//                                            if ([tt.targetUsername isEqualToString:tg.targetUsername]) {
//                                                exist = YES;
//                                                return ;
//                                            }
//                                        }
//                                        if (!exist) {
//                                            [marr addObject:tg];
//                                        }
//                                    }
//                                    u.contacts = [NSArray arrayWithArray:marr];
//                                }
//                            }
//                        }
//                        
//                        dispatch_group_leave(group);
//                    }];
//                }
//                //dispatch_group_leave(group);
//            }];
//        });
//    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
//        NSInteger total = 0;
//        NSInteger person = 0;
//        NSInteger group = 0;
        strong(self);
        
        //NSLog(@"-------->>>>>>>>>>>> 共有%zd个联系人，其中个人好友%zd，群组%zd", total, person, group);
        
        if (strongself.users.count > 0) {
            [self showStatusOnWindow];
        }
        
        for (WSAWechatUserModel* u in strongself.users) {
            if (![u.username isEqualToString:user.username]) {
                continue;
            }
            
//            total = u.contacts.count;
            for (WSAMessageTargetModel* tt in u.contacts) {
//                if (tt.targetType == MessageTarget_person) {
//                    person += 1;
//                }
//                else {
//                    group += 1;
//                }
                
                //-- 发送文本信息
                [NetworkHelper sendMessage:self.messageToSend toUser:tt fromUser:u completeHandler:^(WSAMessageTargetModel *toUser, WSAWechatUserModel *fromUser, NSError *error) {
                    strong(self);
                    
                    if (error) {
                        NSLog(@"---------->>>>>>>>>>>>> message send error: %@", error);
                        toUser.sendingResult = NO;
                        toUser.sendingErrorDesc = [error localizedDescription];
                    }
                    else {
                        NSLog(@"---------->>>>>>>>>>>>> message send success");
                        toUser.sendingResult = YES;
                    }
                    
                    @synchronized (strongself.userSendComplete) {
                        if (strongself.userSendComplete.count >= 100) {
                            [strongself.userSendComplete removeObjectAtIndex:0];
                        }
                        [strongself.userSendComplete addObject:toUser];
                    }
                    strongself.usersHaveSend += 1;
                    [strongself updateStatusLabel];
                    
                    
                    NSMutableArray* marr = [NSMutableArray arrayWithArray:fromUser.contacts];
                    for (WSAMessageTargetModel* tg in marr) {
                        if ([tg.targetUsername isEqualToString:toUser.targetUsername]) {
                            [marr removeObject:tg];
                            break;
                        }
                    }
                    @synchronized (fromUser.contacts) {
                        fromUser.contacts = [NSArray arrayWithArray:marr];
                        if (fromUser.contacts.count == 0) {
                            NSLog(@"-------_>>>>>>>>>> user: %@ send done", fromUser.username);
                            @synchronized (strongself.users) {
                                [strongself.users removeObject:fromUser];
                                if (strongself.users.count == 0) {
                                    NSLog(@"-------_>>>>>>>>>> all send done");
                                    //[strongself hideStatusView];
                                }
                            }
                        }
                    }
                }];
                
                //-- 发送图片信息
                if (self.imageToSend) {
                    [NetworkHelper sendImage:self.imageToSend toUser:tt fromUser:u completeHandler:^(WSAMessageTargetModel *toUser, WSAWechatUserModel *fromUser, NSError *error) {
                        
                    }];
                }
                
                sleep(1);
            }// for sigle user
        }// for all users
        
    });
    
}

- (void)updateStatusLabel {
    
    weak(self);
    GCD_MAIN((^{
        if (_sendingStatusLabel) {
            self.sendingStatusLabel.text = [NSString stringWithFormat:@"推送中(%zd/%zd)，上滑查看详情", weakself.usersHaveSend, weakself.totalUsersToSend];
        }
        
        if (weakself.userSendComplete && weakself.userSendComplete.count > 0) {
            [weakself.sendingRecordTableView reloadData];
            [weakself.sendingRecordTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakself.userSendComplete.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    }))
}

- (void)showStatusOnWindow {
    
    GCD_MAIN(^{
        if (!_shadowView) {
            
            [kKeyWindow addSubview:self.shadowView];
            [self.shadowView addSubview:self.sendingRecordTableView];
            [kKeyWindow bringSubviewToFront:self.shadowView];
            
            [self updateStatusLabel];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:WSASendStatusShowNotification object:nil];
        }
//        [UIView animateWithDuration:0.3 animations:^{
//            self.sendingStatusButton.transform = CGAffineTransformMakeTranslation(0, -kSendStatusButtonHeight);
//        } completion:^(BOOL finished) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:WSASendStatusShowNotification object:nil];
//        }];
    });
}

- (void)hideStatusView {
    GCD_MAIN(^{
        if (_shadowView) {
            
            [_shadowView removeFromSuperview];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:WSASendStatusHideNotification object:nil];
        }
    });
}

- (void)putStatusBack {
    GCD_MAIN(^{
        if (_shadowView) {
            [kKeyWindow sendSubviewToBack:_shadowView];
        }
    });
}

- (void)bringStatusFront {
    GCD_MAIN(^{
        if (_shadowView) {
            [kKeyWindow bringSubviewToFront:_shadowView];
        }
    });
}

@end
