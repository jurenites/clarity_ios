//
//  Message.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/30/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import Foundation

class Message: ApiEntity, Visitable {
    
    struct staticHolder {
        static var dispatchToken: dispatch_once_t = 0
        static var formatter: NSDateFormatter = NSDateFormatter() //For (NSDate) createdDate
        static var stringFormatter: NSDateFormatter = NSDateFormatter() //For (String) formattedDate
    }
    
    var messageId: Int = 0
    var authorId: Int = 0
    var text: String = ""
    var authorName: String = ""
    var isRead: Bool = false
    var isEditable: Bool = false
    var createdDate: NSDate = NSDate()
    var formattedDate: String = ""
    
    //cell layout
    var textHeight: CGFloat = 0
    var messageCellHeight: CGFloat = 0
    
    override func fillWithApiDict(d: NSDictionary) {
        messageId  = ApiInt(d["id"])
        authorId = ApiInt(d["author_id"])
        authorName = ApiString(d["author_name"])
        text = ApiString(d["message"])
        isRead = ApiBool(d["is_read"])
        isEditable = ApiBool(d["is_editable"])
        
        dispatch_once(&staticHolder.dispatchToken) {
            staticHolder.formatter = NSDateFormatter()
            staticHolder.formatter.locale = NSLocale(localeIdentifier: "en_US")
            staticHolder.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            staticHolder.stringFormatter = NSDateFormatter()
            staticHolder.stringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            staticHolder.stringFormatter.dateFormat = "dd/MM/yyyy HH:mm aa"
        }

        //dateFrom = FromServerDateTime(ApiString(d["created_at"])) !!!
        if let date = staticHolder.formatter.dateFromString(ApiString(d["created_at"])) {
            createdDate = date
        }
        
        formattedDate = staticHolder.stringFormatter.stringFromDate(createdDate)
        
        //cell layout
        let out = MessageCell.messageLayout(text)
        textHeight = out.textHeight
        messageCellHeight = out.cellHeight
    }
    
    func visit(v: EntityVisitor) {
        v.field("id", &messageId)
            .field("author_id", &authorId)
            .field("author_name", &authorName)
            .field("message", &text)
            .field("is_read", &isRead)
            .field("is_editable", &isEditable)
    }
    
    func fromDict(d: NSDictionary) -> ShortOrder {
        return DictUnarchiver(d).load()
    }
    
    func toDict() -> NSDictionary {
        return DictArchiver.toDict(self)
    }

}