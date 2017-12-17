//
//  SourceInfoParser.swift
//  NewsApps
//
//  Created by xcode on 12.12.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation

protocol SourceInfoProtocol {
    var name: String? { get }
    var url: String { get }
    var isOn: Bool? { get }
}

struct SourceInfo: SourceInfoProtocol {
    var name: String?
    var url: String
    var isOn: Bool?
}

protocol SourceInfoParserProtocol {
    
    func parse(data: Data) throws -> SourceInfoProtocol
}

class SourceInfoParser: SourceInfoParserProtocol {
    
    func parse(data: Data) throws -> SourceInfoProtocol {
        let xml = XMLCodable.parse(data)
        let channelInfoXml = xml["rss"]["channel"]
        guard let name = channelInfoXml["title"].element?.text else {
            throw ParsingError.wrongStructure(key: "title")
        }
        guard let link = channelInfoXml["link"].element?.text else {
            throw ParsingError.wrongStructure(key: "link")
        }
        return SourceInfo(name: name, url: link, isOn: nil)
    }
}
