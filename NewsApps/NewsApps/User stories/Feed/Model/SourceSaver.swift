//
//  SourceSaver.swift
//  NewsApps
//
//  Created by xcode on 12.12.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation
import CoreData

protocol SourceSaver {
    
    func save(source: SourceInfoProtocol) throws
}

class SourceCoreDataSaver: SourceSaver {
    
    private let container: DataBaseContainable
    
    init(container: DataBaseContainable) {
        self.container = container
    }
    
    func save(source: SourceInfoProtocol) throws {
        let context = container.saveContext
        try SourceMO.createOrUpdate(with: source.url,
                                    name: source.name,
                                    isOn: source.isOn,
                                    context: context)
        try context.save()
    }
}
