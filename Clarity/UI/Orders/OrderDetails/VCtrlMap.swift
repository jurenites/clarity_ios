//
//  VCtrlLocation.swift
//  Clarity
//
//  Created by Oleg Kasimov on 9/29/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import UIKit
import MapKit

class VCtrlMap: VCtrlBase, MKMapViewDelegate {
    private var location: Location
    private let _locationDistance: Double = 1000
    
    @IBOutlet var uiMapView: MKMapView!
    @IBOutlet var uiStreetView: UIView!
    @IBOutlet var uiStreetLabel: UILabel!
    
    @IBInspectable var borderColor: UIColor = UIColor.blackColor()
    
    init(location : Location) {
        self.location = location
        super.init(nibName: "VCtrlMap", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Location Details", comment: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.populate()
        self.view.layoutIfNeeded()
    }
    
    private func populate() {
        uiStreetLabel.text = "\(location.city) \(location.address_1)"
        uiStreetView.layer.borderColor = borderColor.CGColor
        uiStreetView.layer.borderWidth = 0.5
        
        let loc = CLLocation(latitude: ToDouble(self.location.lat), longitude: ToDouble(self.location.lng))
        let pin = MapPin(title: location.address_1, coordinate:loc.coordinate)
        self.uiMapView.addAnnotation(pin)
        self.actShowLocation()
    }
    
    //MARK: Actions
    @IBAction func actShowMe() {
        let regionRadius: CLLocationDistance = _locationDistance
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.uiMapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.uiMapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func actShowLocation() {
        let loc = CLLocation(latitude: ToDouble(self.location.lat), longitude: ToDouble(self.location.lng))
        let regionRadius: CLLocationDistance = _locationDistance
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(loc.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.uiMapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if let av = mapView.dequeueReusableAnnotationViewWithIdentifier("AnnotationIdentifier") {
            return av
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationIdentifier")
            av.image = UIImage(named: "Address")
            av.canShowCallout = true
            return av
        }
    }
}

class MapPin: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = ""
        super.init()
    }
}