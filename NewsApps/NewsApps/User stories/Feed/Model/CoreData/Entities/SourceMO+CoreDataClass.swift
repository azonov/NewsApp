//
//  SourceMO+CoreDataClass.swift
//  NewsApps
//
//  Created by xcode on 14.11.2017.
//  Copyright © 2017 VSU. All rights reserved.
//
//

import Foundation
import CoreData


public class SourceMO: NSManagedObject {

    class func createOrUpdate(
        with url: String,
        name: String?,
        isOn: Bool?,
        context: NSManagedObjectContext) throws
    {
        let request: NSFetchRequest<SourceMO> = SourceMO.fetchRequest(for: url)
        
        let source: SourceMO
        let result = try context.fetch(request)
        
        if result.count == 0 {
            source = SourceMO(context: context)
        } else if let firstSource = result.first, result.count == 1 {
            source = firstSource
        } else {
            assertionFailure("something went wrong")
            source = SourceMO(context: context)
        }
        source.name = name
        source.url = url
        if let isOn = isOn {
            source.isEnabled = isOn
        }
    }
}
