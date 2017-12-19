//
//  SRMergePlotView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/20/15.
//  Copyright © 2017 KalanyuZ. All rights reserved.
//

open class SRMergePlotView: SRPlotView {

    open var numberOfTicks : Int = 0
    open var maxDataRange : Int {
        get {
            return (self.axeLayer?.maxDataRange)!
        }
        set {
            self.axeLayer?.maxDataRange = newValue
			#if os(macOS)
				
            let textSize = "\(self.maxDataRange)".size(withAttributes: [.font: SRFont.boldSystemFont(ofSize: 20)])
			#elseif os(iOS)
				
			let textSize = "\(self.maxDataRange)".size(withAttributes: [NSAttributedStringKey.font: SRFont.boldSystemFont(ofSize: 20)])
			#endif
			
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
		
		#if os(macOS)
			
			self.layer!.addSublayer(self.axeLayer!.layer)
		#elseif os(iOS)
			self.layer.addSublayer(self.axeLayer!.layer)
		
		#endif
		
        self.axeLayer?.yPointsToShow = 2
        self.axeLayer?.graph.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.axeLayer?.hashSystem.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.axeLayer?.hashSystem.color = SRColor.darkGray
        self.titleField?.textColor = SRColor.darkGray
        self.axeLayer?.signalType = .merge
		
		self.maxDataRange = 1
		
    }
	
    required public init(frame frameRect: SRRect) {
        super.init(frame: frameRect)
        
    }
    
    convenience init(frame frameRect: SRRect, title: String, seconds: Double, maxRange: (CGPoint, CGPoint), samplingRatae: CGFloat, origin: CGPoint, padding: CGFloat = 0.0) {
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
            #if os(macOS)
            return CGPoint(x: graphAxes.position.x - graphAxes.pointsPerUnit.x - 1, y: graphAxes.position.y + 1)
            #elseif os(iOS)
            return CGPoint(x: graphAxes.position.x - graphAxes.pointsPerUnit.x , y: graphAxes.position.y - graphAxes.padding.y)
            #endif
        }
    }

}
