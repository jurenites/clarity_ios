//
//  SIgnal.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 12/17/14.
//  Copyright (c) 2014 Life Church. All rights reserved.
//

import Foundation

public class PipelineResult<T>
{
    var result: T?
    var error: NSError?
    
    init(_ result: T) {
        self.result = result
    }
    
    init(_ error: NSError) {
        self.error = error
    }
}

private class SigSubscriber<T>
{
    let _result: (T) -> Void
    let _error: (NSError) -> Void
    
    init(result: (T) -> Void, error: (NSError) -> Void) {
        _result = result
        _error = error
    }
    
    func sendResult(result: T) {
        _result(result)
    }
    
    func sendError(error: NSError) {
        _error(error)
    }
}


public class SignalCommon
{
    private var _isCanceled = false
    
    private func isCanceled() -> Bool {
        var canceled = false
        
        synchronized(self) {
            canceled = self._isCanceled
        }
        
        return canceled
    }
    
    private func cancel() {
        synchronized(self) {
            self._isCanceled = true
        }
    }
}

public class Signal<ResultT>: SignalCommon
{
    private var _subscriber: SigSubscriber<ResultT>?
    private var _weakSubscriber: SigSubscriber<ResultT>?
    
    private var _successFunc: ((ResultT) -> ())?
    private var _errorFunc: ((NSError) -> ())?
    
    override init() {
        super.init()
    }
    
    // Returns operation id
    public func exec(complete: (PipelineResult<ResultT>) -> ()) -> AnyObject? {
        fatalError("Unimplemented Signal::exec()")
    }
    
    public func next<NextResultT: Any>(next: PipelineElem<ResultT, NextResultT>) ->  Signal<NextResultT> {
        assert(_subscriber == nil && _weakSubscriber == nil && next._strongParent == nil && next._parent == nil)
        
        next._strongParent = self
        _weakSubscriber = next.getSubscriber()
        return next
    }
    
    public func next<NextResultT: Any>(sync: (ResultT) -> PipelineResult<NextResultT>) ->  Signal<NextResultT> {
        return next(PiplelineElemBlock(sync: sync))
    }
    
    public func next<NextResultT: Any>(async: (ResultT, (PipelineResult<NextResultT>) -> Void) -> Void) ->  Signal<NextResultT> {
        return next(PiplelineElemBlock(async: async))
    }
    
    public func nextFunc<NextResultT: Any>(fn: (ResultT) -> NextResultT) ->  Signal<NextResultT> {
        return next(PiplelineElemBlock(fn: fn))
    }
    
    public func flatMap<NextResultT: Any>(sync: (ResultT) -> PipelineResult<Signal<NextResultT>>) ->  Signal<NextResultT> {
        return next(PiplelineElemSignal(sync: sync))
    }
    
    public func flatMap<NextResultT: Any>(async: (ResultT, (PipelineResult<Signal<NextResultT>>) -> Void) -> Void) ->  Signal<NextResultT> {
        return next(PiplelineElemSignal(async: async))
    }
    
    public func success(success: (ResultT) -> Void, error: (NSError) -> Void) -> SignalCanceler {
        _successFunc = success
        _errorFunc = error
        return SignalCanceler(pli: self, operationId: start())
    }
    
    public func success(success: () -> Void, error: (NSError) -> Void) -> SignalCanceler {
        return self.success({(res: ResultT) in success()}, error: error)
    }
    
    private func reportSuccess(result: ResultT) {
        dispatchAsyncOnMain {
            if let success = self._successFunc {
                if (!self.isCanceled()) {
                    success(result)
                }
            }
        }
    }
    
    // Returns operation id
    private func start() -> AnyObject? {
        if let next = _weakSubscriber {
            _subscriber = next
            _weakSubscriber = nil
        }
        
        return exec {(pliResult: PipelineResult<ResultT>) -> () in
            if self.isCanceled() {
                return
            }
            
            self.dispatchResult(pliResult)
        }
    }
    
    private func reportError(error: NSError) {
        dispatchAsyncOnMain {
            if let onError = self._errorFunc {
                if (!self.isCanceled()) {
                    onError(error)
                }
            }
        }
    }
    
    private func dispatchResult(pliResult: PipelineResult<ResultT>) {
        if let result = pliResult.result {
            if let next = self._subscriber {
                next.sendResult(result)
            } else {
                self.reportSuccess(result)
            }
        } else if let error = pliResult.error {
            if let next = self._subscriber {
                next.sendError(error)
            } else {
                self.reportError(error)
            }
        } else {
            assertionFailure("error in PipelineItem::execImpl")
        }
    }
}

public class PipelineElem<ArgT: Any, ResultT: Any>: Signal<ResultT>
{
    private weak var _parent: Signal<ArgT>?
    private var _strongParent: Signal<ArgT>?

    public func exec(arg: ArgT, complete: (PipelineResult<ResultT>) -> ()) {
        fatalError("Unimplemented PipelineItem::exec()")
    }
    
    private override func start() -> AnyObject? {
        if let next = _weakSubscriber {
            _subscriber = next
            _weakSubscriber = nil
        }
        
        if let parent = _strongParent {
            _parent = parent
            _strongParent = nil
            return parent.start()
        }
        
        return nil
    }
    
    private override func cancel() {
        super.cancel()
        
        if let parent = _parent {
            parent.cancel()
        }
    }
    
    private func getSubscriber() -> SigSubscriber<ArgT> {
        return SigSubscriber(result: self.sendResult, error: self.sendError)
    }
    
    private func sendResult(arg: ArgT) {
        exec(arg, complete: { (pliResult: PipelineResult<ResultT>) -> () in
            if self.isCanceled() {
                return
            }
            
            self.dispatchResult(pliResult)
        });
    }
    
    private func sendError(error: NSError) {
        if let next = self._subscriber {
            next.sendError(error)
        } else {
            self.reportError(error)
        }
    }
}

public class SignalBlock<ResultT: Any>: Signal<ResultT>
{
    public  typealias CancelBlock = Void -> Void
    public typealias SyncBlock = Void -> PipelineResult<ResultT>
    public typealias AsyncBlock = ((PipelineResult<ResultT>) -> Void) -> Void
    public typealias CancelableAsyncBlock = ((PipelineResult<ResultT>) -> Void) -> (CancelBlock, AnyObject?)
    
    private var _syncBlock: SyncBlock?
    private var _asyncBlock: AsyncBlock?
    private var _cancelableAsyncBlock: CancelableAsyncBlock?
    private var _cancelBlock: CancelBlock?
    
    init(sync: SyncBlock) {
        _syncBlock = sync
        super.init()
    }
    
    init(async: AsyncBlock) {
        _asyncBlock = async
        super.init()
    }
    
    init(cancelableAsync: CancelableAsyncBlock) {
        _cancelableAsyncBlock = cancelableAsync
        super.init()
    }
    
    private override func cancel() {
        super.cancel()
        _cancelBlock?()
    }
    
    public override func exec(complete: (PipelineResult<ResultT>) -> Void) -> AnyObject? {
        if let sync = _syncBlock {
            complete(sync())
        } else if let async = _asyncBlock {
            async(complete)
        } else if let cancelableAsync = _cancelableAsyncBlock {
            let (cancelBlock, operationId) = cancelableAsync(complete)
            _cancelBlock = cancelBlock
            return operationId
        }
        
        return nil
    }
}

public class SignalPassthrough<ResultT>: Signal<ResultT>
{
    private var _result: ResultT
    
    init(_ result: ResultT) {
        _result = result
        super.init()
    }
    
    public override func exec(complete: (PipelineResult<ResultT>) -> Void) -> AnyObject? {
        complete(PipelineResult(_result))
        return nil
    }
}

func MultiplexSignals<T1, T2>(sig1: Signal<T1>, sig2: Signal<T2>) -> Signal<(T1, T2)> {
    typealias ResultT = (T1, T2)
    
    return SignalBlock(cancelableAsync: {(complete: (PipelineResult<ResultT>) -> Void) -> (Void -> Void, AnyObject?) in
        var val1: T1?
        var val2: T2?
        
        var canceler1: Canceler?
        var canceler2: Canceler?
        
        let checkCompletion: Void -> Void = {
            if val1 != nil && val2 != nil {
                let result = (val1!, val2!)
                complete(PipelineResult(result))
            }
        }
        
        let reportError = {(error: NSError) -> Void in
            canceler1?.cancel()
            canceler2?.cancel()
            complete(PipelineResult<ResultT>(error))
        }
        
        canceler1 = sig1.success({(res: T1) in
            val1 = res
            checkCompletion()
            }, error: reportError)
        
        canceler2 = sig2.success({(res: T2) in
            val2 = res
            checkCompletion()
            }, error: reportError)
        
        return ({
            canceler1?.cancel()
            canceler2?.cancel()
        }, NSNumber(integer: 0))
    })
}

func MultiplexSignals<T1, T2, T3>(sig1: Signal<T1>, sig2: Signal<T2>, sig3: Signal<T3>) -> Signal<(T1, T2, T3)> {
    typealias ResultT = (T1, T2, T3)
    
    return SignalBlock(cancelableAsync: {(complete: (PipelineResult<ResultT>) -> Void) -> (Void -> Void, AnyObject?) in
        var val1: T1?
        var val2: T2?
        var val3: T3?
        
        var canceler1: Canceler?
        var canceler2: Canceler?
        var canceler3: Canceler?
        
        let checkCompletion: Void -> Void = {
            if val1 != nil && val2 != nil && val3 != nil {
                let result = (val1!, val2!, val3!)
                complete(PipelineResult(result))
            }
        }
        
        let reportError = {(error: NSError) -> Void in
            canceler1?.cancel()
            canceler2?.cancel()
            canceler3?.cancel()
            complete(PipelineResult<ResultT>(error))
        }
        
        canceler1 = sig1.success({(res: T1) in
            val1 = res
            checkCompletion()
        }, error: reportError)
        
        canceler2 = sig2.success({(res: T2) in
            val2 = res
            checkCompletion()
        }, error: reportError)
        
        canceler3 = sig3.success({(res: T3) in
            val3 = res
            checkCompletion()
        }, error: reportError)
        
        return ({
            canceler1?.cancel()
            canceler2?.cancel()
            canceler3?.cancel()
        }, NSNumber(integer: 0))
    })
}

public class PiplelineElemBlock<ArgT: Any, ResultT: Any>: PipelineElem<ArgT, ResultT>
{
    public typealias SyncBlock = (ArgT) -> PipelineResult<ResultT>
    public typealias AsyncBlock = (ArgT, (PipelineResult<ResultT>) -> Void) -> Void
    
    private var _syncBlock: SyncBlock?
    private var _asyncBlock: AsyncBlock?
    
    init(fn: (ArgT) -> ResultT) {
        _syncBlock = {(arg: ArgT) -> PipelineResult<ResultT> in
            return PipelineResult(fn(arg))
        }
    }
    
    init(sync: SyncBlock) {
        _syncBlock = sync
        super.init()
    }
    
    init(async: AsyncBlock) {
        _asyncBlock = async
        super.init()
    }
    
    override public func exec(arg: ArgT, complete: (PipelineResult<ResultT>) -> ()) {
        if let sync = _syncBlock {
            complete(sync(arg))
        } else if let async = _asyncBlock {
            async(arg, complete)
        }
    }
}

public class PiplelineElemSignal<ArgT: Any, ResultT: Any>: PipelineElem<ArgT, ResultT>
{
    public typealias SyncBlock = (ArgT) -> PipelineResult<Signal<ResultT>>
    public typealias AsyncBlock = (ArgT, (PipelineResult<Signal<ResultT>>) -> Void) -> Void
    
    private var _syncBlock: SyncBlock?
    private var _asyncBlock: AsyncBlock?
    
    init(sync: SyncBlock) {
        _syncBlock = sync
        super.init()
    }
    
    init(async: AsyncBlock) {
        _asyncBlock = async
        super.init()
    }
    
    private func processPliResult(pliResult: PipelineResult<Signal<ResultT>>, complete: (PipelineResult<ResultT>) -> ()) {
        if let result = pliResult.result {
            result.success(switchToBg({complete(PipelineResult($0))}),
                error: switchToBg({complete(PipelineResult<ResultT>($0))}))
        } else if let error = pliResult.error {
            dispatchAsyncOnBg ({
                complete(PipelineResult<ResultT>(error))
            })
        }
    }
    
    override public func exec(arg: ArgT, complete: (PipelineResult<ResultT>) -> ()) {
        dispatchAsyncOnMain {
            if let sync = self._syncBlock {
                self.processPliResult(sync(arg), complete: complete)
            } else if let async = self._asyncBlock {
                async(arg) {self.processPliResult($0, complete: complete)}
            }
        }
    }
}

public class SignalCanceler: Canceler
{
    private weak var _pli: SignalCommon?
    private var _operationId: AnyObject?
    
    init(pli: SignalCommon) {
        _pli = pli
    }
    
    init(pli: SignalCommon, operationId: AnyObject?) {
        _pli = pli
        _operationId = operationId
    }
    
    @objc public func cancel() {
        if let pli = _pli {
            pli.cancel()
            _pli = nil
        }
    }
    
    @objc public func operationId() -> AnyObject? {
        return _operationId
    }
}
