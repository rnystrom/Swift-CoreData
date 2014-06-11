//
//  TodoListController.swift
//  SwiftDo
//
//  Created by Ryan Nystrom on 6/4/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

import UIKit
import CoreData

class TodoListController: UITableViewController, NSFetchedResultsControllerDelegate
{
    
    //:MARK Init
    
    init()
    {
        super.init(style: UITableViewStyle.Plain)
    }

    init(style: UITableViewStyle)
    {
        super.init(style: style)
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    //:MARK Getter
    
    @lazy
    var fetchedResultsController: NSFetchedResultsController =
    {
        var fetch: NSFetchRequest = NSFetchRequest(entityName: "TodoItem")
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        var frc: NSFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: TodoStore.sharedStore().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    let CellIdentifier = "CellIdentifier"
    
    //:MARK Actions
    
    func onAddNewItem()
    {
        var controller = TodoItemController(itemID: nil)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func performFetchAndReload(reload: Bool)
    {
        var moc = fetchedResultsController.managedObjectContext
        
        moc.performBlockAndWait {
            var error: NSErrorPointer = nil
            if !self.fetchedResultsController.performFetch(error) {
                println("\(error)")
            }
            
            if reload {
                self.tableView.reloadData()
            }
        }
    }
    
    func updateCell(cell: UITableViewCell, object: TodoItem) {
        cell.textLabel.text = object.name
    }
    
    //:MARK UIViewController

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Todo List"
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Add,
            target: self,
            action: Selector("onAddNewItem"))
        
        performFetchAndReload(false)
    }
    
    //:MARK UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int
    {
        return fetchedResultsController.sections.count
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int
    {
        let sectionInfo = fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell?
    {
        let cell = tableView!.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as UITableViewCell
        var item: TodoItem = fetchedResultsController.objectAtIndexPath(indexPath) as TodoItem
        
        updateCell(cell, object: item)

        return cell
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item = fetchedResultsController.objectAtIndexPath(indexPath) as TodoItem
            TodoStore.sharedStore().deleteObject(item)
        }
    }
    
    //:MARK UITableViewDelegate

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // TODO: push VC w/ selected item
    }
    
    //:MARK NSFetchedResultsController
    
    func controllerWillChangeContent(controller: NSFetchedResultsController!)
    {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeSection sectionInfo: NSFetchedResultsSectionInfo!, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        if type == NSFetchedResultsChangeInsert {
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        }
        else if type == NSFetchedResultsChangeDelete {
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!)
    {
        switch type {
        case NSFetchedResultsChangeInsert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeDelete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeUpdate:
            updateCell(tableView.cellForRowAtIndexPath(indexPath), object: anObject as TodoItem)
        case NSFetchedResultsChangeMove:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            println("unhandled didChangeObject update type \(type)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!)
    {
        tableView.endUpdates()
    }

}
