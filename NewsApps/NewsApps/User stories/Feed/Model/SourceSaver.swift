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
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func save(source: SourceInfoProtocol) throws {
        try SourceMO.createOrUpdate(with: source.url,
                                    name: source.name,
                                    isOn: source.isOn,
                                    context: context)
        try context.save()
    }
}
