//
//  TapPanToZoomGestureRecognizer.swift
//  TapPanToZoomGestureRecognizer
//
//  Created by liubo on 5/26/16.
//
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

final public class TapPanToZoomGestureRecognizer: UIGestureRecognizer {
    
    //MARK: - Public Variables
    public private(set) var scale = 0.0
    public var originalScale = 1.0
    public var deltaScale = 0.5
    
    //MARK: - Internal Variables
    private var internalTimer: NSTimer?
    
    private var singleTapCount = 0
    private var currentTouchCount = 0
    private var hasDoubleTapped = false
    
    private var originalPoint = CGPointZero
    private var screenHeight = UIScreen.mainScreen().bounds.size.height
    
    private var _tempOriginalScale = 0.0
    private var _tempDeltaScale = 0.0
    
    //MARK: - Life Cycle
    
    override public init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
        
        resetProperties()
    }
    
    deinit {
        invalideInternalTimer()
    }
    
    private func resetProperties() {
        singleTapCount = 0
        currentTouchCount = 0
        hasDoubleTapped = false
        
        originalPoint = CGPointZero
        screenHeight = UIScreen.mainScreen().bounds.size.height
        
        scale = originalScale
        
        _tempOriginalScale = originalScale
        _tempDeltaScale = deltaScale
    }
    
    //MARK: - Handle Timer
    
    private func invalideInternalTimer() {
        guard (internalTimer != nil) else { return }
        
        internalTimer!.invalidate()
        internalTimer = nil
    }
    
    @objc private func timeoutAction() {
        invalideInternalTimer()
        
        self.state = .Failed
    }
    
    //MARK: - Override
    
    override public func reset() {
        super.reset()
        
        invalideInternalTimer()
        
        resetProperties()
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        currentTouchCount += touches.count
        
        if self.state == .Possible && touches.count == 1 {
            
            let aTouch = touches.first!
            
            if aTouch.tapCount == 1 {
                singleTapCount += 1
                
                if internalTimer == nil {
                    internalTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(TapPanToZoomGestureRecognizer.timeoutAction), userInfo: nil, repeats: false)
                }
            }
            else if aTouch.tapCount == 2 {
                hasDoubleTapped = true
            }
            else if aTouch.tapCount > 2 {
                invalideInternalTimer()
                
                self.state = .Failed
            }
        }
        else {
            invalideInternalTimer()
            
            self.state = .Failed
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        invalideInternalTimer()
        
        guard (self.state == .Possible || self.state == .Began || self.state == .Changed) else { return }
        
        let aTouch = touches.first!
        
        if ((touches.count == 1 && aTouch.tapCount == 2) || (currentTouchCount == 1 && singleTapCount == 2)) {
            if self.state == .Possible {
                
                originalPoint = aTouch.locationInView(nil)
                screenHeight = UIScreen.mainScreen().bounds.size.height
                
                scale = originalScale
                
                _tempOriginalScale = originalScale
                _tempDeltaScale = deltaScale
                
                self.state = .Began
            }
            else if self.state == .Began {
                self.state = .Changed
            }
            else if self.state == .Changed {
                
                let point = aTouch.locationInView(nil)
                let delta = originalPoint.y - point.y
                
                scale = _tempOriginalScale + _tempDeltaScale * Double(delta / screenHeight)
            }
        }
        else {
            self.state = .Failed
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        currentTouchCount -= touches.count
        
        if state == .Possible && hasDoubleTapped {
            state = .Failed
        }
        else if state == .Began {
            state = .Cancelled
        }
        else if state == .Changed {
            state = .Ended
        }
    }
    
    override public func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        
        currentTouchCount -= touches.count
        
        if state == .Began || state == .Changed {
            state = .Cancelled
        }
        else {
            invalideInternalTimer()
            
            state = .Failed
        }
    }
    
    override public func shouldBeRequiredToFailByGestureRecognizer(otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.isKindOfClass(UIPanGestureRecognizer) {
            return true
        }
        else if otherGestureRecognizer.isKindOfClass(UITapGestureRecognizer) {
            let aTap = otherGestureRecognizer as! UITapGestureRecognizer
            
            if aTap.numberOfTouchesRequired == 1 && aTap.numberOfTapsRequired <= 2 {
                return true
            }
            
            return false
        }
        else {
            return super.shouldBeRequiredToFailByGestureRecognizer(otherGestureRecognizer)
        }
    }
    
}
