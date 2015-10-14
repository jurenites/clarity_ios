//
//  MenuOverlay.swift
//  Clarity
//
//  Created by Oleg Kasimov on 10/5/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class MenuOverlay: BaseOverlay {
    
    @IBOutlet var uiContainer: UIView!
    @IBOutlet var uiName: UILabel!
    @IBOutlet var uiPortal: UILabel!
    
    init() {
        super.init(nibName: "MenuOverlay", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiName.text = GlobalEntitiesCtrl.shared().currentUser.name
        self.uiPortal.text = GlobalEntitiesCtrl.shared().currentUser.companyName
    }
    
    @IBAction func actLogOut() {
        ClarityApi.shared().logout()
            .success({ () -> Void in
                ApiRouter.shared().logout()
                self.hide()
            }) { (error: NSError) -> Void in
                self.reportError(error)
        }
    }
}

class MenuBack : UIView {
    let rightTriangleMargin: CGFloat = 15
    var leftSide: Bool = false
    @IBOutlet var lcTopMargin: NSLayoutConstraint!
    @IBInspectable var borderColor: UIColor = UIColor.grayColor()
    
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
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        
        let lineEdge = thickness*0.5
        let x: CGFloat = thickness+lineEdge
        
        let y = thickness+lineEdge
        let margin = y+lcTopMargin.constant
        
        CGContextMoveToPoint(context, x, margin)
        CGContextAddLineToPoint(context, rect.width-rightTriangleMargin-lcTopMargin.constant*2-x, margin)
        CGContextAddLineToPoint(context, rect.width-rightTriangleMargin-lcTopMargin.constant-x, y)
        CGContextAddLineToPoint(context, rect.width-rightTriangleMargin-x, margin)
        CGContextAddLineToPoint(context, rect.width-x, margin)
        CGContextAddLineToPoint(context, rect.width-x, rect.height-thickness*2+lineEdge)
        CGContextAddLineToPoint(context, x, rect.height-thickness*2+lineEdge)
        CGContextClosePath(context)
        
        CGContextDrawPath(context, .FillStroke)
    }
}
