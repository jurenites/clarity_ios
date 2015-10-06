//
//  IORequest+Pipeline.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 12/17/14.
//  Copyright (c) 2014 Life Church. All rights reserved.
//

import Foundation

class IORequestResult
{
    let httpCode: Int
    let data: NSData
    let filePath: NSString
    let requestId: UniqueNumber
    
    init(_ httpCode: Int, _ data: NSData, _ filePath: NSString, _ requestId: UniqueNumber) {
        self.httpCode = httpCode
        self.data = data
        self.filePath = filePath
        self.requestId = requestId
    }
}

extension IORequest
{
    func signal(iom: IOManager) -> Signal<IORequestResult> {
        return SignalBlock(cancelableAsync: {complete in
            var reqId = UniqueNumber(number: NSNumber(integer: 0))
            
            self.onSuccess = {data in
                let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
                
                dispatch_async(q, {
                    complete(PipelineResult(IORequestResult(0, (data as? NSData) ?? NSData(), "", reqId)))
                    self.onSuccess = nil
                    self.onError = nil
                })
            }
            
            self.onError = {error in
                self.onSuccess = nil
                self.onError = nil
                complete(PipelineResult<IORequestResult>(error))
            }
            
            reqId = iom.enqueueRequest(self)
            
            return ({[weak iom] in iom?.cancelRequest(reqId); return}, reqId)
        });
    }
}
