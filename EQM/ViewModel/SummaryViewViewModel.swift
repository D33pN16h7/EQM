//
//  SummaryViewViewModel.swift
//  EQM
//
//  Created by Nahum Jovan Aranda López on 11/03/16.
//  Copyright © 2016 Nahum Jovan Aranda López. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum Magnitude {
    case Unknown
    case Weak
    case Moderate
    case Strong
    case VeryStrong
    case Extreme
    
    init(value: Double?) {
        if let realValue = value {
            switch realValue {
            case 0.0..<1.0:
                self = .Weak
            case 1.0..<5.0:
                self = .Moderate
            case 5.0..<7.0:
                self = .Strong
            case 7.0..<9.0:
                self = .VeryStrong
            case let realValue where realValue >= 9.0:
                self = .Extreme
            default:
                self = .Unknown
            }
            return
        }
        
        self = .Unknown
    }
    
    var color: UIColor {
        switch self {
        case .Unknown:
            return UIColor.lightGrayColor()
        case .Weak:
            return UIColor(red: 63.0/255.0, green: 252.0/255.0, blue: 8.0/255.0, alpha: 1.0)
        case .Moderate:
            return UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        case .Strong:
            return UIColor(red: 255.0/255.0, green: 124.0/255.0, blue: 23.0/255.0, alpha: 1.0)
        case .VeryStrong:
            return UIColor(red: 200.0/255.0, green: 24.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        case .Extreme:
            return UIColor(red: 135.0/255.0, green: 0.0/255.0, blue: 6.0/255.0, alpha: 1.0)
        }
    }
}

protocol SummaryViewViewModel {
    var magnitude: String { get }
    var place: String { get }
    var color: UIColor { get }
}

struct SummaryViewViewModelFromFeature: SummaryViewViewModel {
    let magnitude: String
    let place: String
    let color: UIColor
    let objectID: NSManagedObjectID
    
    init(objectID: NSManagedObjectID) throws {
        self.objectID = objectID
        if let context = CoreDataStack.sharedInstance.managedObjectContext {
            if let feature = try context.existingObjectWithID(objectID) as? Feature {
                self.place = feature.place ?? "Unknown"
                self.magnitude = "\(feature.magnitude ?? 0.0)"
                self.color = Magnitude(value: feature.magnitude?.doubleValue).color
                return
            }
        }
        
        self.place = "Unknown"
        self.magnitude = "0.0"
        self.color = Magnitude.Unknown.color
    }
}