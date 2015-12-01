//
//  MessageCell.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/29/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class MessageCell : UITableViewCell {
    
    private static var dispatchToken: dispatch_once_t = 0
    var firstCell : Bool = false
    var _message: Message?
    
    @IBOutlet var uiText: UILabel!
    @IBOutlet var uiUserName: UILabel!
    @IBOutlet var uiBackground: MessageBack!
    
    @IBOutlet var lcTopMargin: NSLayoutConstraint!
    @IBOutlet var lcTextHeight: NSLayoutConstraint!
    
    class func nibName() -> String! {
        return "MessageCell"
    }
    
    func setupMessage(message: Message) {
        self.uiBackground.setNeedsDisplay()
        _message = message
        if let m = _message {
            self.lcTextHeight.constant = m.textHeight
            self.uiText.text = m.text
            self.uiUserName.text = m.authorName
            self.uiBackground.leftSide = !GlobalEntitiesCtrl.shared().isMyId(m.authorId)
        }
    }
    
    class func messageLayout(message : String) -> (textHeight: CGFloat, cellHeight: CGFloat) {
        struct staticHolder {
            static var constHeight: CGFloat = 0
            static var minTextHeight: CGFloat = 0
            static var textWidth: CGFloat = 0
            static var textFont: UIFont = UIFont()
        }
        
        dispatch_once(&dispatchToken) {
            CallSyncOnMainThread({
                let cell = loadViewFromNib(self.nibName())
                cell.contentView.width = UIScreen.mainScreen().bounds.size.width
                cell.contentView.layoutIfNeeded()
                
                staticHolder.minTextHeight = cell.uiText!.height
                staticHolder.constHeight = cell.contentView.height - staticHolder.minTextHeight
                staticHolder.textWidth = cell.uiText!.width
                staticHolder.textFont = cell.uiText!.font
            })
        }
        
        let textHeight = max(message.height(staticHolder.textFont, width: staticHolder.textWidth), staticHolder.minTextHeight)
        let cellHeight = textHeight + staticHolder.constHeight
        return (textHeight, cellHeight)
    }
}

class MessageBack : UIView {
    
    let triangleSide : CGFloat = 15
    let topTriangleSpace : CGFloat = 5
    var leftSide: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        //Draw specific message border
        let thickness : CGFloat = 0.5
        
        let context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        CGContextSetLineWidth(context, thickness)
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        
        let x = triangleSide/2 + thickness
        let lineEdge = thickness*0.5 //thickness
        CGContextMoveToPoint(context, x+lineEdge, thickness+lineEdge)
        if leftSide {
            CGContextAddLineToPoint(context, rect.width-x+lineEdge, thickness+lineEdge)
            CGContextAddLineToPoint(context, rect.width-x+lineEdge, rect.height-thickness*2+lineEdge)
        } else {
            CGContextAddLineToPoint(context, rect.width-x+lineEdge, thickness+lineEdge)
            CGContextAddLineToPoint(context, rect.width-x+lineEdge, topTriangleSpace+lineEdge)
            CGContextAddLineToPoint(context, rect.width-thickness+lineEdge, topTriangleSpace+triangleSide/2+lineEdge)
            CGContextAddLineToPoint(context, rect.width-x+lineEdge, topTriangleSpace+triangleSide+lineEdge)
            CGContextAddLineToPoint(context, rect.width-x+lineEdge, rect.height-thickness*2+lineEdge)
        }
        
        CGContextAddLineToPoint(context, x+lineEdge, rect.height-thickness*2+lineEdge)
        if leftSide {
            CGContextAddLineToPoint(context, x+lineEdge, topTriangleSpace+triangleSide+thickness+lineEdge)
            CGContextAddLineToPoint(context, thickness+lineEdge, topTriangleSpace+triangleSide/2+thickness+lineEdge)
            CGContextAddLineToPoint(context, x+lineEdge, topTriangleSpace+thickness+lineEdge)
            CGContextClosePath(context)
        } else {
            CGContextClosePath(context)
        }
        CGContextDrawPath(context, .FillStroke)
    }
}
