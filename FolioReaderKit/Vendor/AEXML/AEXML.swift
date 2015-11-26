//
// AEXML.swift
//
// Copyright (c) 2014 Marko Tadić <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

/**
 This is base class for holding XML structure.
 
 You can access its structure by using subscript like this:
 `element["foo"]["bar"]` would return `<bar></bar>` element from `<element><foo><bar></bar></foo></element>` XML as an `AEXMLElement` object.
 */
public class AEXMLElement: NSObject {
    
    // MARK: Properties
    
    /// Every `AEXMLElement` should have its parent element instead of `AEXMLDocument` which parent is `nil`.
    public private(set) weak var parent: AEXMLElement?
    
    /// Child XML elements.
    public private(set) var children: [AEXMLElement] = [AEXMLElement]()
    
    /// XML Element name (defaults to empty string).
    public var name: String
    
    /// XML Element value.
    public var value: String?
    
    /// XML Element attributes (defaults to empty dictionary).
    public var attributes: [String : String]
    
    /// String representation of `value` property (if `value` is `nil` this is empty String).
    public var stringValue: String { return value ?? String() }
    
    /// String representation of `value` property with special characters escaped (if `value` is `nil` this is empty String).
    public var escapedStringValue: String {
        // we need to make sure "&" is escaped first. Not doing this may break escaping the other characters
        var escapedString = stringValue.stringByReplacingOccurrencesOfString("&", withString: "&amp;", options: .LiteralSearch)
        
        // replace the other four special characters
        let escapeChars = ["<" : "&lt;", ">" : "&gt;", "'" : "&apos;", "\"" : "&quot;"]
        for (char, echar) in escapeChars {
            escapedString = escapedString.stringByReplacingOccurrencesOfString(char, withString: echar, options: .LiteralSearch)
        }
        
        return escapedString
    }
    
    /// Boolean representation of `value` property (if `value` is "true" or 1 this is `True`, otherwise `False`).
    public var boolValue: Bool { return stringValue.lowercaseString == "true" || Int(stringValue) == 1 ? true : false }
    
    /// Integer representation of `value` property (this is **0** if `value` can't be represented as Integer).
    public var intValue: Int { return Int(stringValue) ?? 0 }
    
    /// Double representation of `value` property (this is **0.00** if `value` can't be represented as Double).
    public var doubleValue: Double { return (stringValue as NSString).doubleValue }
    
    private struct Defaults {
        static let name = String()
        static let attributes = [String : String]()
    }
    
    // MARK: Lifecycle
    
    /**
    Designated initializer - all parameters are optional.
    
    :param: name XML element name.
    :param: value XML element value
    :param: attributes XML element attributes
    
    :returns: An initialized `AEXMLElement` object.
    */
    public init(_ name: String? = nil, value: String? = nil, attributes: [String : String]? = nil) {
        self.name = name ?? Defaults.name
        self.value = value
        self.attributes = attributes ?? Defaults.attributes
    }
    
    // MARK: XML Read
    
    /// This element name is used when unable to find element.
    public static let errorElementName = "AEXMLError"
    
    // The first element with given name **(AEXMLError element if not exists)**.
    public subscript(key: String) -> AEXMLElement {
        if name == AEXMLElement.errorElementName {
            return self
        } else {
            let filtered = children.filter { $0.name == key }
            return filtered.count > 0 ? filtered.first! : AEXMLElement(AEXMLElement.errorElementName, value: "element <\(key)> not found")
        }
    }
    
    /// Returns all of the elements with equal name as `self` **(nil if not exists)**.
    public var all: [AEXMLElement]? { return parent?.children.filter { $0.name == self.name } }
    
    /// Returns the first element with equal name as `self` **(nil if not exists)**.
    public var first: AEXMLElement? { return all?.first }
    
    /// Returns the last element with equal name as `self` **(nil if not exists)**.
    public var last: AEXMLElement? { return all?.last }
    
    /// Returns number of all elements with equal name as `self`.
    public var count: Int { return all?.count ?? 0 }
    
    private func allWithCondition(fulfillCondition: (element: AEXMLElement) -> Bool) -> [AEXMLElement]? {
        var found = [AEXMLElement]()
        if let elements = all {
            for element in elements {
                if fulfillCondition(element: element) {
                    found.append(element)
                }
            }
            return found.count > 0 ? found : nil
        } else {
            return nil
        }
    }
    
    /**
     Returns all elements with given value.
     
     :param: value XML element value.
     
     :returns: Optional Array of found XML elements.
     */
    public func allWithValue(value: String) -> [AEXMLElement]? {
        let found = allWithCondition { (element) -> Bool in
            return element.value == value
        }
        return found
    }
    
    /**
     Returns all elements with given attributes.
     
     :param: attributes Dictionary of Keys and Values of attributes.
     
     :returns: Optional Array of found XML elements.
     */
    public func allWithAttributes(attributes: [String : String]) -> [AEXMLElement]? {
        let found = allWithCondition { (element) -> Bool in
            var countAttributes = 0
            for (key, value) in attributes {
                if element.attributes[key] == value {
                    countAttributes++
                }
            }
            return countAttributes == attributes.count
        }
        return found
    }
    
    // MARK: XML Write
    
    /**
    Adds child XML element to `self`.
    
    :param: child Child XML element to add.
    
    :returns: Child XML element with `self` as `parent`.
    */
    public func addChild(child: AEXMLElement) -> AEXMLElement {
        child.parent = self
        children.append(child)
        return child
    }
    
    /**
     Adds child XML element to `self`.
     
     :param: name Child XML element name.
     :param: value Child XML element value.
     :param: attributes Child XML element attributes.
     
     :returns: Child XML element with `self` as `parent`.
     */
    public func addChild(name name: String, value: String? = nil, attributes: [String : String]? = nil) -> AEXMLElement {
        let child = AEXMLElement(name, value: value, attributes: attributes)
        return addChild(child)
    }
    
    /// Removes `self` from `parent` XML element.
    public func removeFromParent() {
        parent?.removeChild(self)
    }
    
    private func removeChild(child: AEXMLElement) {
        if let childIndex = children.indexOf(child) {
            children.removeAtIndex(childIndex)
        }
    }
    
    private var parentsCount: Int {
        var count = 0
        var element = self
        while let parent = element.parent {
            count++
            element = parent
        }
        return count
    }
    
    private func indentation(var count: Int) -> String {
        var indent = String()
        while count > 0 {
            indent += "\t"
            count--
        }
        return indent
    }
    
    /// Complete hierarchy of `self` and `children` in **XML** escaped and formatted String
    public var xmlString: String {
        var xml = String()
        
        // open element
        xml += indentation(parentsCount - 1)
        xml += "<\(name)"
        
        if attributes.count > 0 {
            // insert attributes
            for (key, value) in attributes {
                xml += " \(key)=\"\(value)\""
            }
        }
        
        if value == nil && children.count == 0 {
            // close element
            xml += " />"
        } else {
            if children.count > 0 {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child.xmlString)\n"
                }
                // add indentation
                xml += indentation(parentsCount - 1)
                xml += "</\(name)>"
            } else {
                // insert string value and close element
                xml += ">\(escapedStringValue)</\(name)>"
            }
        }
        
        return xml
    }
    
}

// MARK: -

/**
This class is inherited from `AEXMLElement` and has a few addons to represent **XML Document**.

XML Parsing is also done with this object.
*/
public class AEXMLDocument: AEXMLElement {
    
    // MARK: Properties
    
    /// This is only used for XML Document header (default value is 1.0).
    public let version: Double
    
    /// This is only used for XML Document header (default value is "utf-8").
    public let encoding: String
    
    /// This is only used for XML Document header (default value is "no").
    public let standalone: String
    
    /// Root (the first child element) element of XML Document **(AEXMLError element if not exists)**.
    public var root: AEXMLElement { return children.count == 1 ? children.first! : AEXMLElement(AEXMLElement.errorElementName, value: "XML Document must have root element.") }
    
    private struct Defaults {
        static let version = 1.0
        static let encoding = "utf-8"
        static let standalone = "no"
        static let documentName = "AEXMLDocument"
    }
    
    // MARK: Lifecycle
    
    /**
    Designated initializer - Creates and returns XML Document object.
    
    :param: version Version value for XML Document header (defaults to 1.0).
    :param: encoding Encoding value for XML Document header (defaults to "utf-8").
    :param: standalone Standalone value for XML Document header (defaults to "no").
    :param: root Root XML element for XML Document (defaults to `nil`).
    
    :returns: An initialized XML Document object.
    */
    public init(version: Double = Defaults.version, encoding: String = Defaults.encoding, standalone: String = Defaults.standalone, root: AEXMLElement? = nil) {
        // set document properties
        self.version = version
        self.encoding = encoding
        self.standalone = standalone
        
        // init super with default name
        super.init(Defaults.documentName)
        
        // document has no parent element
        parent = nil
        
        // add root element to document (if any)
        if let rootElement = root {
            addChild(rootElement)
        }
    }
    
    /**
     Convenience initializer - used for parsing XML data (by calling `loadXMLData:` internally).
     
     :param: version Version value for XML Document header (defaults to 1.0).
     :param: encoding Encoding value for XML Document header (defaults to "utf-8").
     :param: standalone Standalone value for XML Document header (defaults to "no").
     :param: xmlData XML data to parse.
     :param: error If there is an error reading in the data, upon return contains an `NSError` object that describes the problem.
     
     :returns: An initialized XML Document object containing the parsed data. Returns `nil` if the data could not be parsed.
     */
    public convenience init(version: Double = Defaults.version, encoding: String = Defaults.encoding, standalone: String = Defaults.standalone, xmlData: NSData) throws {
        self.init(version: version, encoding: encoding, standalone: standalone)
        try loadXMLData(xmlData)
    }
    
    // MARK: Read XML
    
    /**
    Creates instance of `AEXMLParser` (private class which is simple wrapper around `NSXMLParser`) and starts parsing the given XML data.
    
    :param: data XML which should be parsed.
    
    :returns: `NSError` if parsing is not successfull, otherwise `nil`.
    */
    public func loadXMLData(data: NSData) throws {
        children.removeAll(keepCapacity: false)
        let xmlParser = AEXMLParser(xmlDocument: self, xmlData: data)
        try xmlParser.parse()
    }
    
    // MARK: Override
    
    /// Override of `xmlString` property of `AEXMLElement` - it just inserts XML Document header at the beginning.
    public override var xmlString: String {
        var xml =  "<?xml version=\"\(version)\" encoding=\"\(encoding)\" standalone=\"\(standalone)\"?>\n"
        for child in children {
            xml += child.xmlString
        }
        return xml
    }
    
}

// MARK: -

private class AEXMLParser: NSObject, NSXMLParserDelegate {
    
    // MARK: Properties
    
    let xmlDocument: AEXMLDocument
    let xmlData: NSData
    
    var currentParent: AEXMLElement?
    var currentElement: AEXMLElement?
    var currentValue = String()
    var parseError: NSError?
    
    // MARK: Lifecycle
    
    init(xmlDocument: AEXMLDocument, xmlData: NSData) {
        self.xmlDocument = xmlDocument
        self.xmlData = xmlData
        currentParent = xmlDocument
        super.init()
    }
    
    // MARK: XML Parse
    
    func parse() throws {
        let parser = NSXMLParser(data: xmlData)
        parser.delegate = self
        let success = parser.parse()
        if !success {
            throw parseError ?? NSError(domain: "net.tadija.AEXML", code: 1, userInfo: nil)
        }
    }
    
    // MARK: NSXMLParserDelegate
    
    @objc func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentValue = String()
        currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict)
        currentParent = currentElement
    }
    
    @objc func parser(parser: NSXMLParser, foundCharacters string: String) {
        currentValue += string
        let newValue = currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        currentElement?.value = newValue == String() ? nil : newValue
    }
    
    @objc func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentParent = currentParent?.parent
        currentElement = nil
    }
    
    @objc func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        self.parseError = parseError
    }
    
}