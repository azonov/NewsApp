//
//  SettingsModel.swift
//  NewsApps
//
//  Created by xcode on 12.12.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation
import CoreData

class SettingsModel {
    
    private let container: DataBaseContainable

    private var sourceSaver: SourceSaver {
        return SourceCoreDataSaver(context: container.saveContext)
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(with container: DataBaseContainable) {
        self.container = container
    }
    
    func save(source: SourceMO) {
        do {
            try sourceSaver.save(source: source)
        } catch {
            print(error)
        }
    }
}
