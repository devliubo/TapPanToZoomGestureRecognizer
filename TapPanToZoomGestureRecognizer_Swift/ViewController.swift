//
//  ViewController.swift
//  TapPanToZoomGestureRecognizer_Swift
//
//  Created by 刘博 on 16/6/2.
//
//

import UIKit

class ViewController: UIViewController, MAMapViewDelegate, UIGestureRecognizerDelegate {
    
    var mapView: MAMapView!
    var tapPanToZoom: TapPanToZoomGestureRecognizer!
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = self.view.bounds
        self.view.addSubview(mapView)
        
        tapPanToZoom.originalScale = mapView.zoomLevel
        tapPanToZoom.deltaScale = 5.0
        self.view.addGestureRecognizer(tapPanToZoom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        mapView = MAMapView.init()
        mapView.delegate = self
        
        tapPanToZoom = TapPanToZoomGestureRecognizer.init(target: self, action: #selector(ViewController.tapPanToZoomAction(_:)))
        tapPanToZoom.delegate = self
    }
    
    //MARK: - TapPanToZoomGestureRecognizer Action
    
    func tapPanToZoomAction(gestureRecognizer: TapPanToZoomGestureRecognizer) {
        NSLog("scale:%f", tapPanToZoom.scale)
        
        mapView.setZoomLevel(tapPanToZoom.scale, animated: false)
    }
    
    //MARK: - MAMapView Delegate
    
    func mapView(mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        tapPanToZoom.originalScale = self.mapView.zoomLevel
    }
    
}
