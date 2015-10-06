//
//  Region.swift
//  TRN
//
//  Created by Alexey Klyotzin on 03/04/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import UIKit

class Region: ApiEntity, Visitable
{
    var regionId: Int = 0
    var name: String = ""
    var timeZone: NSTimeZone = NSTimeZone(forSecondsFromGMT: 0)
    var descr: String = ""
    var priority: Int = 0
    
    override func fillWithApiDict(d: NSDictionary) {
        regionId = ApiInt(d["id"])
        name = ApiString(d["name"])
        timeZone = NSTimeZone(name: ApiString(d["timezone"])) ?? timeZone
        descr = ApiString(d["description"])
        priority = ApiInt(d["priority"])
    }
    
    func visit(v: EntityVisitor) {
        var timeZoneName = timeZone.name
        
        v.field("regionId", &regionId)
         .field("name", &name)
         .field("timeZone", &timeZoneName)
         .field("descr", &descr)
         .field("priority", &priority)
        
        if v.type() == .Load {
            timeZone = NSTimeZone(name: timeZoneName) ?? timeZone
        }
    }
    
    class func fromDict(dict: NSDictionary) -> Region {
        return DictUnarchiver(dict).load()
    }
    
    func toDict() -> NSDictionary {
        return DictArchiver.toDict(self)
    }
}
