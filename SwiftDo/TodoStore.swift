//
//  TodoStore.swift
//  SwiftDo
//
//  Created by Ryan Nystrom on 6/4/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

import UIKit
import CoreData

class TodoItem: NSManagedObject {
    @NSManaged
    var name: String
}

class TodoStore {
    
    class func sharedStore() -> TodoStore
    {
        struct Static {
            static var instance: TodoStore?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token, {
            Static.instance = TodoStore()
            })
        return Static.instance!
    }
    
    let managedObjectContext: NSManagedObjectContext =
    {
        let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        moc.undoManager = nil
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return moc
    }()
    
    let managedObjectModel: NSManagedObjectModel =
    {
        let url = NSBundle.mainBundle().URLForResource("Todo", withExtension: "momd")
        let mom = NSManagedObjectModel(contentsOfURL: url)
        
        return mom
    }()
    
    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    init()
    {
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let docUrl: NSURL = urls[urls.count - 1] as NSURL
        let url = docUrl.URLByAppendingPathComponent("Todo.sqlite")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let error: NSErrorPointer = nil
        if !persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: error) {
            println("\(error)")
        }
        
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    func createNewItemWithName(name: String?) -> TodoItem
    {
        let obj = NSEntityDescription.insertNewObjectForEntityForName("TodoItem", inManagedObjectContext: managedObjectContext) as TodoItem
        
        if name {
            obj.name = name!
        }

        return obj
    }
    
    func save() {
        let moc = managedObjectContext
        
        moc.performBlockAndWait {
            let error: NSErrorPointer = nil
            if moc.hasChanges && !moc.save(error) {
                println("\(error)")
            }
        }
    }
    
    func objectWithID(objectID: NSManagedObjectID) -> NSManagedObject {
        return managedObjectContext.objectWithID(objectID)
    }
    
    func deleteObject(object: NSManagedObject) {
        let moc = managedObjectContext
        moc.performBlockAndWait {
            moc.deleteObject(object)
        }
    }
    
    deinit {
        save()
    }
    
}
