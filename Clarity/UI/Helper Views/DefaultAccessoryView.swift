//
//  DefaultAccessoryView.swift
//  TRN
//
//  Created by Alexey Klyotzin on 17/02/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import UIKit

class DefaultAccessoryView: UIView
{
    @IBOutlet var uiDoneButton: CustomButton!
    
    var onDone: (() -> Void)?
    
    class func create() -> DefaultAccessoryView {
        return loadViewFromNib("DefaultAccessoryView") as! DefaultAccessoryView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        uiDoneButton.layer.masksToBounds = true
        uiDoneButton.layer.cornerRadius = 4
        uiDoneButton.layer.borderWidth = 1
        uiDoneButton.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    @IBAction func actDone() {
        onDone?()
    }

}
