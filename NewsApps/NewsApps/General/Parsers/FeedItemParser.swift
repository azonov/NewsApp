//
//  FeedItemParser.swift
//  NewsApps
//
//  Created by xcode on 28.11.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation

protocol FeedItemParsable {
    
    func parse(data: Data) throws -> [FeedItem]
}

enum ParsingError: Error {
    case wrongStructure(key: String)
    case wrongDataFormat()
}

class FeedItemXMLParser: FeedItemParsable {
    
    func parse(data: Data) throws -> [FeedItem] {
        let xml = XMLCodable.parse(data)
        var result: [FeedItem] = []
        for item in xml["rss"]["channel"]["item"].all {
            guard let title = item["title"].element?.text else {
                throw ParsingError.wrongStructure(key: "title")
            }
            guard let description = item["description"].element?.text else {
                throw ParsingError.wrongStructure(key: "description")
            }
            guard let dateString = item["pubDate"].element?.text else {
                throw ParsingError.wrongStructure(key: "pubDate")
            }
            guard let urlString = item["link"].element?.text,
                let url = URL(string: urlString) else {
                throw ParsingError.wrongStructure(key: "link")
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
            
            guard let date = dateFormatter.date(from: dateString) else {
                throw ParsingError.wrongDataFormat()
            }
            var feedItem = FeedItem(title: title,
                                    desc: description,
                                    content: nil,
                                    pubDate: date,
                                    url: url)
            
            parse(item: &feedItem, using: item)
            
            result.append(feedItem)
        }
        return result
    }
    
    func parse(item: inout FeedItem, using xml: XMLIndexer) {}
}
