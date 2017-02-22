//
//  NSSpashBGView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/27/15.
//  Copyright © 2017 KalanyuZ. All rights reserved.
//


public struct SplashBGPosition {
    var TopLeft = CGPoint(x:0, y:1)
    var TopRight = CGPoint(x:1, y:1)
    var BottomLeft = CGPoint(x:0 ,y:0)
    var BottomRight = CGPoint(x:1, y:0)
}

public enum SplashDirection {
    case left
    case right
}

public protocol SRSplashViewDelegate {
    func splashAnimationEnded(startedFrom from: SplashDirection)
}

#if os(macOS)
	extension SRSplashBGView: CALayerDelegate {}
#endif

open class SRSplashBGView: SRView {
    
    public var delegate: SRSplashViewDelegate?
    let splashLayer = CALayer()
    fileprivate var splashColor : SRColor = SRColor.white
    fileprivate let initialSplashSize : CGFloat = 50
    
    required override public init(frame frameRect: SRRect) {
        super.init(frame: frameRect)
		
		#if os(macOS)
			
			self.wantsLayer = true
			self.splashLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
			self.layer?.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
			self.layer?.addSublayer(splashLayer)
		#elseif os(iOS)

			self.layer.addSublayer(splashLayer)
		#endif
		
		self.splashLayer.delegate = self

    }
	
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
		#if os(macOS)
			
			self.wantsLayer = true
			self.splashLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
			self.layer?.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
			self.layer?.addSublayer(splashLayer)
		#elseif os(iOS)
			
			self.layer.addSublayer(splashLayer)
		#endif
    }
    
    override open func draw(_ dirtyRect: SRRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
	
	#if os(macOS)
    open func draw(_ layer: CALayer, in ctx: CGContext) {
	
        if layer === splashLayer {

            let circlePath = SRBezierPath()
            ctx.beginPath()
            circlePath.appendOval(in: CGRect(x: 0 - (initialSplashSize/2),y: 0 - (initialSplashSize/2), width: initialSplashSize, height: initialSplashSize))
            ctx.addPath(circlePath.cgPath)
            ctx.closePath()
            ctx.setFillColor(splashColor.cgColor)
            ctx.fillPath()
        }
    }
	
	override open func fade(toAlpha alpha: CGFloat) {
		super.fade(toAlpha: alpha)
	}
	
	#elseif os(iOS)
	override open func draw(_ layer: CALayer, in ctx: CGContext) {
		
		if layer === splashLayer {
			
			let circlePath = SRBezierPath()
			ctx.beginPath()
			
			circlePath.append(SRBezierPath(ovalIn: CGRect(x: 0 - (initialSplashSize/2),y: 0 - (initialSplashSize/2),width: initialSplashSize, height: initialSplashSize)))
			
			ctx.addPath(circlePath.cgPath)
			ctx.closePath()
			ctx.setFillColor(splashColor.cgColor)
			ctx.fillPath()
		}
	}
	#endif

	
    open func initLayers() {
		
        self.splashLayer.bounds = self.bounds
        self.splashLayer.anchorPoint = CGPoint(x: 0, y: 0)
        self.splashLayer.contentsScale = 2
        self.splashLayer.setNeedsDisplay()
		
    }
	

	
    open func splashFill(toColor color: SRColor,_ splashDirection: SplashDirection) {
        splashColor = color
        splashLayer.setNeedsDisplay()
        self.splashLayer.transform = CATransform3DMakeScale(1, 1, 1)

        if splashDirection == .right {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            let translate = CATransform3DTranslate(self.splashLayer.transform, self.bounds.maxX, 0, 0)
            self.splashLayer.transform = CATransform3DRotate(translate,CGFloat(M_PI), 0, -1, 0)
            CATransaction.commit()
        }
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
			
			#if os(macOS)
				self.layer?.backgroundColor = self.splashColor.cgColor
			#elseif os(iOS)
				self.layer.backgroundColor = self.splashColor.cgColor
			#endif
			
            self.splashLayer.backgroundColor = self.splashColor.cgColor
            self.delegate?.splashAnimationEnded(startedFrom: splashDirection)
            
        })
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.toValue = NSValue(caTransform3D: CATransform3DScale(self.splashLayer.transform, round(self.bounds.size.width * 3 / initialSplashSize), round(self.bounds.size.width * 3 / initialSplashSize), 1))
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        self.splashLayer.add(animation, forKey: "transform")
        CATransaction.commit()
    }
    
	#if os(iOS)
	
    override open func layoutSublayers(of layer: CALayer) {
        splashLayer.setNeedsDisplay()
        self.layer.setNeedsDisplay()
    }
	#elseif os(macOS)
	
	open func layoutSublayers(of layer: CALayer) {
		splashLayer.setNeedsDisplay()
		self.layer!.setNeedsDisplay()
	}
	#endif
	
}
