//
//  PageIndicator.swift
//  StaffApp
//
//  Created by Alexey Klyotzin on 11/28/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

import UIKit

@IBDesignable class PageIndicator: UIView
{
//    @IBInspectable var pages: Int = 3 {didSet{setNeedsLayout()}}
//    @IBInspectable var currentPage: Int = 0 {didSet{setNeedsLayout()}}
//    @IBInspectable var selectedColor: UIColor = UIColor.redColor() {didSet{setNeedsLayout()}}
//    @IBInspectable var unselectedColor: UIColor = UIColor.lightGrayColor() {didSet{setNeedsLayout()}}
//    @IBInspectable var interval: CGFloat = 0 {didSet{setNeedsLayout()}}
//    
//    @IBInspectable var selectedRadius: CGFloat = 0 {didSet{setNeedsLayout()}}
//    @IBInspectable var unselectedRadius: CGFloat = 0 {didSet{setNeedsLayout()}}
    
    @IBInspectable var pages: Int = 3
    @IBInspectable var currentPage: Int = 0 {didSet{setNeedsLayout()}}
    @IBInspectable var selectedColor: UIColor = UIColor.redColor()
    @IBInspectable var unselectedColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var interval: CGFloat = 0
    
    @IBInspectable var selectedRadius: CGFloat = 0
    @IBInspectable var unselectedRadius: CGFloat = 0
    
    private var selectedImage = UIImage()
    private var unselectedImage = UIImage()
    
    private func makeSelectedCircleWithSize(size: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), false, UIScreen.mainScreen().scale)
        let radius: CGFloat = 0.5 * size
        let path: UIBezierPath = UIBezierPath(arcCenter: CGPointMake(radius, radius), radius: radius,
            startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        
        color.setFill()
        path.fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    private func makeUnselectedCircleWithSize(size: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), false, UIScreen.mainScreen().scale)
        let radius: CGFloat = 0.5 * size
        let path: UIBezierPath = UIBezierPath(arcCenter: CGPointMake(radius, radius), radius: radius,
            startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        
        color.setFill()
        path.fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    private func circleSize(page : NSInteger) -> CGFloat {
        return page == currentPage ? selectedRadius : unselectedRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedImage = makeSelectedCircleWithSize(selectedRadius, color: selectedColor)
        unselectedImage = makeUnselectedCircleWithSize(unselectedRadius, color: unselectedColor)
        setNeedsDisplay()
    }
    
    func frameForSelectedPage() -> CGRect {
        if (pages <= 0) {
            return CGRectZero
        }
        
        let startX = 0.5 * (self.frame.size.width - selectedRadius - (CGFloat)(pages - 1) * (unselectedRadius + interval))
        let point = CGPointMake(max(0, startX + CGFloat(currentPage) * (unselectedRadius + interval) - (selectedRadius - unselectedRadius)/2), (self.frame.size.height - selectedRadius)/2)
        return CGRectMake(point.x, point.y, selectedRadius, selectedRadius)
    }
    
    override func drawRect(rect: CGRect) {
        if (pages <= 0) {
            return
        }
        let startX = 0.5 * (rect.width - selectedRadius - (CGFloat)(pages - 1) * (unselectedRadius + interval))
        for var page = 0; page < pages; page++ {
            var point = CGPointMake(startX + CGFloat(page) * (unselectedRadius + interval), 0)
            
            if (page == currentPage) {
                point.y = (rect.height - selectedRadius)/2
                point.x = max(0, point.x - (selectedRadius - unselectedRadius)/2)
                selectedImage.drawAtPoint(point)
            } else {
                point.y = (rect.height - unselectedRadius)/2
                unselectedImage.drawAtPoint(point)
            }
        }
    }
}
