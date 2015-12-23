//
//  VCtrlChat.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/29/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol VCtrlChatDelegate {
    func chatUpdated(byMe: Bool)
}

class VCtrlChat: VCtrlBase, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, EventsHubProtocol {
    let _pageSize = 20
    var _messages = [Message]()
    var delegate: VCtrlChatDelegate?
    
    private var _messagesCountChanged: Bool = false
    private var orderId: Int = 0
    private var _maxMessageInputHeight: CGFloat = 0
    private var _minMessageInputHeight: CGFloat = 0
    private var _isFirstLoad: Bool = true
    
    @IBOutlet var uiTableView: PtrTableView!
    
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
    
    deinit {
        EventsHub.shared().removeListener(self)
    }
    
    override func isNeedPullToRefresh() -> Bool {
        return true
    }
    
    override func isNeedInfiniteScroll() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Messages", comment: "")
        
        self.uiTableView.registerNib(UINib(nibName: MessageCell.nibName(), bundle: nil), forCellReuseIdentifier: MessageCell.nibName())
        
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
        
        EventsHub.shared().addListener(self)
    }
    
    override func viewWillFirstAppear() {
        super.viewWillFirstAppear()
        if self._isFirstLoad {
            self.uiTableView.alpha = 0;
            self.triggerReloadContent()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = self.delegate {
            delegate.chatUpdated(_messagesCountChanged)
        }
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
                    self._messagesCountChanged = true
                    if self._messages.count == 0 {
                        UIView.animateWithDuration(0.33, animations: { () -> Void in
                            self.uiTableView.alpha = 1;
                        })
                        self._isFirstLoad = false
                    }
                    
                    self.hideLoadingOverlay()
                    self._messages += [message]
                    //WARNING: TODO - insert rows to or reload all rows?
                    self.uiTableView.reloadData()

                    self.uiTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self._messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
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
//        if mesage.isEditable {
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        sheet.addAction(UIAlertAction(title: "Copy text", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
            UIPasteboard.generalPasteboard().persistent = true
            UIPasteboard.generalPasteboard().items = [[kUTTypeUTF8PlainText as String: mesage.text]]
        }));
        
        if !mesage.isEditable {
            sheet.addAction(UIAlertAction(title: "Mark Unread", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                self.showLoadingOverlay()
                ClarityApi.shared().setMessageRead(self.orderId, messageId: mesage.messageId, isRead: false)
                    .success({
                        self.hideLoadingOverlay()
                        mesage.isRead = false
                        self.uiTableView.reloadData()
                    }, error: { (error: NSError) -> Void in
                        self.reportError(error)
                        self.hideLoadingOverlay()
                    })
            }));
        }
        
        if mesage.isEditable {
            sheet.addAction(UIAlertAction(title: "Edit Message", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                let editMessage = VCtrlEditMessage(orderId: self.orderId, message: mesage)
                
                editMessage.onChange = {text in
                    mesage.text = text
                    self.uiTableView.reloadData()
                }
                
                editMessage.show()
            }));
        
            sheet.addAction(UIAlertAction(title: "Delete Message", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                self.showLoadingOverlay()
                ClarityApi.shared().deleteMessage(self.orderId, messageId: mesage.messageId)
                    .success({
                        self._messagesCountChanged = true
                        self.hideLoadingOverlay()
                        self.removeMessageWithId(mesage.messageId)
                    }, error: {(error: NSError) -> Void in
                        self.reportError(error)
                        self.hideLoadingOverlay()
                    })
            }));
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil));
        
        self.presentViewController(sheet, animated: true, completion: nil)
//        }
    }
    
    private func removeMessageWithId(messageId: NSInteger) {
        if let idx = _messages.find({message in message.messageId == messageId}) {
            _messages.removeAtIndex(idx)
            self.uiTableView.reloadData()
        }
    }
    
    
    //MARK: Load Content
    override func baseReloadContent(onComplete: ((Bool, Bool) -> Void)!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getMessages(orderId, offset: 0, count: _pageSize)
            .success({ (messages : [Message]) in
                if messages.count > 0 {
                    self._messages = messages
                    self.uiTableView.reloadData()

                    if self._isFirstLoad {
                       self.uiTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self._messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        UIView.animateWithDuration(0.33, animations: { () -> Void in
                            self.uiTableView.alpha = 1;
                        })
                        self._isFirstLoad = false
                    }
                    
                    onComplete(self._messages.count >= self._pageSize, true)
                } else {
                    onComplete(false, true)
                }
                }, error: { (error: NSError) in
                    self.reportError(error)
                    onComplete(false, false)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
    
    override func ptrReloadContent(onComplete: BaseOnLoadMoreComplete!) -> ApiCanceler! {
        return self.baseReloadContent(onComplete)
    }
    
    override func ptrLoadMoreContent(onComplete: BaseOnLoadMoreComplete!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getMessages(orderId, offset: self._messages.count, count: 10)
            .success({ (messages : [Message]) in
                if messages.count > 0 {
                    let prev = self.uiTableView.contentSize.height - self.uiTableView.contentOffset.y
                    self._messages.insertContentsOf(messages, at: 0)
                    
                    self.uiTableView.reloadData()
                    self.uiTableView.contentOffset = CGPoint(x: 0, y: self.uiTableView.contentSize.height - prev)
                    onComplete(self._messages.count >= self._pageSize, true)
                } else {
                    onComplete(false, true)
                }
                }, error: { (error: NSError) in
                    self.reportError(error)
                    onComplete(false, false)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }

    
    //MARK: EventsHubProtocol
    func updateChat(orderId: Int, messageId: Int, action: String!) {
        if !self.isOnScreen || self.orderId != orderId {
            return
        }

        let index = _messages.indexOf( {$0.messageId == messageId} )
            
        if action == PushMessageRemove && index != nil {
            _messages.removeAtIndex(index!)
            uiTableView.beginUpdates()
            uiTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation:UITableViewRowAnimation.Fade)
            uiTableView.endUpdates()
            
            self._messagesCountChanged = true
            return
        }
        
        if action == PushMessageNew || (action == PushMessageUpdate && index != nil) {
            ClarityApi.shared().getMessage(orderId, messageId: messageId)
                .success({ (message: Message) in
                    if action == PushMessageUpdate {
                        self._messages[index!] = message
                        self.uiTableView.beginUpdates()
                        self.uiTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                        self.uiTableView.endUpdates()
                        
                        if index! == self._messages.count-1 {
                            self.uiTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self._messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        }
                    } else { //New
                        let index = NSIndexPath(forRow: self._messages.count, inSection: 0)
                        self._messages.insertContentsOf([message], at: self._messages.count)
                        self.uiTableView.beginUpdates()
                        self.uiTableView.insertRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Bottom)
                        self.uiTableView.endUpdates()
                        
                        //WARNING: TODO - Add here scroll to new message if needed
                        let bottomSpacing = self.uiTableView.contentSize.height - self.uiTableView.contentOffset.y - self.uiTableView.height
                        if bottomSpacing <= message.messageCellHeight*1.5 {
                            self.uiTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self._messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        }
                        
                        self._messagesCountChanged = true
                        GlobalEntitiesCtrl.shared().changeBadgeNumberBy(-1)
                    }
                }, error: { (error: NSError) in
                    self.reportError(error)
            })
        }
        
//            ClarityApi.shared().getMessages(orderId, offset: 0, count: 1)
//                .success({ (messages: [Message]) in
//                    if let message = messages.first {
//
//                        if self._messages.contains( {$0.messageId == message.messageId} ) {
//                           return
//                        }
//                        
//                        let index = NSIndexPath(forRow: self._messages.count, inSection: 0)
//                        self._messages.insertContentsOf([message], at: self._messages.count)
//                        self.uiTableView.beginUpdates()
//                        self.uiTableView.insertRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Bottom)
//                        self.uiTableView.endUpdates()
//                        
//                        //WARNING: TODO - Add here scroll to new message if needed
//                        let bottomSpacing = self.uiTableView.contentSize.height - self.uiTableView.contentOffset.y - self.uiTableView.height
//                        if bottomSpacing <= message.messageCellHeight*1.5 {
//                            self.uiTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self._messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
//                        }
//                        
//                        self._messagesCountChanged = true
//                    }
//                    }, error: { (error: NSError) in
//                        self.reportError(error)
//                })
    }
}
