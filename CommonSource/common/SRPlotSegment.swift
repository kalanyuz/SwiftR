//
//  SRPlotSegment.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/14/15.
//  Copyright © 2017 KalanyuZ. All rights reserved.
//

#if os(iOS)
	import Foundation
	import UIKit
#elseif os(macOS)
	import Cocoa
#endif

open class SRPlotSegment : NSObject, CALayerDelegate {

    open let layer = CALayer()
    
    open var axeSystem : SRPlotAxe?
    open var index: Int = 0;
    open var dataStorage = [[Double]]()

    
    required override public init() {
        super.init()
        layer.delegate = self
        layer.isOpaque = false
        layer.anchorPoint = CGPoint(x: 0, y: 0.5)
    }
    
    convenience init(axesSystem axe: SRPlotAxe, channels: Int) {
        self.init()
        self.axeSystem = axe
        self.index = 60
        dataStorage = [[Double]](repeating: [Double](repeating: 0, count: self.index), count: channels)
        self.layer.bounds = CGRect(x: 0, y: 0, width: axeSystem!.graph.pointsPerUnit.x, height: axeSystem!.graph.bounds.height)
    }

    
    open func draw(_ layer: CALayer, in ctx: CGContext) {
        //skip drawing if graph layer does not exist
        if self.axeSystem == nil {
            return
        }
        
        // Draw the graph
        var lines = [CGPoint](repeating: CGPoint.zero, count: 120)
        
        
        //Create Lines
        //FIXME: Will Bezier path gives smoother lines?
        for c in 0 ..< dataStorage.count
        {
            for i in 0  ..< 59  {
                let data = minMaxNormalization(dataStorage[c][i], min: -axeSystem!.graph.maxDataRange, max: axeSystem!.graph.maxDataRange)
                let nextData = minMaxNormalization(dataStorage[c][i+1], min: -axeSystem!.graph.maxDataRange, max: axeSystem!.graph.maxDataRange)
                //merge axis and  min max normalization using its range
                let apy = axeSystem!.graph.anchorPoint.y
                let ppx = axeSystem!.graph.pointsPerUnit.x
                let ppy = axeSystem!.graph.pointsPerUnit.y
                let channelPos = (axeSystem!.signalType == .split) ? CGFloat(c) * ppy : 0
                
                lines[i*2].x = align(CGFloat(i) * (ppx / 60))
				lines[i*2+1].x = align(CGFloat(i+1) * (ppx / 60))
                lines[i*2].y = (channelPos + (self.layer.bounds.height * apy)) + (CGFloat(data) * ppy)
                lines[i*2+1].y =  (channelPos + (self.layer.bounds.height * apy)) + (CGFloat(nextData) * ppy)
            }
            //get prism color for each specific channel
            ctx.setLineWidth(1.5)
            ctx.setStrokeColor(SRColor.prismColor[c].cgColor)
			ctx.strokeLineSegments(between: lines)
        }
        
    }
    
    open func reset()
    {
        // Clear out our components and reset the index to 60 to start filling values again...
        for i in 0 ..< dataStorage.count {
            dataStorage[i] = [Double](repeating: 0, count: 60)
        }
        
        index = 60;
        // Inform Core Animation that we need to redraw this layer.
        layer.setNeedsDisplay()
    }
    
    open func isFull() -> Bool {
        // Simple, this segment is full if there are no more space in the history.
        return index == 0;
    }
    
    open func isVisibleInRect(_ r: CGRect)-> Bool {
        // Just check if there is an intersection between the layer's frame and the given rect.
        // but return to when the graph is coming from left-off-screen (still invisible)
        
        if layer.frame.origin.x < r.origin.x {
            return true
        }
        
        return r.intersects((layer.frame));
    }
    
    open func add(_ data: [Double]) -> Bool {
        
        // If this segment is not full, then we add data value to the history.
        if index > 0
        {
            // First decrement, both to get to a zero-based index and to flag one fewer position left
            index -= 1;
            
            // prevent index out of bounds issue
            let lastAvailableChannel = min(data.count, dataStorage.count)
            for i in 0  ..< lastAvailableChannel  {
                dataStorage[i][index] = data[i]
            }
            // And inform Core Animation to redraw the layer.
            layer.setNeedsDisplay();
        }
        // And return if we are now full or not (really just avoids needing to call isFull after adding a value).
        return index == 0;
    }
    
    open func action(for layer: CALayer, forKey event: String) -> CAAction? {
        //nil, null, Nil, NSNull, [NSNull null]? Dang it
        return NSNull()
    }
    
    open func align(_ coordinate: CGFloat) -> CGFloat {
        //align points
        return round(coordinate * layer.contentsScale) / layer.contentsScale
    }
    
    open func minMaxNormalization(_ input: Double, min: Int, max: Int) -> Double {
        let minRange : Double = (axeSystem!.signalType == .split) ? 0 : -1
        return ((input - Double(min))/(Double(max) - Double(min))) * (1 - minRange) + minRange

    }
	
	#if os(macOS)
    override open func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool {
        return true
    }
	#endif
    
}

