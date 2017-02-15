//
//  SRPlotView.swift
//  Swift Real-time Plot
//
//  Created by Kalanyu Zintus-art on 9/22/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

#if os(iOS)
	import Foundation
	import UIKit
#elseif os(macOS)
	import Cocoa
#endif


@IBDesignable open class SRPlotView: SRView {
    
    open var totalSecondsToDisplay: CGFloat = 10 {
        didSet {
            self.axeLayer?.xPointsToShow = self.totalSecondsToDisplay
        }
    }
    open var totalChannelsToDisplay: CGFloat = 6 {
        didSet {
            self.axeLayer?.yPointsToShow = self.totalChannelsToDisplay
        }
    }

    open var samplingRate: Double {
        get {
            return (self.axeLayer?.samplingRate)!
        }
        set {
            self.axeLayer?.samplingRate = newValue
        }
    }
    
    open var yTicks: [String] {
        get {
            return self.graphAxes.yLockLabels
        }
        set {
            self.graphAxes.yLockLabels = newValue
            
            var maxFrameWidth : CGFloat = 0
            for label in self.graphAxes.yLockLabels {
                let textSize = label.size(withAttributes: [NSFontAttributeName: NSFont.boldSystemFont(ofSize: 20)])
                if textSize.width > maxFrameWidth {
                    maxFrameWidth = textSize.width
                    self.axeLayer?.padding.x = maxFrameWidth + 20
                    self.axeLayer?.padding.y = textSize.height + 10
                    self.axeLayer?.hashLayer.setNeedsDisplay()
                }
            }
        }
    }
    
    open var title : String = "" {
        didSet {
            resizeFrameWithString(self.title)
        }
    }

    open var axeLayer : SRPlotAxe?
    open var titleField : NSTextLabel?
    open var segments = [SRPlotSegment]()
    open var current : SRPlotSegment?
    
    open var graphAxes: HashDrawer {
        get {
            return self.axeLayer!.hashSystem
        }
    }
    

    //MARK: Initialization
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        titleField = NSTextLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        titleField?.textColor = SRColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        titleField?.font = NSFont.boldSystemFont(ofSize: 20)

        self.addSubview(titleField!)
		
		#if os(macOS)
        self.wantsLayer = true
		#endif
		
        //add layout constraints to the title field
        self.titleField?.translatesAutoresizingMaskIntoConstraints = false
        let textFieldConstraint = NSLayoutConstraint(item: self.titleField!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(textFieldConstraint)
        
        //TODO: Support for axeOrigin
        self.axeLayer = SRPlotAxe(frame: self.frame, axeOrigin: CGPoint.zero, xPointsToShow: totalSecondsToDisplay, yPointsToShow: totalChannelsToDisplay, numberOfSubticks: 1)
        self.layer!.addSublayer(self.axeLayer!.layer)
        self.graphAxes.anchorPoint = CGPoint.zero
        
        
        //set for split signal plot type
        self.axeLayer?.signalType = .split
        self.axeLayer?.hashSystem.color = SRColor.darkGray
        self.titleField?.textColor = SRColor.darkGray

//        self.layer?.backgroundColor = CGColorCreateGenericRGB(0, 0 , 0, 0.05)
//        self.layer?.borderColor = SRColor.darkGrayColor().CGColor
//        self.layer?.borderWidth = 1

    
    }
    
    required override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        titleField = NSTextLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(titleField!)

    }
    
    convenience init(frame frameRect: NSRect, title: String, seconds: Double, channels: Int, samplingRatae: CGFloat, padding: CGPoint = CGPoint.zero) {
        self.init(frame: frameRect)
        self.title = "Filtered EMG Signals"
        self.totalSecondsToDisplay = CGFloat(seconds)
        self.totalChannelsToDisplay = CGFloat(channels)
        
        self.axeLayer =  SRPlotAxe(frame: self.frame, axeOrigin: CGPoint(x: 0, y: 0), xPointsToShow: totalSecondsToDisplay, yPointsToShow: totalChannelsToDisplay)
        self.layer!.addSublayer(self.axeLayer!.layer)

        self.axeLayer!.padding = padding
        self.axeLayer!.samplingRate = samplingRate

        //add layout constraints to the title field
        self.titleField?.translatesAutoresizingMaskIntoConstraints = false
        let textFieldConstraint = NSLayoutConstraint(item: self.titleField!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(textFieldConstraint)
    }
    
    //MARK: Core functions
    open func addData(_ data: [Double])
    {
        self.performSelector(onMainThread: #selector(SRPlotView.addDataInMainthread(_:)), with: data, waitUntilDone: true)
    }
	
	func addDataInMainthread(_ data: [Double]) {
        if current == nil {
            current = addSegment()
        }
        
        // First, add the new acceleration value to the current segment
        if current!.add(data) {
            // If after doing that we've filled up the current segment, then we need to
            // determine the next current segment
            recycleSegment()
            // And to keep the graph looking continuous, we add the acceleration value to the new segment as well.
            let _ = current!.add(data)
        }
        
        // After adding a new data point, we need to advance the x-position of all the segment layers by 1 to
        // create the illusion that the graph is advancing.
        for s in self.segments
        {
            s.layer.position.x += graphAxes.pointsPerUnit.x / 60
        }
        
        // If the last frame crosses the limit will cause the axis to move
//        if let last = segments.last {
//            if last.layer.frame.origin.x > graphAxes.bounds.width * 0.9 {
                axeLayer!.origin!.x -= graphAxes.pointsPerUnit.x / CGFloat(self.samplingRate)
                axeLayer?.hashLayer.setNeedsDisplay()
//            }
//        }
        
    }

    // The initial position of a segment that is meant to be displayed on the left side of the graph.
    // This positioning is meant so that a few entries must be added to the segment's history before it becomes
    // visible to the user. This value could be tweaked a little bit with varying results, but the X coordinate
    // should never be larger than 16 (the center of the text view) or the zero values in the segment's history
    // will be exposed to the user.
    //
    var kSegmentInitialPosition : CGPoint {
        get {
            //something about anchor point being 0.5
//            return CGPoint(x: graphAxes.position.x - graphAxes.pointsPerUnit.x, y: (self.frame.height / 2) + graphAxes.position.y - 9)
            return CGPoint(x: graphAxes.position.x - graphAxes.pointsPerUnit.x , y: (self.frame.height / 2) + graphAxes.position.y -
            (self.titleField!.frame.height / 2) )
        }
    }
    
    open func addSegment() -> SRPlotSegment
    {
        // Create a new segment and add it to the segments array.
        let segment = SRPlotSegment(axesSystem: axeLayer!, channels: Int(totalChannelsToDisplay))
        
        if self.window != nil {
            segment.layer.contentsScale = self.window!.backingScaleFactor
        }
//        Swift.print(segment.layer.frame, self.axeLayer?.frame, self.axeLayer?.layer.frame, self.axeLayer?.dataLayer.frame)
//        segment.layer.backgroundColor = SRColor.redColor().CGColor
        // We add it at the front of the array because -recycleSegment expects the oldest segment
        // to be at the end of the array. As long as we always insert the youngest segment at the front
        // this will be true.
        segments.insert(segment, at: 0)
        
        //POSITION IN SUPERLAYER COORDINATE SPACE
        segment.layer.frame.size = CGSize(width: graphAxes.pointsPerUnit.x, height: graphAxes.bounds.height)        
        segment.layer.position = kSegmentInitialPosition;

        self.axeLayer?.dataLayer.addSublayer(segment.layer)

        return segment
    }
    
    fileprivate func recycleSegment() {
    // We start with the last object in the segments array, as it should either be visible onscreen,
    // which indicates that we need more segments, or pushed offscreen which makes it eligable for recycling.

        let last = self.segments.last
        if last!.isVisibleInRect(axeLayer!.layer.bounds) {
        // The last segment is still visible, so create a new segment, which is now the current segment
            self.current = addSegment()
        }
        else
        {
        // The last segment is no longer visible, so we reset it in preperation to be recycled.
            last?.reset()
        // Position it properly (see the comment for kSegmentInitialPosition)
            last?.layer.frame.size = CGSize(width: graphAxes.pointsPerUnit.x, height: graphAxes.bounds.height)
            last?.layer.position = kSegmentInitialPosition
        // Move the segment from the last position in the array to the first position in the array
            segments.removeLast()
            segments.insert(last!, at: 0)
        // as it is now the youngest segment.

            self.axeLayer?.dataLayer.addSublayer(current!.layer)
        // And make it our current segment
            self.current = last;

        }
    }
    
    //MARK: SRView delegates
    
    override open func viewDidChangeBackingProperties() {
        self.axeLayer?.contentsScale = self.window!.backingScaleFactor
        self.axeLayer?.rescaleSublayers()
    }
    
    override open func layout() {
        super.layout()
        self.axeLayer?.manageDataSublayers()
    }
    
    fileprivate func resizeFrameWithString(_ title: String) {
        let nsTitle = title as NSString
        let textSize = nsTitle.size(withAttributes: [NSFontAttributeName: NSFont.systemFont(ofSize: 15)])
        self.titleField?.stringValue = title
        self.titleField?.frame = CGRect(x: self.bounds.width/2 - textSize.width/2, y: 0, width: textSize.width, height: textSize.height)
        self.titleField?.sizeToFit()
        
        var axeBounds = self.bounds
        axeBounds.origin.y = self.titleField!.frame.height
        
        axeLayer?.layer.frame.origin = axeBounds.origin
        axeLayer?.layer.frame.size.height = self.frame.height - self.titleField!.frame.height
        axeLayer?.layer.frame.size.width = self.frame.width
        //        axeLayer?.dataLayer.bounds.size.height = axeLayer!.layer.bounds.size.height - self.titleField!.frame.height
        axeLayer?.layer.setNeedsDisplay()

        
//        axeLayer?.layer.frame.origin = axeBounds.origin
//        axeLayer?.layer.frame.size.height = self.frame.height - self.titleField!.frame.height
////        axeLayer?.dataLayer.bounds.size.height = axeLayer!.layer.bounds.size.height - self.titleField!.frame.height
//        axeLayer?.layer.setNeedsDisplay()
    }
}
