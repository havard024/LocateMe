//
//  SplashViewController.swift
//  FindMyFriend
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UserManager.shared.logIn { error, destination in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Failed to log in, try again later.", preferredStyle: .alert)
                alert.addAction(.okAction(title: "ok"))
                self.present(alert, animated: true)
            } else {
                self.performSegue(destination!)
            }
        }
    }

}
