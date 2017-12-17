//
//  FeedItem.swift
//  NewsApps
//
//  Created by xcode on 14.11.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import UIKit

protocol FeedItemProtocol {
    var title: String { get }
    var desc: String { get }
    var url: URL { get }
    var content: String? { get }
    var pubDate: Date { get }
}

struct FeedItem: FeedItemProtocol {
    let title: String
    var desc: String
    var content: String?
    let pubDate: Date
    let url: URL
}
