//
//  Mesh.swift
//  KK
//
//  Created by sphota on 2/17/16.
//  Copyright © 2016 Lex Levi. All rights reserved.
//

import Foundation
import UIKit

class Mesh: UIView {
	
	var magnitude = 0
	var qmmap: QMMap?
	var thickness = 1
	lazy var table = [Int]()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.backgroundColor = UIColor.clearColor()
		
	}
	
	convenience init(frame:CGRect, magnitude: Int, table: [Int]) {
		self.init(frame: frame)
		self.magnitude = magnitude
		self.table = table
		self.qmmap = QMMap(minterms: table, magnitude: UInt(magnitude), bounds: self.bounds)
		self.initCoordinates()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func drawRect(rect: CGRect) {
		self.drawMesh(rect)
	}
	
	func drawBezierLine (start start: CGPoint, end: CGPoint) {
		let bezierPath = UIBezierPath()
		bezierPath.moveToPoint(start)
		bezierPath.addLineToPoint(end)
		bezierPath.lineWidth = 3
		
		UIColor.whiteColor().setFill()
		bezierPath.fill()
		UIColor.whiteColor().setStroke()
		bezierPath.stroke()
	}
	
	func drawMesh(frame: CGRect) {
		
		if magnitude == 2 {
			drawBezierLine(start: CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds)),
				end: CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds)))
			
			drawBezierLine(start: CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)),
				end: CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds)))
		}
			
		else if magnitude == 3 {
			drawBezierLine(start: CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)),
			               end: CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds)))
			
			drawBezierLine(start: CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds)),
			               end: CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds)))
			
			drawBezierLine(start: CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds)/2),
			               end: CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds)/2))
			
			drawBezierLine(start: CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds) + CGRectGetMidY(self.bounds)/2),
			               end: CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds) + CGRectGetMidY(self.bounds)/2))
		}
			
		else if magnitude == 4 || magnitude == 0 {
		drawBezierLine(start: CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds)),
								end: CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds)))
		
		drawBezierLine(start: CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)),
								end: CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds)))
		
		drawBezierLine(start: CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds)/2),
			                    end: CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds)/2))
		
		drawBezierLine(start: CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds) + CGRectGetMidY(self.bounds)/2),
								end: CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds) + CGRectGetMidY(self.bounds)/2))
		
		drawBezierLine(start: CGPointMake(CGRectGetMidX(self.bounds) + CGRectGetMidX(self.bounds)/2, CGRectGetMinY(self.bounds)),
								end: CGPointMake(CGRectGetMidX(self.bounds) + CGRectGetMidX(self.bounds)/2,CGRectGetMaxY(self.bounds)))

		drawBezierLine(start: CGPointMake(CGRectGetMidX(self.bounds) / 2, CGRectGetMinY(self.bounds)),
								end: CGPointMake(CGRectGetMidX(self.bounds) / 2, CGRectGetMaxY(self.bounds)))
		}
		
		else if magnitude == 5 {
			
		}
	}
	
	func initCoordinates() {
		self.qmmap?.initCoordinates()
	}

	func animateMesh() {
		let smallerRectForMask = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), self.frame.size.width / 1.3, self.frame.size.height)
		let mask = CAShapeLayer()
		let maskPath = UIBezierPath(rect: smallerRectForMask)
		
		mask.path = maskPath.CGPath
		mask.fillColor = UIColor.blackColor().CGColor
		
		self.layer.mask = mask
			
		let oldBounds = CGRectMake(mask.bounds.origin.x + 200, mask.bounds.origin.y, mask.bounds.width, mask.bounds.height)
		let newBounds = CGRectMake(oldBounds.origin.x - 500, oldBounds.origin.y, oldBounds.width, oldBounds.height)
			
		let moveToNewPos = CABasicAnimation(keyPath: "bounds")
		moveToNewPos.fromValue = NSValue(CGRect: oldBounds)
		moveToNewPos.toValue = NSValue(CGRect: newBounds)
		moveToNewPos.duration = 1.2
		moveToNewPos.repeatCount = .infinity
		
		let	fadeAnimationTo = CABasicAnimation(keyPath: "opacity")
		fadeAnimationTo.fromValue = NSNumber(float: 0.6)
		fadeAnimationTo.toValue = NSNumber(float: 0.0)
		fadeAnimationTo.duration = 1.2
		fadeAnimationTo.repeatCount = .infinity
		
		let	fadeAnimationFro = CABasicAnimation(keyPath: "opacity")
		fadeAnimationFro.fromValue = NSNumber(float: 0.0)
		fadeAnimationFro.toValue = NSNumber(float: 0.6)
		fadeAnimationFro.duration = 1.2
		fadeAnimationFro.repeatCount = .infinity
		
		self.layer.mask?.bounds = newBounds
			
		self.layer.mask?.addAnimation(moveToNewPos, forKey: "bounds")
		self.layer.mask?.addAnimation(fadeAnimationFro, forKey: "opacity")
		self.layer.mask?.addAnimation(fadeAnimationTo, forKey: "opacity")
	}
	
//	func findCenterOfRect (rect: CGRect) -> CGPoint {
//		
//	}
}