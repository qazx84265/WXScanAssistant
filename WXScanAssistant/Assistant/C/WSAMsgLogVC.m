//
//  WSAMsgLogVC.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/4.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAMsgLogVC.h"

@interface WSAMsgLogVC ()

@end

@implementation WSAMsgLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    UIButton* btn = [[UIButton alloc] init];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor RandomColor]] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    weak(self);
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.view);
        make.width.height.equalTo(@100);
    }];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"------------>>>>>>>>>>>>>>> %@ dealloc", [self class]);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"------------>>>>>>>>>>>>>>> %@ viewWillAppear", [self class]);
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"------------>>>>>>>>>>>>>>> %@ viewWillDisappear", [self class]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
