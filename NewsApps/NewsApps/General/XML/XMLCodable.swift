import Foundation

let rootElementName = "AMMXMLHash_Root_Element"
public class XMLCodingOptions {
    internal init() {}
    
    public var shouldProcessLazily = false
    public var shouldProcessNamespaces = false
    public var caseInsensitive = false
    public var encoding = String.Encoding.utf8
}

public class XMLCodable {
    let options: XMLCodingOptions

    private init(_ options: XMLCodingOptions = XMLCodingOptions()) {
        self.options = options
    }

    class public func config(_ configAction: (XMLCodingOptions) -> Void) -> XMLCodable {
        let opts = XMLCodingOptions()
        configAction(opts)
        return XMLCodable(opts)
    }

    public func parse(_ xml: String) -> XMLIndexer {
        guard let data = xml.data(using: options.encoding) else {
            return .xmlError(.encoding)
        }
        return parse(data)
    }

    public func parse(_ data: Data) -> XMLIndexer {
        let parser: SimpleXmlParser = options.shouldProcessLazily
            ? LazyXMLParser(options)
            : FullXMLParser(options)
        return parser.parse(data)
    }

    class public func parse(_ xml: String) -> XMLIndexer {
        return XMLCodable().parse(xml)
    }

    class public func parse(_ data: Data) -> XMLIndexer {
        return XMLCodable().parse(data)
    }

    class public func lazy(_ xml: String) -> XMLIndexer {
        return config { conf in conf.shouldProcessLazily = true }.parse(xml)
    }

    class public func lazy(_ data: Data) -> XMLIndexer {
        return config { conf in conf.shouldProcessLazily = true }.parse(data)
    }
}

struct Stack<T> {
    var items = [T]()
    mutating func push(_ item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.removeLast()
    }
    mutating func drop() {
        _ = pop()
    }
    mutating func removeAll() {
        items.removeAll(keepingCapacity: false)
    }
    func top() -> T {
        return items[items.count - 1]
    }
}

protocol SimpleXmlParser {
    init(_ options: XMLCodingOptions)
    func parse(_ data: Data) -> XMLIndexer
}

#if os(Linux)

extension XMLParserDelegate {

    func parserDidStartDocument(_ feedItemParser: Foundation.XMLParser) { }
    func parserDidEndDocument(_ feedItemParser: Foundation.XMLParser) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                foundNotationDeclarationWithName name: String,
                publicID: String?,
                systemID: String?) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                foundUnparsedEntityDeclarationWithName name: String,
                publicID: String?,
                systemID: String?,
                notationName: String?) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                foundAttributeDeclarationWithName attributeName: String,
                forElement elementName: String,
                type: String?,
                defaultValue: String?) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                foundElementDeclarationWithName elementName: String,
                model: String) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                foundInternalEntityDeclarationWithName name: String,
                value: String?) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                foundExternalEntityDeclarationWithName name: String,
                publicID: String?,
                systemID: String?) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                didStartMappingPrefix prefix: String,
                toURI namespaceURI: String) { }

    func parser(_ feedItemParser: Foundation.XMLParser, didEndMappingPrefix prefix: String) { }

    func parser(_ feedItemParser: Foundation.XMLParser, foundCharacters string: String) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                foundIgnorableWhitespace whitespaceString: String) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                foundProcessingInstructionWithTarget target: String,
                data: String?) { }

    func parser(_ feedItemParser: Foundation.XMLParser, foundComment comment: String) { }

    func parser(_ feedItemParser: Foundation.XMLParser, foundCDATA CDATABlock: Data) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                resolveExternalEntityName name: String,
                systemID: String?) -> Data? { return nil }

    func parser(_ feedItemParser: Foundation.XMLParser, parseErrorOccurred parseError: NSError) { }

    func parser(_ feedItemParser: Foundation.XMLParser,
                validationErrorOccurred validationError: NSError) { }
}

#endif

class LazyXMLParser: NSObject, SimpleXmlParser, XMLParserDelegate {
    required init(_ options: XMLCodingOptions) {
        self.options = options
        self.root.caseInsensitive = options.caseInsensitive
        super.init()
    }

    var root = XMLElement(name: rootElementName, caseInsensitive: false)
    var parentStack = Stack<XMLElement>()
    var elementStack = Stack<String>()

    var data: Data?
    var ops: [IndexOp] = []
    let options: XMLCodingOptions

    func parse(_ data: Data) -> XMLIndexer {
        self.data = data
        return XMLIndexer(self)
    }

    func startParsing(_ ops: [IndexOp]) {
        parentStack.removeAll()
        root = XMLElement(name: rootElementName, caseInsensitive: options.caseInsensitive)
        parentStack.push(root)

        self.ops = ops
        let parser = Foundation.XMLParser(data: data!)
        parser.shouldProcessNamespaces = options.shouldProcessNamespaces
        parser.delegate = self
        _ = parser.parse()
    }

    func parser(_ parser: Foundation.XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {

        elementStack.push(elementName)

        if !onMatch() {
            return
        }

        let currentNode = parentStack
            .top()
            .addElement(elementName, withAttributes: attributeDict, caseInsensitive: self.options.caseInsensitive)
        parentStack.push(currentNode)
    }

    func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
        if !onMatch() {
            return
        }

        let current = parentStack.top()

        current.addText(string)
    }

    func parser(_ parser: Foundation.XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        let match = onMatch()

        elementStack.drop()

        if match {
            parentStack.drop()
        }
    }

    func onMatch() -> Bool {
        if elementStack.items.count > ops.count {
            return elementStack.items.starts(with: ops.map { $0.key })
        } else {
            return ops.map { $0.key }.starts(with: elementStack.items)
        }
    }
}

class FullXMLParser: NSObject, SimpleXmlParser, XMLParserDelegate {
    required init(_ options: XMLCodingOptions) {
        self.options = options
        self.root.caseInsensitive = options.caseInsensitive
        super.init()
    }

    var root = XMLElement(name: rootElementName, caseInsensitive: false)
    var parentStack = Stack<XMLElement>()
    let options: XMLCodingOptions

    func parse(_ data: Data) -> XMLIndexer {
        parentStack.removeAll()

        parentStack.push(root)

        let parser = Foundation.XMLParser(data: data)
        parser.shouldProcessNamespaces = options.shouldProcessNamespaces
        parser.delegate = self
        _ = parser.parse()

        return XMLIndexer(root)
    }

    func parser(_ parser: Foundation.XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {

        let currentNode = parentStack
            .top()
            .addElement(elementName, withAttributes: attributeDict, caseInsensitive: self.options.caseInsensitive)

        parentStack.push(currentNode)
    }

    func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
        let current = parentStack.top()

        current.addText(string)
    }

    func parser(_ parser: Foundation.XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        parentStack.drop()
    }
}

public class IndexOp {
    var index: Int
    let key: String

    init(_ key: String) {
        self.key = key
        self.index = -1
    }

    func toString() -> String {
        if index >= 0 {
            return key + " " + index.description
        }

        return key
    }
}

public class IndexOps {
    var ops: [IndexOp] = []

    let parser: LazyXMLParser

    init(parser: LazyXMLParser) {
        self.parser = parser
    }

    func findElements() -> XMLIndexer {
        parser.startParsing(ops)
        let indexer = XMLIndexer(parser.root)
        var childIndex = indexer
        for op in ops {
            childIndex = childIndex[op.key]
            if op.index >= 0 {
                childIndex = childIndex[op.index]
            }
        }
        ops.removeAll(keepingCapacity: false)
        return childIndex
    }

    func stringify() -> String {
        var s = ""
        for op in ops {
            s += "[" + op.toString() + "]"
        }
        return s
    }
}

public enum IndexingError: Error {
    case attribute(attr: String)
    case attributeValue(attr: String, value: String)
    case key(key: String)
    case index(idx: Int)
    case initialize(instance: AnyObject)
    case encoding
    case error

    @available(*, unavailable, renamed: "attribute(attr:)")
    public static func Attribute(attr: String) -> IndexingError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "attributeValue(attr:value:)")
    public static func AttributeValue(attr: String, value: String) -> IndexingError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "key(key:)")
    public static func Key(key: String) -> IndexingError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "index(idx:)")
    public static func Index(idx: Int) -> IndexingError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "initialize(instance:)")
    public static func Init(instance: AnyObject) -> IndexingError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "error")
    public static var Error: IndexingError {
        fatalError("unavailable")
    }
}

public enum XMLIndexer {
    case element(XMLElement)
    case list([XMLElement])
    case stream(IndexOps)
    case xmlError(IndexingError)
    @available(*, unavailable, renamed: "element(_:)")
    public static func Element(_: XMLElement) -> XMLIndexer {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "list(_:)")
    public static func List(_: [XMLElement]) -> XMLIndexer {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "stream(_:)")
    public static func Stream(_: IndexOps) -> XMLIndexer {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "xmlError(_:)")
    public static func XMLError(_: IndexingError) -> XMLIndexer {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "withAttribute(_:_:)")
    public static func withAttr(_ attr: String, _ value: String) throws -> XMLIndexer {
        fatalError("unavailable")
    }

    public var element: XMLElement? {
        switch self {
        case .element(let elem):
            return elem
        case .stream(let ops):
            let list = ops.findElements()
            return list.element
        default:
            return nil
        }
    }

    public var all: [XMLIndexer] {
        switch self {
        case .list(let list):
            var xmlList = [XMLIndexer]()
            for elem in list {
                xmlList.append(XMLIndexer(elem))
            }
            return xmlList
        case .element(let elem):
            return [XMLIndexer(elem)]
        case .stream(let ops):
            let list = ops.findElements()
            return list.all
        default:
            return []
        }
    }

    public var children: [XMLIndexer] {
        var list = [XMLIndexer]()
        for elem in all.flatMap({ $0.element }) {
            for elem in elem.xmlChildren {
                list.append(XMLIndexer(elem))
            }
        }
        return list
    }

    public func withAttribute(_ attr: String, _ value: String) throws -> XMLIndexer {
        switch self {
        case .stream(let opStream):
            let match = opStream.findElements()
            return try match.withAttribute(attr, value)
        case .list(let list):
            if let elem = list.first(where: {
                value.compare($0.attribute(by: attr)?.text, $0.caseInsensitive)
            }) {
                return .element(elem)
            }
            throw IndexingError.attributeValue(attr: attr, value: value)
        case .element(let elem):
            if value.compare(elem.attribute(by: attr)?.text, elem.caseInsensitive) {
                return .element(elem)
            }
            throw IndexingError.attributeValue(attr: attr, value: value)
        default:
            throw IndexingError.attribute(attr: attr)
        }
    }

    public init(_ rawObject: AnyObject) throws {
        switch rawObject {
        case let value as XMLElement:
            self = .element(value)
        case let value as LazyXMLParser:
            self = .stream(IndexOps(parser: value))
        default:
            throw IndexingError.initialize(instance: rawObject)
        }
    }
    public init(_ elem: XMLElement) {
        self = .element(elem)
    }

    init(_ stream: LazyXMLParser) {
        self = .stream(IndexOps(parser: stream))
    }

    public func byKey(_ key: String) throws -> XMLIndexer {
        switch self {
        case .stream(let opStream):
            let op = IndexOp(key)
            opStream.ops.append(op)
            return .stream(opStream)
        case .element(let elem):
            let match = elem.xmlChildren.filter({
                $0.name.compare(key, $0.caseInsensitive)
            })
            if !match.isEmpty {
                if match.count == 1 {
                    return .element(match[0])
                } else {
                    return .list(match)
                }
            }
            throw IndexingError.key(key: key)
        default:
            throw IndexingError.key(key: key)
        }
    }

    public subscript(key: String) -> XMLIndexer {
        do {
            return try self.byKey(key)
        } catch let error as IndexingError {
            return .xmlError(error)
        } catch {
            return .xmlError(IndexingError.key(key: key))
        }
    }

    public func byIndex(_ index: Int) throws -> XMLIndexer {
        switch self {
        case .stream(let opStream):
            opStream.ops[opStream.ops.count - 1].index = index
            return .stream(opStream)
        case .list(let list):
            if index < list.count {
                return .element(list[index])
            }
            return .xmlError(IndexingError.index(idx: index))
        case .element(let elem):
            if index == 0 {
                return .element(elem)
            }
            return .xmlError(IndexingError.index(idx: index))
        default:
            return .xmlError(IndexingError.index(idx: index))
        }
    }

    public subscript(index: Int) -> XMLIndexer {
        do {
            return try byIndex(index)
        } catch let error as IndexingError {
            return .xmlError(error)
        } catch {
            return .xmlError(IndexingError.index(idx: index))
        }
    }
}

extension XMLIndexer: CustomStringConvertible {
    public var description: String {
        switch self {
        case .list(let list):
            return list.reduce("", { $0 + $1.description })
        case .element(let elem):
            if elem.name == rootElementName {
                return elem.children.reduce("", { $0 + $1.description })
            }

            return elem.description
        default:
            return ""
        }
    }
}

extension IndexingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .attribute(let attr):
            return "XML Attribute Error: Missing attribute [\"\(attr)\"]"
        case .attributeValue(let attr, let value):
            return "XML Attribute Error: Missing attribute [\"\(attr)\"] with value [\"\(value)\"]"
        case .key(let key):
            return "XML Element Error: Incorrect key [\"\(key)\"]"
        case .index(let index):
            return "XML Element Error: Incorrect index [\"\(index)\"]"
        case .initialize(let instance):
            return "XML Indexer Error: initialization with Object [\"\(instance)\"]"
        case .encoding:
            return "String Encoding Error"
        case .error:
            return "Unknown Error"
        }
    }
}

public protocol XMLContent: CustomStringConvertible { }

public class TextElement: XMLContent {
    /// The underlying text value
    public let text: String
    init(text: String) {
        self.text = text
    }
}

public struct XMLAttribute {
    public let name: String
    public let text: String
    init(name: String, text: String) {
        self.name = name
        self.text = text
    }
}

public class XMLElement: XMLContent {
    public let name: String

    public var caseInsensitive: Bool

    public var allAttributes = [String: XMLAttribute]()

    public func attribute(by name: String) -> XMLAttribute? {
        if caseInsensitive {
            return allAttributes.first(where: { $0.key.compare(name, true) })?.value
        }
        return allAttributes[name]
    }

    public var text: String {
        return children.reduce("", {
            if let element = $1 as? TextElement {
                return $0 + element.text
            }

            return $0
        })
    }

    public var recursiveText: String {
        return children.reduce("", {
            if let textElement = $1 as? TextElement {
                return $0 + textElement.text
            } else if let xmlElement = $1 as? XMLElement {
                return $0 + xmlElement.recursiveText
            } else {
                return $0
            }
        })
    }

    public var children = [XMLContent]()
    var count: Int = 0
    var index: Int

    var xmlChildren: [XMLElement] {
        return children.flatMap { $0 as? XMLElement }
    }

    init(name: String, index: Int = 0, caseInsensitive: Bool) {
        self.name = name
        self.caseInsensitive = caseInsensitive
        self.index = index
    }

    func addElement(_ name: String, withAttributes attributes: [String: String], caseInsensitive: Bool) -> XMLElement {
        let element = XMLElement(name: name, index: count, caseInsensitive: caseInsensitive)
        count += 1

        children.append(element)

        for (key, value) in attributes {
            element.allAttributes[key] = XMLAttribute(name: key, text: value)
        }

        return element
    }

    func addText(_ text: String) {
        let elem = TextElement(text: text)

        children.append(elem)
    }
}

extension TextElement: CustomStringConvertible {
    public var description: String {
        return text
    }
}

extension XMLAttribute: CustomStringConvertible {
    public var description: String {
        return "\(name)=\"\(text)\""
    }
}

extension XMLElement: CustomStringConvertible {
    public var description: String {
        let attributesString = allAttributes.reduce("", { $0 + " " + $1.1.description })

        if !children.isEmpty {
            var xmlReturn = [String]()
            xmlReturn.append("<\(name)\(attributesString)>")
            for child in children {
                xmlReturn.append(child.description)
            }
            xmlReturn.append("</\(name)>")
            return xmlReturn.joined(separator: "")
        }

        return "<\(name)\(attributesString)>\(text)</\(name)>"
    }
}

extension XMLCodable {
    public typealias XMLElement = AMMXMLHashXMLElement
}

public typealias AMMXMLHashXMLElement = XMLElement

fileprivate extension String {
    func compare(_ str2: String?, _ insensitive: Bool) -> Bool {
        guard let str2 = str2 else {
            return false
        }
        let str1 = self
        if insensitive {
            return str1.caseInsensitiveCompare(str2) == .orderedSame
        }
        return str1 == str2
    }
}
