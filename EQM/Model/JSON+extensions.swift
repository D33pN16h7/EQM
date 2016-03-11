//
//  JSON+extensions.swift
//  EQM
//
//  Created by Nahum Jovan Aranda López on 10/03/16.
//  Copyright © 2016 Nahum Jovan Aranda López. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    public var decimalNumber: NSDecimalNumber? {
        get {
            if let number = self.number {
                return NSDecimalNumber(decimal: number.decimalValue)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(double: newValue.doubleValue)
            } else {
                self.object = NSNull()
            }
        }
    }

}