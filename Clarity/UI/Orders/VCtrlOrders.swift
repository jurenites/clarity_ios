//
//  VCtrlOrders.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/24/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlOrders: VCtrlBaseTable, UITableViewDelegate, UITableViewDataSource, VCtrlOrderDetailsProtocol {
    
    let _pageSize = 10
    var _orders = [ShortOrder]()
    
    @IBOutlet var uiTableHeader: UIView!
    
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
    
    override func isNeedInfiniteScroll() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Order List", comment: "")
        self.tableView.registerNib(UINib(nibName: OrdersListCell.nibName(), bundle: nil), forCellReuseIdentifier: OrdersListCell.nibName())
    }
    
    override func viewWillFirstAppear() {
        super.viewWillFirstAppear()
        if _orders.count == 0 {
            self.tableView.alpha = 0;
            self.triggerReloadContent()
        }
    }
    
    private func populate() {
        
    }
    
    //MARK: VCtrlOrderDetailsProtocol
    func orderChanged(shortOrder: ShortOrder, delete: Bool) {
        if let currOrderIndex = _orders.indexOf({$0.orderId == shortOrder.orderId}) {
            if !delete {
                _orders[currOrderIndex] = shortOrder
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: currOrderIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                if let nav = self.navigationController {
                    nav.popViewControllerAnimated(true)
                }
                _orders.removeAtIndex(currOrderIndex)
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: currOrderIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
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
        cell.setOrder(_orders[indexPath.row], even: indexPath.row%2 == 0)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let details = VCtrlOrderDetails(orderId: _orders[indexPath.row].orderId)
        details.delegate = self
        if let nav = self.navigationController {
            nav.pushViewController(details, animated: true)
        }
    }
    
    //MARK: Load Content
    override func baseReloadContent(onComplete: ((Bool, Bool) -> Void)!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getOrders(0, limit: _pageSize)
            .success({ (orders : [ShortOrder]) in
                self._orders = orders
                self.uiTableHeader.hidden = false
                self.tableView.reloadData()
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.tableView.alpha = 1;
                })
                onComplete(self._orders.count >= self._pageSize, true)
            }, error: { (error: NSError) in
                self.tableView.alpha = 1
                self.uiTableHeader.hidden = true
                self.reportError(error)
                onComplete(false, true)
        })
        
        return ApiCancelerSignal.wrap(canceler)
    }
    
    override func tableReloadContent(onComplete: BaseTableOnLoadMoreComplete!) -> ApiCanceler! {
        return self.baseReloadContent(onComplete)
    }
    
    override func tableLoadMoreContent(onComplete: BaseTableOnLoadMoreComplete!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getOrders(self._orders.count, limit: 5)
            .success({ (orders : [ShortOrder]) in
                self._orders += orders
                self.tableView.reloadData()
                onComplete(self._orders.count >= self._pageSize, true)
            }, error: { (error: NSError) in
                self.reportError(error)
                onComplete(false, true)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
}