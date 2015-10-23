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
    
    @IBOutlet var uiContainer: UIView!
    @IBOutlet var uiInfoContainer : UIView!
    @IBOutlet var uiOrderStatus : OrderStatusView!
    
    @IBInspectable var borderColor: UIColor = UIColor.blackColor()
    @IBInspectable var highlitedColor: UIColor = UIColor.blackColor()
    @IBInspectable var defaultColor: UIColor = UIColor.blackColor()
    
    @IBInspectable var evenColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var notEvenColor: UIColor = UIColor.darkGrayColor()
    
    private var titleDefaultColor: UIColor = UIColor.blackColor()
    
    class func nibName() -> String! {
        return "OrdersListCell"
    }
    
    class func height() -> CGFloat {
        return 110
    }
    
    func setOrder(order: ShortOrder, even: Bool) {
        self.uiOrderNum.text = "\(order.orderId)"
        self.uiAddress.text = order.address
        self.uiPrice.text = "$ \(order.price)"
        self.uiOrderStatus.setup(order.status)
        
        if even {
             uiContainer.backgroundColor = evenColor
        } else {
             uiContainer.backgroundColor = notEvenColor
        }
        
        let color = uiInfoContainer.backgroundColor
        uiInfoContainer.backgroundColor = UIColor.clearColor()
        uiInfoContainer.layer.backgroundColor = color?.CGColor
        uiInfoContainer.layer.borderColor = borderColor.CGColor
        uiInfoContainer.layer.borderWidth = 0.5
        uiInfoContainer.layer.masksToBounds = false
        uiInfoContainer.layer.shouldRasterize = true
        uiInfoContainer.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layoutIfNeeded()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        if animated {
            UIView.animateWithDuration(0.33, animations: { () -> Void in
                self.uiInfoContainer.backgroundColor = selected ? self.highlitedColor : UIColor.whiteColor()
            })
        } else {
            self.uiInfoContainer.backgroundColor = selected ? self.highlitedColor : UIColor.whiteColor()
        }
    }
}
