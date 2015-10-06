//
//  TipOverlay.swift
//  TRN
//
//  Created by Oleg Kasimov on 4/28/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import UIKit

class TipOverlay: UIViewController
{
    @objc enum ArrowDirection : Int {case Up, Down}
    
    @IBOutlet var uiTip: UIView!
    @IBOutlet var uiTipHeader: UILabel!
    @IBOutlet var uiTipLabel: UILabel!
    @IBOutlet var uiTopArrow : UIImageView!
    @IBOutlet var uiBottomArrow : UIImageView!
    
    @IBOutlet var lcTipY: NSLayoutConstraint!
    @IBOutlet var lcTipX: NSLayoutConstraint!
    @IBOutlet var lcTipWidth: NSLayoutConstraint!
    @IBOutlet var lcTipLabelX: NSLayoutConstraint!
    @IBOutlet var lcTipLabelY: NSLayoutConstraint!
    @IBOutlet var lcArrowHeight: NSLayoutConstraint!
    
    private var _window: UIWindow!
    private var _text: String!
    private var _header: String!
    private var _point: CGPoint!
    private var _tipWidth : CGFloat!
    private var _tipHeight : CGFloat!
    private var _direction : ArrowDirection = .Down
    private var _onTapFunc: (() -> Void)?
    private var _isShown : Bool = false
    let _padding : CGFloat = 5.0
    
    init(header: String, text: String, width: CGFloat, pointToFrame: CGRect, direction: ArrowDirection, onTap: (() -> Void)?) {
        _text = text
        _header = header;
        
        _direction = direction
        
        _tipWidth = width
        _point = CGPointMake(pointToFrame.origin.x + pointToFrame.width/2, pointToFrame.origin.y + (_direction == ArrowDirection.Up ? pointToFrame.height : 0))
        
        if let fn = onTap {
            _onTapFunc = fn
        }
        
        super.init(nibName: "TipOverlay", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTip.layer.cornerRadius = 5.0
        uiTopArrow.hidden = _direction == ArrowDirection.Down
        uiBottomArrow.hidden = _direction == ArrowDirection.Up
        
        lcTipWidth.constant = _tipWidth - lcTipLabelX.constant * 2
        lcTipX.constant = _point.x - _tipWidth/2
        
        let headerH = NSAttributedString(string: _header, attributes: [NSFontAttributeName : uiTipHeader.font])
        let textH = NSAttributedString(string: _text, attributes: [NSFontAttributeName : uiTipLabel.font])
        
        let width = _tipWidth -  lcTipLabelX.constant * 4
        let hh = headerH.length > 0 ? headerH.heightForWidth(width) : 0
        let th = textH.length > 0 ? textH.heightForWidth(width) : 0
        _tipHeight = hh + th
        
        let tipWithArrowHeight = _tipHeight + lcTipLabelY.constant * 2 + lcArrowHeight.constant*2 + _padding
        
        lcTipY.constant = _point.y + (_direction == ArrowDirection.Down ? -tipWithArrowHeight : _padding)
        uiTipLabel.text = _text
        uiTipHeader.text = _header
        
        self.view.setNeedsLayout()
    }
    
    func show() {
        _window = UIWindow(frame: UIScreen.mainScreen().bounds)
        _window.rootViewController = self
        _window.windowLevel = UIWindowLevelNormal + 10
        
        _window.makeKeyAndVisible()
        
        self._isShown = true
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
