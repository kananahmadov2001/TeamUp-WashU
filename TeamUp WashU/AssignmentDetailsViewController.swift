import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol AssignmentDetailsDelegate: AnyObject {
    func updateAssignment(updatedAssignment: Assignment)
    func deleteAssignment(assignment: Assignment)
}

class AssignmentDetailsViewController: UIViewController {

    // Outlets for UI elements
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var teammatesTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Firebase properties
    let db = Firestore.firestore()
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }

    // Assignment passed from DashboardViewController
    var assignment: Assignment?
    weak var delegate: AssignmentDetailsDelegate?

    // Categories data source
    let categories = ["Homework", "Side-Project", "Other"]
    var selectedCategory: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        guard let assignment = assignment else { return }

        // Populate text fields with current assignment data
        titleTextField.text = assignment.name
        descriptionTextField.text = assignment.description
        dueDateTextField.text = assignment.dueDate
        teammatesTextField.text = assignment.teammates.joined(separator: ", ")

        // Set up the category picker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        if let currentCategory = assignment.categories.first {
            selectedCategory = currentCategory
            if let index = categories.firstIndex(of: currentCategory) {
                categoryPicker.selectRow(index, inComponent: 0, animated: false)
            }
        }

        // Set up the status switch
        statusSwitch.isOn = assignment.isCompleted
    }

    // MARK: - Save Button Action
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let updatedName = titleTextField.text, !updatedName.isEmpty else {
            showAlert(message: "Title is required.")
            return
        }

        guard let updatedDueDate = dueDateTextField.text, !updatedDueDate.isEmpty else {
            showAlert(message: "Due Date is required.")
            return
        }

        // Validate the due date format
        if !isValidDateFormat(updatedDueDate) {
            showAlert(message: "Invalid date format. Please use mm/dd/yyyy.")
            return
        }

        let updatedDescription = descriptionTextField.text ?? ""
        let updatedTeammates = teammatesTextField.text?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        let updatedStatus = statusSwitch.isOn // Get the status from the switch
        let updatedCategory = selectedCategory ?? "Other" // Default to "Other" if none selected

        // Update assignment in Firebase and notify delegate
        guard let userID = userID, var updatedAssignment = assignment else { return }
        updatedAssignment.name = updatedName
        updatedAssignment.dueDate = updatedDueDate
        updatedAssignment.description = updatedDescription
        updatedAssignment.teammates = updatedTeammates
        updatedAssignment.isCompleted = updatedStatus
        updatedAssignment.categories = [updatedCategory]

        db.collection("users").document(userID).collection("assignments").document(updatedAssignment.id).setData([
            "name": updatedAssignment.name,
            "dueDate": updatedAssignment.dueDate,
            "description": updatedAssignment.description,
            "teammates": updatedAssignment.teammates,
            "isCompleted": updatedAssignment.isCompleted,
            "categories": updatedAssignment.categories
        ], merge: true) { error in
            if let error = error {
                print("Error updating assignment: \(error.localizedDescription)")
                self.showAlert(message: "Failed to save assignment. Please try again.")
                return
            }
            self.delegate?.updateAssignment(updatedAssignment: updatedAssignment)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Delete Button Action
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let userID = userID, let assignment = assignment else { return }

        db.collection("users").document(userID).collection("assignments").document(assignment.id).delete { error in
            if let error = error {
                print("Error deleting assignment: \(error.localizedDescription)")
                self.showAlert(message: "Failed to delete assignment. Please try again.")
                return
            }
            self.delegate?.deleteAssignment(assignment: assignment)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Helper function to validate date format
    private func isValidDateFormat(_ date: String) -> Bool {
        let dateRegex = #"^\d{2}/\d{2}/\d{4}$"#
        return NSPredicate(format: "SELF MATCHES %@", dateRegex).evaluate(with: date)
    }
    
    // Helper function to show alerts
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension AssignmentDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
}
