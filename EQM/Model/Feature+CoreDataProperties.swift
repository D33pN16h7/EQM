//
//  Feature+CoreDataProperties.swift
//  
//
//  Created by Nahum Jovan Aranda López on 10/03/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Feature {

    @NSManaged var id: String?
    @NSManaged var latitude: NSDecimalNumber?
    @NSManaged var longitude: NSDecimalNumber?
    @NSManaged var depth: NSDecimalNumber?
    @NSManaged var magnitude: NSDecimalNumber?
    @NSManaged var place: String?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var date: NSDate?
    @NSManaged var metadata: Metadata?

}
