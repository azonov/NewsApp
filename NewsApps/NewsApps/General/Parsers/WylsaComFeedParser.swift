//
//  WylsaComFeedParser.swift
//  NewsApps
//
//  Created by xcode on 12.12.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation

class WylsaComFeedParser: FeedItemXMLParser {

    override func parse(item: inout FeedItem, using xml: XMLIndexer) {
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let data  = item.desc.data(using: .utf8),
            let attributedString = try? NSAttributedString(data: data,
                                                           options: options,
                                                           documentAttributes: nil) {
            item.desc = attributedString.string
        }
        
        if let content = xml["content:encoded"].element?.text,
            let data = content.data(using: .utf8),
            let attributedString = try? NSAttributedString(data: data,
                                                           options: options,
                                                           documentAttributes: nil) {
            item.content = attributedString.string
        }
    }
}
