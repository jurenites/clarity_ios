//
//  VCtrlContact.swift
//  Clarity
//
//  Created by Oleg Kasimov on 12/8/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlContact: VCtrlBase {
    
    private var contact: Contact
    private var sharingHelper = SharingHelper()
    
    @IBOutlet var uiNameLabel: UILabel!
    @IBOutlet var uiWorkPhoneButton: CustomButton!
    @IBOutlet var uiMobilePhoneButton: CustomButton!
    @IBOutlet var uiEmailButton: CustomButton!
    @IBOutlet var uiAddBtn: CustomButton!

    init(contact : Contact) {
        self.contact = contact
        super.init(nibName: "VCtrlContact", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Contact Details", comment: "")
        sharingHelper.user = contact
        sharingHelper.presentingViewController = self
        
        self.populate()
    }
    
    private func populate() {
        uiAddBtn.uiTitle.attributedText = self.makeUnderline(uiAddBtn.uiTitle.text!)
        
        if contact.name.length > 0 {
            uiNameLabel.text = contact.name
        }
        
        if contact.workPhone.length > 0 {
            uiWorkPhoneButton.uiTitle.text = contact.workPhone
        } else {
            uiWorkPhoneButton.enabled = false
        }
        
        if contact.otherPhone.length > 0 {
            uiMobilePhoneButton.uiTitle.text = contact.otherPhone
        } else {
            uiMobilePhoneButton.enabled = false
        }
        
        if contact.email.length > 0 {
            uiEmailButton.uiTitle.text = contact.email
        } else {
            uiEmailButton.enabled = false
        }
    }
    
    private func makeUnderline(text: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: text,
            attributes: [NSForegroundColorAttributeName : uiAddBtn.uiTitle.textColor,
                NSFontAttributeName : uiAddBtn.uiTitle.font,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue])
        
        return attrString
    }
    
    //MARK: Actions
    @IBAction func mailAction() {
        sharingHelper.sendViaEmail()
    }
    
    @IBAction func callAction() {
//        if (![DeviceHardware isIphone]) {
//            [[AlertView new] showWithTitle:@""
//            text:NSLocalizedString(@"Sorry!\nYour device cannot make phone calls.", nil)
//            cancelButtonTitle:NSLocalizedString(@"Ok", nil)
//            otherButtonTitles:@[]
//            onComplete:nil];
//            onComplete();
//            return;
//        }
//        NSString *number = [NSString stringWithFormat:@"tel://646-416-7901"];
//        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:number]]){
//            onComplete();
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
//        }else{
//            onComplete();
//        }

    }
    
    @IBAction func contactAction() {
        sharingHelper.saveContact()
    }
    
}