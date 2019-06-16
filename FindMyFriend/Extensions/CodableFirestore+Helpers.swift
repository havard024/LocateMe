//
//  CodableFirestore+Helpers.swift
//  FindMyFriend
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

// Required extensions to be able to use the below fields as codables: https://github.com/alickbass/CodableFirebase

import FirebaseFirestore
import CodableFirebase

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}
