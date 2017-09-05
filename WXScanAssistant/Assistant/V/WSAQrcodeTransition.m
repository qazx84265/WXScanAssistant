//
//  WSAQrcodeTransition.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/4.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAQrcodeTransition.h"
#import "WSAHomeVC.h"
#import "WSAQRCodeVC.h"

@interface WSAQrcodeTransition()<CAAnimationDelegate>

@end

@implementation WSAQrcodeTransition

+ (instancetype)transitionWithTransitionType:(WSAQrcodeTransitionType)type{
    return [[self alloc] initWithTransitionType:type];
}

- (instancetype)initWithTransitionType:(WSAQrcodeTransitionType)type{
    self = [super init];
    if (self) {
        _transitionType = type;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    switch (_transitionType) {
        case WSAQrcodeTransitionTypePresent:
            [self presentAnimation:transitionContext];
            break;
            
        case WSAQrcodeTransitionTypeDismiss:
            [self dismissAnimation:transitionContext];
            break;
    }
}

/**
 *  执行present过渡动画
 */
- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    WSAHomeVC *fromVC = (WSAHomeVC *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    WSAQRCodeVC *toVC = (WSAQRCodeVC *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //拿到当前点击的cell的imageView
    
    CGRect finalFrameForVc = [transitionContext finalFrameForViewController:toVC];
    UIView *containerView = [transitionContext containerView];
    
    UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wsa_qrcode"]];
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect frame = [fromVC.qrcodeButton.imageView convertRect:fromVC.qrcodeButton.imageView.bounds toView: containerView];
    CGRect endFrame = [fromVC.qrcodeButton convertRect:frame toView: containerView];
    tempView.frame = endFrame;
    //设置动画前的各个控件的状态
    
    toVC.view.frame = frame;
    toVC.view.alpha = 0;
    
    //tempView 添加到containerView中，要保证在最前方，所以后添加
    [containerView addSubview:toVC.view];
    [containerView addSubview:tempView];
    
    //开始做动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:10 options:0 animations:^{
        tempView.frame = endFrame;
        toVC.view.frame = CGRectMake(0, 20, finalFrameForVc.size.width, finalFrameForVc.size.height - 20);
        toVC.view.alpha = 1;
        //[self clickCornerWidth:toVC.view];
    } completion:^(BOOL finished) {
        tempView.hidden = YES;
        
        //如果动画过渡取消了就标记不完成，否则才完成，这里可以直接写YES，如果有手势过渡才需要判断，必须标记，否则系统不会中动画完成的部署，会出现无法交互之类的bug
        [transitionContext completeTransition:YES];
    }];
}
/**
 *  执行dismiss过渡动画
 */
- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    WSAQRCodeVC *fromVC = (WSAQRCodeVC *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    WSAHomeVC *toVC = (WSAHomeVC *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    //这里的lastView就是push时候初始化的那个tempView
    UIView *tempView = containerView.subviews.lastObject;
    
    CGRect frame = [toVC.qrcodeButton.imageView convertRect:toVC.qrcodeButton.imageView.bounds toView: containerView];
    CGRect endFrame = [toVC.qrcodeButton convertRect:frame toView: containerView];
    
    //设置初始状态
    tempView.hidden = NO;
    
    [toVC viewWillAppear:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:10 options:0 animations:^{
        tempView.frame = endFrame;
        fromVC.view.frame = [toVC.qrcodeButton convertRect:toVC.qrcodeButton.bounds toView: containerView];
        fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}


- (void)clickCornerWidth:(UIView *)view{
    CGSize screenSize =   [UIScreen mainScreen].bounds.size;
    //顶部圆角
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenSize.width, screenSize.height * 3) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *sharpLayer = [CAShapeLayer layer];
    sharpLayer.path = path.CGPath;
    view.layer.mask = sharpLayer;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    switch (_transitionType) {
        case WSAQrcodeTransitionTypePresent:{
            
            id<UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
            [transitionContext completeTransition:YES];
            //            [transitionContext viewControllerForKey:UITransitionContextToViewKey].view.layer.mask = nil;
        }
            break;
        case WSAQrcodeTransitionTypeDismiss:{
            id<UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            if ([transitionContext transitionWasCancelled]) {
                [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
            }
        }
            break;
    }
}
@end
