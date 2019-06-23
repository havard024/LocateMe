//
//  UIAlertAction+Helpers.swift
//  FindMyFriend
//
//  Created by mac on 6/23/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit

extension UIAlertAction {
    
    static func okAction(title: String = "Continue", completion: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: completion)
    }
    
    static func cancelAction(title: String = "Cancel", completion: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .cancel, handler: completion)
    }
}
