//
//  CoreDataManager.swift
//  NewsApps
//
//  Created by xcode on 14.11.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataProtocol {
    
    func save(context: NSManagedObjectContext) throws
    var persistentContaner: NSPersistentContainer { get }
}

class CoreDataManager: CoreDataProtocol {
    
    lazy var persistentContaner: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores()
        { (storeDescriprion, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error.userInfo)")
            }
        }
        return container
    }()
    
    func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
