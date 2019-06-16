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

#warning("Consider using uid from firebase user using anonymous login")
class UserManager {
    static let shared = UserManager()
    
    private let userID: String!
    
    init() {
        if UserDefaultsWrapper.userID == nil {
            UserDefaultsWrapper.userID = FirestoreAPI.shared.getDocumentID("users")
        }
        
        self.userID = UserDefaultsWrapper.userID
    }
    
    #warning("If users node is going to contain private data, might need to move public location to a different node")
    func updateLocation(_ coordinate: CLLocationCoordinate2D) -> Bool {
        // debugPrint("updateLocation", coordinate)
        let user = UserLocation(geoPoint: GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), id: userID)
        return FirestoreAPI.shared.setUserData(user)
    }
}
