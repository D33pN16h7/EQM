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
import CoreLocation
import MapKit

protocol DetailViewViewModel {
    var coordinate: CLLocationCoordinate2D { get }
    var depth: String { get }
    var magnitude: String { get }
    var magnitudeDescription: String { get }
    var place: String { get }
    var date: String { get }
    var time: String { get }
    var color: UIColor { get }
}

class QuakeAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    let color: UIColor
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, color: UIColor?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.color = color ?? Magnitude.Unknown.color
    }
}

struct DetailViewViewModelFromFeature: DetailViewViewModel {
    let coordinate: CLLocationCoordinate2D
    let depth: String
    let magnitude: String
    let magnitudeDescription: String
    let place: String
    let date: String
    let time: String
    let color: UIColor
    let objectID: NSManagedObjectID
    
    init(objectID: NSManagedObjectID) throws {
        self.objectID = objectID
        if let context = CoreDataStack.sharedInstance.managedObjectContext {
            if let feature = try context.existingObjectWithID(objectID) as? Feature {
                self.place = feature.place ?? "Unknown"
                self.magnitude = "\(feature.magnitude ?? 0.0)"
                self.magnitudeDescription = "Magnitude: \(feature.magnitude ?? 0.0)"
                self.depth = "\(feature.depth ?? 0.0)km"
                
                let df = NSDateFormatter()
                
                df.locale = NSLocale.currentLocale()
                df.timeZone = NSTimeZone.localTimeZone()
                
                if let date = feature.date {
                    df.dateFormat = "dd/MMM/yyyy"
                    self.date = df.stringFromDate(date)
                    
                    df.dateFormat = "HH:mm:ss zzz"
                    self.time = df.stringFromDate(date)
                }
                else {
                    self.date = " - "
                    self.time = " - "
                }
                
                self.color = Magnitude(value: feature.magnitude?.doubleValue).color
                self.coordinate = CLLocationCoordinate2DMake(feature.latitude?.doubleValue ?? 0.0, feature.longitude?.doubleValue ?? 0.0)
                
                
                return
            }
        }
        
        self.place = "Unknown"
        self.magnitude = "0.0"
        self.magnitudeDescription = "Magnitude: 0.0"

        self.depth = " - "
        self.date = " - "
        self.time = " - "
        self.color = Magnitude.Unknown.color
        self.coordinate = CLLocationCoordinate2DMake(0.0, 0.0)
    }
}