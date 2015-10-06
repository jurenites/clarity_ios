//
//  Location.swift
//  Clarity
//
//  Created by Oleg Kasimov on 10/5/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import Foundation

class Location: ApiEntity, Visitable  {
    var locationId: Int = 0
    var address_1: String = ""
    var address_2: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var county: String = ""
    var lng: String = ""
    var lat: String = ""
    
    override func fillWithApiDict(d: NSDictionary) {
        locationId = ApiInt(d["id"])
        address_1 = ApiString(d["address_1"])
        address_2 = ApiString(d["address_2"])
        city = ApiString(d["city"])
        state = ApiString(d["state"])
        zip = ApiString(d["zip_code"])
        county = ApiString(d["county"])
        lng = ApiString(d["lng"])
        lat = ApiString(d["lat"])
    }
    
    func visit(v: EntityVisitor) {
        v.field("id", &locationId)
            .field("address_1", &address_1)
            .field("address_2", &address_2)
            .field("city", &city)
            .field("state", &state)
            .field("zip_code", &zip)
            .field("county", &county)
            .field("lng", &lng)
            .field("lat", &lat)
    }
    
    func fromDict(d: NSDictionary) -> ShortOrder {
        return DictUnarchiver(d).load()
    }
    
    func toDict() -> NSDictionary {
        return DictArchiver.toDict(self)
    }
}
