//
//  DataManager.swift
//  EQM
//
//  Created by Nahum Jovan Aranda López on 10/03/16.
//  Copyright © 2016 Nahum Jovan Aranda López. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

enum EQMServices: String {
    case AllHourFeed = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"
}

class DataManager {
    let HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]

    
    private func retrieveData(functionType: EQMServices, completion: (JSON: AnyObject?, error: NSError?) -> ()) {
        Alamofire.Manager.sharedInstance.request(.GET, EQMServices.AllHourFeed.rawValue, parameters: nil, encoding: .JSON, headers: self.HTTPHeaders).validate().responseJSON(completionHandler: { (response) -> Void in
            if let JSON = response.result.value where response.result.error == nil {
                print("(GET) JSON -> \(JSON)")
                completion(JSON: JSON, error: nil)
            }
            else {
                completion(JSON: nil, error: response.result.error)
            }
        })
    }

    
    func startFeed(completion: ((data: [NSManagedObjectID]?, error: NSError?) -> ())? = nil)  {
        self.retrieveData(.AllHourFeed) { (JSON, error) -> () in
            if error == nil {
                let dataCordinator = DataCordinator(data: JSON!, service: .AllHourFeed)
                dataCordinator.parse { (data, error) -> () in
                    completion?(data: data, error: error)
                }
            }
        }
        
    }
    
    func retrieveTitle() -> String {
        let notAvailableTitle = "Not Available"
        if let context = CoreDataStack.sharedInstance.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: EntityName.Metadata.rawValue)
            
            do {
                if let fetchedObjects = try context.executeFetchRequest(fetchRequest) as? [Metadata] {
                    if fetchedObjects.count > 0 {
                        return fetchedObjects.last!.title ?? notAvailableTitle
                    }
                }
            }
            catch {
                return notAvailableTitle
            }
        }
        
        return notAvailableTitle
    }
}