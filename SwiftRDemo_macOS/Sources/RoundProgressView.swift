//
//  RoundProgressView.swift
//  SMKTunes
//
//  Created by Kalanyu Zintus-art on 11/1/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa
import Foundation
import SwiftR

protocol RoundProgressProtocol {
    func roundProgressClicked(_ sender: NSView)
}

@IBDesignable class RoundProgressView: NSView {
    fileprivate let innerRing = CAShapeLayer()
    fileprivate let outerRing = CAShapeLayer()
    fileprivate var state = NSOffState
    fileprivate let lineWidth : CGFloat = 10

    open let titleLabel = NSTextLabel()
    
    var showMarker = false
    
    var roundDelegate : RoundProgressProtocol?
    var loadSeconds = 1.0
    
    var title : String {
        get {
            return titleLabel.stringValue
        }
        set {
            titleLabel.stringValue = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layer?.addSublayer(innerRing)
        self.layer?.addSublayer(outerRing)
        
        innerRing.shouldRasterize = true
        innerRing.rasterizationScale = 2
        innerRing.strokeColor = PrismColor()[1].cgColor
        innerRing.fillColor = NSColor.clear.cgColor
        innerRing.lineWidth = lineWidth * 0.8
        innerRing.lineCap = kCALineCapRound
        innerRing.lineDashPattern = nil
        innerRing.lineDashPhase = 0.0
        //testLayer.strokeEnd = 0
        
        
        outerRing.shouldRasterize = true
        outerRing.rasterizationScale = 2
        outerRing.strokeColor = NSColor.white.cgColor
        outerRing.fillColor = NSColor.clear.cgColor
        outerRing.lineWidth = lineWidth
        outerRing.lineCap = kCALineCapRound
        outerRing.lineDashPattern = nil
        outerRing.lineDashPhase = 0.0

        titleLabel.textColor = NSColor.white
        self.addSubview(titleLabel)
        
        self.titleLabel.font = NSFont.boldSystemFont(ofSize: 20)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        var countFieldConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        countFieldConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        
        titleLabel.stringValue = "Title"
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if let currentContext = NSGraphicsContext.current() {
        
        //CGPathMoveToPoint(path, nil, 0, 0)
        //CGPathAddArc(path, nil, 0, 0, 300, 0, CGFloat(M_PI), false)
        let path = CGMutablePath()
//        Swift.print(self.bounds.width)
        var circleSize : CGFloat = min(self.bounds.width/2, self.bounds.height/2)
        let margin = lineWidth + 10
//        CGPathAddArc(path, nil, self.bounds.midX, self.bounds.midY, circleSize - (lineWidth + innerRing.lineWidth) , CGFloat(-M_PI/2), CGFloat(19 * M_PI / 12.6), true)
				let midPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
				
				path.addArc(center: midPoint, radius: circleSize - (lineWidth + innerRing.lineWidth), startAngle: CGFloat(-M_PI/2), endAngle: CGFloat(19 * M_PI / 12.6), clockwise: true)
        //CGPathAddArc(path, nil, 100, 100, 100, 0, (360 * CGFloat(M_PI))/180, true);
        
        circleSize = min(self.bounds.width, self.bounds.height) - margin
        
        let path2 = CGMutablePath()
//        CGPathAddEllipseInRect(path2, nil, CGRect(x: self.bounds.midX - (circleSize/2), y: self.bounds.midY - (circleSize/2), width: circleSize, height: circleSize))
        path2.addEllipse(in: CGRect(x: self.bounds.midX - (circleSize/2), y: self.bounds.midY - (circleSize/2), width: circleSize, height: circleSize))
        outerRing.path = path2
        innerRing.path = path
        innerRing.strokeEnd = 0
        
            if showMarker {
                currentContext.cgContext.saveGState()
                //3 - move top left of context to the previous center position
                currentContext.cgContext.translateBy(x: bounds.width/2, y: bounds.height/2)
                
                let markerHeight = self.lineWidth / 4
                let markerWidth = self.lineWidth * 2.5
                
                for i in 0...1 {
                    let markerPath = CGPath(rect: CGRect(x: -markerHeight / 2, y: 0, width: markerHeight, height: markerWidth), transform: nil)
                    //4 - save the centred context
                    currentContext.cgContext.saveGState()
                    
                    //5 - calculate the rotation angle
                    
                    //rotate and translate
                    currentContext.cgContext.rotate(by: deg2rad(180.0 * CGFloat(i)) + CGFloat(M_PI/2))
                    currentContext.cgContext.translateBy(x: 0, y: circleSize/2 - markerWidth)
                    currentContext.cgContext.addPath(markerPath)

                    let color = PrismColor()
                    color[3].set()

                    
                    //6 - fill the marker rectangle
                    currentContext.cgContext.fillPath()
                    
                    currentContext.cgContext.restoreGState()
                }
                    
                currentContext.cgContext.restoreGState()
                        
            }
        // Drawing code here.
        }
    }
    
    override func layout() {
        super.layout()
        titleLabel.font = NSFont.boldSystemFont(ofSize: resizeFontWithString(titleLabel.stringValue))
        titleLabel.sizeToFit()
        titleLabel.frame.origin = CGPoint(x: self.bounds.midX - titleLabel.bounds.width/2, y: self.bounds.midY - titleLabel.bounds.height/2)
    }
    
    fileprivate func loadProgressForSeconds(_ seconds: Double) {
        CATransaction.begin()
//        CATransaction.setCompletionBlock {
//            self.state = NSOnState
//        }
        let animate = CABasicAnimation(keyPath: "strokeEnd")
        animate.toValue = 1
        animate.duration = seconds
        animate.repeatCount = 1
        animate.fillMode = kCAFillModeForwards
        animate.isRemovedOnCompletion = false

        innerRing.add(animate, forKey: "strokeEnd")
        CATransaction.commit()
    }
    
    fileprivate func removeProgress() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            let animate = CABasicAnimation(keyPath: "strokeEnd")
            animate.toValue = 0
            animate.duration = 0
            animate.repeatCount = 1
            animate.fillMode = kCAFillModeForwards
            animate.isRemovedOnCompletion = false
            self.innerRing.add(animate, forKey: "strokeEnd")
            CATransaction.commit()
        })
        let animate = CABasicAnimation(keyPath: "opacity")
        animate.toValue = 0
        animate.duration = 0.5
        animate.repeatCount = 1
        animate.fillMode = kCAFillModeForwards
        animate.isRemovedOnCompletion = true
        
        innerRing.add(animate, forKey: "opacity")

        CATransaction.commit()
    }

    fileprivate func resizeFontWithString(_ title: String) -> CGFloat {
        //        defer {
        //            Swift.print(textSize, self.bounds, displaySize)
        //        }
        
        let smallestSize : CGFloat = 10
        let largestSize : CGFloat = 40
        var textSize = CGSize.zero
        var displaySize = smallestSize
        
        while displaySize < largestSize {
            let nsTitle = NSString(string: title)
            let attributes = [NSFontAttributeName: NSFont.boldSystemFont(ofSize: displaySize)]
            textSize = nsTitle.size(withAttributes: attributes)
            if textSize.width < self.bounds.width - (lineWidth * 2) * 4 {
                //                Swift.print(displaySize, "increasing")
                displaySize += 1
            } else {
                Swift.print(displaySize)
                return displaySize
            }
        }
        return largestSize
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        state = (state == NSOnState ? NSOffState : NSOnState)
        
        if let delegate = roundDelegate {
            if state == NSOnState {
                delegate.roundProgressClicked(self)
                loadProgressForSeconds(self.loadSeconds)
            } else {
                removeProgress()
            }
        }
    }
    
    fileprivate func deg2rad(_ degree: CGFloat) -> CGFloat {
        return degree * CGFloat(M_PI) / CGFloat(180.0)
    }
}
