//
//  WSAIapVC.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/6.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAIapVC.h"
#import "WSAIapTVC.h"


@interface WSAIapVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* productsTableView;
@property (nonatomic, strong) NSMutableArray* products;

@property (nonatomic, strong) UILabel* headTipLabel;
@property (nonatomic, strong) UIButton* appidButton;

@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic, strong) UIButton* purchaseButton;
@property (nonatomic, strong) UIButton* restoreButton;
@property (nonatomic, strong) UIButton* trialButton;
@end

@implementation WSAIapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[WSAMsgSendManager defaultManager] putStatusBack];
    [self getProductInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[WSAMsgSendManager defaultManager] bringStatusFront];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"应用内购买";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(iapDone)];
    
    [self.view addSubview:self.productsTableView];
    self.productsTableView.tableHeaderView = [self tableViewHeaderView];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.purchaseButton];
    [self.bottomView addSubview:self.restoreButton];
    [self.bottomView addSubview:self.trialButton];
    self.purchaseButton.enabled = NO;
    self.restoreButton.enabled = YES;
    self.trialButton.enabled = YES;
    
    weak(self);
    [self.productsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(weakself.view);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakself.view);
        make.top.equalTo(weakself.productsTableView.mas_bottom).offset(0);
        make.height.equalTo(@(180*kHeight_Scale));
    }];
    
    [self.purchaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.restoreButton.mas_centerX);
        make.width.height.equalTo(weakself.restoreButton);
        make.bottom.equalTo(weakself.restoreButton.mas_top).offset(-10);
    }];
    [self.restoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.bottomView);
        make.left.equalTo(weakself.bottomView.mas_left).offset(15*kWidth_Scale);
        make.height.equalTo(@35);
    }];
    [self.trialButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.restoreButton.mas_centerX);
        make.width.height.equalTo(weakself.restoreButton);
        make.top.equalTo(weakself.restoreButton.mas_bottom).offset(10);
    }];
}

- (UIView*)tableViewHeaderView {
    UIView* hview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
    
    self.headTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*kWidth_Scale, 10, self.view.width-20, 80)];
    self.headTipLabel.text = [NSString stringWithFormat:@"当前版本: %@，试用版无需购买\n要使用高级功能，选择对应版本，点击立即购买\n如果之前已购买过高级版本，点击恢复购买，使用对应的Apple ID进行恢复", [WSAIapVC featureNameFromVersion:[USER_DEFAULT integerForKey:kIAPPurchaseedKey]]];
    self.headTipLabel.font = [UIFont systemFontOfSize:14.0];
    self.headTipLabel.numberOfLines = 0;
    
    self.appidButton = [[UIButton alloc] initWithFrame:CGRectMake(3*kWidth_Scale, CGRectGetMaxY(self.headTipLabel.frame), 150, 30)];
    [self.appidButton setBackgroundColor:[UIColor whiteColor]];
    self.appidButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.appidButton addTarget:self action:@selector(appleidSwitch:) forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString *astr = [[NSMutableAttributedString alloc] initWithString:@"如何切换Apple ID？"];
    NSRange strRange = {0,[astr length]};
    [astr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [astr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:strRange];
    [self.appidButton setAttributedTitle:astr forState:UIControlStateNormal];
    
    [hview addSubview:self.headTipLabel];
    [hview addSubview:self.appidButton];
    
    
    return hview;
}

- (UITableView*)productsTableView {
    if (!_productsTableView) {
        _productsTableView = [[UITableView alloc] init];
        _productsTableView.backgroundColor = [UIColor whiteColor];
        _productsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _productsTableView.rowHeight = UITableViewAutomaticDimension;
        _productsTableView.estimatedRowHeight = 100;
        _productsTableView.dataSource = self;
        _productsTableView.delegate = self;
        _productsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_productsTableView registerClass:[WSAIapTVC class] forCellReuseIdentifier:@"WSAIapTVC"];
    }
    return _productsTableView;
}

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.layer.shadowOffset = CGSizeMake(0, -2);
        _bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
        _bottomView.layer.shadowOpacity = 0.5;
        _bottomView.layer.shadowRadius = 2;
    }
    return _bottomView;
}

- (UIButton*)purchaseButton {
    if (!_purchaseButton) {
        _purchaseButton = [[UIButton alloc] init];
        _purchaseButton.layer.cornerRadius = kButtonCornerRadius;
        _purchaseButton.layer.masksToBounds = YES;
        _purchaseButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_purchaseButton setTitle:@"立即购买" forState:UIControlStateNormal];
        [_purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_purchaseButton setTitleColor:kButtonDisableTitleColor forState:UIControlStateDisabled];
        [_purchaseButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#f857a6"]] forState:UIControlStateNormal];
        [_purchaseButton setBackgroundImage:[UIImage imageWithColor:kButtonDisableBgColor] forState:UIControlStateDisabled];
        [_purchaseButton addTarget:self action:@selector(purchase:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _purchaseButton;
}

- (UIButton*)restoreButton {
    if (!_restoreButton) {
        _restoreButton = [[UIButton alloc] init];
        _restoreButton.layer.cornerRadius = kButtonCornerRadius;
        _restoreButton.layer.masksToBounds = YES;
        _restoreButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_restoreButton setTitle:@"恢复购买" forState:UIControlStateNormal];
        [_restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_restoreButton setTitleColor:kButtonDisableTitleColor forState:UIControlStateDisabled];
        [_restoreButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#34e89e"]] forState:UIControlStateNormal];
        [_restoreButton setBackgroundImage:[UIImage imageWithColor:kButtonDisableBgColor] forState:UIControlStateDisabled];
        [_restoreButton addTarget:self action:@selector(restore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _restoreButton;
}

- (UIButton*)trialButton {
    if (!_trialButton) {
        _trialButton = [[UIButton alloc] init];
        _trialButton.layer.cornerRadius = kButtonCornerRadius;
        _trialButton.layer.masksToBounds = YES;
        _trialButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_trialButton setTitle:@"立即试用" forState:UIControlStateNormal];
        [_trialButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_trialButton setTitleColor:kButtonDisableTitleColor forState:UIControlStateDisabled];
        [_trialButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#36D1DC"]] forState:UIControlStateNormal];
        [_trialButton setBackgroundImage:[UIImage imageWithColor:kButtonDisableBgColor] forState:UIControlStateDisabled];
        [_trialButton addTarget:self action:@selector(trial:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _trialButton;
}

- (NSMutableArray*)products {
    if (!_products) {
        _products = [[NSMutableArray alloc] init];
    }
    return _products;
}


#pragma mark -- dealloc
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"------------>>>>>>>>>>>>>>> %@ dealloc", [self class]);
}


#pragma mark -- actions
- (void)purchase:(UIButton*)button {
    NSIndexPath* indexPath = [self.productsTableView indexPathForSelectedRow];
    NSLog(@"------------>>>>>>>>>>>>>>> purchase at index: %zd", indexPath.row);
    if (!indexPath || indexPath.row == 0) {
        return;
    }
    
    SKProduct* product = [self.products objectAtIndex:indexPath.row];
    [[IAPShare sharedHelper].iap buyProduct:product onBegin:^() {
        [SVProgressHUD  show];
    } onCompletion:^(SKPaymentTransaction *transaction) {
        [SVProgressHUD dismiss];
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"---------->>>>>>>>>>>>>>>> transactionStatePurchased id = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"------------->>>>>>>>>>>>> 商品添加进列表");
                break;
            default:
                break;
        }
    }];
}

- (void)restore:(UIButton*)button {
    NSLog(@"------------>>>>>>>>>>>>>>> restore");
    [SVProgressHUD showWithStatus:@"正在恢复..."];
    [[IAPShare sharedHelper].iap restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
        [SVProgressHUD dismiss];
        //check with SKPaymentQueue
        
        NSString* tip = @"";
        if (error) {
            tip = [error localizedDescription];
            [SVProgressHUD showErrorWithStatus:tip];
        }
        else {
            if (!payment || !payment.transactions || payment.transactions.count==0) {
                tip = @"此Apple ID暂无购买记录";
                [SVProgressHUD showErrorWithStatus:tip];
            }
            else {
                for (int ii=0; ii<payment.transactions.count; ii++) {
                    SKPaymentTransaction *transaction = [payment.transactions objectAtIndex:ii];
                    NSString *purchased = transaction.payment.productIdentifier;
                    if (ii != 0) {
                        tip = [tip stringByAppendingString:@","];
                    }
                    tip = [tip stringByAppendingString:[WSAIapVC featureNameFromVersion:[WSAIapVC determineVersionByID:purchased]]];
                    [self savePurchasedProductByID:purchased];
                }
                
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已恢复购买版本: %@", tip]];
            }
        }
        
        
        [SVProgressHUD dismissWithDelay:1.5];
    }];
}

- (void)trial:(UIButton*)button {
    NSLog(@"------------>>>>>>>>>>>>>>> trial");
    [[NSUserDefaults standardUserDefaults] setInteger:appFeatureVersion_demo forKey:kIAPPurchaseedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)iapDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)appleidSwitch:(UIButton*)button {
    UIAlertController* avc = [UIAlertController alertControllerWithTitle:@"切换Apple ID" message:nil/*@"\n步骤一：\n方法一：打开App Store，首页滑到底部，点击已登录AppleID -> 注销。\n\n方法二：打开设置App，进入iTunes Store与App Store，点击已登录AppleID -> 注销。\n\n步骤二：返回本App，恢复购买或选择版本购买"*/ preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    [avc addAction:cancel];
    
    unsigned int count = 0;
    Ivar *property = class_copyIvarList([UIAlertController class], &count);
    Ivar message = property[2];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"\n步骤一：注销已登录AppleID\n方法①：打开App Store，首页滑到底部，点击已登录AppleID -> 注销。\n\n方法②：打开设置App，进入iTunes Store与App Store，点击已登录AppleID -> 注销。\n\n步骤二：\n返回本App，恢复购买或选择版本购买" attributes:nil];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentLeft;//设置对齐方式
    
    [str setAttributes:@{NSParagraphStyleAttributeName:paragraph, NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(0, str.length)];
    object_setIvar(avc, message, str);
    
    [self presentViewController:avc animated:YES completion:nil];
}


#pragma mark -- tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.products.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSAIapTVC* cell = [tableView dequeueReusableCellWithIdentifier:@"WSAIapTVC"];
//    if (indexPath.row == 0) {
//        
//    }
//    else {
//        [cell setContentWithProduct:[self.products objectAtIndex:indexPath.row]];
//    }
    [cell setContentWithProduct:[self.products objectAtIndex:indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //WSAIapTVC* cell = [tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"------------->>>>>>>>>>>>>>>> didSelectRowAtIndexPath selected: %@", cell.isSelected ? @"yes" : @"no");
    
    self.purchaseButton.enabled = indexPath.row != 0;
    self.restoreButton.enabled = YES;
    self.trialButton.enabled = indexPath.row == 0;
    
}
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"------------->>>>>>>>>>>>>>>> didDeselectRowAtIndexPath");
//}

#pragma mark -- IAP
//-- 获取商品信息
- (void)getProductInfo {
    [self.products removeAllObjects];
    
    NSString *emojiPath = [[NSBundle mainBundle] pathForResource:@"IAPIDs" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:emojiPath];
    NSSet *set = [NSSet setWithArray:array];
    
    if (![IAPShare sharedHelper].iap) {
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:set];
        //[IAPShare sharedHelper].iap.production = IAPEnvironmentProduction;
#if DEBUG
        [IAPShare sharedHelper].iap.production = NO;
#else
        [IAPShare sharedHelper].iap.production = YES;
#endif
    }
    
    [SVProgressHUD showWithStatus:@"正在获取产品信息"];
    weak(self);
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response, NSError* error) {
        [SVProgressHUD dismiss];
        strong(self);
        
        if (error || !response || response.products.count==0) {
            NSString* str = [error localizedDescription] && ![[error localizedDescription] isEqualToString:@""] ? [error localizedDescription] : @"暂时无法产品信息";
            [SVProgressHUD showErrorWithStatus:str];
            [SVProgressHUD dismissWithDelay:1.5];
        }
        else {
            NSArray* products = response.products;
            products = [products sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                SKProduct* p1 = obj1;
                SKProduct* p2 = obj2;
                return [p1.price compare:p2.price];
            }];
            [strongself.products addObjectsFromArray:products];
        }
        
        SKProduct* p = [[SKProduct alloc] init];
        [p setValue:@"试用版" forKey:@"localizedTitle"];
        [p setValue:@"单个用户的推广消息发送人数上限为3人（当用户的联系人多于3人时，只发送给前3）" forKey:@"localizedDescription"];
        [p setValue:[NSDecimalNumber decimalNumberWithString:@"0"] forKey:@"price"];
        [p setValue:@"wechat.assistant.demo" forKey:@"productIdentifier"];
        [strongself.products insertObject:p atIndex:0];
        
        GCD_MAIN(^{
            [strongself.productsTableView reloadData];
        })
    }];
}
     

#pragma transaction observer

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    // Your application should implement these two methods.
//    NSString * productIdentifier = transaction.payment.productIdentifier;
//    NSString * receipt = [transaction.transactionReceipt base64EncodedString];
//    if ([productIdentifier length] > 0) {
//        // 向自己的服务器验证购买凭证
//    }
    
    NSLog(@"-------->>>>>>>>>>>>>> completeTransaction product id : %@", transaction.payment.productIdentifier);
    [self savePurchasedProductByID:transaction.payment.productIdentifier];
    self.headTipLabel.text = [NSString stringWithFormat:@"当前版本: %@，试用版无需购买\n要使用高级功能，选择对应版本，点击立即购买\n如果之前已购买过高级版本，点击恢复购买，使用对应的Apple ID进行恢复", [WSAIapVC featureNameFromVersion:[USER_DEFAULT integerForKey:kIAPPurchaseedKey]]];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"---------->>>>>>>>>>>>>购买失败");
        [SVProgressHUD showErrorWithStatus:[transaction.error localizedDescription]/*@"购买失败"*/];
        [SVProgressHUD dismissWithDelay:1];
    } else {
        NSLog(@"----------->>>>>>>>>>>>>>>用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 对于已购商品，处理恢复购买的逻辑
    [self savePurchasedProductByID:transaction.payment.productIdentifier];
    self.headTipLabel.text = [NSString stringWithFormat:@"当前版本: %@，试用版无需购买\n要使用高级功能，选择对应版本，点击立即购买\n如果之前已购买过高级版本，点击恢复购买，使用对应的Apple ID进行恢复", [WSAIapVC featureNameFromVersion:[USER_DEFAULT integerForKey:kIAPPurchaseedKey]]];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)savePurchasedProductByID:(NSString*)productID {
    appFeatureVersion purchasedVersion = [WSAIapVC determineVersionByID:productID];
    NSLog(@"--------->>>>>>>>>>>>>> purchase version: %@", [WSAIapVC featureNameFromVersion:purchasedVersion]);
    
    appFeatureVersion localVersion = [USER_DEFAULT integerForKey:kIAPPurchaseedKey];
    
    if (purchasedVersion > localVersion) {
        [USER_DEFAULT setInteger:purchasedVersion forKey:kIAPPurchaseedKey];
        [USER_DEFAULT synchronize];
    }
}

#pragma mark -- other
//-- 通过内购产品ID判断
+ (appFeatureVersion)determineVersionByID:(NSString*)productID {
    if (!productID || [productID isEqualToString:@""]) {
        return appFeatureVersion_demo;
    }
    
    if ([productID isEqualToString:kIAPProdcutID_master]) {
        return appFeatureVersion_master;
    }
    else if ([productID isEqualToString:kIAPProdcutID_diamond]) {
        return appFeatureVersion_diamond;
    }
    else if ([productID isEqualToString:kIAPProdcutID_gold]) {
        return appFeatureVersion_gold;
    }
    else if ([productID isEqualToString:kIAPProdcutID_silver]) {
        return appFeatureVersion_silver;
    }
    else if ([productID isEqualToString:kIAPProdcutID_bronze]) {
        return appFeatureVersion_bronze;
    }
    
    return appFeatureVersion_demo;
}

+ (NSString*)determinProductIDByVersion:(appFeatureVersion)version {
    switch (version) {
        case appFeatureVersion_demo:
            return kIAPProdcutID_demo;
            break;
        case appFeatureVersion_bronze:
            return kIAPProdcutID_bronze;
            break;
        case appFeatureVersion_silver:
            return kIAPProdcutID_silver;
            break;
        case appFeatureVersion_gold:
            return kIAPProdcutID_gold;
            break;
        case appFeatureVersion_diamond:
            return kIAPProdcutID_diamond;
            break;
        case appFeatureVersion_master:
            return kIAPProdcutID_master;
            break;
        default:
            return kIAPProdcutID_demo;
            break;
    }
}


+ (NSString*)featureNameFromVersion:(appFeatureVersion)version {
    switch (version) {
        case appFeatureVersion_demo:
            return @"试用版";
            break;
        case appFeatureVersion_bronze:
            return @"青铜版";
            break;
        case appFeatureVersion_silver:
            return @"白银版";
            break;
        case appFeatureVersion_gold:
            return @"黄金版";
            break;
        case appFeatureVersion_diamond:
            return @"钻石版";
            break;
        case appFeatureVersion_master:
            return @"大师版";
            break;
        default:
            return @"试用版";
            break;
    }
}

+ (NSUInteger)limitForVersion:(appFeatureVersion)version {
    switch (version) {
        case appFeatureVersion_demo:
            return kDemoMaxUserLimit;
            break;
        case appFeatureVersion_bronze:
            return kBronzeMaxUserLimit;
            break;
        case appFeatureVersion_silver:
            return kSilverMaxUserLimit;
            break;
        case appFeatureVersion_gold:
            return kGoldMaxUserLimit;
            break;
        case appFeatureVersion_diamond:
            return kDiamondMaxUserLimit;
            break;
        case appFeatureVersion_master:
            return kMasterMaxUserLimit;
            break;
        default:
            return kDemoMaxUserLimit;
            break;
    }
}

+ (appFeatureVersion)currentAppFeatureVersion {
    return [USER_DEFAULT integerForKey:kIAPPurchaseedKey];
}

@end
