//
//  SchedBlock.swift
//  TRN
//
//  Created by Alexey Klyotzin on 01/04/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import UIKit

class SchedBlock: ApiEntity, ApiConvertableEntity
{
    var schedBlockId: Int = 0
    var regionId: Int = 0
    var dateFrom: NSDate = NSDate.Empty
    var dateTo: NSDate = NSDate.Empty
    var sessions: [SchedSession] = []
    
    override func fillWithApiDict(d: NSDictionary) {
        schedBlockId = ApiInt(d["id"])
        regionId = ApiInt(d["region_id"])
//        dateFrom = FromServerDate(ApiString(d["date_from"]))
//        dateTo = FromServerDate(ApiString(d["date_to"]))
        sessions = FromApiArray(d["sessions"])
    }
    
    func toApiDict() -> [String: AnyObject] {
        return ["":""]//["date_from": ToServerDate(dateFrom), "date_to": ToServerDate(dateTo)]
    }
}
