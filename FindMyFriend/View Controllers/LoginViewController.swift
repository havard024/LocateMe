//
//  LoginViewController.swift
//  FindMyFriend
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginTapped(_ sender: Any) {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
