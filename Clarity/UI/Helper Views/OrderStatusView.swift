//
//  OrderStatusView.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/28/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class OrderStatusView: UIView {
    private let _submittedColor : UIColor = UIColor(fromHex: "#8B7AC8")
    private let _assignedColor : UIColor = UIColor(fromHex: "#5C6EC7")
    private let _progressColor : UIColor = UIColor(fromHex: "#9AC55A")
    private let _broadcastedColor : UIColor = UIColor(fromHex: "#6DBBBC")
    
    @IBOutlet var uiTitle : UILabel!
    
    func setup(status : ShortOrder.Status) {
        switch status {
        case ShortOrder.Status.Assigned :
            self.backgroundColor = _assignedColor
            self.uiTitle.text = NSLocalizedString("Assigned", comment: "")
        case ShortOrder.Status.Submitted :
            self.backgroundColor = _submittedColor
            self.uiTitle.text = NSLocalizedString("Submitted", comment: "")
        case ShortOrder.Status.Progress :
            self.backgroundColor = _progressColor
            self.uiTitle.text = NSLocalizedString("In Progress", comment: "")
        case ShortOrder.Status.Broadkasted :
            self.backgroundColor = _broadcastedColor
            self.uiTitle.text = NSLocalizedString("Broadkasted", comment: "")
        default : self.uiTitle.text = ""
        }
    }
    
}
