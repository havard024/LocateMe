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

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}

struct User: Codable {
    let id: String
    let location: GeoPoint
    let updatedAt: Timestamp
    
    init(location: GeoPoint, id: String) {
        self.location = location
        self.updatedAt = Timestamp(date: Date())
        self.id = id
    }
}

struct Location: Codable {
    let latitude: String
    let longitude: String
    
}

class MapViewController: UIViewController {

    private let locationManager = CLLocationManager()
    private var annotationMap: [String: MKPointAnnotation] = [:]
    private var isFirstTimeInHere = true
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            #warning("Handle case where app does not have location access or location service is disabled")
        }
        
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        
        let db = Firestore.firestore()
        let users = db.collection("users").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                debugPrint("Error fetching documents: \(error!)")
                return
            }
            #warning("This will crash if returned data contains data that can't be decoded")
            
            let locations = documents.map { (doc: DocumentSnapshot) -> User in
                var docData = doc.data()
                docData?["id"] = doc.documentID
                return try! FirebaseDecoder().decode(User.self, from: docData)
            }
            
            debugPrint(locations)
            
            locations.forEach { user in
                let annotation = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2D(latitude: user.location.latitude, longitude: user.location.longitude)
                annotation.coordinate = coordinate
                let title = timeAgoSince(user.updatedAt.dateValue())
                annotation.title = title
                
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
