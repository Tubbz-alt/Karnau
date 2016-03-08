//
//  QMTypeDef.swift
//  K
//
//  Created by sphota on 1/20/16.
//  Copyright © 2016 Lex Levi. All rights reserved.
//

import Foundation

let MAX_MAGNITUDE : UInt = 6
let IMPLICANT_FLAG : UInt  = 999
let PRIME_FLAG : UInt = 888

/***************************************/
class QMMinterm : NSObject
	/***************************************/
{
	let vars = ["A", "B", "C", "D", "E", "F"]
	var intValue: UInt = 0;
	var stringValue: String = "";
	var letters: String = "";
	var count: Int = 0;
	var magnitude: UInt = 0;
	var matches	: [QMMinterm] = []
	var paired: Bool = false
	var essential: Bool = false
	var tag: String = ""
	
	init(i: UInt, m: UInt) {
		if i == IMPLICANT_FLAG {
			self.intValue = IMPLICANT_FLAG;
			self.stringValue = "";
		} else if i == PRIME_FLAG {
			self.intValue = 0
			self.magnitude = 0
		} else {
			if m <= MAX_MAGNITUDE {
				self.magnitude = m;
				self.intValue = i;
				self.stringValue = String(self.intValue, radix: 2);
				
				self.stringValue = "0" * (m - UInt(self.stringValue.characters.count)) + self.stringValue
				for s in self.stringValue.characters {
					if s == "1" { self.letters += vars[self.count] } else { self.letters += (vars[self.count].lowercaseString) }
					self.count++;
				}
			}
		}
		
	}
	convenience init (min1: QMMinterm, min2: QMMinterm, idx: UInt) {
		self.init(i: IMPLICANT_FLAG, m: min1.magnitude)
		var s = min1.stringValue
		s.replaceRange(s.startIndex.advancedBy(Int(s.characters.count - 1) - Int(idx))...s.startIndex.advancedBy(Int(s.characters.count - 1) - Int(idx)), with: "-")
		self.stringValue = s
	}
	
	convenience init(str: String, magnitude: UInt) {
		self.init(i: PRIME_FLAG, m: magnitude)
		self.magnitude = UInt(str.characters.count)
	}
	
	func print() {
		if self.intValue != IMPLICANT_FLAG || self.intValue != PRIME_FLAG {
			Swift.print("\(stringValue) : \(intValue) : \(letters)");
		}
		else {
			Swift.print(self.stringValue + " " + self.matches.debugDescription)
		}
		
	}
}

/* This is the class to store the final equation */
/***************************************/
class QMProductSum : NSObject
	/***************************************/
{
	let vars = ["A", "B", "C", "D", "E", "F"]
	var products : [QMMinterm] = []
	/* format: "ABC + ABC + ABC + . . ." */
	var stringValue : String;
	
	init(withProducts: [QMMinterm], magnitude: UInt) {
		stringValue = "";
		
		for p in withProducts {
			products.append(p)
		}
	}
	
	func convertToLetters () {
		for p in products {
			for var i = 0; i < p.stringValue.characters.count; i++ {
				if p.stringValue[i] == Character("1") {
					self.stringValue += vars[i]
				}
				else if p.stringValue[i] == Character("0") {
					self.stringValue += vars[i] + "'"
				}
				else {
					self.stringValue += ""
				}
			}
			self.stringValue += " + "
		}
		
	}
	
	func print () {
		convertToLetters()
		// remove trailing plus sign
		stringValue.removeAtIndex(stringValue.startIndex.advancedBy(stringValue.characters.count - 1))
		stringValue.removeAtIndex(stringValue.startIndex.advancedBy(stringValue.characters.count - 1))
		Swift.print(self.stringValue)
	}
}

