//
//  VCtrlOrderDetails.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/28/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlOrderDetails: VCtrlBase {
    
    private var orderId : Int = 0
    var order : Order?
    
    @IBOutlet var uiMapButton: CustomButton!
    @IBOutlet var uiReportType: CustomButton!
    @IBOutlet var uiPropertyType: CustomButton!
    @IBOutlet var uiContact: CustomButton!
    @IBOutlet var uiFree: CustomButton!
    @IBOutlet var uiDate: CustomButton!
    @IBOutlet var uiMessanges: CustomButton!
    @IBOutlet var uiStatus: OrderStatusView!
    
    init(orderId : Int) {
        self.orderId = orderId
        super.init(nibName: "VCtrlOrderDetails", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func needNavBar() -> Bool {
//        return true
//    }
//    
//    override func needBackButton() -> Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (order == nil) {
            self.triggerReloadContent()
        }
    }
    
    private func populate() {
        if let ord = order {
            uiMapButton.uiTitle.text = ord.address
            uiReportType.uiTitle.text = ord.reportType
            uiPropertyType.uiTitle.text = ord.propertyType
            if let contact = ord.contact {
                uiContact.uiTitle.text = contact.name
            }
            uiFree.uiTitle.text = String(ord.price)
//            uiDate.uiTitle.text = ord.dateTo
            uiStatus.setup(ord.status)
            uiMessanges.uiTitle.text = String(ord.messagesCount)
        }
    }
    
    @IBAction func actChat() {
        let details = VCtrlChat()
        if let nav = self.navigationController {
            nav.pushViewController(details, animated: true)
        }
    }
    
    override func baseReloadContent(onComplete: ((Bool, Bool) -> Void)!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().test_getOrder(self.orderId)
            .success({ (order : Order) in
                self.order = order
                self.populate()
                onComplete(false, false)
                }, error: { (error: NSError) in
                    self.reportError(error)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
    
}
