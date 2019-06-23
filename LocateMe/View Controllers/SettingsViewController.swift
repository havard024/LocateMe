//
//  SettingsViewController.swift
//  FindMyFriend
//
//  Created by mac on 6/23/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction func logoutTapped(_ sender: Any) {
        let logout = UIAlertController(title: "Are you sure you want to log out?", message: "Logging out will cause the app to forget the current user, so next time you log in, you will be treated as a new random user.", preferredStyle: .actionSheet)
        logout.addAction(.okAction(completion: self.logOut))
        logout.addAction(.cancelAction())
        present(logout, animated: true)
    }
    
    // MARK: - Helper Functions
    
    private func logOut(action: UIAlertAction) {
        UserManager.shared.logOut { error, destination in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "An error occured while logging you out. Please try again later.", preferredStyle: .alert)
                alert.addAction(.okAction(title: "ok"))
                debugPrint(error)
                self.present(alert, animated: true)
            } else {
                self.performSegue(destination!)
            }
        }
    }
}
