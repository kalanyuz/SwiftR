//
//  NSTextLabel.swift
//  SwiftSigV
//
//  Created by Kalanyu Zintus-art on 2017/02/15.
//  Copyright © 2017 kalanyuz. All rights reserved.
//

open class NSTextLabel: NSTextField {
	
	required override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.isBezeled = false
		self.drawsBackground = false
		self.isEditable = false
		self.isSelectable = false
		self.font = NSFont.systemFont(ofSize: 15)
	}
	
	required public init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
}
