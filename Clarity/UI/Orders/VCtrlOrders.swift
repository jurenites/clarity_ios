//
//  VCtrlOrders.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/24/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlOrders: VCtrlBaseTable, UITableViewDelegate, UITableViewDataSource {
    
    let _pageSize = 5
    var _orders = [ShortOrder]()
    
    init() {
        super.init(nibName: "VCtrlOrders", bundle: nil)
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
        
        self.tableView.registerNib(UINib(nibName: OrdersListCell.nibName(), bundle: nil), forCellReuseIdentifier: OrdersListCell.nibName())
        
        let menu = MenuOverlay()
        menu.show()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.tableView.hidden {
            self.triggerReloadContent()
        }
    }
    
    private func populate() {
        
    }
    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return OrdersListCell.height()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _orders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(OrdersListCell.nibName()) as! OrdersListCell
        cell.setOrder(_orders[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let details = VCtrlOrderDetails(orderId: _orders[indexPath.row].orderId)
        if let nav = self.navigationController {
            nav.pushViewController(details, animated: true)
        }
    }
    
    //MARK: Load Content
    override func baseReloadContent(onComplete: ((Bool, Bool) -> Void)!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().test_getOrders(0, count: 0)
            .success({ (orders : [ShortOrder]) in
                self._orders = orders
                self.tableView.reloadData()
                onComplete(self._orders.count >= self._pageSize, false)
            }, error: { (error: NSError) in
                self.reportError(error)
        })
        
        return ApiCancelerSignal.wrap(canceler)
    }
    
//    override func tableReloadContent(onComplete: BaseTableOnLoadMoreComplete!) -> ApiCanceler! {
//        return self.baseReloadContent(onComplete)
//    }
    
    override func tableLoadMoreContent(onComplete: BaseTableOnLoadMoreComplete!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().test_getOrders(0, count: 0)
            .success({ (orders : [ShortOrder]) in
                self._orders += orders
                onComplete(self._orders.count >= self._pageSize, false)
            }, error: { (error: NSError) in
                self.reportError(error)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
}