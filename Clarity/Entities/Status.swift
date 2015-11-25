//
//  Status.swift
//  Clarity
//
//  Created by Oleg Kasimov on 11/25/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import Foundation

class Status: ApiEntity, Visitable  {
    var key: String = ""
    var name: String = ""
    var hex: String = ""
    
    override func fillWithApiDict(d: NSDictionary) {
        key = ApiString(d["key"])
        name = ApiString(d["name"])
        hex = ApiString(d["hex"])
    }
    
    func visit(v: EntityVisitor) {
        v.field("key", &key)
            .field("name", &name)
            .field("hex", &hex)
    }
    
    func fromDict(d: NSDictionary) -> ShortOrder {
        return DictUnarchiver(d).load()
    }
    
    func toDict() -> NSDictionary {
        return DictArchiver.toDict(self)
    }
}