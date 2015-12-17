//
//  Order.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/25/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

import Foundation

class ShortOrder: ApiEntity, Visitable {
    
    var orderId : Int = 0
    var price : Double = 0
    var address : String = ""
    var status : String = ""
    var date: NSDate = NSDate.Empty
    
    override func fillWithApiDict(d: NSDictionary) {
        orderId  = ApiInt(d["id"])
        price = ApiDouble(d["vendor_fee"])
        address = ApiString(d["property_address"])
        status = ApiString(d["order_status"])
    }
    
    func visit(v: EntityVisitor) {
        v.field("id", &orderId)
        .field("vendor_fee", &price)
        .field("property_address", &address)
        .field("order_status", &status)
    }
    
    func fromDict(d: NSDictionary) -> ShortOrder {
        return DictUnarchiver(d).load()
    }
    
    func toDict() -> NSDictionary {
        return DictArchiver.toDict(self)
    }
}

class Order: ShortOrder {
    
    var messagesCount: Int = 0
    var unreadMessagesCount : Int = 0
    var dateTo: NSDate = NSDate.init()
    var dateFrom: NSDate = NSDate.init()
    var reportType: String = ""
    var propertyType: String = ""
    var contact: Contact? = nil
    var location: Location? = nil
    var canAccept: Bool = false
    var canAcceptWConditions: Bool = false
    var canDecline: Bool = false
    
    override func fillWithApiDict(d: NSDictionary) {
        super.fillWithApiDict(d)
        
        canAccept = ApiBool(d["accept_allowed"])
        canAcceptWConditions = ApiBool(d["accept_with_condition_allowed"])
        canDecline = ApiBool(d["decline_allowed"])
        
        reportType = ApiString(d["report_type"])
        propertyType = ApiString(d["property_type"])
        
        let user = Contact()
        user.fillWithApiDict(AssureIsDict(d["contact"]))
        contact = user
        
        let loc = Location()
        loc.fillWithApiDict(AssureIsDict(d["location"]))
        location = loc
        
        messagesCount = ApiInt(d["messages_count"])
        unreadMessagesCount = ApiInt(d["messages_unread"])
        dateFrom = FromServerDateTime(ApiString(d["created_at"]))
        dateTo = FromServerDate(ApiString(d["date_needed"]))
    }
    
    override func visit(v: EntityVisitor) {
        super.visit(v)
        
        v.field("messanges", &messagesCount)
            .field("unreadMessagesCount", &unreadMessagesCount)
            .field("date_needed", &dateTo)
            .field("created_at", &dateFrom)
            .field("report_type", &reportType)
            .field("property_type", &propertyType)
            .field("contact", &contact)
            .field("accept_allowed", &canAccept)
            .field("accept_with_condition_allowed", &canAcceptWConditions)
            .field("decline_allowed", &canDecline)
    }
    
    override func fromDict(d: NSDictionary) -> Order {
        return DictUnarchiver(d).load()
    }
    
    override func toDict() -> NSDictionary {
        return DictArchiver.toDict(self)
    }
}
