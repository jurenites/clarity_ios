//
//  ChatTextView.swift
//  Clarity
//
//  Created by Oleg Kasimov on 10/2/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class ChatTextView: UITextView {
    
    @IBInspectable var placeholder: String?
    
    func calculateHeight() -> CGFloat {
        return  ceil(self.sizeThatFits(self.frame.size).height)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if self.text.length > 0 {return}
        
        if let ph = placeholder {
            let font = self.font ?? UIFont.systemFontOfSize(15)
            let color = self.textColor ?? UIColor.lightGrayColor()
            
            let attributedPlaceholder = NSAttributedString(string: ph, attributes:
                [NSFontAttributeName : font, NSForegroundColorAttributeName : color])
            let size = attributedPlaceholder.size()
            attributedPlaceholder.drawInRect(CGRectMake(5, self.textContainerInset.top, size.width, size.height)) //0.5*(rect.height - size.height)
        }
    }
}
