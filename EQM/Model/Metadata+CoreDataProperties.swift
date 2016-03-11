//
//  Metadata+CoreDataProperties.swift
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

extension Metadata {

    @NSManaged var title: String?
    @NSManaged var generated: NSNumber?
    @NSManaged var features: NSSet?

}
