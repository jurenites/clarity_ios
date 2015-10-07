//
//  OrderStatusView.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/28/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class OrderStatusView: UIView {
    private static var dispatchToken: dispatch_once_t = 0
    private let _submittedColor : UIColor = UIColor(fromHex: "#8B7AC8")
    private let _assignedColor : UIColor = UIColor(fromHex: "#5C6EC7")
    private let _progressColor : UIColor = UIColor(fromHex: "#9AC55A")
    private let _broadcastedColor : UIColor = UIColor(fromHex: "#6DBBBC")
    
    @IBOutlet var uiTitle : UILabel!

    class func item(status: String) -> (hex: String, image: String) {
        struct staticHolder {
            static var itemsMap: [String : [String : String]] = [:]
        }
        dispatch_once(&dispatchToken) {
            CallSyncOnMainThread({
                staticHolder.itemsMap = [
                    "assigned" : ["hex" : "#5C6EC7", "image" : "Assigned"],
                    "scheduled" : ["hex" : "#759B62", "image" : "Scheduled"],
                    "in_progress" : ["hex" : "#9AC55A", "image" : "in-Progress"],
                    "in_review" : ["hex" : "#BFAE3A", "image" : "in-Review"],
                    "bid" : ["hex" : "#5C6EC7", "image" : "Bid"],
                    "accepted_by_vendor_with_conditions" : ["hex" : "#6DBBBC", "image" : "Accepted-with-conditions"],
                    "assignment_pending" : ["hex" : "#6381CF", "image" : "Assignment-Pending"],
                    "broadcasted" : ["hex" : "#5C6EC7", "image" : "Broadcasted"],
                    "declined_by_vendor" : ["hex" : "#6DBBBC", "image" : "Declined-by-Vendor"],
                    "corrections_requested_by_amc" : ["hex" : "#F8A717", "image" : "Corrections-requested"],
                    "accepted_by_vendor" : ["hex" : "#6DBBBC", "image" : "Accepted-by-Vendor"],
                    "submitted" : ["hex" : "#A9B35D", "image" : "Submitted"],
                    "pending_approval" : ["hex" : "#7A93DA", "image" : "Pending-Approval"],
                    "completed" : ["hex" : "#D28100", "image" : "Completed"]
                ]
            })
        }
        
        if let result = staticHolder.itemsMap[status] {
            return (result["hex"]!, result["image"]!)
        }
        return ("#5C6EC7", "Declined-by-Vendor")
    }
    
    func setup(status : String) {
        
        let result = OrderStatusView.item(status)
        
        self.backgroundColor = UIColor(fromHex: result.hex)
        self.uiTitle.text = GlobalEntitiesCtrl.shared().orderStatusForKey(status)
    }
    
}
