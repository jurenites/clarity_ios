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

    class func statusHexColor(status: String) -> String {
        struct staticHolder {
            static var colorsMap: [String : String] = [:]
        }
        dispatch_once(&dispatchToken) {
            CallSyncOnMainThread({
                staticHolder.colorsMap = [
                    "assigned" : "#5C6EC7",
                    "scheduled" : "#759B62",
                    "in_progress" : "#9AC55A",
                    "in_review" : "#BFAE3A",
                    "bid" : "#5C6EC7",
                    "accepted_by_vendor_with_conditions" : "#6DBBBC",
                    "assignment_pending" : "#6381CF",
                    "broadcasted" : "#5C6EC7",
                    "declined_by_vendor" : "#6DBBBC",
                    "corrections_requested_by_amc" : "#F8A717",
                    "accepted_by_vendor" : "#6DBBBC",
                    "submitted" : "#A9B35D",
                    "pending_approval" : "#7A93DA",
                    "completed" : "#D28100"
                ]
            })
        }
        
        if let hex = staticHolder.colorsMap[status] {
            return hex
        }
        return "#5C6EC7"
    }
    
    func setup(status : String) {
        self.backgroundColor = UIColor(fromHex: OrderStatusView.statusHexColor(status))
        self.uiTitle.text = GlobalEntitiesCtrl.shared().orderStatusForKey(status)
    }
    
}
