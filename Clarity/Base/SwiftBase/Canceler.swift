//
//  Canceler.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 12/17/14.
//  Copyright (c) 2014 Life Church. All rights reserved.
//

import Foundation

@objc protocol Canceler
{
    func cancel()
    func operationId() -> AnyObject?
}


class EmptyCanceler: Canceler
{
    @objc func cancel() {
    }
    
    @objc func operationId() -> AnyObject? {
        return nil
    }
}

class ApiCancelerSignal: ApiCancelerImplAbstract {
    
    private var _canceler: Canceler?
    
    class func wrap(canceler: Canceler) -> ApiCanceler {
        return ApiCanceler(impl: ApiCancelerSignal(canceler))
    }
    
    init(_ canceler: Canceler) {
        _canceler = canceler
        super.init()
    }
    
    override func cancel() {
        _canceler?.cancel()
        _canceler = nil
    }
    
    
    func swiftCanceler() -> Canceler? {
        return _canceler
    }
}
