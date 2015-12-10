//
//  VCtrlOrders.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/24/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

import UIKit

class VCtrlOrders: VCtrlBase, UITableViewDelegate, UITableViewDataSource, VCtrlOrderDetailsProtocol { //Table
    
    let _pageSize = 10
    var _orders = [ShortOrder]()
    
    var _filterString: String = ""
    var _needUpdate: Bool = false
    
    @IBOutlet var uiTableView: PtrTableView!
    
    @IBOutlet var uiTableHeader: UIView!
    @IBOutlet var uiFilter: SelectCtrl!
    
    init() {
        super.init(nibName: "VCtrlOrders", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func isNeedInfiniteScroll() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Order List", comment: "")
        self.uiTableView.registerNib(UINib(nibName: OrdersListCell.nibName(), bundle: nil), forCellReuseIdentifier: OrdersListCell.nibName())
        
        let accessoryView = DefaultAccessoryView.create()
        uiFilter.inputAccessoryView = accessoryView
        accessoryView.onDone = WrapAction(self, method: VCtrlOrders.actKbdDone)
        
        var selectItems = [SelectCtrlItem]()
        
        for str in GlobalEntitiesCtrl.shared().orderFilters{
            let item = SelectCtrlItem()
            item.key = str
            item.name = GlobalEntitiesCtrl.shared().orderFilterForKey(str as! String)
            
            selectItems.append(item)
        }
        
        uiFilter.setItems(selectItems)
    }
    
    override func viewWillFirstAppear() {
        super.viewWillFirstAppear()
        if _orders.count == 0 {
            self.uiTableView.alpha = 0;
            self.triggerReloadContent()
        }
    }

    private func populate() {
        
    }
    
    @IBAction func actFilterChanged() {
        let prevFilter = _filterString
        if let key = uiFilter.selectedItem {
            if let keyName = key.key as? String {
                _filterString = keyName
                if prevFilter != _filterString {
                    _needUpdate = true
                }
            }
        } else {
            _filterString = ""
            if prevFilter != _filterString {
                _needUpdate = true
            }
        }
    }
    
    private func actKbdDone() {
        if (_needUpdate) {
            _needUpdate = false
            self.triggerReloadContent()
        }
        self.view.endEditing(true)
    }
    
    //MARK: VCtrlOrderDetailsProtocol
    func orderChanged(shortOrder: ShortOrder, delete: Bool) {
        if let currOrderIndex = _orders.indexOf({$0.orderId == shortOrder.orderId}) {
            if !delete {
                _orders[currOrderIndex] = shortOrder
                self.uiTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: currOrderIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                if let nav = self.navigationController {
                    nav.popViewControllerAnimated(true)
                }
                _orders.removeAtIndex(currOrderIndex)
                self.uiTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: currOrderIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
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
        let canceler = ClarityApi.shared().getOrders(_filterString, offset: 0, limit: _pageSize)
            .success({ (orders : [ShortOrder]) in
                self._orders = orders
                self.uiTableHeader.hidden = false
                self.uiTableView.reloadData()
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.uiTableView.alpha = 1;
                })
                onComplete(self._orders.count >= self._pageSize, true)
            }, error: { (error: NSError) in
                self.uiTableView.alpha = 1
                self.uiTableHeader.hidden = true
                self.reportError(error)
                onComplete(false, true)
        })
        
        return ApiCancelerSignal.wrap(canceler)
    }
    
    override func ptrReloadContent(onComplete: BaseOnLoadMoreComplete!) -> ApiCanceler! {
        return self.baseReloadContent(onComplete)
    }
    
//    override func tableReloadContent(onComplete: BaseTableOnLoadMoreComplete!) -> ApiCanceler! {
//        return self.baseReloadContent(onComplete)
//    }
    
//    override func tableLoadMoreContent(onComplete: BaseTableOnLoadMoreComplete!) -> ApiCanceler! {
    override func ptrLoadMoreContent(onComplete: BaseOnLoadMoreComplete!) -> ApiCanceler! {
        let canceler = ClarityApi.shared().getOrders(_filterString, offset: self._orders.count, limit: 5)
            .success({ (orders : [ShortOrder]) in
                self._orders += orders
                self.uiTableView.reloadData()
                onComplete(self._orders.count >= self._pageSize, true)
            }, error: { (error: NSError) in
                self.reportError(error)
                onComplete(false, true)
            })
        
        return ApiCancelerSignal.wrap(canceler)
    }
}