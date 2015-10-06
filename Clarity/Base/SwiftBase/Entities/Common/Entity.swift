//
//  Entity.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 12/18/14.
//  Copyright (c) 2014 Life Church. All rights reserved.
//

import Foundation

enum EntityVisitorType {case Load, Save}

protocol EntityVisitor
{
    func type() -> EntityVisitorType
    
    func field(name: String, inout _ val: Int) -> EntityVisitor
    func field(name: String, inout _ val: Double) -> EntityVisitor
    func field(name: String, inout _ val: Bool) -> EntityVisitor
    func field(name: String, inout _ val: String) -> EntityVisitor
    func field(name: String, inout _ val: NSDate) -> EntityVisitor
    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: EntityT) -> EntityVisitor
    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: [EntityT]) -> EntityVisitor
    func field<ValueT: Any where ValueT: ObjConvertable>(name: String, inout _ val: [ValueT]) -> EntityVisitor
    
    func field(name: String, inout _ val: Int?) -> EntityVisitor
    func field(name: String, inout _ val: Double?) -> EntityVisitor
    func field(name: String, inout _ val: Bool?) -> EntityVisitor
    func field(name: String, inout _ val: String?) -> EntityVisitor
    func field(name: String, inout _ val: NSDate?) -> EntityVisitor
    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: EntityT?) -> EntityVisitor
    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: [EntityT]?) -> EntityVisitor
    func field<ValueT: Any where ValueT: ObjConvertable>(name: String, inout _ val: [ValueT]?) -> EntityVisitor
}

protocol Visitable
{
    func visit(v: EntityVisitor)
}

protocol ApiConvertableEntity
{
    func toApiDict() -> [String: AnyObject]
}

class ApiEntity: NSObject
{
    class func create<T: ApiEntity>() -> T {
        return (T.self as T.Type).init()
    }
    
    required override init() {
        super.init()
    }
    
    func fillWithApiDict(d: NSDictionary) {
    }
}

func PliFromApiArray<EntityT: ApiEntity>(apiArray: AnyObject?) -> PipelineResult<[EntityT]> {
    var array = [EntityT]()
    
    if let _apiArray = apiArray as? NSArray {
        for dict in _apiArray {
            if let _dict = dict as? NSDictionary {
                let entity: EntityT = EntityT.create()
                
                entity.fillWithApiDict(_dict)
                array.append(entity)
            }
        }
    } else {
        return PipelineResult(InternalError(descr: "Types mismatch"))
    }
    
    return PipelineResult(array)
}

func PliFromApiDict<EntityT: ApiEntity>(apiDict: AnyObject?) -> PipelineResult<EntityT> {
    let entity: EntityT = EntityT.create()
    
    if let _dict = apiDict as? NSDictionary {
        entity.fillWithApiDict(_dict)
    }
    return PipelineResult(entity)
}

func FromApiArray<EntityT: ApiEntity>(apiArray: AnyObject?) -> [EntityT] {
    return PliFromApiArray(apiArray).result ?? []
}

func FromApiDict<EntityT: ApiEntity>(apiDict: AnyObject?) -> EntityT {
    return PliFromApiDict(apiDict).result ?? EntityT.create()
}

func ToApiArray<EntityT: ApiConvertableEntity>(entities: [EntityT]) -> [[String: AnyObject]] {
    var list: [[String: AnyObject]] = []
    
    for entity in entities {
        list.append(entity.toApiDict())
    }
    
    return list
}

func PliParseJson(result: IORequestResult) -> PipelineResult<AnyObject> {
    if let jsonData: AnyObject = try? NSJSONSerialization.JSONObjectWithData(result.data, options: NSJSONReadingOptions()) {
        return PipelineResult(jsonData)
    }
    
    return PipelineResult(InternalError(descr: "Bad JSON"))
}

class FromApiStruct<EntityT: ApiEntity>
{
    class func pliFromArray(apiArray: AnyObject?) -> PipelineResult<[EntityT]> {
        return PliFromApiArray(apiArray)
    }
    
    class func pliFromDict(apiDict: AnyObject?) -> PipelineResult<EntityT> {
        return PliFromApiDict(apiDict)
    }
}


