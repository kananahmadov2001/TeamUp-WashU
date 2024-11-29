//
//  DashboardViewController.swift
//  TeamUp WashU
//
//  Created by Ahmadov, Kanan on 11/11/24.
//

import UIKit
import Foundation

struct Assignment: Codable {
    let projectName: String
    let dueDate: String
    var isCompleted: Bool
}

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dashboardStackView: UIStackView!
    @IBOutlet weak var assignmentsTableView: UITableView!
    @IBOutlet weak var dashboardLabel: UILabel!

    // array of project names for dashboard buttons
    var dashboardEvents: [String] = []
    // array of assignments (using the Assignment struct)
    var upcomingAssignments: [Assignment] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // initial setup: Set default text for the label and hide the table view initially
        dashboardLabel.text = "Your Dashboard!"
        assignmentsTableView.isHidden = true
        assignmentsTableView.delegate = self
        assignmentsTableView.dataSource = self
        assignmentsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "assignmentCell")
        loadDashboardEvents()
        loadAssignments()
        updateDashboard()
        assignmentsTableView.reloadData()
    }

    // saving the list of dashboard events to UserDefaults
    func saveDashboardEvents() {
        UserDefaults.standard.set(dashboardEvents, forKey: "dashboardEvents")
        print("Dashboard events saved: \(dashboardEvents)")
    }

    // loading the list of dashboard events from UserDefaults
    func loadDashboardEvents() {
        if let savedEvents = UserDefaults.standard.array(forKey: "dashboardEvents") as? [String] {
            dashboardEvents = savedEvents
            print("Dashboard events loaded: \(dashboardEvents)")
        }
    }

    // saving the list of assignments using Codable for JSON encoding
    func saveAssignments() {
        if let encodedData = try? JSONEncoder().encode(upcomingAssignments) {
            UserDefaults.standard.set(encodedData, forKey: "upcomingAssignments")
            print("Assignments saved successfully.")
        }
    }

    // loading the list of assignments using Codable for JSON decoding
    func loadAssignments() {
        if let savedData = UserDefaults.standard.data(forKey: "upcomingAssignments"),
           let decodedAssignments = try? JSONDecoder().decode([Assignment].self, from: savedData) {
            upcomingAssignments = decodedAssignments
            print("Assignments loaded: \(upcomingAssignments)")
        }
    }

    // updating the dashboard UI based on the current data
    func updateDashboard() {
        if dashboardEvents.isEmpty {
            // showing a message if there are no events
            dashboardLabel.text = "Your Dashboard is empty. Tap 'Create' to add events."
        } else {
            // updating the label and show the table view if there are events
            dashboardLabel.text = "Your Dashboard"
            assignmentsTableView.isHidden = false
        }
        updateDashboardButtons()
    }

    // creating and update buttons for each event in the stack view
    func updateDashboardButtons() {
        dashboardStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // creating a button for each event in the list
        for event in dashboardEvents {
            let button = UIButton(type: .system)
            button.setTitle(event, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(dashboardButtonTapped(_:)), for: .touchUpInside)
            dashboardStackView.addArrangedSubview(button)
        }
    }

    @objc func dashboardButtonTapped(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            print("Tapped on event: \(title)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows: \(upcomingAssignments.count)")
        return upcomingAssignments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath)
        let assignment = upcomingAssignments[indexPath.row]

        cell.textLabel?.text = "\(assignment.dueDate) - \(assignment.projectName)"
        cell.accessoryType = assignment.isCompleted ? .checkmark : .none
        print("Cell for row \(indexPath.row): \(assignment.dueDate) - \(assignment.projectName)")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        upcomingAssignments[indexPath.row].isCompleted.toggle()
        saveAssignments()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    @IBAction func createButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New Project", message: "Enter project details", preferredStyle: .alert)
        alertController.addTextField { $0.placeholder = "Project Name" }
        alertController.addTextField { $0.placeholder = "Due Date (e.g., 12/01)" }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let projectName = alertController.textFields?[0].text, !projectName.isEmpty,
                  let dueDate = alertController.textFields?[1].text, !dueDate.isEmpty else { return }

            self.addProjectToDashboard(projectName: projectName)
            self.addAssignmentToList(projectName: projectName, dueDate: dueDate)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    func addProjectToDashboard(projectName: String) {
        dashboardEvents.append(projectName)
        saveDashboardEvents()
        updateDashboardButtons()
    }

    func addAssignmentToList(projectName: String, dueDate: String) {
        let newAssignment = Assignment(projectName: projectName, dueDate: dueDate, isCompleted: false)
        upcomingAssignments.append(newAssignment)
        saveAssignments()
        assignmentsTableView.isHidden = false
        assignmentsTableView.reloadData()
    }
    
}
