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
    
    private let usersRef: CollectionReference
    private let userRef: DocumentReference

    init() {
        let db = Firestore.firestore()
        self.usersRef = db.collection("users")
        
        if let userID = UserDefaultsWrapper.userID {
            self.userRef = usersRef.document(userID)
        } else {
            self.userRef = usersRef.document()
            UserDefaultsWrapper.userID = self.userRef.documentID
        }
    }
    
    #warning("If users node is going to contain private data, might need to move public location to a different node")
    func updateLocation(_ coordinate: CLLocationCoordinate2D) {
        debugPrint("updateLocation", coordinate)
        let db = Firestore.firestore()
        let user = User(location: GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), id: userRef.documentID)
        let data = try! FirebaseEncoder().encode(user)
        self.userRef.setData(data as! [String : Any])
    }
}
