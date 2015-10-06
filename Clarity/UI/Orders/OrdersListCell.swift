//
//  OrdersListCell.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/25/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

import UIKit

class OrdersListCell: UITableViewCell {
    
    @IBOutlet var uiOrderNum : UILabel!
    @IBOutlet var uiAddress : UILabel!
    @IBOutlet var uiPrice : UILabel!
    
    @IBOutlet var uiPriceContainer : UIView!
    @IBOutlet var uiOrderStatus : OrderStatusView!
    
    @IBInspectable var borderColor: UIColor = UIColor.blackColor()
    
    class func nibName() -> String! {
        return "OrdersListCell"
    }
    
    class func height() -> CGFloat {
        return 90
    }
    
    func setOrder(order: ShortOrder) {
//        self.uiOrderNum.text = String(format: "%d", order.orderNumber)
        self.uiAddress.text = order.address
        self.uiPrice.text =  String(format: "$ %d", order.price)
        self.uiOrderStatus.setup(order.status)
        
        let color = uiPriceContainer.backgroundColor
        uiPriceContainer.backgroundColor = UIColor.clearColor()
        uiPriceContainer.layer.backgroundColor = color?.CGColor
//        uiStatusContainer.layer.cornerRadius = 8
        uiPriceContainer.layer.borderColor = borderColor.CGColor
        uiPriceContainer.layer.borderWidth = 0.5
        uiPriceContainer.layer.masksToBounds = false
        uiPriceContainer.layer.shouldRasterize = true
        uiPriceContainer.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layoutIfNeeded()
    }
}
