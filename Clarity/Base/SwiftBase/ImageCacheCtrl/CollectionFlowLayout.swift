//
//  CollectionFlowLayout.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 1/13/15.
//  Copyright (c) 2015 Life Church. All rights reserved.
//

import UIKit


protocol CollectionFlowLayoutDelegate: class
{
    func flowLayoutIsReady(layout: CollectionFlowLayout)
}

class CollectionFlowLayout: UICollectionViewFlowLayout
{
    private var _layoutIsReady = false
    private var _layoutPrepared = false
    
    var isReady: Bool {return _layoutIsReady}
    var delegate: CollectionFlowLayoutDelegate?
    
    override func prepareLayout() {
        super.prepareLayout()
        _layoutPrepared = true
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if _layoutPrepared && !_layoutIsReady {
            _layoutIsReady = true
            delegate?.flowLayoutIsReady(self)
        }
        
        return super.layoutAttributesForElementsInRect(rect)
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        _layoutPrepared = false
        _layoutIsReady = false
    }
}