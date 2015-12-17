//
//  VCtrlOrderDetails.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/28/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

protocol VCtrlOrderDetailsProtocol {
    func orderChanged(shortOrder: ShortOrder, delete: Bool)
}

class VCtrlOrderDetails: VCtrlBase, VCtrlChatDelegate {
    
    private var orderId : Int = 0
    private var order : Order?
    
    var delegate: VCtrlOrderDetailsProtocol?
    
    @IBOutlet var uiMapButton: CustomButton!
    @IBOutlet var uiReportType: CustomButton!
    @IBOutlet var uiPropertyType: CustomButton!
    @IBOutlet var uiContact: CustomButton!
    @IBOutlet var uiFree: CustomButton!
    @IBOutlet var uiDate: CustomButton!
    @IBOutlet var uiMessanges: CustomButton!
    @IBOutlet var uiStatus: OrderStatusView!
    
    @IBOutlet var uiContainer: UIView!
    
    @IBOutlet var uiAcceptBtn: CustomButton!
    @IBOutlet var uiAcceptWConditionsBtn: CustomButton!
    @IBOutlet var uiDeclineBtn: CustomButton!
    
    init(orderId : Int) {
        self.orderId = orderId
        super.init(nibName: "VCtrlOrderDetails", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Order Details", comment: "")
        
        self.populate()
    }
    
    override func viewWillFirstAppear() {
        super.viewWillFirstAppear()
        if (order == nil) {
            self.showSpinner()
            self.uiContainer.alpha = 0
            self.triggerReloadContent()
        }
    }
    
    private func populate() {
        if let ord = order {
            uiMapButton.uiTitle.text = ord.address
            uiReportType.uiTitle.text = ord.reportType
            uiReportType.enabled = false
            uiPropertyType.uiTitle.text = ord.propertyType
            uiPropertyType.enabled = false
            
            if let contact = ord.contact {
                uiContact.uiTitle.text = contact.name
            } else {
                uiContact.enabled = false
            }
            
            uiFree.uiTitle.text = "$ \(ord.price)"
            uiFree.enabled = false
            
            uiStatus.setup(ord.status)
            uiMessanges.uiTitle.text = String(ord.messagesCount)
            
            let fmt = NSDateFormatter()
//            fmt.locale = NSLocale(localeIdentifier: "en_US")
            fmt.dateFormat = "MM.dd.YYYY"
            uiDate.uiTitle.text = fmt.stringFromDate(ord.dateTo)
            uiDate.enabled = false
            
            let needButtons = ord.canAccept && ord.canAcceptWConditions && ord.canDecline //Now we manipulate all buttons
            uiAcceptBtn.hidden = !needButtons
            uiAcceptWConditionsBtn.hidden = !needButtons
            uiDeclineBtn.hidden = !needButtons
        }
    }
    
    private func orderChanged(delete: Bool = false) {
        if let delegate = self.delegate, order = self.order {
            let dict: NSDictionary = order.toDict()
            let shortOrder = ShortOrder().fromDict(dict)
            delegate.orderChanged(shortOrder, delete: delete)
        }
    }
    
    func chatUpdated() {
        self.triggerReloadContent()
    }
    
    //MARK: Actions
    @IBAction func actMap() {
        if let loc = order?.location {
            let map = VCtrlMap(location: loc)
            if let nav = self.navigationController {
                nav.pushViewController(map, animated: true)
            }
        }
    }
    
    @IBAction func actContact() {
        if let contact = order?.contact {
            let contact = VCtrlContact(contact: contact)
            if let nav = self.navigationController {
                nav.pushViewController(contact, animated: true)
            }
        }
    }
    
    @IBAction func actChat() {
        if let orderId = order?.orderId {
            let chat = VCtrlChat(orderId: orderId)
            chat.delegate = self
            if let nav = self.navigationController {
                nav.pushViewController(chat, animated: true)
            }
        }
    }
    
    //would be greate to merge actAccept and actAcceptWConditions methods it one, and also on a serverside.
    @IBAction func actAccept() {
        self.showLoadingOverlay()
        ClarityApi.shared().acceptOrder(self.orderId)
            .flatMap({ (obj: AnyObject) -> PipelineResult<Signal<Order>> in
                return PipelineResult(ClarityApi.shared().getOrder(self.orderId))
            }).success({ (order : Order) in
                self.order = order
                self.populate()
                self.hideLoadingOverlay()
                self.orderChanged()
                }, error: { (error: NSError) in
                    self.hideLoadingOverlay()
                    self.reportError(error)
            })
    }
    
    @IBAction func actAcceptWConditions() {
        let conditions = ConditionsOverlay(isAcceptance: true, positiveAction: {(string: String) -> Void in
            self.showLoadingOverlay()
            ClarityApi.shared().acceptOrder(self.orderId, conditions: string)
                .flatMap({ (obj: AnyObject) -> PipelineResult<Signal<Order>> in
                    return PipelineResult(ClarityApi.shared().getOrder(self.orderId))
                }).success({ (order : Order) in
                    self.order = order
                    self.populate()
                    self.hideLoadingOverlay()
                    self.orderChanged()
                    }, error: { (error: NSError) in
                        self.hideLoadingOverlay()
                        self.reportError(error)
                })
        })
        conditions.show()
    }
    
    @IBAction func actDecline() {
        let conditions = ConditionsOverlay(isAcceptance: false, positiveAction: {(string: String) -> Void in
            self.showLoadingOverlay()
            ClarityApi.shared().declineOrder(self.orderId, conditions: string)
                .success({ () -> Void in
                    self.hideLoadingOverlay()
                    self.orderChanged(true)
                    }, error: { (error: NSError) in
                        self.hideLoadingOverlay()
                        self.reportError(error)
                })
            })
        conditions.show()
    }
    
    override func baseReloadContent(onComplete: ((Bool, Bool) -> Void)!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getOrder(self.orderId)
            .success({ (order : Order) in
                self.order = order
                self.populate()
                self.hideSpinner()
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.uiContainer.alpha = 1
                })
                onComplete(false, false)
                }, error: { (error: NSError) in
                    self.reportError(error)
                    self.goBackAfretDelay(1.0)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
}
