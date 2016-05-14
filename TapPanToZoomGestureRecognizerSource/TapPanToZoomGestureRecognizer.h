//
//  TapPanToZoomGestureRecognizer.h
//  testGesture
//
//  Created by 刘博 on 16/5/11.
//  Copyright © 2016年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TapPanToZoomGestureRecognizer : UIGestureRecognizer

/**
 *  手势当前位置的scale值,范围[originalScale-deltaScale, originalScale+deltaScale]
 *
 *  默认情况下: scale的范围为[0.5,1.5],当手势从屏幕顶端滑动到底端,scale值从1.0减小到0.5; 当手势从屏幕中心滑动到顶端,scale值从1.0增大到1.25;
 */
@property (nonatomic, readonly) double scale;

/**
 *  初始的scale值,默认1.0,手势开始后修改此值无效
 */
@property (nonatomic, assign) double originalScale;

/**
 *  originalScale的最大改变量,默认0.5,手势开始后修改此值无效
 */
@property (nonatomic, assign) double deltaScale;

@end
