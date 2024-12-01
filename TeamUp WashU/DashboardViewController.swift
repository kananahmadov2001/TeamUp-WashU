//
//  DashboardViewController.swift
//  TeamUp WashU
//
//  Created by Ahmadov, Kanan on 11/11/24.
//

import UIKit
import Foundation

struct Assignment: Codable {
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
    
    // Assignments array (Data source)
    var assignments: [Assignment] = []
    var filteredAssignments: [Assignment] = [] // For filtering by category and completion

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up labels
        dashboardLabel.text = "Main Dashboard!"

        // Set up collection view
        assignmentsCollectionView.dataSource = self
        assignmentsCollectionView.delegate = self

        // Register the custom collection view cell
        assignmentsCollectionView.register(AssignmentCollectionViewCell.self, forCellWithReuseIdentifier: "assignmentCell")

        // Initially hide the segmented controls
        categorySegmentedControl.isHidden = true
        completionSegmentedControl.isHidden = true

        // Load assignments from UserDefaults
        loadAssignments()
        filterAssignments()
    }

    // MARK: - Filter Assignments by Category and Completion
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        filterAssignments()

    }
    
    @IBAction func completionChanged(_ sender: UISegmentedControl) {
        filterAssignments()
    }

    private func filterAssignments() {
        let selectedCategoryIndex = categorySegmentedControl.selectedSegmentIndex
        let selectedCategory = categorySegmentedControl.titleForSegment(at: selectedCategoryIndex) ?? "All"
        
        let selectedCompletionIndex = completionSegmentedControl.selectedSegmentIndex
        let selectedCompletion: Bool? = {
            switch selectedCompletionIndex {
            case 1: return true // Completed
            case 2: return false // In-Progress
            default: return nil // All
            }
        }()

        // Start with all assignments
        filteredAssignments = assignments

        // Filter by category if not "All"
        if selectedCategory != "All" {
            filteredAssignments = filteredAssignments.filter { $0.categories.contains(selectedCategory) }
        }

        // Filter by completion status if specified
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
    
    // MARK: - Create Button Action
    @IBAction func createButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New Assignment", message: "Enter assignment details", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Project Title"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Due Date (example: 12/01/2024)"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Description"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Teammate Names"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Category (choose: Homework, Side-Project, Other)"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let name = alertController.textFields?[0].text, !name.isEmpty,
                  let dueDate = alertController.textFields?[1].text, !dueDate.isEmpty else {
                self.showAlert(message: "Assignment name and due date are required.")
                return
            }

            // Validate the due date format
            if !self.isValidDateFormat(dueDate) {
                self.showAlert(message: "Invalid date format. Please use mm/dd/yyyy.")
                return
            }
            
            let description = alertController.textFields?[2].text ?? ""
            let teammates = alertController.textFields?[3].text?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
            let category = alertController.textFields?[4].text ?? "Other"

            // Create a new assignment
            let newAssignment = Assignment(name: name, dueDate: dueDate, description: description, teammates: teammates, isCompleted: false, categories: [category])
            self.assignments.append(newAssignment)
            
            // Save assignments to UserDefaults
            self.saveAssignments()
            
            // Reload the collection view
            self.filterAssignments()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    // MARK: - Helper Methods
    private func isValidDateFormat(_ date: String) -> Bool {
        let dateRegex = #"^\d{2}/\d{2}/\d{4}$"#
        let datePredicate = NSPredicate(format: "SELF MATCHES %@", dateRegex)
        return datePredicate.evaluate(with: date)
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
        
        // Define colors in a specific order
        let assignmentColors: [UIColor] = [
            UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1), // Dark yellow
            UIColor(red: 0/255, green: 0/255, blue: 139/255, alpha: 1), // Dark blue
            UIColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 1), // Dark green
            .red,
            UIColor(red: 139/255, green: 0/255, blue: 0/255, alpha: 1)  // Dark red
        ]

        // Get the color based on the index
        let color = assignmentColors[indexPath.item % assignmentColors.count]
        
        // Configure the cell
        let statusText = assignment.isCompleted ? "✅" : ""
        cell.configure(title: "\(assignment.name) \(statusText)\nDue: \(assignment.dueDate)", backgroundColor: color)
        cell.assignmentButton.addTarget(self, action: #selector(assignmentButtonTapped(_:)), for: .touchUpInside)
        cell.assignmentButton.tag = indexPath.item

        return cell
    }

    // MARK: - Assignment Button Action
    @IBAction func assignmentButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let assignment = filteredAssignments[index]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "AssignmentDetailsViewController") as? AssignmentDetailsViewController {
            detailsVC.delegate = self
            detailsVC.assignment = assignment
            navigationController?.pushViewController(detailsVC, animated: true)
        } else {
            print("Error: Could not instantiate AssignmentDetailsViewController")
        }
    }
    
    

    // MARK: - Save and Load Assignments
    func saveAssignments() {
        if let encodedData = try? JSONEncoder().encode(assignments) {
            UserDefaults.standard.set(encodedData, forKey: "assignments")
        }
    }

    func loadAssignments() {
        if let savedData = UserDefaults.standard.data(forKey: "assignments"),
           let decodedAssignments = try? JSONDecoder().decode([Assignment].self, from: savedData) {
            assignments = decodedAssignments
        }
    }
}

// MARK: - AssignmentDetailsDelegate Implementation
extension DashboardViewController: AssignmentDetailsDelegate {
    func updateAssignment(updatedAssignment: Assignment) {
        if let index = assignments.firstIndex(where: { $0.name == updatedAssignment.name }) {
            assignments[index] = updatedAssignment
            saveAssignments()
            filterAssignments()
        }
    }

    func deleteAssignment(assignment: Assignment) {
        assignments.removeAll { $0.name == assignment.name }
        saveAssignments()
        filterAssignments()
    }
}
