//
//  CreateEventViewController.swift
//  TeamUp WashU
//
//  Created by Ahmadov, Kanan on 11/12/24.
//

import UIKit
import Foundation

protocol CreateEventDelegate: AnyObject {
    func didCreateEvent(title: String, date: String)
}

class CreateEventViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    weak var delegate: CreateEventDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Action for Save button tap
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty,
              let date = dateTextField.text, !date.isEmpty else {
            return
        }

        // Pass the event data back to DashboardViewController
        delegate?.didCreateEvent(title: title, date: date)
        navigationController?.popViewController(animated: true)
    }
}

