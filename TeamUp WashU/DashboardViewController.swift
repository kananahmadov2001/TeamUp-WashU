import UIKit
import FirebaseFirestore
import FirebaseAuth

struct Assignment: Codable {
    var id: String // Unique identifier for Firestore
    var name: String
    var dueDate: String
    var description: String
    var teammates: [String]
    var isCompleted: Bool
    var categories: [String]
}

class DashboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // Outlets
    @IBOutlet weak var dashboardLabel: UILabel!
    @IBOutlet weak var assignmentsCollectionView: UICollectionView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var completionSegmentedControl: UISegmentedControl!

    // Firebase properties
    let db = Firestore.firestore()
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }

    // Assignments
    var assignments: [Assignment] = []
    var filteredAssignments: [Assignment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dashboardLabel.text = "Main Dashboard!"

        assignmentsCollectionView.dataSource = self
        assignmentsCollectionView.delegate = self
        assignmentsCollectionView.register(AssignmentCollectionViewCell.self, forCellWithReuseIdentifier: "assignmentCell")

        categorySegmentedControl.isHidden = true
        completionSegmentedControl.isHidden = true

        loadAssignmentsFromFirebase()
    }

    // MARK: - Load Assignments from Firebase
    func loadAssignmentsFromFirebase() {
        guard let userID = userID else { return }
        db.collection("users").document(userID).collection("assignments").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching assignments: \(error.localizedDescription)")
                return
            }
            self.assignments = snapshot?.documents.compactMap { doc -> Assignment? in
                let data = doc.data()
                return Assignment(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    dueDate: data["dueDate"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    teammates: data["teammates"] as? [String] ?? [],
                    isCompleted: data["isCompleted"] as? Bool ?? false,
                    categories: data["categories"] as? [String] ?? []
                )
            } ?? []
            self.filterAssignments()
        }
    }

    // MARK: - Filter Assignments
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        filterAssignments()
    }

    @IBAction func completionChanged(_ sender: UISegmentedControl) {
        filterAssignments()
    }

    private func filterAssignments() {
        let selectedCategory = categorySegmentedControl.titleForSegment(at: categorySegmentedControl.selectedSegmentIndex) ?? "All"
        let selectedCompletion: Bool? = {
            switch completionSegmentedControl.selectedSegmentIndex {
            case 1: return true
            case 2: return false
            default: return nil
            }
        }()

        filteredAssignments = assignments

        if selectedCategory != "All" {
            filteredAssignments = filteredAssignments.filter { $0.categories.contains(selectedCategory) }
        }

        if let isCompleted = selectedCompletion {
            filteredAssignments = filteredAssignments.filter { $0.isCompleted == isCompleted }
        }

        assignmentsCollectionView.reloadData()
    }
    
    // MARK: - Show Segmented Controls on Search
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let shouldShow = categorySegmentedControl.isHidden && completionSegmentedControl.isHidden
        categorySegmentedControl.isHidden = !shouldShow
        completionSegmentedControl.isHidden = !shouldShow
    }
    
    // MARK: - Create Assignment
    @IBAction func createButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New Assignment", message: "Enter assignment details", preferredStyle: .alert)

        alertController.addTextField { $0.placeholder = "Project Title" }
        alertController.addTextField { $0.placeholder = "Due Date (mm/dd/yyyy)" }
        alertController.addTextField { $0.placeholder = "Description" }
        alertController.addTextField { $0.placeholder = "Teammate Names" }
        alertController.addTextField { $0.placeholder = "Category (e.g., Homework, Side-Project)" }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let name = alertController.textFields?[0].text, !name.isEmpty,
                  let dueDate = alertController.textFields?[1].text, !dueDate.isEmpty,
                  let description = alertController.textFields?[2].text, !description.isEmpty,
                  let teammatesText = alertController.textFields?[3].text, !teammatesText.isEmpty,
                  let category = alertController.textFields?[4].text, !category.isEmpty else {
                self.showAlert(message: "All fields are required.")
                return
            }

            guard self.isValidDateFormat(dueDate), self.isFutureDate(dueDate) else {
                self.showAlert(message: "Due date must be in the future.")
                return
            }

            let teammates = teammatesText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let newAssignment = Assignment(
                id: UUID().uuidString,
                name: name,
                dueDate: dueDate,
                description: description,
                teammates: teammates,
                isCompleted: false,
                categories: [category]
            )
            self.saveAssignmentToFirebase(newAssignment)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // MARK: - Save Assignment to Firebase
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
            self.assignments.append(assignment)
            self.filterAssignments()
        }
    }

    // MARK: - Assignment Button Tapped
    @objc func assignmentButtonTapped(_ sender: UIButton) {
        let tag = sender.tag
        guard tag < filteredAssignments.count else { return }

        let assignment = filteredAssignments[tag]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "AssignmentDetailsViewController") as? AssignmentDetailsViewController {
            detailsVC.assignment = assignment
            detailsVC.delegate = self
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }

    // MARK: - Helper Functions
    private func isValidDateFormat(_ date: String) -> Bool {
        let regex = #"^\d{2}/\d{2}/\d{4}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: date)
    }

    private func isFutureDate(_ date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let date = dateFormatter.date(from: date) {
            return date > Date()
        }
        return false
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredAssignments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "assignmentCell", for: indexPath) as? AssignmentCollectionViewCell else {
            return UICollectionViewCell()
        }

        let assignment = filteredAssignments[indexPath.item]
        let titleText = assignment.isCompleted ? "✅ \(assignment.name)" : assignment.name
        cell.configure(
            title: "\(titleText)\nDue: \(assignment.dueDate)",
            backgroundColor: .orange
        )
        
        cell.assignmentButton.tag = indexPath.item
        cell.assignmentButton.addTarget(self, action: #selector(assignmentButtonTapped(_:)), for: .touchUpInside)

        return cell
    }
}


// MARK: - AssignmentDetailsDelegate Implementation
extension DashboardViewController: AssignmentDetailsDelegate {
    func updateAssignment(updatedAssignment: Assignment) {
        guard let userID = userID else { return }
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
                return
            }
            if let index = self.assignments.firstIndex(where: { $0.id == updatedAssignment.id }) {
                self.assignments[index] = updatedAssignment
                self.filterAssignments()
            }
        }
    }

    func deleteAssignment(assignment: Assignment) {
        guard let userID = userID else { return }
        db.collection("users").document(userID).collection("assignments").document(assignment.id).delete { error in
            if let error = error {
                print("Error deleting assignment: \(error.localizedDescription)")
                return
            }
            self.assignments.removeAll { $0.id == assignment.id }
            self.filterAssignments()
        }
    }
}
