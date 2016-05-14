//
//  ViewController.h
//  TapPanToZoomGestureRecognizer
//
//  Created by 刘博 on 16/5/13.
//
//

#import <UIKit/UIKit.h>

#import <MAMapKit/MAMapKit.h>
#import "TapPanToZoomGestureRecognizer.h"

@interface ViewController : UIViewController<UIGestureRecognizerDelegate, MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) TapPanToZoomGestureRecognizer *tapPanToZoom;

@end

