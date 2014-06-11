//
//  TodoItemController.swift
//  SwiftDo
//
//  Created by Ryan Nystrom on 6/4/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

import UIKit
import CoreData

class TodoItemController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var itemNameField : UITextField
    
    let itemID: NSManagedObjectID?
    let item: TodoItem
    
    init(itemID: NSManagedObjectID?) {
        let store = TodoStore.sharedStore()
        
        if itemID {
            let moc = store.managedObjectContext
            item = moc.objectWithID(itemID) as TodoItem
            self.itemID = itemID
        }
        else {
            item = store.createNewItemWithName("New Item")
            self.itemID = item.objectID
        }
        
        super.init(nibName: "TodoItemController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Todo Item"
        
        itemNameField.text = item.name
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        
        item.name = itemNameField.text
        
        navigationController.popViewControllerAnimated(true)
        
        return true
    }

}
