//
//  VCtrlLogin.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/24/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlLogin : VCtrlBaseOld, UITextFieldDelegate {
    
    @IBOutlet var uiLogin: CustomTextField!
    @IBOutlet var uiPassword: CustomTextField!
    
    @IBOutlet var uiLoginContainer: UIView!
    @IBOutlet var uiPassContainer: UIView!
    @IBInspectable var borderColor: UIColor = UIColor.grayColor()
    
    @IBOutlet var uiContainer: UIView!
    @IBOutlet var uiLoginBtn: CustomButton!
    @IBOutlet var uiRecoveryBtn: CustomButton!
    @IBOutlet var uiTapControl: UIControl!
    
    @IBOutlet var lcContainerCenter : NSLayoutConstraint!
    
    private var _defContainerBottom : CGFloat = 0
    
    private var _isRecovering : Bool = false
    
    init() {
        super.init(nibName: "VCtrlLogin", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func needNavBar() -> Bool {
        return true
    }
    
    override func needBackButton() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populate()
    }
    
    private func populate() {
        uiRecoveryBtn.uiTitle.attributedText = self.makeUnderline(uiRecoveryBtn.uiTitle.text!)
        uiLoginContainer.layer.borderColor = borderColor.CGColor
        uiPassContainer.layer.borderColor = borderColor.CGColor
        uiLoginContainer.layer.borderWidth = 0.5
        uiPassContainer.layer.borderWidth = 0.5
    }
    
    override func keyboardWillShowWithSize(kbdSize: CGSize, duration: NSTimeInterval, curve: UIViewAnimationOptions) {
        UIView.animateWithDuration(duration) {
            let keyboardFrame = CGRectMake(0, self.uiTapControl.bounds.height - kbdSize.height, kbdSize.width, kbdSize.height)
            
            let rect = self.uiTapControl.convertRect(self.uiLoginBtn.frame, fromView:self.uiContainer)
            let intersection = CGRectIntersection(keyboardFrame, rect)
 
            if  intersection.height != 0 {
                self.lcContainerCenter.constant = -intersection.height-(intersection.origin.y-keyboardFrame.origin.y)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    override func keyboardWillHideWithDuration(duration: NSTimeInterval, curve: UIViewAnimationOptions) {
        UIView.animateWithDuration(duration) {
            self.lcContainerCenter.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(uiLogin) {
            textField.text = NSString(string: textField.text!).nameString()
            uiPassword.becomeFirstResponder()
        } else if textField.isEqual(uiPassword) {
            self.actLogin()
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let nsCurrentStr = NSString(string: textField.text!)
        let newStr = nsCurrentStr.stringByReplacingCharactersInRange(range, withString: string)
        
        if newStr.length > (textField as? CustomTextField)?.maxSymbolsCount {
            return false
        }
        return true
    }

    private func validateFields() -> String? {
        if let error = NSString(string: uiLogin.text!).validateFullNameWithMaxLength(uiLogin.maxSymbolsCount) {//validateFullNameWithMaxLength(uiLogin.maxSymbolsCount) {//Name
            return error
        }
        if _isRecovering {//If recover there will be no pass
            return nil
        }
        if let error = NSString(string: uiPassword.text!).validatePass() {//Pass
            return error
        }
        
        return nil
    }
    
    private func validateForm() -> Bool {
        if let error =  self.validateFields() {
            self.reportErrorString(error)
            return false
        }
        return true
    }
    
    @IBAction func actLogin() {
        if !self.validateForm() {
            return
        }
        
        if !_isRecovering {
            self.view.endEditing(true)
            self.showLoadingOverlay()
            let canceler = ClarityApi.shared().login(uiLogin.text!, pass: uiPassword.text!)
                .flatMap({ (user: User) -> PipelineResult<Signal<AnyObject>> in
                    return PipelineResult(ClarityApi.shared().getCommonInfo())
                })
                .success({
                    self.hideLoadingOverlay()
                    VCtrlRoot.current().showMainUI()
                }, error: { (error : NSError) -> Void in
                    self.hideLoadingOverlay()
                    self.reportError(error)
                })
            self.pendingRequest = ApiCancelerSignal.wrap(canceler)
        } else {
            let canceler = ClarityApi.shared().recover(uiLogin.text!)
                .success({
                    self.showNotice("Check your e-mail now!")
                    self.actRecovery()
                }, error: { (error : NSError) -> Void in
                    self.reportError(error)
                })
            self.pendingRequest = ApiCancelerSignal.wrap(canceler)
        }
    }
    
    @IBAction func actRecovery() {
        
        _isRecovering = !_isRecovering
        
//        uiPassword.hidden = _isRecovering
        uiPassContainer.hidden = _isRecovering
        uiRecoveryBtn.uiTitle.attributedText = _isRecovering ? self.makeUnderline("Cancel") : self.makeUnderline("Password recovery")
        uiLoginBtn.uiTitle.text = _isRecovering ? NSLocalizedString("Reset", comment: "") : NSLocalizedString("Login", comment: "")
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func actTapFreeSpace() {
        self.view.endEditing(true)
    }
    
    private func makeUnderline(text: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: text,
            attributes: [NSForegroundColorAttributeName : uiRecoveryBtn.uiTitle.textColor,
                NSFontAttributeName : self.uiRecoveryBtn.uiTitle.font,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue])
        
        return attrString
    }
}
