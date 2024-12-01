//
//  ProfileViewController.swift
//  TeamUp WashU
//
//  Created by Ahmadov, Kanan on 11/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class ProfileViewController: UIViewController {

    // Outlets for UI elements
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var skillsStackView: UIStackView!
    
    
    let db = Firestore.firestore()
    
    var userID: String?
    

    // Data models
    var skills: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        
        fetchUserData()
    }

//


    
    @IBAction func LogoutButton(_ sender: Any){
        do{
            try Auth.auth().signOut()
            print("logged out succesfully")
            
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            guard let window = UIApplication.shared.windows.first else {return}
            window.rootViewController = loginViewController
            window.makeKeyAndVisible()
            
        }catch let error {
            print("Eror signing out: \(error.localizedDescription)")
        }
        
    }
    
    

    // Function to load existing user data
    func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        self.userID = userID
        
        let userDocRef = db.collection("users").document(userID)
        userDocRef.getDocument {(document, error)  in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                
            }
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                self.nameTextField.text = data["name"] as? String ?? ""
                self.emailTextField.text = data["email"] as? String ?? ""
                self.phoneTextField.text = data["phone"] as? String ?? ""
                self.majorTextField.text = data["major"] as? String ?? ""
                self.skills =  data["skills"] as? [String] ?? []
                self.updateSkillsStackView()
                
            }else {
                self.createUserDocument()
                
            }
        }
    }
    
    func createUserDocument() {
        guard let userID = userID else {return}
        
        db.collection("users").document(userID).setData([
            "name": "",
            "email": Auth.auth().currentUser?.email ?? "",
            "phone":"",
            "major":"",
            "skills": []
        
        
        ]){ error in
            if let error = error {
                print("Error creating user document: \(error.localizedDescription)")
            } else {
                print("New user document created!")
                self.fetchUserData()
            }
        }
    }
    
    
    
    
    
    

    // Function to update skills section with buttons for each skill
    func updateSkillsStackView() {
        skillsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for skill in skills {
            let skillButton = UIButton(type: .system)
            skillButton.setTitle(skill, for: .normal)
            skillButton.backgroundColor = .systemGray5
            skillButton.setTitleColor(.black, for: .normal)
            skillButton.layer.cornerRadius = 10
            skillsStackView.addArrangedSubview(skillButton)
        }

        // Add "+" button for adding new skills
        let addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 10
        addButton.addTarget(self, action: #selector(addSkillTapped), for: .touchUpInside)
        skillsStackView.addArrangedSubview(addButton)
    }

    
    
    
    
    
    
    

    // Action for adding a new skill
    @IBAction func addSkillTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add Skill", message: "Enter your skill:", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Skill"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            if let skill = alertController.textFields?.first?.text, !skill.isEmpty {
                if !self.skills.contains(skill){
                    self.skills.append(skill)
                    self.updateSkillsStackView()
                    self.saveSkills()
                } else {
                    print("Skill already exists")
                }
                
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    // Function to save skills to UserDefaults
    func saveSkills() {
        guard let userID = userID else { return }
        db.collection("users").document(userID).updateData(["skills": skills]) {error in
            if let error = error {
                print("Error saving skills: \(error.localizedDescription) ")
            } else {
                print("skills saved successfully")
            }
            
        }
    }
    
    
    @IBAction func saveProfileTapped(_ sender: UIButton){
        guard let userID = userID else { return }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            print("Name cannot be empty")
            return
        }
        
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            print("phone cannot be empty")
            return
        }
        
        guard let major = majorTextField.text, !major.isEmpty else {
            print("Major cannot be empty")
            return
        }
        
        let updatedData : [String: Any] = [
            "name": nameTextField.text ?? "",
            "phone": phoneTextField.text ?? "",
            "major": majorTextField.text ?? "",
            "skills": skills
        ]
        
        db.collection("users").document(userID).updateData(updatedData) {error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription) ")
                
            }else {
                print("Profile updated successfully")
                self.fetchUserData()
            }
        }
        
    }
    
    
}
