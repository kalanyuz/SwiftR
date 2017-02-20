//
//  HalfCircleMeterView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/5/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


@IBDesignable open class CountView: SRView {
	
    open var titleField : SRLabel?
    open var countField : SRLabel?

    open var title : String = "" {
        didSet {
			#if os(macOS)
            self.titleField?.stringValue = self.title
			#elseif os(iOS)
			self.titleField?.text = self.title
			#endif
        }
    }
    
    open var directionValue : Int? {
        get {
            return NumberFormatter().number(from: self.countText)?.intValue
        }
        set {
            if let countNumber = NumberFormatter().string(from: NSNumber(value: newValue! as Int)) {
                if newValue > 0 {
                    self.countText = "+\(countNumber)"
                } else if newValue <= 0 {
                    self.countText = countNumber
                }
            } else {
                self.countText = "0"
            }
        }
    }
    
    open var countText : String = "0" {
        didSet {
            //already has layout constraints, no need for frame adjustment
            //TODO:size adjustments for readability
			#if os(macOS)
			countField?.stringValue = self.countText
			#elseif os(iOS)
			countField?.text = self.countText
			#endif
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        titleField = SRLabel(frame: CGRect.zero)
        countField = SRLabel(frame: CGRect.zero)
        
        titleField?.textColor = SRColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        countField?.textColor = SRColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)

        self.addSubview(titleField!)
        self.addSubview(countField!)
        
        self.titleField?.font = SRFont.boldSystemFont(ofSize: 20)
        self.countField?.font = SRFont.systemFont(ofSize: 100)
        self.countField?.translatesAutoresizingMaskIntoConstraints = false
        var countFieldConstraint = NSLayoutConstraint(item: self.countField!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        countFieldConstraint = NSLayoutConstraint(item: self.countField!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        
        self.titleField?.translatesAutoresizingMaskIntoConstraints = false
        let titleFieldConstraint = NSLayoutConstraint(item: self.titleField!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(titleFieldConstraint)

		#if os(macOS)
			
        countField?.stringValue = "0"
        titleField?.stringValue = "Title"
        self.wantsLayer = true
			
		#elseif os(macOS)
			
		countField?.text = "0"
		titleField?.text = "Title"
			
		#endif

    }
    
	#if os(macOS)
    override open func layout() {
        super.layout()
        countField?.font = SRFont.boldSystemFont(ofSize: resizeFontWithString(countField!.stringValue))
    }
	#endif
	
    fileprivate func resizeFontWithString(_ title: String) -> CGFloat {
//        defer {
//            Swift.print(textSize, self.bounds, displaySize)
//        }
        
        let smallestSize : CGFloat = 100
        let largestSize : CGFloat = 200
        var textSize = CGSize.zero
        var displaySize = smallestSize
        
        while displaySize < largestSize {
            let nsTitle = NSString(string: title)
            let attributes = [NSFontAttributeName: SRFont.boldSystemFont(ofSize: displaySize)]
			
			#if os(macOS)
            textSize = nsTitle.size(withAttributes: attributes)
			#elseif os(iOS)
			textSize = nsTitle.size(attributes: attributes)
			#endif
			
            if textSize.width < self.bounds.width * 0.8 {
                displaySize += 1
            } else {
                return displaySize
            }
        }
        return largestSize
    }
}
