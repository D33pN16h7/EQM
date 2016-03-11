//
//  ViewController.swift
//  EQM
//
//  Created by Nahum Jovan Aranda López on 10/03/16.
//  Copyright © 2016 Nahum Jovan Aranda López. All rights reserved.
//

import UIKit
import CoreData

class SummaryViewController: UITableViewController {
    var timer: NSTimer! = nil
    let dataManager = DataManager()
    
    lazy var fetchedResultsController: NSFetchedResultsController? = {
        if let context = CoreDataStack.sharedInstance.managedObjectContext
        {
            let fetchRequest = NSFetchRequest(entityName: EntityName.Feature.rawValue)
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "TRUEPREDICATE")
            
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            fetchedResultsController.delegate = self
            
            return fetchedResultsController
        }
        
        return nil
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: Selector("refresh:"), forControlEvents: UIControlEvents.ValueChanged)
        
        self.refresh(refreshControl)
        self.updateTitle()
        
        
        do {
            try self.fetchedResultsController?.performFetch()
        }
        catch (let error as NSError) {
            assert(false, "Something went wrong \(error)")
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        assert(self.timer == nil, "Timer MUST not exist here")
        self.timer = NSTimer(timeInterval: 60.0, target: self, selector: Selector("scheduledUpdate:"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSDefaultRunLoopMode)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
        self.timer = nil
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(refreshControl: UIRefreshControl!) {
        self.dataManager.startFeed { (data, error) in
            refreshControl?.endRefreshing()
        }
    }

    func updateTitle() {
        self.navigationItem.title = self.dataManager.retrieveTitle()
    }

    func scheduledUpdate(timer: NSTimer) {
        print("scheduledUpdate...")
        self.refresh(nil)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            if let detailViewController = segue.destinationViewController as? DetailViewController, cell = sender as? UITableViewCell {
                if let indexPath = self.tableView?.indexPathForCell(cell) {
                    if let feature = self.fetchedResultsController?.objectAtIndexPath(indexPath) {
                        do {
                            detailViewController.viewModel = try DetailViewViewModelFromFeature(objectID: feature.objectID)
                        }
                        catch {
                            assert(false, "D: OMG, Object Feature not Found!!!")
                        }
                    }
                }
            }
        }
    }

}


extension SummaryViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if controller == self.fetchedResultsController {
            self.tableView?.beginUpdates()
        }
        
        self.updateTitle()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if controller == self.fetchedResultsController {
            switch type {
            case .Insert:
                self.tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
            case .Delete:
                self.tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.None)
            case .Update:
                self.tableView?.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.None)
            case .Move:
                if indexPath != newIndexPath {
                    self.tableView?.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                }
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        if controller == self.fetchedResultsController {
            switch type {
            case .Insert:
                self.tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                break
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if controller == self.fetchedResultsController {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView?.endUpdates()
            })
        }
    }
}

extension SummaryViewController {
    override func numberOfSectionsInTableView(tableView: UITableView )-> Int {
        if let sections = self.fetchedResultsController?.sections{
            return sections.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.fetchedResultsController?.fetchedObjects?.count {
            print("Section \(section) count \(count)")
            return count
        }
        
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "summaryCell"
        if let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? SummaryTableViewCell {
            if let feature = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Feature {
                do {
                    cell.viewModel = try SummaryViewViewModelFromFeature(objectID: feature.objectID)
                }
                catch (let error as NSError) {
                    assert(false, "shouldn't fail \(error.description)")
                }
            }
            return cell
        }

        return UITableViewCell()
    }
}

