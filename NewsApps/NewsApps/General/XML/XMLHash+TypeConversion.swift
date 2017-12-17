import Foundation

public protocol XMLIndexerDeserializable {
    static func deserialize(_ element: XMLIndexer) throws -> Self
}

public extension XMLIndexerDeserializable {

    static func deserialize(_ element: XMLIndexer) throws -> Self {
        throw XMLDeserializationError.implementationIsMissing(
            method: "XMLIndexerDeserializable.deserialize(element: XMLIndexer)")
    }
}

public protocol XMLElementDeserializable {
    static func deserialize(_ element: XMLElement) throws -> Self
}

public extension XMLElementDeserializable {
    static func deserialize(_ element: XMLElement) throws -> Self {
        throw XMLDeserializationError.implementationIsMissing(
            method: "XMLElementDeserializable.deserialize(element: XMLElement)")
    }
}

public protocol XMLAttributeDeserializable {
    static func deserialize(_ attribute: XMLAttribute) throws -> Self
}

public extension XMLAttributeDeserializable {

    static func deserialize(attribute: XMLAttribute) throws -> Self {
        throw XMLDeserializationError.implementationIsMissing(
            method: "XMLAttributeDeserializable(element: XMLAttribute)")
    }
}

public extension XMLIndexer {

    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> T {
        switch self {
        case .element(let element):
            return try element.value(ofAttribute: attr)
        case .stream(let opStream):
            return try opStream.findElements().value(ofAttribute: attr)
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) -> T? {
        switch self {
        case .element(let element):
            return element.value(ofAttribute: attr)
        case .stream(let opStream):
            return opStream.findElements().value(ofAttribute: attr)
        default:
            return nil
        }
    }

    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> [T] {
        switch self {
        case .list(let elements):
            return try elements.map { try $0.value(ofAttribute: attr) }
        case .element(let element):
            return try [element].map { try $0.value(ofAttribute: attr) }
        case .stream(let opStream):
            return try opStream.findElements().value(ofAttribute: attr)
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> [T]? {
        switch self {
        case .list(let elements):
            return try elements.map { try $0.value(ofAttribute: attr) }
        case .element(let element):
            return try [element].map { try $0.value(ofAttribute: attr) }
        case .stream(let opStream):
            return try opStream.findElements().value(ofAttribute: attr)
        default:
            return nil
        }
    }

    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> [T?] {
        switch self {
        case .list(let elements):
            return elements.map { $0.value(ofAttribute: attr) }
        case .element(let element):
            return [element].map { $0.value(ofAttribute: attr) }
        case .stream(let opStream):
            return try opStream.findElements().value(ofAttribute: attr)
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    func value<T: XMLElementDeserializable>() throws -> T {
        switch self {
        case .element(let element):
            return try T.deserialize(element)
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    func value<T: XMLElementDeserializable>() throws -> T? {
        switch self {
        case .element(let element):
            return try T.deserialize(element)
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return nil
        }
    }

    func value<T: XMLElementDeserializable>() throws -> [T] {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize($0) }
        case .element(let element):
            return try [element].map { try T.deserialize($0) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return []
        }
    }

    func value<T: XMLElementDeserializable>() throws -> [T]? {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize($0) }
        case .element(let element):
            return try [element].map { try T.deserialize($0) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return nil
        }
    }

    func value<T: XMLElementDeserializable>() throws -> [T?] {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize($0) }
        case .element(let element):
            return try [element].map { try T.deserialize($0) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return []
        }
    }

    func value<T: XMLIndexerDeserializable>() throws -> T {
        switch self {
        case .element:
            return try T.deserialize(self)
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    func value<T: XMLIndexerDeserializable>() throws -> T? {
        switch self {
        case .element:
            return try T.deserialize(self)
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return nil
        }
    }

    func value<T>() throws -> [T] where T: XMLIndexerDeserializable {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize( XMLIndexer($0) ) }
        case .element(let element):
            return try [element].map { try T.deserialize( XMLIndexer($0) ) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    func value<T: XMLIndexerDeserializable>() throws -> [T]? {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize( XMLIndexer($0) ) }
        case .element(let element):
            return try [element].map { try T.deserialize( XMLIndexer($0) ) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return nil
        }
    }
    func value<T: XMLIndexerDeserializable>() throws -> [T?] {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize( XMLIndexer($0) ) }
        case .element(let element):
            return try [element].map { try T.deserialize( XMLIndexer($0) ) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }
}

extension XMLElement {

    public func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> T {
        if let attr = self.attribute(by: attr) {
            return try T.deserialize(attr)
        } else {
            throw XMLDeserializationError.attributeDoesNotExist(element: self, attribute: attr)
        }
    }

    public func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) -> T? {
        if let attr = self.attribute(by: attr) {
            return try? T.deserialize(attr)
        } else {
            return nil
        }
    }

    internal func nonEmptyTextOrThrow() throws -> String {
        let textVal = text
        if !textVal.isEmpty {
            return textVal
        }

        throw XMLDeserializationError.nodeHasNoValue
    }
}

public enum XMLDeserializationError: Error, CustomStringConvertible {
    case implementationIsMissing(method: String)
    case nodeIsInvalid(node: XMLIndexer)
    case nodeHasNoValue
    case typeConversionFailed(type: String, element: XMLElement)
    case attributeDoesNotExist(element: XMLElement, attribute: String)
    case attributeDeserializationFailed(type: String, attribute: XMLAttribute)

    @available(*, unavailable, renamed: "implementationIsMissing(method:)")
    public static func ImplementationIsMissing(method: String) -> XMLDeserializationError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "nodeHasNoValue(_:)")
    public static func NodeHasNoValue(_: IndexOps) -> XMLDeserializationError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "typeConversionFailed(_:)")
    public static func TypeConversionFailed(_: IndexingError) -> XMLDeserializationError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "attributeDoesNotExist(_:_:)")
    public static func AttributeDoesNotExist(_ attr: String, _ value: String) throws -> XMLDeserializationError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "attributeDeserializationFailed(_:_:)")
    public static func AttributeDeserializationFailed(_ attr: String, _ value: String) throws -> XMLDeserializationError {
        fatalError("unavailable")
    }

    public var description: String {
        switch self {
        case .implementationIsMissing(let method):
            return "This deserialization method is not implemented: \(method)"
        case .nodeIsInvalid(let node):
            return "This node is invalid: \(node)"
        case .nodeHasNoValue:
            return "This node is empty"
        case .typeConversionFailed(let type, let node):
            return "Can't convert node \(node) to value of type \(type)"
        case .attributeDoesNotExist(let element, let attribute):
            return "Element \(element) does not contain attribute: \(attribute)"
        case .attributeDeserializationFailed(let type, let attribute):
            return "Can't convert attribute \(attribute) to value of type \(type)"
        }
    }
}

extension String: XMLElementDeserializable, XMLAttributeDeserializable {

    public static func deserialize(_ element: XMLElement) -> String {
        return element.text
    }

    public static func deserialize(_ attribute: XMLAttribute) -> String {
        return attribute.text
    }
}

extension Int: XMLElementDeserializable, XMLAttributeDeserializable {

    public static func deserialize(_ element: XMLElement) throws -> Int {
        guard let value = Int(try element.nonEmptyTextOrThrow()) else {
            throw XMLDeserializationError.typeConversionFailed(type: "Int", element: element)
        }
        return value
    }

    public static func deserialize(_ attribute: XMLAttribute) throws -> Int {
        guard let value = Int(attribute.text) else {
            throw XMLDeserializationError.attributeDeserializationFailed(
                type: "Int", attribute: attribute)
        }
        return value
    }
}

extension Double: XMLElementDeserializable, XMLAttributeDeserializable {

    public static func deserialize(_ element: XMLElement) throws -> Double {
        guard let value = Double(try element.nonEmptyTextOrThrow()) else {
            throw XMLDeserializationError.typeConversionFailed(type: "Double", element: element)
        }
        return value
    }

    public static func deserialize(_ attribute: XMLAttribute) throws -> Double {
        guard let value = Double(attribute.text) else {
            throw XMLDeserializationError.attributeDeserializationFailed(
                type: "Double", attribute: attribute)
        }
        return value
    }
}

extension Float: XMLElementDeserializable, XMLAttributeDeserializable {

    public static func deserialize(_ element: XMLElement) throws -> Float {
        guard let value = Float(try element.nonEmptyTextOrThrow()) else {
            throw XMLDeserializationError.typeConversionFailed(type: "Float", element: element)
        }
        return value
    }

    public static func deserialize(_ attribute: XMLAttribute) throws -> Float {
        guard let value = Float(attribute.text) else {
            throw XMLDeserializationError.attributeDeserializationFailed(
                type: "Float", attribute: attribute)
        }
        return value
    }
}

extension Bool: XMLElementDeserializable, XMLAttributeDeserializable {
 
    public static func deserialize(_ element: XMLElement) throws -> Bool {
        let value = Bool(NSString(string: try element.nonEmptyTextOrThrow()).boolValue)
        return value
    }

    public static func deserialize(_ attribute: XMLAttribute) throws -> Bool {
        let value = Bool(NSString(string: attribute.text).boolValue)
        return value
    }
}
