//
//  TapPanToZoomGestureRecognizer.m
//  testGesture
//
//  Created by 刘博 on 16/5/11.
//  Copyright © 2016年 . All rights reserved.
//

#import "TapPanToZoomGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TapPanToZoomGestureRecognizer ()
{
    //防止手势开始后外部修改originalScale和deltaScale造成scale计算错误
    double _tempOriginalScale;
    double _tempDeltaScale;
}

@property (nonatomic, strong) NSTimer *internalTimer;

@property (nonatomic, assign) NSInteger singleTapCount;
@property (nonatomic, assign) NSInteger currentTouchCount;
@property (nonatomic, assign) BOOL hasDoubleTapped;

@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, assign) double screenHeight;

@property (nonatomic, assign, readwrite) double scale;

@end

@implementation TapPanToZoomGestureRecognizer

#pragma mark - Life Cycle

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    if (self = [super initWithTarget:target action:action])
    {
        self.originalScale = 1.0;
        self.deltaScale = 0.5;
        
        [self resetProperties];
    }
    return self;
}

- (void)dealloc
{
    [self invalidateInternalTimer];
}

- (void)resetProperties
{
    self.singleTapCount = 0;
    self.currentTouchCount = 0;
    self.hasDoubleTapped = NO;
    
    self.originalPoint = CGPointZero;
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.scale = self.originalScale;
    
    _tempOriginalScale = self.originalScale;
    _tempDeltaScale = self.deltaScale;
}

#pragma mark - Handle Timer

- (void)invalidateInternalTimer
{
    if (self.internalTimer)
    {
        [self.internalTimer invalidate];
        self.internalTimer = nil;
    }
}

- (void)timeoutAction
{
    [self invalidateInternalTimer];
    
    self.state = UIGestureRecognizerStateFailed;
}

#pragma mark - Override

- (void)reset
{
    [super reset];
    
    [self invalidateInternalTimer];
    
    [self resetProperties];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    //Began时增加,End时减少,用于记录停留在屏幕上的Touch数量;
    //解决与Pinch手势的冲突,Pinch会将两个finger的单击然后Move识别为Pinch手势
    self.currentTouchCount += [touches count];
    
    if (self.state == UIGestureRecognizerStatePossible && [touches count] == 1)
    {
        //单指触摸处理
        UITouch *aTouch = [touches anyObject];
        
        if (aTouch.tapCount == 1)
        {
            //将有距离间隔的两次singleTap识别为TapPan
            ++self.singleTapCount;
            
            //第一下点击开始计时
            //如果 点击一下 or 点击两下且没有Move,则超时后进入Failed;如果点击两下且有Move则进入Began;
            if (self.internalTimer == nil)
            {
                self.internalTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(timeoutAction) userInfo:nil repeats:NO];
            }
        }
        else if (aTouch.tapCount == 2)
        {
            //防止双击因等待timer超时反应过慢:双击手势会在两次Began后进入End;TapPan会在两次Began后进入Move;
            self.hasDoubleTapped = YES;
        }
        else if (aTouch.tapCount > 2)
        {
            //点击超过两下直接进入Failed
            [self invalidateInternalTimer];
            
            self.state = UIGestureRecognizerStateFailed;
        }
    }
    else
    {
        //多指触摸直接进入Failed
        [self invalidateInternalTimer];
        
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    [self invalidateInternalTimer];
    
    //Canceled和Failed不处理
    if (self.state != UIGestureRecognizerStatePossible
        && self.state != UIGestureRecognizerStateBegan
        && self.state != UIGestureRecognizerStateChanged)
    {
        return;
    }
    
    UITouch *aTouch = [touches anyObject];
    
    //Began条件: 1.单指点击两下的情况; 2.两下有距离间隔的singleTap; 其他情况进入Failed.
    if (([touches count] == 1 && aTouch.tapCount == 2) || (self.currentTouchCount == 1 && self.singleTapCount == 2))
    {
        if (self.state == UIGestureRecognizerStatePossible)
        {
            //进入Began时需要记录originalPoint
            self.originalPoint = [aTouch locationInView:nil];
            self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
            
            self.scale = self.originalScale;
            
            _tempOriginalScale = self.originalScale;
            _tempDeltaScale = self.deltaScale;
            
            self.state = UIGestureRecognizerStateBegan;
        }
        else if (self.state == UIGestureRecognizerStateBegan)
        {
            self.state = UIGestureRecognizerStateChanged;
        }
        else if (self.state == UIGestureRecognizerStateChanged)
        {
            CGPoint point = [aTouch locationInView:nil];
            double delta = self.originalPoint.y - point.y;
            
            self.scale = _tempOriginalScale + _tempDeltaScale * (delta / self.screenHeight);
        }
    }
    else
    {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    self.currentTouchCount -= [touches count];
    
    if (self.state == UIGestureRecognizerStatePossible && self.hasDoubleTapped)
    {
        self.state = UIGestureRecognizerStateFailed;
    }
    else if (self.state == UIGestureRecognizerStateBegan)
    {
        self.state = UIGestureRecognizerStateCancelled;
    }
    else if (self.state == UIGestureRecognizerStateChanged)
    {
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    self.currentTouchCount -= [touches count];
    
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged)
    {
        self.state = UIGestureRecognizerStateCancelled;
    }
    else
    {
        [self invalidateInternalTimer];
        
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        //UIPanGestureRecognizer需要在Failed后才可以触发
        return YES;
    }
    else if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        //UITapGestureRecognizer的单击和双击需要在Failed后才可以触发
        UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)otherGestureRecognizer;
        
        if (tapGestureRecognizer.numberOfTouchesRequired == 1 && tapGestureRecognizer.numberOfTapsRequired <= 2)
        {
            return YES;
        }
        return NO;
    }
    else
    {
        return [super shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];
    }
}

@end
