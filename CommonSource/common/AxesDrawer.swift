//
//  AxesDrawer.swift
//  Calculator
//
//  Credit: CS193p, 2015 Stanford University.
//  Created by Kalanyu Zintus-art on 10/27/15.
//  Copyright © 2017 KalanyuZ. All rights reserved.


open class AxesDrawer
{
    open var maxDataRange : Int = 1
    
    //padding parameter, moves the axes further in
    open var padding = CGPoint.zero
    
    open var color = SRColor.gray
    
//    var color = SRColor.redColor()
    
    
    // set this from UIView's contentScaleFactor to position axes with maximum accuracy
    open var contentScaleFactor: CGFloat = 1
    
    
    //public variables for declaring drawing coordinates to data-drawers
    open var pointsPerUnit = CGPoint.zero
    open var bounds = CGRect.zero
    open var position = CGPoint.zero
    open var plotFrame = CGRect.zero
    open var numberOfSubticks : CGFloat = 0
    open var displayLabels = true
    
    open var anchorPoint = CGPoint.zero
    
    convenience init(color: SRColor, contentScaleFactor: CGFloat) {
        self.init()
        self.color = color
        self.contentScaleFactor = contentScaleFactor
    }
    
    convenience init(color: SRColor) {
        self.init()
        self.color = color
    }
    
    convenience init(contentScaleFactor: CGFloat) {
        self.init()
        self.contentScaleFactor = contentScaleFactor
    }
    
    // this method is the heart of the AxesDrawer
    // it draws in the current graphic context's coordinate system
    // therefore origin and bounds must be in the current graphics context's coordinate system
    // pointsPerUnit is essentially the "scale" of the axes
    // e.g. if you wanted there to be 100 points along an axis between -1 and 1,
    //    you'd set pointsPerUnit to 50
    open func drawAxesInRect(_ context: CGContext, bounds: CGRect, axeOrigin: CGPoint, xPointsToShow: CGFloat, yPointsToShow: CGFloat = 1, numberOfTicks: Int = 0, maxDataRange: Int = 1)
    {
		#if os(iOS)
		context.translateBy(x: 0.0, y: bounds.height)
		context.scaleBy(x: 1.0, y: -1.0)
		#endif
		
        //DRAWING IN LAYER CANNOT BE DONE USING NSPath Stroke
//        color.set()
        self.numberOfSubticks = CGFloat(numberOfTicks)
        self.maxDataRange = max(maxDataRange, 1)

        let ppX = (bounds.width - padding.x) / (xPointsToShow + (displayLabels ? 0.5: 0))
        var ppY = (bounds.height - padding.y) / (yPointsToShow + (displayLabels ? 0.5: 0))
		
        let posX = (bounds.origin.x + padding.x)
		
		//FIXME: posY is calculated from anchorPoint 0,0, cause bug with negative Y range
        let posY = (bounds.origin.y + padding.y) + ((bounds.height - padding.y) * anchorPoint.y)
        let position = CGPoint(x: posX, y: posY )

    
        //if pointsPerY is not assigned (or default)
        if yPointsToShow == 0 {
            ppY = ppX
        }
    
        self.pointsPerUnit.x = ppX
        self.pointsPerUnit.y = ppY
        self.bounds = bounds
        self.bounds = bounds
        self.position = position
    
        let path = SRBezierPath()
        context.beginPath()
    
        path.lineWidth = 1
        
        let lineHalfWidth = path.lineWidth / 2
        

        context.setFillColor(SRColor(red: 1, green: 1, blue: 1, alpha: 0.95).cgColor)

        context.fill(CGRect(x: bounds.minX + padding.x, y: bounds.minY + padding.y, width:  bounds.width, height: bounds.height))
        
        //draw x-axis
        path.move(to: CGPoint(x: bounds.minX + padding.x, y: align(position.y + lineHalfWidth)))
        path.line(to: CGPoint(x: bounds.maxX, y: align(position.y + lineHalfWidth)))
        
        //draw y-axis
        path.move(to: CGPoint(x: align(position.x + lineHalfWidth), y: align(bounds.minY + padding.y) ))
        path.line(to: CGPoint(x: align(position.x + lineHalfWidth), y: bounds.maxY))
		
        //closing the borders on all four sides (incase where the origin is not (0,0)
        path.move(to: CGPoint(x: bounds.minX + padding.x, y: bounds.minY + padding.y + lineHalfWidth))
        path.line(to: CGPoint(x: bounds.minX + padding.x, y: bounds.maxY - lineHalfWidth))
		
        path.move(to: CGPoint(x: bounds.minX + padding.x, y: bounds.maxY - lineHalfWidth))
        path.line(to: CGPoint(x: bounds.maxX, y: bounds.maxY - lineHalfWidth))
        
        path.move(to: CGPoint(x: bounds.maxX - lineHalfWidth, y: bounds.maxY - lineHalfWidth))
        path.line(to: CGPoint(x: bounds.maxX - lineHalfWidth, y: bounds.minY + padding.y))
        
        path.move(to: CGPoint(x: bounds.minX + padding.x, y: bounds.minY + padding.y + lineHalfWidth))
        path.line(to: CGPoint(x: bounds.maxX, y: bounds.minY + padding.y + lineHalfWidth))
        
        context.addPath(path.cgPath)
        context.setStrokeColor(SRColor.gray.cgColor)
        context.setLineWidth(1)
        context.strokePath()
        path.removeAllPoints()
        
        context.beginPath()
    
        for gridSpacing in stride(from: align(bounds.minX + padding.x), to: bounds.maxX, by: align(ppX)) {
            path.move(to: CGPoint(x: align(gridSpacing), y: align(bounds.minY + padding.y)))
            path.line(to: CGPoint(x: align(gridSpacing), y: bounds.maxY))
        }
        for gridSpacing in stride(from: align(posY), to: bounds.maxY, by: align(ppY) / numberOfSubticks) {
            path.move(to: CGPoint(x: bounds.minX + padding.x, y: align(gridSpacing)))
            path.line(to: CGPoint(x: bounds.maxX, y: align(gridSpacing)))
        }
		
        for gridSpacing in stride(from: align(posY), to: bounds.minY, by: align(ppY)) {
            path.move(to: CGPoint(x: bounds.minX + padding.x, y: align(gridSpacing)))
            path.line(to: CGPoint(x: bounds.maxX, y: align(gridSpacing)))
        }
		
        context.addPath(path.cgPath)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(0.25)
        context.strokePath()
		
    }



    
    // we want the axes and hashmarks to be exactly on pixel boundaries so they look sharp
    // setting contentScaleFactor properly will enable us to put things on the closest pixel boundary
    // if contentScaleFactor is left to its default (1), then things will be on the nearest "point" boundary instead
    // the lines will still be sharp in that case, but might be a pixel (or more theoretically) off of where they should be
    
    open func alignedPoint(x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = insideBounds {
            if (!permissibleBounds.contains(point)) {
                return nil
            }
        }
        return point
    }
    
    open func align(_ coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
}

extension CGRect
{
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}
