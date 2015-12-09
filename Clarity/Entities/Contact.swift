//
//  Contact.swift
//  Clarity
//
//  Created by Oleg Kasimov on 12/8/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import Foundation

class Contact: ApiEntity, Visitable {
    
    var contactId: Int = 0
    var name: String = ""
    var email: String = ""
    var workPhone: String = ""
    var otherPhone: String = ""

    override func fillWithApiDict(d: NSDictionary) {
        contactId = ApiInt(d["id"])
        name = ApiString(d["name"])
        email = ApiString(d["email"])
        workPhone = ApiString(d["work_phone"])
        otherPhone = ApiString(d["mobile_phone"])
    }
    
    func visit(v: EntityVisitor) {
        v.field("id", &contactId)
            .field("name", &name)
            .field("email", &email)
            .field("work_phone", &workPhone)
            .field("mobile_phone", &otherPhone)
    }
    
    func fromDict(d: NSDictionary) -> User {
        return DictUnarchiver(d).load()
    }
    
    func toDict() -> NSDictionary {
        return DictArchiver.toDict(self)
    }
}