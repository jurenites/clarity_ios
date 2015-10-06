//
//  TypeConv.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 12/18/14.
//  Copyright (c) 2014 Life Church. All rights reserved.
//

import Foundation

extension NSObject
{
    func apiFloatVal() -> Float {
        return 0.0
    }
    
    func apiDoubleVal() -> Double {
        return 0.0
    }
    
    func apiIntVal() -> Int {
        return 0
    }
    
    func apiBoolVal() -> Bool {
        return false
    }
    
    func apiDateVal() -> NSDate {
        return NSDate(timeIntervalSince1970: 0)
    }
    
    func apiStringVal() -> String {
        return ""
    }
}

extension NSString
{
    override func apiFloatVal() -> Float {
        return self.floatValue()
    }
    
    override func apiDoubleVal() -> Double {
        return self.doubleValue()
    }
    
    override func apiIntVal() -> Int {
        return self.integerValue
    }
    
    override func apiBoolVal() -> Bool {
        return self.boolValue()
    }
    
    override func apiDateVal() -> NSDate {
        struct S {
            static var formatter = NSDateFormatter()
            static var shortFormatter = NSDateFormatter()
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&S.onceToken, { () -> Void in
            let locale = NSLocale(localeIdentifier: "en_US_POSIX")
            
            S.formatter.locale = locale
            S.formatter.timeZone = NSTimeZone.localTimeZone()
            S.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            S.shortFormatter.locale = locale
            S.shortFormatter.timeZone = NSTimeZone.localTimeZone()
            S.shortFormatter.dateFormat = "yyyy-MM-dd"
        })
        
        let formatter = self.length > 10 ? S.formatter : S.shortFormatter
        
        return formatter.dateFromString(self as String) ?? NSDate(timeIntervalSince1970: 0)
    }
    
    override func apiStringVal() -> String {
        return self as String
    }
}

extension NSNumber
{
    override func apiFloatVal() -> Float {
        return self.floatValue()
    }
    
    override func apiDoubleVal() -> Double {
        return self.doubleValue()
    }
    
    override func apiIntVal() -> Int {
        return self.integerValue
    }
    
    override func apiBoolVal() -> Bool {
        return self.boolValue()
    }
    
    override func apiStringVal() -> String {
        return self.stringValue() as String
    }
    
    override func apiDateVal() -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(self.apiIntVal()))
    }
}

extension NSDate
{
    class var Empty: NSDate {get{return NSDate(timeIntervalSince1970: 0)}}
}

func ApiString(val: AnyObject?) -> String {
    return (val as? NSObject)?.apiStringVal() ?? ""
}

func ApiInt(val: AnyObject?) -> Int {
    return (val as? NSObject)?.apiIntVal() ?? 0
}

func ApiBool(val: AnyObject?) -> Bool {
    return (val as? NSObject)?.apiBoolVal() ?? false
}

func ApiFloat(val: AnyObject?) -> Float {
    return (val as? NSObject)?.apiFloatVal() ?? 0
}

func ApiDouble(val: AnyObject?) -> Double {
    return (val as? NSObject)?.apiDoubleVal() ?? 0
}

func ApiDate(val: AnyObject?) -> NSDate {
    return (val as? NSObject)?.apiDateVal() ?? NSDate(timeIntervalSince1970: 0)
}


func ApiVal(val: AnyObject?) -> NSString {
    return ApiString(val)
}

func ApiVal(val: AnyObject?) -> Int {
    return ApiInt(val)
}

func ApiVal(val: AnyObject?) -> Bool {
    return ApiBool(val)
}

func ApiVal(val: AnyObject?) -> Float {
    return ApiFloat(val)
}

func ApiVal(val: AnyObject?) -> Double {
    return ApiDouble(val)
}

func ApiVal(val: AnyObject?) -> NSDate {
    return ApiDate(val)
}


// MARK: String conv
func ToString(val: Int?) -> NSString {
    return (val != nil) ? NSNumber(integer: val!).apiStringVal() : ""
}

func ToString(val: NSDate?) -> NSString {
    struct S {
        static var formatter = NSDateFormatter()
        static var onceToken: dispatch_once_t = 0
    }
    
    dispatch_once(&S.onceToken, { () -> Void in
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        S.formatter.locale = locale
        S.formatter.timeZone = NSTimeZone.localTimeZone()
        S.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    })
    
    if let date = val {
        return S.formatter.stringFromDate(date)
    }
    
    return ""
}

private struct S {
    private static var formatter = NSDateFormatter()
    private static var onceToken: dispatch_once_t = 0
    
    static func fmt() -> NSDateFormatter {
        dispatch_once(&S.onceToken, {
            let locale = NSLocale(localeIdentifier: "en_US_POSIX")
            self.formatter.locale = locale
            self.formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        })
        return formatter
    }
}

func PersistToString(date: NSDate) -> String {
    return S.fmt().stringFromDate(date)
}

func PersistToDate(string: String) -> NSDate {
    return S.fmt().dateFromString(string) ?? NSDate.Empty
}

// MARK: ObjConvertable
protocol ObjConvertable
{
    typealias ItemType
    
    static func makeWithObject(object: AnyObject?) -> ItemType
    func toObject() -> NSObject
}

extension Int: ObjConvertable
{
    static func makeWithObject(object: AnyObject?) -> Int {
        return ApiInt(object)
    }
    
    func toObject() -> NSObject {
        return NSNumber(integer: self)
    }
}

extension Float: ObjConvertable
{
    static func makeWithObject(object: AnyObject?) -> Float {
        return ApiFloat(object)
    }
    
    func toObject() -> NSObject {
        return NSNumber(float: self)
    }
}

extension Double: ObjConvertable
{
    static func makeWithObject(object: AnyObject?) -> Double {
        return ApiDouble(object)
    }
    
    func toObject() -> NSObject {
        return NSNumber(double: self)
    }
}

extension Bool: ObjConvertable
{
    static func makeWithObject(object: AnyObject?) -> Bool {
        return ApiBool(object)
    }
    
    func toObject() -> NSObject {
        return NSNumber(bool: self)
    }
}

extension String: ObjConvertable
{
    static func makeWithObject(object: AnyObject?) -> String {
        return ApiString(object)
    }
    
    func toObject() -> NSObject {
        return self
    }
}

extension NSDate: ObjConvertable
{
    class func makeWithObject(object: AnyObject?) -> NSDate {
        return ApiDate(object)
    }
    
    func toObject() -> NSObject {
        return ToString(self)
    }
}

func ConvertValuesToObjects<ValueT: Any where ValueT: ObjConvertable>(values: [ValueT]) -> NSArray {
    return values.map{(value: ValueT) -> NSObject in value.toObject()}
}

func ConvertObjectsToValues<ValueT: Any where ValueT: ObjConvertable>(__objects: AnyObject?) -> [ValueT] {
    var values = [ValueT]()
    
    if let objects = __objects as? NSArray {
        for obj in objects {
            values.append(ValueT.makeWithObject(obj) as! ValueT)
        }
    }
    
    return values
}

// MARK: JSON conversion

private func ObjectToJson(object: AnyObject) -> String {
    if let data = try? NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions()) {
        return (NSString(data: data, encoding: NSUTF8StringEncoding) ?? "") as String
    }
    
    return ""
}

func ToJson<EntityT: ApiEntity where EntityT: Visitable>(entity: EntityT) -> String {
    let arch = DictArchiver();
    
    arch.save(entity)
    return ObjectToJson(arch.dict())
}

func ToJson<EntityT: ApiEntity where EntityT: Visitable>(entities: [EntityT]) -> String {
    let array = entities.map{(entity: EntityT) -> NSDictionary in DictArchiver.toDict(entity)}
    
    return ObjectToJson(array)
}

func ToJson<ValueT: Any where ValueT: ObjConvertable>(values: [ValueT]) -> String {
    return ObjectToJson(ConvertValuesToObjects(values))
}

private func ObjectFromJson(json: String) -> AnyObject {
    return (try? NSJSONSerialization.JSONObjectWithData(json.dataUsingEncoding(NSUTF8StringEncoding) ?? NSData(), options: NSJSONReadingOptions())) ?? NSArray()
}

func FromJson<EntityT: ApiEntity where EntityT: Visitable>(json: String) -> EntityT {
    if let object = ObjectFromJson(json) as? NSDictionary {
        let entity: EntityT = DictUnarchiver(object).load()
        return entity
    }
    
    return (EntityT.self as EntityT.Type).init()
}

func FromJson<EntityT: ApiEntity where EntityT: Visitable>(json: String) -> [EntityT] {
    if let entityArray = ObjectFromJson(json) as? NSArray {
        var arr = [EntityT]()
        
        for dict in entityArray {
            if let entityDict = dict as? NSDictionary {
                let entity: EntityT = DictUnarchiver(entityDict).load()
                arr.append(entity)
            }
        }
        return arr
    }
    
    return []
}

func FromJson<ValueT: Any where ValueT: ObjConvertable>(json: String) -> [ValueT] {
    if let valuesArray = ObjectFromJson(json) as? NSArray {
        return ConvertObjectsToValues(valuesArray)
    }
    
    return []
}
