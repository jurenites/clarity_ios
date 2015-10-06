//
//  BaseOverlay.swift
//  Clarity
//
//  Created by Oleg Kasimov on 10/5/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class BaseOverlay: VCtrlBase {
    var _onTapFunc: (() -> Void)?
    private var _window: UIWindow!
    private var _isShown : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("actTap"))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    //MARK: Base
    func show() {
        self.view.alpha = 0
        
        _window = UIWindow(frame: UIScreen.mainScreen().bounds)
        _window.rootViewController = self
        _window.windowLevel = UIWindowLevelNormal + 10
        
        _window.makeKeyAndVisible()
        
        UIView.animateWithDuration(0.33, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.view.alpha = 1
            }, completion: {(compl: Bool) in
                self._isShown = true
        })
    }
    
    func hide() {
        UIView.animateWithDuration(0.33, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.view.alpha = 0
            }, completion: {(compl: Bool) in
                self._isShown = false
                self._window.rootViewController = nil
                self._window.hidden = true
                self._window.removeFromSuperview()
        })
    }
    
    func isShown() -> Bool {
        return self._isShown
    }
    
    @IBAction func actTap() {
        if let fn = _onTapFunc {
            fn()
        }
        self.hide()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
