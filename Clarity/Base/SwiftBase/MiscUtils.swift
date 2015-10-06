//
//  MiscUtils.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 12/17/14.
//  Copyright (c) 2014 Life Church. All rights reserved.
//

import Foundation

func synchronized(obj: AnyObject, block: () -> Void) {
    objc_sync_enter(obj)
    block()
    objc_sync_exit(obj)
}


func dispatchAsyncOnMain(block: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), block);
}

func dispatchAsyncOnBg(block: () -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
}

func dispatchAfter(delay: NSTimeInterval,block: Void -> Void) {
    let fireTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delay));
    dispatch_after(fireTime, dispatch_get_main_queue(), block)
}

func switchToBg(block: () -> Void) -> () -> Void {
    return {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
    }
}

func switchToBg<T>(block: (T) -> Void) -> (T) -> Void {
    return {(arg: T) -> Void in
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            block(arg)
        })
    }
}

func Bind<T, RetT>(block: (T) -> RetT, arg: T) -> () -> RetT {
    return {() -> RetT in
        return block(arg)
    }
}

func Bind<T, T2, RetT>(block: (T, T2) -> RetT, arg: T) -> (T2) -> RetT {
    return {(arg2: T2) -> RetT in
        return block(arg, arg2)
    }
}

func Bind<T, T2, T3, RetT>(block: (T, T2, T3) -> RetT, arg: T, arg2: T2) -> (T3) -> RetT {
    return {(arg3: T3) -> RetT in
        return block(arg, arg2, arg3)
    }
}

func Bind<T, T2, T3, T4, RetT>(block: (T, T2, T3, T4) -> RetT, arg: T, arg2: T2, arg3: T3) -> (T4) -> RetT {
    return {(arg4: T4) -> RetT in
        return block(arg, arg2, arg3, arg4)
    }
}

func BindMethodWeak<T: AnyObject>(method: (T) -> () -> Void, object: T) -> () -> Void {
    weak var weakObject: T? = object
    
    return {() -> Void in
        if let strongObject = weakObject {
            method(strongObject)()
        }
    }
}

func BindMethodWeak<T: AnyObject, ArgT>(method: (T) -> (ArgT) -> Void, object: T) -> (ArgT) -> Void {
    weak var weakObject: T? = object
    
    return {(arg: ArgT) -> Void in
        if let strongObject = weakObject {
            method(strongObject)(arg)
        }
    }
}

func BindMethodWeak<T: AnyObject, ArgT, Arg2T>(method: (T) -> (ArgT, Arg2T) -> Void, object: T) -> (ArgT, Arg2T) -> Void {
    weak var weakObject: T? = object
    
    return {(arg: ArgT, arg2: Arg2T) -> Void in
        if let strongObject = weakObject {
            method(strongObject)(arg, arg2)
        }
    }
}

func getRandom() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

func lowerThan8iOS() -> Bool {
    return (UIDevice.currentDevice().systemVersion as NSString).floatValue() < 7.99
}

func TRNTimeTo24String(time: Int) -> String {
    return String(format: "%02d:%02d", time / 60, time % 60)
}

func TRNTimeToGMT(time: Int) -> Int {
    let timeZone = NSTimeZone.localTimeZone()
    
    return time - (timeZone.secondsFromGMT) / 60
}

func TRNTimeTo12String(time: Int) -> String {
    let hour = time / 60
    let minute = time % 60
    var amPmHour = 0
    var isPm = false
    
    if hour == 0 {
        amPmHour = 12
        isPm = false
    } else if hour == 12 {
        amPmHour = 12
        isPm = true
    } else if hour > 12 {
        amPmHour = hour - 12
        isPm = true
    } else {
        amPmHour = hour
        isPm = false
    }
    
    return String(format: "%d:%02d%@", amPmHour, minute, isPm ? "pm" : "am") //02
}

func CastArray<ElemT: AnyObject>(array: NSArray) -> [ElemT] {
    if array.count == 0 {
        return []
    }
    
    return array as! [ElemT]
}

extension String
{
    func hasCharacters() -> Bool {
        return ((self as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as NSString).length > 0
    }
    
    var length: Int {
        return (self as NSString).length
    }
    
    func trim() -> String {
        return ((self as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as NSString) as String
    }
    
    func firstWord() -> String {
        if let first = (self as NSString).componentsSeparatedByString(" ").first {
            return first
        }
        return self as String
    }
    
    func height(font: UIFont, width: CGFloat) -> CGFloat {
        let str = NSAttributedString(string: self, attributes: [NSFontAttributeName : font])
        let rect = str.boundingRectWithSize(CGSizeMake(width, 8000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return ceil(rect.height)
    }
}

extension Array
{
    func find(includedElement: Element -> Bool) -> Int? {
        for (idx, element) in self.enumerate() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}

class WeakWrapper<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

func WrapAction<T: AnyObject>(object: T, method: (T) -> () -> Void) -> () -> Void {
    weak var weakObject: T? = object
    
    return {() -> Void in
        if let strongObject = weakObject {
            method(strongObject)()
        }
    }
}

func WrapAction<T: AnyObject, ArgT: Any>(object: T, method: (T) -> (ArgT) -> Void) -> (ArgT) -> Void {
    weak var weakObject: T? = object
    
    return {(arg: ArgT) -> Void in
        if let strongObject = weakObject {
            method(strongObject)(arg)
        }
    }
}
