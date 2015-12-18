//
//  ConditionsOverlay.swift
//  Clarity
//
//  Created by Oleg Kasimov on 10/6/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class ConditionsOverlay: BaseOverlay, UITextViewDelegate {
    private var isAcceptance: Bool = false
    private var positiveTapFunc: ((string: String) -> Void)?
    @IBOutlet var lcBottom: NSLayoutConstraint!
    @IBOutlet var uiMessageInput: ChatTextView!
    @IBOutlet var uiPositiveButton: CustomButton!
    
    init(isAcceptance: Bool, positiveAction: ((string: String) -> Void)?) {
        if let fn = positiveAction {
            self.positiveTapFunc = fn
        }
        self.isAcceptance = isAcceptance
        super.init(nibName: "ConditionsOverlay", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isAcceptance {
            self.uiPositiveButton.backgroundColor = UIColor(fromHex: "#A71D21")
            self.uiPositiveButton.uiTitle.text = NSLocalizedString("Decline with condition", comment: "")
        }
    }
    
    @IBAction func actPositive() {
        if let fn = self.positiveTapFunc {
            fn(string: uiMessageInput.text)
        }
        self.view.endEditing(true)
        self.hide()
    }
    
    @IBAction func actNegative() {
        self.view.endEditing(true)
        self.hide()
    }
    
    func textViewDidChange(textView: UITextView) {
        self.uiMessageInput.setNeedsDisplay()
    }
    
    override func keyboardWillShowWithSize(kbdSize: CGSize, duration: NSTimeInterval, curve: UIViewAnimationOptions) {
        UIView.animateWithDuration(duration) {
            self.lcBottom.constant = kbdSize.height
            self.view.layoutIfNeeded()
            self.uiMessageInput.setNeedsDisplay()
        }
    }
    
    override func keyboardWillHideWithDuration(duration: NSTimeInterval, curve: UIViewAnimationOptions) {
        UIView.animateWithDuration(duration) {
            self.lcBottom.constant = 0
            self.view.layoutIfNeeded()
            self.uiMessageInput.setNeedsDisplay()
        }
    }
}
