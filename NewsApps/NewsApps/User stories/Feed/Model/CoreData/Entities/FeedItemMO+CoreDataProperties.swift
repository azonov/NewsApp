//
//  FeedItemMO+CoreDataProperties.swift
//  NewsApps
//
//  Created by xcode on 14.11.2017.
//  Copyright © 2017 VSU. All rights reserved.
//
//

import Foundation
import CoreData


extension FeedItemMO: FeedItemProtocol {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedItemMO> {
        return NSFetchRequest<FeedItemMO>(entityName: "FeedItem")
    }

    @NSManaged public var pubDate: Date
    @NSManaged public var title: String
    @NSManaged public var desc: String
    @NSManaged public var url: URL
    @NSManaged public var content: String?
    @NSManaged public var source: SourceMO?

}
