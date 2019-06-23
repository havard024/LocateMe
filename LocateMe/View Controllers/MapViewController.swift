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
import FontAwesome_swift

class MapViewController: UIViewController {

    // MARK: - Controller Properties
    
    private let locationManager = CLLocationManager()
    private var annotationMap: [String: MKPointAnnotation] = [:]
    private var isFirstTimeInHere = true
    private var latestRegion: MKCoordinateRegion?
    
    private enum ErrorLabel: CaseIterable {
        case locationManagerErrorLabel
        case userLocationErrorLabel
        case generalErrorLabel
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var errorLabelView: UIStackView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var locationManagerErrorTitleLabel: UILabel!
    @IBOutlet weak var locationManagerErrorDescriptionLabel: UILabel!
    @IBOutlet weak var userLocationErrorTitleLabel: UILabel!
    @IBOutlet weak var userLocationErrorDescriptionLabel: UILabel!
    @IBOutlet weak var genericErrorTitleLabel: UILabel!
    @IBOutlet weak var genericErrorDescriptionLabel: UILabel!
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        clearErrorLabels()
        
        initLocationManager()
        initMapView()
        subscribeToData()
        
        infoButton.setTitle(String.fontAwesomeIcon(name: .infoCircle), for: .normal)
        infoButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .solid)
        
        centerButton.setTitle(String.fontAwesomeIcon(name: .locationArrow), for: .normal)
        centerButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .solid)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)


        /*
         self.setErrorLabel(label: .generalErrorLabel, title: "General Error label", description: "Some kinda description which should be a decent length to test it properly")
         self.setErrorLabel(label: .locationManagerErrorLabel, title: "LocationManager Error label", description: "Some kinda description which should be a decent length to test it properly")
         self.setErrorLabel(label: .userLocationErrorLabel, title: "UserLocation Error label", description: "Some kinda description which should be a decent length to test it properly")
            */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - IBActions
    
    @IBAction func centerTapped(_ sender: Any) {
        if let latestRegion = latestRegion {
            self.mapView.setRegion(latestRegion, animated: true)
        }
    }
    
    @IBAction func infoTapped(_ sender: Any) {
        performSegue(.settings)
    }
    
    // MARK: - Helper Functions
    
    private func subscribeToData() {
        FirestoreAPI.shared.subscribeToCollection(.users) { error, userLocations in
            
            if let error = error {
                self.setErrorLabel(label: .generalErrorLabel, title: "Failed to fetch locations from server", description: error.localizedDescription ?? "No error description provided")
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
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        } else {
            setErrorLabel(label: .locationManagerErrorLabel, title: "Location service is disabled.", description: "Please turn on location service in settings")
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
            
            if let ann = self.annotationMap[user.id] {
                UIView.animate(withDuration: 0.25) {
                    ann.coordinate.latitude = coordinate.latitude
                    ann.coordinate.longitude = coordinate.longitude
                }
                
                ann.title = title
                
            } else {
                self.annotationMap[user.id] = annotation
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func setErrorLabel(label: ErrorLabel, title: String? = "", description: String? = "") {
        let titleLabel: UILabel!
        let descriptionLabel: UILabel!
        
        switch label {
        case .locationManagerErrorLabel:
            titleLabel = locationManagerErrorTitleLabel
            descriptionLabel = locationManagerErrorDescriptionLabel
        case .userLocationErrorLabel:
            titleLabel = userLocationErrorTitleLabel
            descriptionLabel = userLocationErrorDescriptionLabel
        case .generalErrorLabel:
            titleLabel = genericErrorTitleLabel
            descriptionLabel = genericErrorDescriptionLabel
        }
        
        debugPrint(titleLabel, descriptionLabel)
        
        titleLabel.text = title
        titleLabel.isHidden = title == nil
        
        descriptionLabel.text = description
        descriptionLabel.isHidden = description == nil
        
        toggleErrorLabelViewVisibility()
    }
    
    private func clearErrorLabel(label: ErrorLabel) {
        setErrorLabel(label: label)
    }
    
    private func clearErrorLabels() {
        ErrorLabel.allCases.forEach{ self.clearErrorLabel(label: $0) }
    }
    
    private func toggleErrorLabelViewVisibility() {
        let emptyLabels = errorLabelView.subviews.filter({ label in
            let label = label as! UILabel
            if let text = label.text {
                return text.isEmpty
            }
            return true
        })
        
        if emptyLabels.count < 6 {
            errorView.backgroundColor = .red
            errorView.isHidden = false
        } else {
            errorView.backgroundColor = nil
            errorView.isHidden = true
        }
        
    }
    
    private func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
            
        case .notDetermined:
            clearErrorLabel(label: .locationManagerErrorLabel)
        case .restricted:
            setErrorLabel(label: .locationManagerErrorLabel, title: "Location access is restricted.")
        case .denied:
            setErrorLabel(label: .locationManagerErrorLabel, title: "Location access is disabled.", description: "Please enable location access in settings")
        case .authorizedAlways:
            clearErrorLabel(label: .locationManagerErrorLabel)
        case .authorizedWhenInUse:
            clearErrorLabel(label: .locationManagerErrorLabel)
        @unknown default:
            setErrorLabel(label: .locationManagerErrorLabel, title: "Unknown error")
        }
    }
    
    @objc private func appMovedToForeground() {
        if CLLocationManager.locationServicesEnabled() {
            setErrorLabel(label: .locationManagerErrorLabel)
            let status = CLLocationManager.authorizationStatus()
            handleLocationAuthorizationStatus(status: status)
        } else {
            setErrorLabel(label: .locationManagerErrorLabel, title: "Location service is disabled.", description: "Please turn on location service in settings")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = location.coordinate
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            if UserManager.shared.updateLocation(center) == false {
                setErrorLabel(label: .generalErrorLabel, title: "Failed to update location")
            } else {
                clearErrorLabel(label: .generalErrorLabel)
            }
            self.latestRegion = region
            // Center map first time we get a location
            if isFirstTimeInHere {
                self.mapView.setRegion(region, animated: true)
                self.isFirstTimeInHere = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.handleLocationAuthorizationStatus(status: status)
    }
}