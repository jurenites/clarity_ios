//
//  VCtrlEditMessage.swift
//  Clarity
//
//  Created by Alexey Klyotzin on 13/10/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlEditMessage: BaseOverlay
{
    private var _orderId: NSInteger = 0
    private var _message = Message()
    
    @IBOutlet var uiForm: UIView!
    @IBOutlet var uiMessage: UITextView!
    
    @IBOutlet var lcSpaceTop: NSLayoutConstraint!
    @IBOutlet var lcSpaceBottom: NSLayoutConstraint!
    
    @IBInspectable var textBorderColor: UIColor = UIColor.lightGrayColor()
    
    var onChange: ((text: String) -> Void)?
    
    init(orderId: NSInteger, message: Message) {
        _orderId = orderId
        _message = message
        super.init(nibName: "VCtrlEditMessage", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiMessage.layer.borderColor = UIColor.lightGrayColor().CGColor
        uiMessage.layer.borderWidth = 0.5
        
        uiForm.layer.masksToBounds = true
        uiForm.layer.cornerRadius = 4
        
        uiMessage.text = _message.text
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        lcSpaceTop.constant = topLayoutGuide.length
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        uiMessage.becomeFirstResponder()
    }
    
    override func keyboardWillShowWithSize(kbdSize: CGSize, duration: NSTimeInterval, curve: UIViewAnimationOptions) {
        UIView.animateWithDuration(duration, delay: 0, options: curve, animations: {
            self.lcSpaceBottom.constant = kbdSize.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func keyboardWillHideWithDuration(duration: NSTimeInterval, curve: UIViewAnimationOptions) {
        UIView.animateWithDuration(duration, delay: 0, options: curve, animations: {
            self.lcSpaceBottom.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func actSave() {
        let text = uiMessage.text.trim()
        
        if text.characters.count == 0 {
            reportErrorString("Message is empty")
            return
        }
        
        self.showLoadingOverlay()
        
        ClarityApi.shared().setMessageText(_orderId, messageId: _message.messageId, text: text)
            .success({
                self.hideLoadingOverlay()
                self.hide()
                self.view.endEditing(true)
                self.onChange?(text: text)
            }, error: {(error: NSError) in
                self.reportError(error)
            })
    }
    
    @IBAction func actCancel() {
        self.view.endEditing(true)
        hide()
    }
    
    override func actTap() {
    }
}
