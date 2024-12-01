//
//  UIViewController+.swift
//  TeamUp WashU
//
//  Created by 김성태 on 12/1/24.
//

import UIKit

extension UIViewController {
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
