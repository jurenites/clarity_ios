//
//  SchedSession.swift
//  TRN
//
//  Created by Alexey Klyotzin on 01/04/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import UIKit

class SchedSession: ApiEntity
{
    enum Status: String {
        case Unknown = "", Booked = "booked", Canceled = "canceled"
    }
    
    var sessionId: Int = 0
    var locationId: Int = 0
    var dateFrom: NSDate = NSDate.Empty
    var dateTo: NSDate = NSDate.Empty
    var status: Status = .Unknown
    
    override func fillWithApiDict(d: NSDictionary) {
        sessionId = ApiInt(d["id"])
        locationId = ApiInt(d["location_id"])
//        dateFrom = FromServerDate(ApiString(d["date_from"]))
//        dateTo = FromServerDate(ApiString(d["date_to"]))
        status = Status(rawValue: ApiString(d["status"])) ?? .Unknown
    }
}
