//
//  SRPlotAxe.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/15/15.
//  Copyright © 2017 KalanyuZ. All rights reserved.
//

#if os(iOS)
	import Foundation
	import UIKit
#elseif os(macOS)
	import Cocoa
#endif

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

#if os(macOS)
extension SRPlotAxe: NSWindowDelegate {}
#endif

open class SRPlotAxe: NSObject, CALayerDelegate {
    //TODO: Separate axis layer and hashmarks drawer for less redraws and improved performance
    //TODO: Support axe origin shift
    public enum SRPlotSignalType {
        case split
        case merge
    }
    //1. where the moving hash marks will be drawn
    open let hashLayer = CALayer()
    //2. where the axis will be drawn
    open let layer = CALayer()
    //3. axis layer, where the actual data will be plot
    open let dataLayer = CALayer()
    
    open var numberOfSubticks : Int = 0
    open var maxDataRange : Int = 1 {
        didSet {
            self.hashLayer.setNeedsDisplay()
        }
    }
    
    open var graph = AxesDrawer()
    open var hashSystem = HashDrawer()
    
    open var signalType = SRPlotSignalType.split
    
    //axis origin that causes the axe to move
    open var origin : CGPoint?
    
    open var xPointsToShow : CGFloat? {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    open var yPointsToShow: CGFloat? {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    open var samplingRate : Double = 60
    
    open var padding = CGPoint.zero {
        didSet {
            graph.padding = padding
            hashSystem.padding = padding
        }
    }
    
    open var contentsScale : CGFloat {
        get {
            return layer.contentsScale
        }
        
        set {
            layer.contentsScale = newValue
            hashLayer.contentsScale = newValue
            manageDataSublayers()
        }
    }
    
    open var innerTopRightPadding : CGFloat = 10
    
    convenience init(frame frameRect: CGRect) {
        self.init()
        
        hashLayer.delegate = self
        hashLayer.anchorPoint = CGPoint.zero
        hashLayer.needsDisplayOnBoundsChange = true
        hashLayer.bounds = CGRect(x: 0, y: 0, width: frameRect.width, height: frameRect.height)
		
        layer.delegate = self
        layer.anchorPoint = CGPoint.zero
        //MUST: set anchorpoint first or else set frame will shift it else where due to the coordinate system
        layer.needsDisplayOnBoundsChange = true
//        Swift.print(layer.bounds)
        layer.bounds = CGRect(x: 0, y: 0, width: hashLayer.bounds.width - innerTopRightPadding, height: hashLayer.bounds.height - innerTopRightPadding)
        //SWIFT 2.0 Syntax : Option Settypes
		#if os(macOS)
			
			hashLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
			layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
		#endif
		
        self.dataLayer.anchorPoint = CGPoint.zero
        self.dataLayer.bounds = CGRect(x: 0, y: 0, width: layer.bounds.width, height: layer.bounds.height )
        //if parent layer has implicit and children don't have it, ghosting occurs!
        //fix: disable animation makes ghosting disappear !!!!
        self.dataLayer.delegate = self

        let masking = CALayer()

		masking.backgroundColor = SRColor.black.cgColor
        self.dataLayer.mask = masking
        
        self.layer.insertSublayer(self.dataLayer, below: self.layer)
        self.layer.insertSublayer(self.hashLayer, at: 0)

    }
	
    convenience init(frame: CGRect, axeOrigin: CGPoint, xPointsToShow: CGFloat, yPointsToShow: CGFloat, numberOfSubticks: Int = 0) {
        self.init(frame: frame)
        
        self.origin = axeOrigin
        self.xPointsToShow = xPointsToShow
        self.yPointsToShow = yPointsToShow
        self.numberOfSubticks = numberOfSubticks
        
    }
    
    convenience init(frame: CGRect, axeOrigin: CGPoint, xPointsToShow: CGFloat, numberOfSubticks: Int = 0, maxDataRange: Int = 1) {
        self.init(frame: frame, axeOrigin: axeOrigin, xPointsToShow: xPointsToShow, yPointsToShow: 1, numberOfSubticks: numberOfSubticks)
        self.maxDataRange = maxDataRange
    }
	
    open func draw(_ layer: CALayer, in ctx: CGContext) {
        guard layer === self.layer || layer === self.hashLayer else {
            return
        }
        
        if (layer === self.layer) {
            graph.drawAxesInRect(ctx, bounds: self.layer.bounds, axeOrigin: origin!, xPointsToShow: xPointsToShow!, yPointsToShow: yPointsToShow!, numberOfTicks: numberOfSubticks, maxDataRange: self.maxDataRange)
        } else if (layer === self.hashLayer) {
            hashSystem.drawHashInRect(ctx, bounds: self.layer.bounds, axeOrigin: origin!, xPointsToShow: xPointsToShow!, yPointsToShow: yPointsToShow!, numberOfTicks: numberOfSubticks, maxDataRange: self.maxDataRange)
        }
        
    }
	
	
    open func layoutSublayers(of layer: CALayer) {
        //=== identical to : refers to the same memory
        //== equal in value
        guard layer === self.dataLayer && self.dataLayer.sublayers?.count > 0 else {
            return
        }
        //resize clipping mask
        if layer.mask != nil {
            layer.mask!.bounds = self.layer.bounds
            layer.mask!.bounds.size.height = self.layer.bounds.height * 2
            layer.mask!.bounds.size.width = self.layer.bounds.width - self.padding.x
        }
		
//        var translation = CATransform3DMakeTranslation(self.layer.bounds.width / 2 + self.graph.position.x, self.layer.bounds.height / 2, 0)
		
        //        FIXME: set this up in initializer somewhere
        //        left to right mode
        if layer.mask != nil {
            layer.mask!.position.x = self.graph.position.x + (self.layer.bounds.width / 2)
            layer.mask!.position.y = self.graph.position.y
        }
        // right to left mode
        let translation = CATransform3DMakeTranslation(self.graph.bounds.width + self.graph.position.x, self.layer.bounds.height * fabs(self.hashSystem.anchorPoint.y - 0.5), 0)
        layer.mask!.position.x =  (self.layer.bounds.width / 2) + self.padding.x/2
        layer.transform = CATransform3DRotate(translation, CGFloat(M_PI), 0, 1, 0)
    }
    
    open func action(for layer: CALayer, forKey event: String) -> CAAction? {
        //disable implicit animation of any kind
        return NSNull()
    }
    
    //MARK: NSWindowDelegate
	#if os(macOS)
    open func rescaleSublayers() {
        //set layer's contentScale for crisp display
        guard let sublayers = self.dataLayer.sublayers, self.dataLayer.sublayers?.count > 0 else {
            return
        }
        for sublayer in sublayers {
            sublayer.contentsScale = NSApplication.shared().windows[0].backingScaleFactor
        }
        self.layer.contentsScale = NSApplication.shared().windows[0].backingScaleFactor
        self.hashLayer.contentsScale = NSApplication.shared().windows[0].backingScaleFactor
    }
	#elseif os(iOS)
	
	func rescaleSublayers() {
		//set layer's contentScale for crisp display
		guard let sublayers = self.dataLayer.sublayers, self.dataLayer.sublayers?.count > 0 else {
			return
		}
		for sublayer in sublayers {
			sublayer.contentsScale = UIScreen.main.scale
		}
		self.layer.contentsScale = UIScreen.main.scale
		self.hashLayer.contentsScale = UIScreen.main.scale
	}
	
	#endif
	
    //MARK: Utilities
    open func manageDataSublayers() {
        guard let sublayers = self.dataLayer.sublayers, self.dataLayer.sublayers?.count > 0 else {
            return
        }
        

        for sublayer in sublayers {
            sublayer.frame.size.width = 0
            sublayer.frame.size.height = 0
        }
        
    }
    
    open func align(_ coordinate: CGFloat) -> CGFloat {
        return round(coordinate * layer.contentsScale) / layer.contentsScale
    }
    
}
