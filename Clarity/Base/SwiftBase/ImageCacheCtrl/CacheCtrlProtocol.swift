//
//  CacheCtrlProtocol.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 1/14/15.
//  Copyright (c) 2015 Life Church. All rights reserved.
//

import Foundation
import UIKit

protocol CacheCtrl
{
    var isActive: Bool {get set}
    var cachedScreens: CGFloat {get set}
    func reloadData()
    func itemsWasAdded()
    func memoryWarningReceived()
    func restartRequest()
    func clear()
    
    func imagesAtIndex(index: Int) -> ImageCacheResult
    func imageAtIndex(index: Int) -> UIImage?
}

protocol CacheCtrlDelegate: class
{
    typealias CacheRequestT
    
    func cacheCtrl(ctrl: CacheCtrl, itemsAtIndex index: Int) -> [CacheRequestT]
    func cacheCtrl(ctrl: CacheCtrl, signalForRequest request: CacheRequestT) -> Signal<UIImage>
    func cacheCtrl(ctrl: CacheCtrl, imageReady image: UIImage, forRequest request: CacheRequestT, atIndex index: Int)
}
