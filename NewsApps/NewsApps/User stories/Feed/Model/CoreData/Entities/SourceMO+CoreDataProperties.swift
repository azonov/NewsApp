//
//  SourceMO+CoreDataProperties.swift
//  NewsApps
//
//  Created by xcode on 14.11.2017.
//  Copyright © 2017 VSU. All rights reserved.
//
//

import Foundation
import CoreData


extension SourceMO: SourceInfoProtocol {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SourceMO> {
        return NSFetchRequest<SourceMO>(entityName: "Source")
    }

    @nonobjc public class func fetchRequest(for url: String) -> NSFetchRequest<SourceMO> {
        let request: NSFetchRequest<SourceMO> = fetchRequest()
        request.predicate = NSPredicate(format: "url = %@", url)
        
        return request
    }
    
    @NSManaged public var url: String
    @NSManaged public var isEnabled: Bool
    @NSManaged public var name: String?
    @NSManaged public var feedItems: NSSet?
    
    var isOn: Bool? {
        return isEnabled
    }
}

// MARK: Generated accessors for feedItems
extension SourceMO {

    @objc(addFeedItemsObject:)
    @NSManaged public func addToFeedItems(_ value: FeedItemMO)

    @objc(removeFeedItemsObject:)
    @NSManaged public func removeFromFeedItems(_ value: FeedItemMO)

    @objc(addFeedItems:)
    @NSManaged public func addToFeedItems(_ values: NSSet)

    @objc(removeFeedItems:)
    @NSManaged public func removeFromFeedItems(_ values: NSSet)

}
