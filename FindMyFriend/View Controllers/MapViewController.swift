//
//  MapViewController.swift
//  FindMyFriend
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import CodableFirebase

class MapViewController: UIViewController {

    // MARK: - Controller Properties
    
    private let locationManager = CLLocationManager()
    private var annotationMap: [String: MKPointAnnotation] = [:]
    private var isFirstTimeInHere = true
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        initLocationManager()
        initMapView()
        subscribeToData()
    }
    
    // MARK: - Helper Functions
    
    private func subscribeToData() {
        #warning("Should we keep a reference to the listener so that we can unregister for events at some point?")
        FirestoreAPI.shared.subscribeToCollection(.users) { error, userLocations in
            
            if let error = error {
                #warning("Should we notify user about error here")
                return
            }
            self.updateMapWithUserLocations(userLocations)
        }
    }
    
    private func initLocationManager() {
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            #warning("Handle case where app does not have location access or location service is disabled")
        }
    }
    
    private func initMapView() {
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
    }
    
    private func updateMapWithUserLocations(_ userLocations: [UserLocation]) {
        userLocations.forEach { user in
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: user.geoPoint.latitude, longitude: user.geoPoint.longitude)
            annotation.coordinate = coordinate
            let title = timeAgoSince(user.updatedAt.dateValue())
            annotation.title = title
            
            debugPrint()
            if let ann = self.annotationMap[user.id] {
                ann.coordinate = coordinate
                ann.title = title
            } else {
                self.annotationMap[user.id] = annotation
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = location.coordinate
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            UserManager.shared.updateLocation(center)
            // Center map first time we get a location
            if isFirstTimeInHere {
                self.mapView.setRegion(region, animated: true)
                self.isFirstTimeInHere = false
            }
        }
    }
}
