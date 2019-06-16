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

#warning("Consider using uid from firebase user using anonymous login")
class UserManager {
    static let shared = UserManager()
    
    private let usersRef: CollectionReference
    private let userRef: DocumentReference

    init() {
        let db = Firestore.firestore()
        Firestore.enableLogging(true)
        self.usersRef = db.collection("users")
        
        if let userID = UserDefaultsWrapper.userID {
            self.userRef = usersRef.document(userID)
        } else {
            self.userRef = usersRef.document()
            UserDefaultsWrapper.userID = self.userRef.documentID
        }
    }
    
    func updateLocation(_ coordinate: CLLocationCoordinate2D) {
        debugPrint("updateLocation", coordinate)
        let db = Firestore.firestore()
        self.userRef.setData(["location": ["latitude": coordinate.latitude, "longitude": coordinate.longitude, "updatedAt": Timestamp(date: Date())]], merge: true)
    }
}
