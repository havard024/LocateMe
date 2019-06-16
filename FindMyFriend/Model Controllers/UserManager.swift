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
#warning("Figure out how to map firestore data to models to become more type safe")
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
    func updateLocation(_ coordinate: CLLocationCoordinate2D) {
        // debugPrint("updateLocation", coordinate)
        let user = UserLocation(geoPoint: GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), id: userID)
        #warning("Call can fail and we are not handling it. Should either handle it or document why we don't need to handle it.")
        FirestoreAPI.shared.setUserData(user)
    }
}
