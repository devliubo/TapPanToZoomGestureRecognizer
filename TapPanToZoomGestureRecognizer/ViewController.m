//
//  ViewController.m
//  TapPanToZoomGestureRecognizer
//
//  Created by 刘博 on 16/5/13.
//
//

#import "ViewController.h"

@interface ViewController ()

//Compatibility Testing
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UITapGestureRecognizer *twoFingerTap;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Add MapView
    [self.view addSubview:self.mapView];
    
    //Add TapPanToZoom GestureRecognizer
    self.tapPanToZoom.originalScale = self.mapView.zoomLevel;
    self.tapPanToZoom.deltaScale = 5;
    [self.view addGestureRecognizer:self.tapPanToZoom];
    
    //Add Other GestureRecognizer
//    [self addOtherGestureRecognizer];
}

#pragma mark - MapView

- (MAMapView *)mapView
{
    if (_mapView == nil)
    {
        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
    }
    return _mapView;
}

#pragma mark - TapPanToZoomGestureRecognizer

- (TapPanToZoomGestureRecognizer *)tapPanToZoom
{
    if (_tapPanToZoom == nil)
    {
        _tapPanToZoom = [[TapPanToZoomGestureRecognizer alloc] initWithTarget:self action:@selector(tapPanToZoomAction:)];
        _tapPanToZoom.delegate = self;
    }
    return _tapPanToZoom;
}

#pragma mark - TapPanToZoom Action

- (void)tapPanToZoomAction:(TapPanToZoomGestureRecognizer *)gestureRecognizer
{
    NSLog(@"scale:%f", self.tapPanToZoom.scale);
    
    [self.mapView setZoomLevel:self.tapPanToZoom.scale animated:NO];
}

#pragma mark - MAMapView Delegate

- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction
{
    self.tapPanToZoom.originalScale = self.mapView.zoomLevel;
}

#pragma mark - Compatibility Testing

//#pragma mark UIGestureRecognizerDelegate
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    if (gestureRecognizer == self.singleTap && otherGestureRecognizer == self.doubleTap)
//    {
//        return YES;
//    }
//    return NO;
//}
//
//#pragma mark OtherGestureRecognizer
//
//- (void)addOtherGestureRecognizer
//{
//    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
//    self.singleTap.delegate = self;
//    self.singleTap.numberOfTapsRequired = 1;
//    self.singleTap.numberOfTouchesRequired = 1;
//    [self.view addGestureRecognizer:self.singleTap];
//    
//    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
//    self.doubleTap.delegate = self;
//    self.doubleTap.numberOfTapsRequired = 2;
//    self.doubleTap.numberOfTouchesRequired = 1;
//    [self.view addGestureRecognizer:self.doubleTap];
//    
//    self.twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TwoFingerTapAction:)];
//    self.twoFingerTap.delegate = self;
//    self.twoFingerTap.numberOfTapsRequired = 1;
//    self.twoFingerTap.numberOfTouchesRequired = 2;
//    [self.view addGestureRecognizer:self.twoFingerTap];
//    
//    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    self.longPress.delegate = self;
//    [self.view addGestureRecognizer:self.longPress];
//    
//    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
//    self.panGesture.delegate = self;
//    [self.view addGestureRecognizer:self.panGesture];
//    
//    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
//    self.pinchGesture.delegate = self;
//    [self.view addGestureRecognizer:self.pinchGesture];
//}
//
//- (void)singleTapAction:(UITapGestureRecognizer *)gestureRecognizer
//{
//    NSLog(@"singleTap");
//}
//
//- (void)doubleTapAction:(UITapGestureRecognizer *)gesture
//{
//    NSLog(@"doubleTap");
//}
//
//- (void)TwoFingerTapAction:(UITapGestureRecognizer *)gestureRecognizer
//{
//    NSLog(@"twoFingerTap");
//}
//
//- (void)longPressAction:(UILongPressGestureRecognizer *)gestureRecognizer
//{
//    NSLog(@"longPress");
//}
//
//- (void)panGestureAction:(UITapGestureRecognizer *)gestureRecognizer
//{
//    NSLog(@"panGesture");
//}
//
//- (void)pinchGestureAction:(UITapGestureRecognizer *)gestureRecognizer
//{
//    NSLog(@"pinchGesture");
//}

@end
