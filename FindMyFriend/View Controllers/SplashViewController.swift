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
        
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "map", sender: nil)
        } else {
            Auth.auth().signInAnonymously() { authResult, error in
                if error != nil {
                    fatalError("Failed to sign in: \(error)")
                }
                
                self.performSegue(withIdentifier: "map", sender: nil)
            }
        }
    }

}
