//
//  Api.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 1/8/15.
//  Copyright (c) 2015 Life Church. All rights reserved.
//

import Foundation


class ApiManager2: NSObject
{
    private var _apiRouter = ApiRouter.shared()
    private var _apiIO = ApiRouter.shared().apiIO
    private var _mediaIO = ApiRouter.shared().mediaIO
    
    var apiRouter: ApiRouter {return _apiRouter}
    
    func callMethod(name: ApiMethodID, urlParams: [String: AnyObject] = [String: AnyObject](), params: [String: AnyObject] = [String: AnyObject]()) -> Signal<AnyObject> {
        let req = IOHTTPRequest()
        
        _apiRouter.prepareHttpRequest(req, withMethodID: name, andUrlParams: urlParams)
        req.addParams(params)
        return req.signal(_apiIO).next(PliParseResponse)
    }
    
}

func PliIsApiDictionary(object: AnyObject) -> PipelineResult<NSDictionary> {
    if let d = object as? NSDictionary {
        return PipelineResult(d)
    }
    
    return PipelineResult(InternalError(descr: "Types mismatch"))
}

func PLISwitchToMain<AnyT: Any>(val: AnyT, fn: (PipelineResult<AnyT>) -> Void) {
    dispatchAsyncOnMain {
        fn(PipelineResult(val))
    }
}

func PliParseResponse(result: IORequestResult) -> PipelineResult<AnyObject> {
    if let jsonData: AnyObject = try? NSJSONSerialization.JSONObjectWithData(result.data, options: NSJSONReadingOptions()) {
        if let dict = jsonData as? NSDictionary {
            if ToBool(dict["success"]) {
                if let result: AnyObject = dict["results"] {
                    if !(result is NSNull) {
                        return PipelineResult(result)
                    }
                } else {
                    return PipelineResult(NSNull())
                }
            } else if let result = dict["results"] as? NSDictionary {//dict["results"] != nil {
                let errorCode = ToInt(result["errorCode"])
//                let errorCode = ToInt(dict["code"])
                
                if errorCode == Int(ApiErrorBadSessionToken.rawValue) || errorCode == Int(ApiErrorSessionTokenExpired.rawValue) {
                    dispatch_async(dispatch_get_main_queue(), {
                        ApiRouter.shared().logout()
                    })
                }
                var description = ""
                if let message: AnyObject = result["userMessage"] {
                    description = message as! String
                }
                return PipelineResult(ApiError(code: Int(errorCode), descr: description))
            }
        }
        
        return PipelineResult(InternalError(descr: "Types mismatch"))
    }
    
    return PipelineResult(InternalError(descr: "Bad JSON"))
}

