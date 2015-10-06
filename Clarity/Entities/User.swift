//
//  User.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/24/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

import UIKit

class User : ApiEntity, Visitable {
    
    var userId: Int = 0
    var companyId: Int = 0
    var vendorId: Int = 0
    var name: String = ""
    var email: String = ""
    var vendorName: String = ""
    var companyName: String = ""
    var role: String = ""
    var workPhone: String = ""
    var otherPhone: String = ""
    
    override func fillWithApiDict(d: NSDictionary) {
        userId = ApiInt(d["id"])
        companyId = ApiInt(d["company_id"])
        vendorId = ApiInt(d["vendor_id"])
        
        name = ApiString(d["name"])
        email = ApiString(d["email"])
        vendorName = ApiString(d["vendor_name"])
        companyName = ApiString(d["company_name"])
        
        role = ApiString(d["role"])
        
        workPhone = ApiString(d["work_phone"])
        otherPhone = ApiString(d["other_phone"])
    }
    
    func visit(v: EntityVisitor) {
        v.field("id", &userId)
            .field("company_id", &companyId)
            .field("vendor_id", &vendorId)
            .field("name", &name)
            .field("email", &email)
            .field("vendor_name", &vendorName)
            .field("company_name", &companyName)
            .field("role", &role)
            .field("work_phone", &workPhone)
            .field("other_phone", &otherPhone)
    }
    
    func fromDict(d: NSDictionary) -> User {
        return DictUnarchiver(d).load()
    }
    
    func toDict() -> NSDictionary {
        return DictArchiver.toDict(self)
    }
}