//
//  UserManager.swift
//  FindMyFriend
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MapKit
import CodableFirebase
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    
    var user: User? {
        get {
            return Auth.auth().currentUser
        }
    }
    
    #warning("If users node is going to contain private data, might need to move public location to a different node")
    func updateLocation(_ coordinate: CLLocationCoordinate2D) -> Bool {
        // debugPrint("updateLocation", coordinate)
        let user = UserLocation(geoPoint: GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), id: self.user!.uid)
        return FirestoreAPI.shared.setUserData(user)
    }
}
