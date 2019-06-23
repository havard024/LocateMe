//
//  UIViewController+Helpers.swift
//  FindMyFriend
//
//  Created by mac on 6/23/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit

extension UIViewController {
    func performSegue(_ identifier: SegueIdentifier) {
        self.performSegue(withIdentifier: identifier.rawValue, sender: self)
    }
}
