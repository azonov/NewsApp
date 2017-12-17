//
//  FeedModel.swift
//  NewsApps
//
//  Created by xcode on 17.10.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation
import CoreData

class FeedModel: NSObject, XMLParserDelegate {
    
    struct Source {
        let sourceInfoParser: SourceInfoParserProtocol
        let feedItemParser: FeedItemParsable
        let url: URL
    }
    
    public var viewContext: NSManagedObjectContext
    
    private let sources: [Source]
    private let session = URLSession(configuration: .default)
    private var feedItemSaver: FeedItemSaver
    private var sourceSaver: SourceSaver
    
    init(with container: DataBaseContainable) {
        feedItemSaver = FeedItemCoreDataSaver(container: container)
        sourceSaver = SourceCoreDataSaver(container: container)
        viewContext = container.viewContext
        let wylsa = Source(sourceInfoParser: SourceInfoParser(),
                           feedItemParser: WylsaComFeedParser(),
                           url: URL(string: "https://wylsa.com/feed")!)
        let lenta = Source(sourceInfoParser: SourceInfoParser(),
                           feedItemParser: FeedItemXMLParser(),
                           url: URL(string: "https://lenta.ru/rss/news")!)
        sources = [wylsa, lenta]
        super.init()
    }
    
    func retreiveFeed() {
        for source in sources {
            let task = session.dataTask(with: source.url)
            { (data, response, error) in
                if let data = data {
                    do {
                        let sourceInfo = try source.sourceInfoParser.parse(data: data)
                        try self.sourceSaver.save(source: sourceInfo)
                        let items = try source.feedItemParser.parse(data: data)
                        try self.feedItemSaver.save(feedItems: items, for: sourceInfo)
                    } catch {
                        print(error)
                    }
                }
                if let error = error {
                    print(error)
                }
            }
            task.resume()
        }
    }
}
