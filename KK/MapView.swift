//
//  MapView.swift
//  KK
//
//  Created by sphota on 2/15/16.
//  Copyright © 2016 Lex Levi. All rights reserved.
//

import UIKit

class MapView: UIView {
	let groupErr: UInt = 0b0010
	
	var mesh: Mesh?
	var magnitude: UInt?
	var onCoordinates: [CGPoint]?
	var dcCoordinates: [CGPoint]?
	var mintermButtons: [UIButton] = [UIButton]()
	var offMintermButtons: [UIButton] = [UIButton]()
	var solutions: [QMProductSum]? = [QMProductSum]()
	private var selectedMintermButtons: [UInt : UIButton] = [UInt : UIButton]()
	private var selectedProductSum: QMProductSum = QMProductSum(withProducts: [], magnitude: 0)
	private var isAttemptingWrapAround: Bool = false

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.opaque = false
		self.backgroundColor = bgColor
	}
	
	convenience init(frame: CGRect, magnitude: Int, table: [UInt]) {
		self.init(frame: frame)
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapView.userDidCheckEquation(_:)), name: didCallForCheckEquationNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserverForName(didResetTableOnMapViewNotification, object: nil, queue: nil) { (notification) in
			self.selectedProductSum = QMProductSum(withProducts: [], magnitude: 0)
			for b in self.mintermButtons {
				b.selected = false
				b.backgroundColor = bgColor
			}
			for view in self.subviews {
				if view.tag == -1 {
					UIView .animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
						view.alpha = 0;
						}, completion: { (done) in
							view.removeFromSuperview()
					})
				}
			}
			self.selectedMintermButtons.removeAll()
		}
		
		self.magnitude = UInt(magnitude)
		let mesh = Mesh(frame: self.bounds, magnitude: magnitude, table: table)
		self.mesh = mesh
		self.addSubview(mesh)
		for m in mesh.qmmap!.minterms {
			if (m.state == on) {
				var mintermInMapView: UIButton
				if magnitude > 2 {
					mintermInMapView = UIButton(frame: CGRectMake(m.coordinate!.x - 20, m.coordinate!.y - 20, 40, 40))
				} else {
					mintermInMapView = UIButton(frame: CGRectMake(m.coordinate!.x - 40, m.coordinate!.y - 40, 80, 80))
				}
				mintermInMapView.setTitle("1", forState: UIControlState.Normal)
				mintermInMapView.titleLabel?.textColor = UIColor.whiteColor()
				mintermInMapView.tag = Int((m.minterm?.intValue)!)
				mintermInMapView.userInteractionEnabled = false;
				self.addSubview(mintermInMapView)
				self.mintermButtons.append(mintermInMapView)
			} else {
				var offMintermInMapView: UIButton
				if magnitude > 2 {
					offMintermInMapView = UIButton(frame: CGRectMake(m.coordinate!.x - 20, m.coordinate!.y - 20, 40, 40))
				} else {
					offMintermInMapView = UIButton(frame: CGRectMake(m.coordinate!.x - 40, m.coordinate!.y - 40, 80, 80))
				}
				offMintermInMapView.tag = Int((m.minterm?.intValue)!)
				offMintermInMapView.userInteractionEnabled = false;
				self.addSubview(offMintermInMapView)
				self.offMintermButtons.append(offMintermInMapView)
			}
		}
		NSNotificationCenter.defaultCenter().addObserverForName(didCallForCheckEquationNotification, object: self, queue: nil) { (notification) in
			debugPrint(notification.debugDescription)
			debugPrint("notification called")
			var correct = false
			self.selectedProductSum.print()
			debugPrint(self.selectedProductSum.strRepresentationOfProducts)
			if self.solutions == nil {
				debugPrint("we are fucked")
				return
			} else {
				for e in self.solutions! {
					e.print()
					debugPrint(e.strRepresentationOfProducts)
					if self.selectedProductSum == e {
						correct = true
						break
					}
				}
			}
			if correct {
				debugPrint("correct")
			} else {
				debugPrint("wrong")
			}
			let data = ["correct" : correct]
			NSNotificationCenter.defaultCenter().postNotificationName(didCheckEquationNotification, object: self, userInfo: data)
		}
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
    override func drawRect(rect: CGRect) {
         self.drawMapBorders(rect)
    }
	
	func drawMapBorders(frame: CGRect) {
		let rectanglePath = UIBezierPath(roundedRect: CGRectMake(self.bounds.origin.x, self.bounds.origin.y	, self.bounds.width, self.bounds.height), cornerRadius: 0)
		rectanglePath.lineWidth = 5
		UIColor.whiteColor().setStroke()
		rectanglePath.stroke()
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.isAttemptingWrapAround = false
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = event?.allTouches()?.first
		let touchLocation = touch?.locationInView(self)
		for b in self.mintermButtons {
			if CGRectContainsPoint(b.frame, touchLocation!){
				b.backgroundColor = UIColor(hex: 0x50E3C2, alpha: 0.8)
				b.selected = true;
			}
		}
		if !CGRectContainsPoint(self.bounds, touchLocation!) {
			print(touchLocation!)
			self.isAttemptingWrapAround = true
		}
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		var table = [UInt]()
		var group = [UIButton]()
		for b in self.mintermButtons {
			if b.selected {
				table.append(UInt(b.tag))
				group.append(b)
				b.backgroundColor = bgColor
			}
		}
		if table.count != 0 {
			var equation = QMCore.minimizer.computePrimeProducts(table, magnitude: self.magnitude!)
			var data: [String: QMProductSum] = [String: QMProductSum]()
			if log2(Double(group.count)) % 1 != 0 || equation?.last?.minCount > 1 {
				var data: [String: UInt] = [String: UInt]()
				data["error"] = groupErr
				for b in self.mintermButtons {
					if b.selected {
						b.selected = false;
					}
				}
				self.isAttemptingWrapAround = false
				NSNotificationCenter.defaultCenter().postNotificationName(didSelectGroupNotification, object: self, userInfo: data)
				return
			}
			self.drawRectAroundButtons(group, wrapAround: self.isAttemptingWrapAround)
			// this is the ugliest way of doing things but shoot me, I'm tired
			self.selectedProductSum.addProduct(equation!.last!.products.last!)
			data["data"] = equation?.popLast()
			equation?.removeAll()
			for b in self.mintermButtons {
				if b.selected {
					b.selected = false;
				}
			}
			self.isAttemptingWrapAround = false
			NSNotificationCenter.defaultCenter().postNotificationName(didSelectGroupNotification, object: self, userInfo: data)
		}
	}
	
	func drawRectAroundButtons(buttons: [UIButton], wrapAround: Bool) {
		var frames = [CGRect]()
		for b in buttons {
			frames.append(b.frame)
		}
		while frames.count > 1 {
			frames[0] = CGRectUnion(frames[0], frames[1])
			frames.removeAtIndex(1)
		}
		if wrapAround == true {
			let wholeFrame = frames[0]
			var holeFrame = [CGRect]()
			for b in self.offMintermButtons {
				if wholeFrame.contains(b.frame) {
					holeFrame.append(b.frame)
				}
			}
			for c in self.mintermButtons {
				if wholeFrame.contains(c.frame) && !c.selected {
					holeFrame.append(c.frame)
				}
			}
			while holeFrame.count > 1 {
				holeFrame[0] = CGRectUnion(holeFrame[0], holeFrame[1])
				holeFrame.removeAtIndex(1)
			}
			let grabView = UIView(frame: wholeFrame)
			grabView.addDashedBorder()
			grabView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.2)
			grabView.tag = -1
			let drabView = UIView(frame: holeFrame[0])
			drabView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0.6, alpha: 0.3)
			drabView.layer.borderColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1).CGColor
			drabView.layer.borderWidth = 1
			drabView.tag = -1
			drabView.addDashedBorder()
			self.addSubview(grabView)
			self.addSubview(drabView)
		} else {
			let grabView = UIView(frame: frames[0])
			grabView.addDashedBorder()
			grabView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.2)
			grabView.tag = -1
			self .addSubview(grabView)
		}
	}
}
