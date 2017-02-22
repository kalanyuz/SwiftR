//
//  Constants.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/7/15.
//  Copyright © 2017 KalanyuZ. All rights reserved.
//

#if os(iOS)
	import Foundation
	import UIKit
	public typealias SRColor = UIColor
	public typealias SRView = UIView
	public typealias SRBezierPath = UIBezierPath
	public typealias SRRect = CGRect
	public typealias SRLabel = UILabel
	public typealias SRFont = UIFont
#elseif os(macOS)
	import Cocoa
	public typealias SRColor = NSColor
	public typealias SRView = NSView
	public typealias SRBezierPath = NSBezierPath
	public typealias SRRect = NSRect
	public typealias SRLabel = NSTextLabel
	public typealias SRFont = NSFont
#endif

//public extension SRView {}
