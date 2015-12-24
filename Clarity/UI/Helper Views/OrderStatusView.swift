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
    
    @IBOutlet var uiTitle : UILabel!
    @IBOutlet var uiIcon: UIImageView!

    class func item(status: String) -> String {
        struct staticHolder {
            static var imagesMap: [String : String] = [:]
        }
        dispatch_once(&dispatchToken) {
            CallSyncOnMainThread({
                staticHolder.imagesMap = [
                    "assigned" : "Assigned",
                    "scheduled" : "Scheduled",
                    "in_progress" : "in-Progress",
                    "in_review" : "in-Review",
                    "bid" : "Bid",
                    "accepted_by_vendor_with_conditions" : "Accepted-with-conditions",
                    "assignment_pending" : "Assignment-Pending",
                    "broadcasted" : "Broadcasted",
                    "declined_by_vendor" : "Declined-by-Vendor",
                    "corrections_requested_by_amc" : "Corrections-requested",
                    "lender_corrections_request" : "Corrections-requested",
                    "accepted_by_vendor" : "Accepted-by-Vendor",
                    "submitted" : "Submitted",
                    "pending_approval" : "Pending-Approval",
                    "completed" : "Completed"
                ]
            })
        }
        
        if let result = staticHolder.imagesMap[status] {
            return result
        }
        return ("")
    }
    
    func setup(status : String) {
        let stat = GlobalEntitiesCtrl.shared().orderStatusForKey(status)
        self.backgroundColor = UIColor(fromHex: stat.hex)
        self.uiIcon.image = UIImage(named: OrderStatusView.item(status))
        self.uiTitle.text = stat.name
    }
}
