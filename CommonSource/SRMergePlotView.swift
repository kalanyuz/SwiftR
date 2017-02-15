//
//  SRMergePlotView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/20/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

#if os(iOS)
	import Foundation
	import UIKit
#elseif os(macOS)
	import Cocoa
#endif

open class SRMergePlotView: SRPlotView {

    open var numberOfTicks : Int = 0
    open var maxDataRange : Int {
        get {
            return (self.axeLayer?.maxDataRange)!
        }
        set {
            self.axeLayer?.maxDataRange = newValue
            let textSize = "\(self.maxDataRange)".size(withAttributes: [NSFontAttributeName: NSFont.boldSystemFont(ofSize: 20)])
            self.axeLayer?.padding.x = newValue < 10 ? textSize.width * 3: textSize.width
            self.axeLayer?.layer.setNeedsDisplay()

        }
    }
    
    open var axeOrigin = CGPoint.zero
    
    //MARK: Initialization
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.axeLayer!.layer.removeFromSuperlayer()
//
        self.axeLayer = SRPlotAxe(frame: self.frame, axeOrigin: CGPoint.zero, xPointsToShow: totalSecondsToDisplay, yPointsToShow: totalChannelsToDisplay, numberOfSubticks: 1)
        self.layer!.addSublayer(self.axeLayer!.layer)
        self.axeLayer?.yPointsToShow = 2
        self.axeLayer?.graph.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.axeLayer?.hashSystem.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.axeLayer?.hashSystem.color = SRColor.darkGray
        self.titleField?.textColor = SRColor.darkGray
        self.axeLayer?.signalType = .merge
        
    }
    
    required public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
    }
    
    convenience init(frame frameRect: NSRect, title: String, seconds: Double, maxRange: (CGPoint, CGPoint), samplingRatae: CGFloat, origin: CGPoint, padding: CGFloat = 0.0) {
        self.init(frame: frameRect)
        
    }
    
    // The initial position of a segment that is meant to be displayed on the left side of the graph.
    // This positioning is meant so that a few entries must be added to the segment's history before it becomes
    // visible to the user. This value could be tweaked a little bit with varying results, but the X coordinate
    // should never be larger than 16 (the center of the text view) or the zero values in the segment's history
    // will be exposed to the user.
    //
    override var kSegmentInitialPosition : CGPoint {
        get {
            //something about anchor point being 0.5
            //line width hack
            return CGPoint(x: graphAxes.position.x - graphAxes.pointsPerUnit.x - 1, y: graphAxes.position.y + 1)
        }
    }
    
}
