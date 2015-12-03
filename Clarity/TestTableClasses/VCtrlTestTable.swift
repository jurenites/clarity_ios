//
//  VCtrlTestTable.swift
//  Clarity
//
//  Created by Oleg Kasimov on 12/1/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlTestTable: VCtrlBase, UITableViewDelegate, UITableViewDataSource {
    
    let _pageSize = 10
    var _orders = [ShortOrder]()
    
    var _filterString: String = ""
    var _needUpdate: Bool = false
    
    @IBOutlet var uiTable: PtrTableView!
    
    init() {
        super.init(nibName: "VCtrlTestTable", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func isNeedPullToRefresh() -> Bool {
        return true
    }
    
    override func isNeedInfiniteScroll() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Order List", comment: "")
        self.uiTable.registerNib(UINib(nibName: OrdersListCell.nibName(), bundle: nil), forCellReuseIdentifier: OrdersListCell.nibName())
    }
    
    override func viewWillFirstAppear() {
        super.viewWillFirstAppear()
        if _orders.count == 0 {
            self.uiTable.alpha = 0;
            self.triggerReloadContent()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
//        let details = VCtrlOrderDetails(orderId: _orders[indexPath.row].orderId)
//        details.delegate = self
//        if let nav = self.navigationController {
//            nav.pushViewController(details, animated: true)
//        }
    }

    //MARK: Load Content
    
    override func baseReloadContent(onComplete: ((Bool, Bool) -> Void)!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getOrders(_filterString, offset: 0, limit: _pageSize)
            .success({ (orders : [ShortOrder]) in
                self._orders = orders
                //                self.uiTableHeader.hidden = false
                self.uiTable.reloadData()
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.uiTable.alpha = 1;
                })
                self.uiTable.scrollToRowAtIndexPath(NSIndexPath(forRow: self._orders.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                onComplete(self._orders.count >= self._pageSize, true)
                }, error: { (error: NSError) in
                    self.uiTable.alpha = 1
                    //                    self.uiTableHeader.hidden = true
                    self.reportError(error)
                    onComplete(false, true)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
    
    override func ptrReloadContent(onComplete: BaseOnLoadMoreComplete!) -> ApiCanceler! {
        return self.baseReloadContent(onComplete)
    }
    
    override func ptrLoadMoreContent(onComplete: BaseOnLoadMoreComplete!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getOrders(_filterString, offset: self._orders.count, limit: 5)
            .success({ (orders : [ShortOrder]) in
                if orders.count > 0 {
//                    self._orders += orders
                    let prev = self.uiTable.contentSize.height - self.uiTable.contentOffset.y
                    self._orders.insertContentsOf(orders, at: 0)

                    self.uiTable.reloadData()
                    self.uiTable.contentOffset = CGPoint(x: 0, y: self.uiTable.contentSize.height - prev)
                }
                
                onComplete(self._orders.count >= self._pageSize, true)
                }, error: { (error: NSError) in
                    self.reportError(error)
                    onComplete(false, true)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
}
