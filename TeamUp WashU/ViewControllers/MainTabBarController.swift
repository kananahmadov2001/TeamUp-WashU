//
//  MainTabBarController.swift
//  TeamUp WashU
//
//  Created by Sow, Abdou on 11/29/24.
//

import Foundation
import UIKit
import FirebaseAuth


class MainTabBarController: UITabBarController {


    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogoutButton()
    }


    private func setupLogoutButton() {
        // Add the logout button to the navigation bar
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        self.navigationItem.rightBarButtonItem = logoutButton
    }


    @objc private func logoutTapped() {
        // Handle logout
        do {
            try Auth.auth().signOut()
            
            // Navigate back to the Login screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            
            guard let window = UIApplication.shared.windows.first else { return }
            window.rootViewController = loginViewController
            window.makeKeyAndVisible()
            
//            let transition = CATransition()
//            transition.type = .fade
//            transition.duration = 0.3
//            window.layer.add(transition, forKey: kCATransition)
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}





