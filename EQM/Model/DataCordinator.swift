//
//  DataCordinator.swift
//  EQM
//
//  Created by Nahum Jovan Aranda López on 10/03/16.
//  Copyright © 2016 Nahum Jovan Aranda López. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

enum EntityName: String {
    case Metadata = "Metadata"
    case Feature = "Feature"
}

class DataCordinator {
    let json: JSON?
    let service: EQMServices
    
    init(data: AnyObject, service: EQMServices) {
        self.json = JSON(data)
        self.service = service
    }
    
    func parse(completion: (data: [NSManagedObjectID]?, error: NSError? ) -> ()) {
        switch (self.service) {
        case EQMServices.AllHourFeed:
            if let context = CoreDataStack.createPrivateContext() {
                context.performBlock({ () -> Void in
                    do {
                        if let metadata = try self.updateMetadata(context) {
                            let features = try self.updateFeatures(metadata, context: context)
                            
                            try context.save()
                            CoreDataStack.saveContext({ (success, error) -> () in
                                if error != nil {
                                    completion(data: nil, error: error)
                                    return
                                }
                                completion(data: features, error: nil)
                            })
                            
                        }
                    }
                    catch (let error as NSError) {
                        completion (data: nil, error: error)
                    }
                })

            }
            break
        }
    }
    
    private func updateMetadata(context: NSManagedObjectContext) throws -> Metadata?  {
        let fetchRequest = NSFetchRequest(entityName: EntityName.Metadata.rawValue)
        
        if let fetchedObjects = try context.executeFetchRequest(fetchRequest) as? [Metadata] {
            let metadata: Metadata
            if fetchedObjects.count > 0 {
                metadata = fetchedObjects.last!
            }
            else {
                metadata = NSEntityDescription.insertNewObjectForEntityForName(EntityName.Metadata.rawValue, inManagedObjectContext: context) as! Metadata
            }
            
            if let properties = self.json?["metadata"] {
                metadata.title = properties["title"].string
                metadata.generated = properties["generated"].number
            }
            else {
                throw NSError(domain: CoreDataStack.errorDomain, code: ErrorCode.CantCreateMetadata.rawValue, userInfo: nil)
            }
            
            return metadata
        }
        
        return nil
        
    }

    private func updateFeatures(metadata: Metadata, context: NSManagedObjectContext) throws -> [NSManagedObjectID] {
        if let features = metadata.features {
            for feature in features  {
                context.deleteObject(feature as! Feature)
            }
        }
        
        var returnFeatures = [NSManagedObjectID]()
        if let features = self.json?["features"].array {
            for var featureInfo in features {
                let feature = NSEntityDescription.insertNewObjectForEntityForName(EntityName.Feature.rawValue, inManagedObjectContext: context) as! Feature
                
                feature.id = featureInfo["id"].string
                if let properties = featureInfo["properties"].dictionary {
                    feature.magnitude = properties["mag"]?.decimalNumber
                    feature.place = properties["place"]?.string
                    
                    if let time = properties["time"]?.double {
                        feature.date = NSDate(timeIntervalSince1970: time / 1000)
                    }
                    
                    if let updated = properties["updated"]?.double {
                        feature.updatedAt = NSDate(timeIntervalSince1970: updated / 1000)
                    }
                }
                
                if let geometry = featureInfo["geometry"]["coordinates"].array where geometry.count > 2 {
                    feature.longitude = geometry[0].decimalNumber
                    feature.latitude = geometry[1].decimalNumber
                    feature.depth = geometry[2].decimalNumber
                    
                }
                
                feature.metadata = metadata
                returnFeatures.append(feature.objectID)
            }
        }
        else {
            throw NSError(domain: CoreDataStack.errorDomain, code: ErrorCode.CantCreateFeatures.rawValue, userInfo: nil)
        }
        
        return returnFeatures
    }
}