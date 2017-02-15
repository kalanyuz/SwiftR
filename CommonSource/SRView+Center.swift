//
//  NSView+Center.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/16/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

extension SRView {
    var center : CGPoint {
        get {
            Swift.print(self.frame, CGPoint(x: self.frame.origin.x + (self.frame.width / 2), y: self.frame.origin.y + (self.frame.height/2)))
            return CGPoint(x: self.frame.origin.x + (self.frame.width / 2), y: self.frame.origin.y + (self.frame.height/2))
        }
    }
    
    func fade(toAlpha alpha: CGFloat) {
        
        NSAnimationContext.runAnimationGroup({
            (context) -> () in
                if self.isHidden && alpha == 1 {
                    self.isHidden = false
                }
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                self.animator().alphaValue = alpha
            }, completionHandler: {
                if alpha == 0 {
                    self.isHidden = true
                }
        })

    }
}
