//
//  FeedItemSaver.swift
//  NewsApps
//
//  Created by xcode on 28.11.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation
import CoreData

protocol FeedItemSaver {
    
    func save(feedItems: [FeedItem], for source: SourceInfoProtocol) throws
}

class FeedItemCoreDataSaver: FeedItemSaver {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func save(feedItems: [FeedItem], for source: SourceInfoProtocol) throws {
        let sourceMO = try context.fetch(SourceMO.fetchRequest(for: source.url)).first
        for feedItem in feedItems {
            let item = try FeedItemMO.createOrUpdate(item: feedItem, context: context)
            item.source = sourceMO
        }
        try context.save()
    }
}
