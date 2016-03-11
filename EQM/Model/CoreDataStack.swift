//
//  CoreDataStack.swift
//  Rides
//
//  Created by Nahum Jovan Aranda López on 28/07/14.
//  Copyright (c) 2014 Nahum Jovan Aranda Lopez. All rights reserved.
//

import Foundation
import CoreData

typealias FinishLoginClosure = (success:Bool, identifier: String?, token: String?, error:NSError?) -> ()
typealias FinishClosure = (success:Bool, error:NSError?) -> ()


class CoreDataStack {
    static let errorDomain = "com.d33pn16h7.EQM"
    class var sharedInstance: CoreDataStack {
    struct Singleton {
        static let instance = CoreDataStack()
        }
        return Singleton.instance
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("EQM", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationCacheDirectory.URLByAppendingPathComponent("EQM.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ];
        
        do {
        try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        }
            catch (var error as NSError) {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
                
            error = NSError(domain: CoreDataStack.errorDomain, code: 9999, userInfo: ((dict as NSDictionary) as! [NSObject : AnyObject]))
            // Replace this with code to handle the error appropriately.
            // a bort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var privateObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.

        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.privateObjectContext
        return managedObjectContext
        }()
    
    lazy var applicationCacheDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.d33pn16h7.dev.Rides" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    
    class func createPrivateContext() -> NSManagedObjectContext?
    {
        let newPrivateManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        newPrivateManagedObjectContext.parentContext = CoreDataStack.sharedInstance.managedObjectContext
        newPrivateManagedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return newPrivateManagedObjectContext
    }
    
    // MARK: - Core Data Saving support
    class func saveContext(finishClosure:FinishClosure?)
    {
        if let privateObjectContext = CoreDataStack.sharedInstance.privateObjectContext
        {
            if let managedObjectContext = CoreDataStack.sharedInstance.managedObjectContext
            {
                managedObjectContext.performBlockAndWait {
                    if(managedObjectContext.hasChanges) {
                        do {
                            try managedObjectContext.save()
                            
                            privateObjectContext.performBlockAndWait{
                                if privateObjectContext.hasChanges {
                                    
                                    do {
                                        try privateObjectContext.save()
                                        try privateObjectContext.save()
                                        privateObjectContext.processPendingChanges()
                                        if let finish = finishClosure {
                                            finish(success:true, error: nil)
                                        }
                                    }
                                    catch (let error as NSError) {
                                        if let finish = finishClosure {
                                            finish(success:false, error:error)
                                        }
                                    }
                                }
                                else if let finish = finishClosure {
                                    finish(success: true, error: nil)
                                }

                            }
                            
                        }
                        catch (let error as NSError) {
                            if let finish = finishClosure {
                                finish(success:false, error:error)
                            }
                        }
                    }
                    else {
                        if let finish = finishClosure {
                            finish(success: true, error: nil)
                        }
                    }
                }
                
            }
        }
    }
}
