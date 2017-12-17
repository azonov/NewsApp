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
    
    var viewContext: NSManagedObjectContext
    
    private var sourceSaver: SourceSaver
    
    init(with container: DataBaseContainable) {
        viewContext = container.viewContext
        sourceSaver = SourceCoreDataSaver(container: container)
    }
    
    func save(source: SourceMO) {
        do {
            try sourceSaver.save(source: source)
        } catch {
            print(error)
        }
    }
}
