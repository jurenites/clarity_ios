//
//  TRNApi.swift
//  TRN
//
//  Created by Alexey Klyotzin on 02/02/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import Foundation

@objc class ClarityApi: ApiManager2
{
    class func shared() -> ClarityApi {
        struct S {
            static var shared = ClarityApi()
        }
        
        return S.shared
    }
    
    //MARK: Auth
    func login(login: String, pass: String) -> Signal<User> {
        //WARNING: TODO Should make this method as POST, connect with backend!!!
        return callMethod(ApiMethodID.AMLoginViaEmail, params: [
            "username" : login,
            "password" : pass])
            .next(PliIsApiDictionary)
            .next(PLISwitchToMain)
            .next({(res: NSDictionary, complete: (PipelineResult<User>) -> Void) in
                let token = ToString(res["token"])
                let user = User().fromDict(AssureIsDict(res["user_data"]))
                
                self.apiRouter.userLoggedIn(user, withApiToken: token, onComplete: { () -> Void in
                    complete(PipelineResult(user))
                })
            })
    }
    
    func logout() -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMLogout)
    }
    
    func recover(login: String) -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMRecoverPassword, urlParams: ["username" : login])
    }
    
    func sendApns(token: String) -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMSetAPNS, params:
            ["device_type" : "ios",
            "device_token" : token])
    }
    
    //MARK: Orders
    func getCommonInfo() -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMGetCommonInfo)
            .next(PliIsApiDictionary)
            .next(PLISwitchToMain)
            .next({(res: NSDictionary) in
                if let statuses = res["statuses"] as? NSArray {
                    var array = [Status]()
                    for dict in statuses {
                        if let _dict = dict as? NSDictionary {
                            let entity: Status = Status.create()
                            
                            entity.fillWithApiDict(_dict)
                            array.append(entity)
                        }
                    }
                    GlobalEntitiesCtrl.shared().fillOrderStatuses(array)
                }
                
                if let filters = res["order_filters"] as? NSDictionary {
                   GlobalEntitiesCtrl.shared().fillFilters(filters as [NSObject : AnyObject])
                }
                return PipelineResult("")
            })
    }
    
    func getOrderStatuses() -> Signal<[Status]> {
        return callMethod(ApiMethodID.AMGetOrderStatuses).next(PliFromApiArray)
    }
    
    func getOrders(filter: String = "", offset: Int, limit: Int) -> Signal<[ShortOrder]> {
        return callMethod(ApiMethodID.AMGetOrders, params: [
            "filters[order_status]" : filter,
            "offset" : NSNumber(integer: offset),
            "limit" : NSNumber(integer: limit)])
            .next(PliFromApiArray)
//            .nextFunc({ (orders: [ShortOrder]) -> [ShortOrder] in
//                orders.sort({$0.dateFrom.compare($1.dateFrom) == NSComparisonResult.OrderedDescending })
//        })
    }
    
    func getOrder(orderId: Int) -> Signal<Order> {
        return callMethod(ApiMethodID.AMGetOrder, urlParams: ["id": NSNumber(integer: orderId)])
        .next(PliFromApiDict)
    }
    
    func updateOrder(order: Order) -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMUpdateOrder,
            urlParams: ["id": NSNumber(integer: order.orderId)],
            params: order.toDict() as! [String : AnyObject])
    }
    
    func acceptOrder(orderId: Int) ->Signal<AnyObject> {
        return callMethod(ApiMethodID.AMAcceptOrder, urlParams: ["id": NSNumber(integer: orderId)])
    }
    
    func acceptOrder(orderId: Int, conditions: String) -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMAcceptOrderWithConditions,
            urlParams: ["id": NSNumber(integer: orderId)],
            params: ["condition_notes" : conditions])
    }
    
    func declineOrder(orderId: Int, conditions: String = "") -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMDeclineOrder,
            urlParams: ["id": NSNumber(integer: orderId)],
            params: ["condition_notes" : conditions])
    }
    
    //MARK: Messages
    func getMessage(orderId: Int, messageId: Int) -> Signal<Message> {
        return callMethod(ApiMethodID.AMGetMessage,
            urlParams: [
                "order_id" : NSNumber(integer: orderId),
                "message_id" : NSNumber(integer: messageId)
            ])
            .next(PliFromApiDict)
    }
    
    func getMessages(orderId: Int, offset: Int, count: Int) -> Signal<[Message]> {
        return callMethod(ApiMethodID.AMGetMessages,
            urlParams: ["order_id": NSNumber(integer: orderId)],
            params: [
                "offset": NSNumber(integer: offset),
                "limit": NSNumber(integer: count)
            ])
            .next(PliFromApiArray) //async
    }
    
    func createMessage(orderId: Int, text: String) -> Signal<Message> {
        return callMethod(ApiMethodID.AMCreateMessage ,
            urlParams: ["order_id": NSNumber(integer: orderId)],
            params: ["message" : text])
        .next(PliFromApiDict)
    }
    
    func updateMessage(orderId: Int, messageId: Int, message: Message) -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMUpdateMessage,
            urlParams: [
                "order_id" : NSNumber(integer: orderId),
                "message_id" : NSNumber(integer: messageId)
            ],
            params: message.toDict() as! [String : AnyObject])
    }
    
    func setMessageRead(orderId: Int, messageId: Int, isRead: Bool) -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMUpdateMessage,
            urlParams: [
                "order_id" : NSNumber(integer: orderId),
                "message_id" : NSNumber(integer: messageId)
            ],
            params: ["is_read": NSNumber(bool: isRead)])
    }
    
    func setMessageText(orderId: Int, messageId: Int, text: String) -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMUpdateMessage,
            urlParams: [
                "order_id" : NSNumber(integer: orderId),
                "message_id" : NSNumber(integer: messageId)
            ],
            params: ["message": text])
    }
    
    func deleteMessage(orderId: Int, messageId: Int) -> Signal<AnyObject> {
        return callMethod(ApiMethodID.AMDeleteMessage, urlParams: [
            "order_id" : NSNumber(integer: orderId),
            "message_id" : NSNumber(integer: messageId)
            ])
    }
    
    
//    MARK: OBJC
    func setApnsToken(token: String, onSuccess: Void -> Void, onError: (NSError) -> Void) -> ApiCanceler {
        let canceler = sendApns(token)
        .success({ () -> Void in
            onSuccess()
            },error: { (error: NSError) in
                onError(error)
        })
        return ApiCancelerSignal.wrap(canceler)
    }
    
    func loadCommonInfo(onSuccess: Void -> Void, onError: (NSError) -> Void) -> ApiCanceler {
        let canceler = getCommonInfo()
            .success({ () -> Void in
                onSuccess()
                },error: { (error: NSError) in
                    onError(error)
            })
        return ApiCancelerSignal.wrap(canceler)
    }
    
//    MARK: Tests
    func test_getMessages(offset: Int, count: Int) -> Signal<[Message]> {
        return SignalBlock(sync: {() -> PipelineResult<IORequestResult> in
            if let path = NSBundle.mainBundle().pathForResource("Messages", ofType: "json") {
                do {
                    let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                    return PipelineResult(IORequestResult(200, data, "", UniqueNumber(number: NSNumber(integer: 0))))
                } catch let error as NSError {
                    print(error, terminator: "")
                } catch {
                    print("FATAL IN test getMessages()")
                    fatalError()
                }
                
            }
            
            return PipelineResult<IORequestResult>(ApiError(descr: "Test error"))
        })
            .next(PliParseResponse)
            .next(PliFromApiArray)
    }
    
    func test_getOrder(orderId: Int) -> Signal<Order> {
        return SignalBlock(sync: {() -> PipelineResult<IORequestResult> in
            if let path = NSBundle.mainBundle().pathForResource("Order", ofType: "json") {
                do {
                    let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                    return PipelineResult(IORequestResult(200, data, "", UniqueNumber(number: NSNumber(integer: 0))))
                } catch let error as NSError {
                    print(error, terminator: "")
                } catch {
                    print("FATAL IN test getOrder()")
                    fatalError()
                }
                
            }
            
            return PipelineResult<IORequestResult>(ApiError(descr: "Test error"))
        })
            .next(PliParseResponse)
            .next(PliFromApiDict)
    }
    
    func test_getOrders(offset: Int, count: Int) -> Signal<[ShortOrder]> {
        return SignalBlock(sync: {() -> PipelineResult<IORequestResult> in
            if let path = NSBundle.mainBundle().pathForResource("Orders", ofType: "json") {
                do {
                    let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                    return PipelineResult(IORequestResult(200, data, "", UniqueNumber(number: NSNumber(integer: 0))))
                } catch let error as NSError {
                    print(error, terminator: "")
                } catch {
                    print("FATAL IN test getOrders()")
                    fatalError()
                }
                
            }
            
            return PipelineResult<IORequestResult>(ApiError(descr: "Test error"))
        })
            .next(PliParseResponse)
            .next(PliFromApiArray)
    }
    
    func test_login(login: String, pass: String) -> Signal<User> {
        return SignalBlock(sync: {() -> PipelineResult<IORequestResult> in
            if let path = NSBundle.mainBundle().pathForResource("Login", ofType: "json") {
                do {
                    let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                    return PipelineResult(IORequestResult(200, data, "", UniqueNumber(number: NSNumber(integer: 0))))
                } catch let error as NSError {
                    print(error, terminator: "")
                } catch {
                    print("FATAL IN test login()")
                    fatalError()
                }
                
            }
            
            return PipelineResult<IORequestResult>(ApiError(descr: "Test error"))
        })
            .next(PliParseResponse)
            .next(PliIsApiDictionary)
            .next(PLISwitchToMain)
            .next({(res: NSDictionary, complete: (PipelineResult<User>) -> Void) in
                let token = ToString(res["session_token"])
                let user = User()
                
                self.apiRouter.userLoggedIn(user, withApiToken: token, onComplete: { () -> Void in
                    complete(PipelineResult(user))
                })
            })
    }
    
    func test_recover(login: String) -> Signal<AnyObject> {
        return SignalBlock(sync: {() -> PipelineResult<IORequestResult> in
            if let path = NSBundle.mainBundle().pathForResource("Recover", ofType: "json") {
                do {
                    let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                    return PipelineResult(IORequestResult(200, data, "", UniqueNumber(number: NSNumber(integer: 0))))
                } catch let error as NSError {
                    print(error, terminator: "")
                } catch {
                    print("FATAL IN test recover()")
                    fatalError()
                }
                
            }
            
            return PipelineResult<IORequestResult>(ApiError(descr: "Test error"))
        })
            .next(PliParseResponse)
    }
}
