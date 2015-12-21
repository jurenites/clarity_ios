//
//  LoadingIndicator.swift
//  TRN
//
//  Created by Alexey Klyotzin on 06/02/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import UIKit

class LoadingOverlay: UIViewController
{
    @IBOutlet var uiSpinnerContainer: UIView!
    @IBOutlet var uiSpinner: UIActivityIndicatorView!
  
    private var _window: UIWindow!
    
    init() {
        super.init(nibName: "LoadingOverlay", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiSpinnerContainer.layer.masksToBounds = true
        uiSpinnerContainer.layer.cornerRadius = 6
        
        uiSpinner.startAnimating()
    }

    func show() {
        _window = UIWindow(frame: UIScreen.mainScreen().bounds)
        _window.rootViewController = self
        _window.windowLevel = UIWindowLevelNormal + 10
        
        _window.makeKeyAndVisible()
        
        uiSpinnerContainer.alpha = 0
        
        UIView.animateWithDuration(0.33, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.uiSpinnerContainer.alpha = 1
        }, completion: {(compl: Bool) in
        })
    }
    
    func hide() {
        UIView.animateWithDuration(0.33, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.uiSpinnerContainer.alpha = 0
        }, completion: {(compl: Bool) in
            self._window.rootViewController = nil
            self._window.hidden = true
            self._window.removeFromSuperview()
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
