//
//  CommonExtension.swift
//  
//
//  Created by kin nam on 2022/12/14.
//

import Foundation
import Alamofire

extension String {
    func makeJsonObj<T>() -> T? {
        guard let data = self.data(using: .utf8) else {return nil}
        return try? JSONSerialization.jsonObject(with: data) as? T
    }
    func makeObj<T:Decodable>() -> T? {
        guard let data = self.data(using: .utf8) else {return nil}
        return try? JSONDecoder().decode(T.self, from: data)
    }
    func makeObj<T:Decodable>(t:T.Type) -> T? {
        guard let data = self.data(using: .utf8) else {return nil}
        return try? JSONDecoder().decode(T.self, from: data)
    }
    public var fullRange: NSRange {
        return NSRange(location: 0, length: self.count)
    }
    public func regex(pattern:String,options:NSRegularExpression.Options,_ block:(NSTextCheckingResult?, NSRegularExpression.MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let reg = try? NSRegularExpression(pattern: pattern, options: options)
        reg?.enumerateMatches(in: self, options: [], range: fullRange){ result, flags, stop in
            block(result,flags,stop)
        }
        
    }
    public func matches(pattern:String,with name:String?) -> [String]? {
        let regex = try? NSRegularExpression(pattern: pattern)
        let result = regex?.matches(in: self, range: fullRange)
        return result?.map({ (ele) -> String? in
            var range:NSRange?
            if let name = name {
                range = ele.range(withName: name)
            }
            else {
                range = ele.range
            }
            guard let r = range else {return nil}
            return (self as NSString).substring(with: r)
        }).compactMap{$0}
    }
    public func matches(pattern:String, with names:[String]) -> [[String:String]] {
        var list = [[String:String]]()
        let regex = try? NSRegularExpression(pattern: pattern)
        let result = regex?.matches(in: self, range: fullRange)
        result?.forEach { match in
            var item = [String:String]()
            item[""] = (self as NSString).substring(with: match.range)
            names.forEach {
                item[$0] = (self as NSString).substring(with: match.range(withName: $0))
            }
            list.append(item)
        }
        return list
    }
    public func attributedString(pattern:String,attrs:[NSAttributedString.Key : Any]) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(string: self)
        self.regex(pattern: pattern, options: []) { (match, _, _) in
            if let m = match {
                attrStr.addAttributes(attrs, range: m.range)
            }
        }
        return attrStr
    }
    var makeURL:URL? {
        return URL(string: self)
    }
    public func replace(pattern:String, replaceWith:String = "") -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return self
        }
    }
    func index(at offset: Int) -> String.Index {
        index(startIndex, offsetBy: offset)
    }
    subscript(_ index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    subscript(_ range: CountableClosedRange<Int>) -> String {
        String(self[index(at: max(0, range.lowerBound))...index(at: min(self.count, range.upperBound))])
    }
    
    subscript(_ range: CountableRange<Int>) -> String {
        String(self[index(at: max(0, range.lowerBound))..<index(at: min(self.count, range.upperBound))])
    }
    
    subscript(_ range: PartialRangeUpTo<Int>) -> String {
        String(self[..<index(at: min(self.count, range.upperBound))])
    }
    
    subscript(_ range: PartialRangeThrough<Int>) -> String {
        String(self[...index(at: min(self.count, range.upperBound))])
    }
    
    subscript(_ range: PartialRangeFrom<Int>) -> String {
        String(self[index(at: max(0, range.lowerBound))...])
    }
    static func random(length:Int = 20)->String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".map {
            return String($0)
        }
        var randomString: String = ""
        for _ in 0..<length {
            randomString += base.randomElement()!
        }
        return randomString
    }
    var version:Version {
        .init(version: self)
    }
    var intValue:Int? {
        .init(self)
    }
//    var qrCode:UIImage? {
//        let data = self.data(using: String.Encoding.ascii)
//        guard let filter = CIFilter(name: "CIQRCodeGenerator")?.then({ $0.setValue(data, forKey: "inputMessage")}),
//              let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 3, y: 3)) else {return nil}
//        return UIImage(ciImage: output)
//    }
    var localized:String {
        return NSLocalizedString(self, comment: "")
    }
    func localized(comment:String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    func localized(with argument:CVarArg..., comment:String = "") -> String {
        return String(format: self.localized(comment: comment), argument)
    }
}
struct Version : Equatable {
    var version:String
}
extension Version {
    static func ==(lhs: Version, rhs: Version) -> Bool {
        return lhs.version.compare(rhs.version, options: .numeric) == .orderedSame
    }
    
    static func <(lhs: Version, rhs: Version) -> Bool {
        return lhs.version.compare(rhs.version, options: .numeric) == .orderedAscending
    }
    
    static func <=(lhs: Version, rhs: Version) -> Bool {
        return lhs.version.compare(rhs.version, options: .numeric) == .orderedAscending || lhs.version.compare(rhs.version, options: .numeric) == .orderedSame
    }
    
    static func >(lhs: Version, rhs: Version) -> Bool {
        return lhs.version.compare(rhs.version, options: .numeric) == .orderedDescending
    }
    
    static func >=(lhs: Version, rhs: Version) -> Bool {
        return lhs.version.compare(rhs.version, options: .numeric) == .orderedDescending || lhs.version.compare(rhs.version, options: .numeric) == .orderedSame
    }
}

extension Data {
    func makeObj<T:Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
    func makeObj<T:Decodable>(type:T.Type) throws -> T {
        return try makeObj()
    }
    var dict:[String:Any]? {
        return try? JSONSerialization.jsonObject(with: self) as? [String:Any]
    }
}

extension Encodable {
    var allProperties:[(String,Encodable?)] {
        var result = [(String,Encodable?)]()
        let mirror = Mirror(reflecting: self)
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return []
        }
        for (property, value) in mirror.children {
            if let p = property {
                result.append((p,value as? Encodable))
            }
        }
        return result
    }
    var JSONString:String? {
        return String(data: self.data, encoding: .utf8)
    }
    var data:Data {
        guard let data = try? JSONEncoder().encode(self) else {
            return Data()
        }
        return data
    }
}
extension Decodable {
    var makeHttpHeader:HTTPHeaders {
        var result = HTTPHeaders()
        let mirror = Mirror(reflecting: self)
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return [:]
        }
        for (property, value) in mirror.children {
            if let p = property {
                result[p] = value as? String
            }
        }
        return result
    }
}
