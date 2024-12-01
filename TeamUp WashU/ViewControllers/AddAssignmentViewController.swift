//
//  AddAssignmentViewController.swift
//  TeamUp WashU
//
//  Created by 김성태 on 12/1/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol AddAssignmentViewControllerDelegate {
    func addAssignmentDone(updatedAssignment: Assignment)
}

final class AddAssignmentViewController: UIViewController {
    
    var delegate: AddAssignmentViewControllerDelegate?
    
    var selectedDate: Date?
    
    let db = Firestore.firestore()
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }    
    
    let categories = ["Homework", "Side-Project", "Other"]
    
    @IBOutlet var titleTextFieldStackView: UIStackView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descTextFieldStackView: UIStackView!
    @IBOutlet var descTextField: UITextField!
    @IBOutlet var dueDateDatePicker: UIDatePicker!
    @IBOutlet var teamMatesTextFieldStackView: UIStackView!
    @IBOutlet var teamMatesTextField: UITextField!
    @IBOutlet var statusToggle: UISwitch!
    @IBOutlet var categorySegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        titleTextFieldStackView.layer.cornerRadius = 4
        descTextFieldStackView.layer.cornerRadius = 4
        teamMatesTextFieldStackView.layer.cornerRadius = 4
        setupSegmentControl()
        setSelectedDate(date: selectedDate)
        statusToggle.isOn = false
    }
    
    private func setSelectedDate(date: Date?) {
        guard let date = date else {
            return
        }
        dueDateDatePicker.date = date
    }
    
    func setData(date: Date?) {
        selectedDate = date
    }
    
    func setupSegmentControl() {
        categorySegmentControl.removeAllSegments()
        for (index, category) in categories.enumerated() {
            categorySegmentControl.insertSegment(withTitle: category, at: index, animated: false)
        }
        categorySegmentControl.selectedSegmentIndex = 0
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let name = titleTextField.text, !name.isEmpty,
              let desc = descTextField.text, !desc.isEmpty else {
            self.showErrorAlert(message: "All fields are required.")
            return
        }
        let teammates = teamMatesTextField.text!
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        
        let assignment = Assignment(
            id: UUID().uuidString,
            name: name,
            dueDate: dueDateDatePicker.date.str,
            description: desc,
            teammates: teammates,
            isCompleted: statusToggle.isOn,
            categories: [self.categories[categorySegmentControl.selectedSegmentIndex]]
        )
        saveAssignmentToFirebase(assignment)
    }
    
    func saveAssignmentToFirebase(_ assignment: Assignment) {
        guard let userID = userID else { return }
        db.collection("users").document(userID).collection("assignments").document(assignment.id).setData([
            "name": assignment.name,
            "dueDate": assignment.dueDate,
            "description": assignment.description,
            "teammates": assignment.teammates,
            "isCompleted": assignment.isCompleted,
            "categories": assignment.categories
        ]) { error in
            if let error = error {
                print("Error saving assignment: \(error.localizedDescription)")
                return
            }
            self.dismiss(animated: true)
            self.delegate?.addAssignmentDone(updatedAssignment: assignment)
        }
    }
}
