//
//  VCtrlLocation.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/29/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit
import MapKit

class VCtrlMap: VCtrlBase {
    private var location: Location
    
    @IBOutlet var uiMapView: MKMapView!
    
    init(location : Location) {
        self.location = location
        super.init(nibName: "VCtrlMap", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.populate()
    }
    
    func populate() {
        let loc = CLLocation(latitude: ToDouble(self.location.lat), longitude: ToDouble(self.location.lng))
        let regionRadius: CLLocationDistance = 1000
        
    }
    
}