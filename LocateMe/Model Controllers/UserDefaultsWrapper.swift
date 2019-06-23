//
//  UserDefaultsWrapper.swift
//  FindMyFriend
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import Foundation

struct UserDefaultsWrapper {
    private enum Key: String {
        case userID = "UserID"
    }
    
    private static var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private static func setValue<T>(_ value: T, for key: Key) {
        self.defaults.setValue(value, forKey: key.rawValue)
    }
    
    private static func removeValue(for key: Key) {
        self.defaults.removeObject(forKey: key.rawValue)
    }
    
    private static func value<T>(for key: Key) -> T? {
        return self.defaults.value(forKey: key.rawValue) as? T
    }
    
    static var userID: String? {
        get {
            return self.value(for: .userID)
        }
        set {
            if let newUserID = newValue {
                self.setValue(newUserID, for: .userID)
            } else {
                self.removeValue(for: .userID)
            }
        }
    }
}
