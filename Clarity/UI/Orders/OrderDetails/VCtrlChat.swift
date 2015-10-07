//
//  VCtrlChat.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/29/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlChat: VCtrlBaseTable, UITextViewDelegate {
    let _pageSize = 20
    var _messages = [Message]()
    private var orderId: Int = 0
    private var _maxMessageInputHeight: CGFloat = 0
    private var _minMessageInputHeight: CGFloat = 0
    
    @IBOutlet var lcBottomMargin: NSLayoutConstraint!
    @IBOutlet var lcInputHeight: NSLayoutConstraint!
    @IBOutlet var uiMessageInput : ChatTextView!
    @IBOutlet var uiMessageContainer : UIView!
    
    private var _accessoryView: DefaultAccessoryView!
    
    init(orderId: Int) {
        self.orderId = orderId
        super.init(nibName: "VCtrlChat", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: MessageCell.nibName(), bundle: nil), forCellReuseIdentifier: MessageCell.nibName())
        
        self.uiMessageInput.text = "X\n"
        _minMessageInputHeight = self.uiMessageInput.calculateHeight()
        self.uiMessageInput.text = "X\n\n\n\n\n\n\n\n\n"
        _maxMessageInputHeight = self.uiMessageInput.calculateHeight()
        self.uiMessageInput.text = ""
        self.uiMessageContainer.layer.borderWidth = 0.5
        self.uiMessageContainer.layer.borderColor = UIColor.grayColor().CGColor
        
        self.setupInputHeight(false)
        
        _accessoryView = DefaultAccessoryView.create()
        _accessoryView.onDone = WrapAction(self, method: VCtrlChat.actSend)
        uiMessageInput.inputAccessoryView = _accessoryView
    }
    
    override func viewWillFirstAppear() {
        super.viewWillFirstAppear()
        if _messages.count == 0 {
            self.tableView.alpha = 0;
            self.triggerReloadContent()
        }
    }
    
    private func populate() {
        
    }
    
    private func setupInputHeight(animated: Bool) {
        let newHeight = min(max(self.uiMessageInput.calculateHeight(), _minMessageInputHeight), _maxMessageInputHeight)
        if newHeight != self.uiMessageInput.height {
            let needScroll = newHeight >= _maxMessageInputHeight
            self.uiMessageInput.scrollEnabled = needScroll
            self.lcInputHeight.constant = min(max(newHeight, _minMessageInputHeight), _maxMessageInputHeight)
            
            if animated {
                UIView.animateWithDuration(0.33, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func actSend() {
        let text = self.uiMessageInput.text
        self.uiMessageInput.text = ""
        self.setupInputHeight(true)
        self.view.endEditing(true)
        if text.length > 0 {
            self.showLoadingOverlay()
            ClarityApi.shared().createMessage(self.orderId, text: text)
                .success({ (message: Message) -> Void in
                    self.hideLoadingOverlay()
                    self._messages += [message]
                    self.tableView.reloadData()
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self._messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                    }) { (error: NSError) -> Void in
                        self.hideLoadingOverlay()
                        self.reportError(error)
            }
        }
    }
    
    //MARK: UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        self.uiMessageInput.setNeedsDisplay()
        self.setupInputHeight(true)
    }
    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        let currentString = textView.text
//        let newString = currentString.stringByReplacingCharactersInRange(range, withString: text)
//        return true
//    }
    
    //MARK: Keyboard
    override func keyboardWillShowWithSize(kbdSize: CGSize, duration: NSTimeInterval, curve: UIViewAnimationOptions) {
        UIView.animateWithDuration(duration) {
            self.lcBottomMargin.constant = kbdSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    override func keyboardWillHideWithDuration(duration: NSTimeInterval, curve: UIViewAnimationOptions) {
        UIView.animateWithDuration(duration) {
            self.lcBottomMargin.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let m = _messages[indexPath.row]
        return m.messageCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MessageCell.nibName()) as! MessageCell
        let m = _messages[indexPath.row]
        cell.setupMessage(m)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let mesage = _messages[indexPath.row]
        if mesage.isEditable {
//            let overlay = ChatOptionsOverlay(actionFunc: { (action: Action) -> Void in
//                
//            })
        }
    }
    
    //MARK: Load Content
    override func baseReloadContent(onComplete: ((Bool, Bool) -> Void)!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getMessages(orderId, offset: 0, count: _pageSize)
            .success({ (messages : [Message]) in
                self._messages = messages
                self.tableView.reloadData()
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.tableView.alpha = 1;
                })
                onComplete(self._messages.count >= self._pageSize, true)
                }, error: { (error: NSError) in
                    self.reportError(error)
                    onComplete(false, false)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
    
    override func tableReloadContent(onComplete: BaseTableOnLoadMoreComplete!) -> ApiCanceler! {
        return self.baseReloadContent(onComplete)
    }
    
    override func tableLoadMoreContent(onComplete: BaseTableOnLoadMoreComplete!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getMessages(orderId, offset: self._messages.count, count: 10)
            .success({ (messages : [Message]) in
                self._messages += messages
                onComplete(self._messages.count >= self._pageSize, true)
                }, error: { (error: NSError) in
                    self.reportError(error)
                    onComplete(false, false)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
}
