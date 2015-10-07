//
//  ChatOptionsOverlay.swift
//  Clarity
//
//  Created by Oleg Kasimov on 10/7/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class ChatOptionsOverlay: BaseOverlay {
    enum Action : Int {
        case Copy = 0, MarkUnread, Delete
    }
    
    private var actionFunc: ((action: Action) -> Void)?
    
    @IBOutlet var uiCopyButton: CustomButton!
    @IBOutlet var uiMarkButton: CustomButton!
    @IBOutlet var uiDeleteButton: CustomButton!
    @IBOutlet var uiCancelButton: CustomButton!
    
    init(actionFunc: ((action: Action) -> Void)?) {
        if let fn = actionFunc {
            self.actionFunc = fn
        }
        super.init(nibName: "ChatOptionsOverlay", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func actionTap(sender: CustomButton) {
        if let fn = actionFunc {
            switch (sender) {
            case uiCopyButton:
                fn(action: Action.Copy)
                break;
            case uiMarkButton:
                fn(action: Action.MarkUnread)
                break
            case uiDeleteButton:
                fn(action: Action.Delete)
                break
            case uiCancelButton:
                self.hide()
                break
            default:
                self.hide()
                break
            }
        } else {
            self.hide()
        }
    }
}
