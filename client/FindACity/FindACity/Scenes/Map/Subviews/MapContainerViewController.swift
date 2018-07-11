//
//  MapContainerViewController.swift
//  FindACity
//
//  Created by Nisum on 7/8/18.
//  Copyright © 2018 Orlando Arzola. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Polyline

protocol MapContainerViewControllerDelegate: class {
    func receivedPlaceMark(placeMark: CLPlacemark)
}

class MapContainerViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    
    weak var delegate: MapContainerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupLocationManager()
    }

    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = true
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
//        let polyline = Polyline(encodedPolyline: "c|pvDqfq}DxuAbvEt~Css@iDg{AmP{kBmgAp@")
//        let coordinates = polyline.coordinates
//        
//        let polygon = MKPolygon(coordinates: coordinates!, count: (coordinates?.count)!)
//        
//        setMapLocation(lat: coordinates![0].latitude, lon: coordinates![0].longitude)
//        
//        mapView.add(polygon)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter =  500
        locationManager.startUpdatingLocation()
    }
    
    func setMapWorkingArea(workingArea: [String]) {
        for area in workingArea {
            let polyline = Polyline(encodedPolyline: area)
            let coordinates = polyline.coordinates
    
            let polygon = MKPolygon(coordinates: coordinates!, count: (coordinates?.count)!)
        
            mapView.add(polygon)
        }
    }
    
    func setMapLocation(lat: Double, lon: Double) {
        let latitude: CLLocationDegrees = lat
        let longitude: CLLocationDegrees = lon
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location, 10000, 10000)
        
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.first!
        setMapLocation(lat: userLocation.coordinate.latitude, lon: userLocation.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(userLocation) { [weak self](placeMarks, error) in
            guard error == nil else {return}
            guard let placeMarks = placeMarks, let placeMark = placeMarks.first else {return}
            self?.delegate?.receivedPlaceMark(placeMark: placeMark)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            //polygonView.strokeColor = .red
            //polygonView.lineWidth = 1
            polygonView.fillColor = UIColor.gray.withAlphaComponent(0.5)
            return polygonView
        }
        
        return MKOverlayRenderer()
    }
}
