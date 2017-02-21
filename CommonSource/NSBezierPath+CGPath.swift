//
//  NSBezierPath+CGPath.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/16/15.
//  Copyright © 2017 KalanyuZ. All rights reserved.
// Credit : icodeforlove
// URL : https://gist.github.com/jorgenisaksson/76a8dae54fd3dc4e31c2

extension NSBezierPath {
	var cgPath : CGPath {
		let path = CGMutablePath()
		var didClosePath = false
		
		for i in 0...self.elementCount-1 {
			var points = [NSPoint](repeating: NSZeroPoint, count: 3)
			
			switch self.element(at: i, associatedPoints: &points) {
			case .moveToBezierPathElement:path.move(to: points[0])
			case .lineToBezierPathElement:path.addLine(to: points[0])
			case .curveToBezierPathElement:path.addCurve(to: points[0], control1: points[1], control2: points[2])
			case .closePathBezierPathElement:path.closeSubpath()
			didClosePath = true;
			}
		}
		
		if !didClosePath {
			path.closeSubpath()
		}
		let result = path.copy() ?? CGMutablePath()
		
		return result
	}
}
