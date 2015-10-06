//
//  DictArchive.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 12/25/14.
//  Copyright (c) 2014 Life Church. All rights reserved.
//

import Foundation

class DictArchiver: EntityVisitor
{
    private var _dict = NSMutableDictionary()
    
    class func toDict<EntityT: ApiEntity where EntityT: Visitable>(val: EntityT) -> NSDictionary {
        let inner = DictArchiver()
        
        val.visit(inner)
        return inner.dict()
    }
    
    func save<EntityT: ApiEntity where EntityT: Visitable>(val: EntityT) {
        val.visit(self)
    }
    
    func dict() -> NSDictionary {
        return _dict
    }
    
    func type() -> EntityVisitorType {
        return .Save
    }
    
    // MARK: Setters
    
    private func setVal(name: String, _ val: Int) {
        _dict[name] = NSNumber(integer: val)
    }
    
    private func setVal(name: String, _ val: Double) {
        _dict[name] = NSNumber(double: val)
    }
    
    private func setVal(name: String, _ val: Bool) {
        _dict[name] = NSNumber(bool: val)
    }
    
    private func setVal(name: String, _ val: String) {
        _dict[name] = val as NSString
    }
    
    private func setVal(name: String, _ val: NSDate) {
        _dict[name] = PersistToString(val)
    }
    
    private func setVal<EntityT: ApiEntity where EntityT: Visitable>(name: String, _ val: EntityT) {
        _dict[name] = DictArchiver.toDict(val)
    }
    
    private func setVal<EntityT: ApiEntity where EntityT: Visitable>(name: String, _ val: [EntityT]) {
        let array = val.map{(entity: EntityT) -> NSDictionary in DictArchiver.toDict(entity)}
        _dict[name] = array
    }
    
    // MARK: EntityVisitor
    
    func field(name: String, inout _ val: Int) -> EntityVisitor {
        setVal(name, val)
        return self
    }

    func field(name: String, inout _ val: Double) -> EntityVisitor {
        setVal(name, val)
        return self
    }

    func field(name: String, inout _ val: Bool) -> EntityVisitor {
        setVal(name, val)
        return self
    }

    func field(name: String, inout _ val: String) -> EntityVisitor {
        setVal(name, val)
        return self
    }

    func field(name: String, inout _ val: NSDate) -> EntityVisitor {
        setVal(name, val)
        return self
    }

    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: EntityT) -> EntityVisitor {
        setVal(name, val)
        return self
    }

    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: [EntityT]) -> EntityVisitor {
        setVal(name, val)
        return self
    }

    func field<ValueT: Any where ValueT: ObjConvertable>(name: String, inout _ val: [ValueT]) -> EntityVisitor {
        _dict[name] = ConvertValuesToObjects(val)
        return self
    }
    
    func field(name: String, inout _ val: Int?) -> EntityVisitor {
        if let _val = val {
            setVal(name, _val)
        }
        return self
    }

    func field(name: String, inout _ val: Double?) -> EntityVisitor {
        if let _val = val {
            setVal(name, _val)
        }
        return self
    }

    func field(name: String, inout _ val: Bool?) -> EntityVisitor {
        if let _val = val {
            setVal(name, _val)
        }
        return self
    }

    func field(name: String, inout _ val: String?) -> EntityVisitor {
        if let _val = val {
            setVal(name, _val)
        }
        return self
    }

    func field(name: String, inout _ val: NSDate?) -> EntityVisitor {
        if let _val = val {
            setVal(name, _val)
        }
        return self
    }

    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: EntityT?) -> EntityVisitor {
        if let _val = val {
            setVal(name, _val)
        }
        return self
    }

    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: [EntityT]?) -> EntityVisitor {
        if let _val = val {
            setVal(name, _val)
        }
        return self
    }
    
    func field<ValueT: Any where ValueT: ObjConvertable>(name: String, inout _ val: [ValueT]?) -> EntityVisitor {
        if let _val = val {
            _dict[name] = ConvertValuesToObjects(_val)
        }
        return self
    }
}

//==========================================================
class DictUnarchiver: EntityVisitor
{
    private var _dict = NSDictionary()
    
    init(_ dict: NSDictionary) {
        _dict = dict
    }
    
    func load<EntityT: ApiEntity where EntityT: Visitable>() -> EntityT {
        let entity = (EntityT.self as EntityT.Type).init()
        
        entity.visit(self)
        return entity
    }
    
    func load<EntityT: ApiEntity where EntityT: Visitable>(inout entity: EntityT) {
        entity.visit(self)
    }
    
    func type() -> EntityVisitorType {
        return .Load
    }
    
    private func getIntVal(val: AnyObject?) -> Int {
        return ApiInt(val)
    }
    
    private func getFloatVal(val: AnyObject?) -> Float {
        return ApiFloat(val)
    }
    
    private func getDoubleVal(val: AnyObject?) -> Double {
        return ApiDouble(val)
    }
    
    private func getBoolVal(val: AnyObject?) -> Bool {
        return ApiBool(val)
    }

    private func getStringVal(val: AnyObject?) -> String {
        return ApiString(val)
    }
    
    private func getDateVal(val: AnyObject?) -> NSDate {
        if let str = val as? String {
            return PersistToDate(str)
        }
        return NSDate.Empty
    }
    
    func getEntityVal<EntityT: ApiEntity where EntityT: Visitable>(val: AnyObject?) -> EntityT {
        if let entityDict = val as? NSDictionary {
            return DictUnarchiver(entityDict).load()
        }
        
        return (EntityT.self as EntityT.Type).init()
    }
    
    func getArrayVal<EntityT: ApiEntity where EntityT: Visitable>(val: AnyObject?) -> [EntityT] {
        if let entityArray = val as? NSArray {
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
    
    // MARK: EntityVisitor
    
    func field(name: String, inout _ val: Int) -> EntityVisitor {
        val = getIntVal(_dict[name])
        return self
    }
    
    func field(name: String, inout _ val: Float) -> EntityVisitor {
        val = getFloatVal(_dict[name])
        return self
    }

    func field(name: String, inout _ val: Double) -> EntityVisitor {
        val = getDoubleVal(_dict[name])
        return self
    }

    func field(name: String, inout _ val: Bool) -> EntityVisitor {
        val = getBoolVal(_dict[name])
        return self
    }

    func field(name: String, inout _ val: String) -> EntityVisitor {
        val = getStringVal(_dict[name])
        return self
    }

    func field(name: String, inout _ val: NSDate) -> EntityVisitor {
        val = getDateVal(_dict[name])
        return self
    }

    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: EntityT) -> EntityVisitor {
        val = getEntityVal(_dict[name])
        return self
    }

    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: [EntityT]) -> EntityVisitor {
        val = getArrayVal(_dict[name])
        return self
    }

    func field<ValueT: Any where ValueT: ObjConvertable>(name: String, inout _ val: [ValueT]) -> EntityVisitor {
        val = ConvertObjectsToValues(_dict[name])
        return self
    }
    
    
    func field(name: String, inout _ val: Int?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            val = getIntVal(obj)
        } else {
            val = nil
        }
        return self
    }

    func field(name: String, inout _ val: Float?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            val = getFloatVal(obj)
        } else {
            val = nil
        }
        return self
    }

    func field(name: String, inout _ val: Double?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            val = getDoubleVal(obj)
        } else {
            val = nil
        }
        return self
    }

    func field(name: String, inout _ val: Bool?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            val = getBoolVal(obj)
        } else {
            val = nil
        }
        return self
    }

    func field(name: String, inout _ val: String?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            val = getStringVal(obj)
        } else {
            val = nil
        }
        return self
    }

    func field(name: String, inout _ val: NSDate?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            val = getDateVal(obj)
        } else {
            val = nil
        }
        return self
    }

    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: EntityT?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            let entity: EntityT = getEntityVal(obj)
            val = entity
        } else {
            val = nil
        }
        return self
    }

    func field<EntityT: ApiEntity where EntityT: Visitable>(name: String, inout _ val: [EntityT]?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            val = getArrayVal(obj)
        } else {
            val = nil
        }
        return self
    }

    func field<ValueT: Any where ValueT: ObjConvertable>(name: String, inout _ val: [ValueT]?) -> EntityVisitor {
        if let obj: AnyObject = _dict[name] {
            val = ConvertObjectsToValues(_dict[name])
        } else {
            val = nil
        }
        return self
    }
    
}

