//
//  UserLocation.swift
//  FindMyFriend
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import FirebaseFirestore

struct UserLocation: Codable {
    let id: String
    let geoPoint: GeoPoint
    let updatedAt: Timestamp
    
    init(geoPoint: GeoPoint, id: String) {
        self.geoPoint = geoPoint
        self.updatedAt = Timestamp(date: Date())
        self.id = id
    }
}
