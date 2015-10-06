//
//  StromgTypedContainers.swift
//  TRN
//
//  Created by Alexey Klyotzin on 17/02/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import Foundation

class MyMutableSet<ElemT: AnyObject>
{
    private var _set = NSMutableSet()
    
    func add(elem: ElemT) {
        _set.addObject(elem)
    }
    
    func remove(elem: ElemT) {
        _set.removeObject(elem)
    }
    
    func contains(elem: ElemT) -> Bool {
        return _set.containsObject(elem)
    }
    
    func count() -> Int {
        return _set.count
    }
    
    func clear() {
        _set.removeAllObjects()
    }
    
    func array() -> [ElemT] {
        if _set.count == 0 {
            return []
        }
        
        return _set.allObjects as! [ElemT]
    }
    
    func set() -> NSMutableSet {
        return _set
    }
}
