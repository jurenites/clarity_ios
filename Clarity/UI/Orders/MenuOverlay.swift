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
    
    init() {
        super.init(nibName: "MenuOverlay", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiContainer.layer.borderWidth = 0.5
        self.uiContainer.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    @IBAction func actNameTap() {
        
    }
    
    @IBAction func actPortalTap() {
        
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
