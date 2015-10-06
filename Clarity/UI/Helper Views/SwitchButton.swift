//
//  SwitchButton.swift
//  TRN
//
//  Created by Alexey Klyotzin on 18/02/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import UIKit

class SwitchButton: UIControl
{
    @IBOutlet var uiImage: UIImageView!
    
    override var selected: Bool {
        get {return super.selected}
        set(newSel) {
            super.selected = newSel
            uiImage.highlighted = newSel
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        uiImage.highlighted = false
    }
}
