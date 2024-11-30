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

        // Initial setup
        //setupProfileImageView()
        
        //updateSkillsStackView()
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
                self.skills.append(skill)
                self.updateSkillsStackView()
                self.saveSkills()
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
    
    
    //    // Function to check if the user is new
    //    func checkIfNewUser() {
    //        let isNewUser = UserDefaults.standard.bool(forKey: "isNewUser")
    //
    //        if isNewUser {
    //            // Clear all fields for a new user
    //            profileImageView.image = UIImage(systemName: "person.circle")
    //            nameTextField.text = ""
    //            emailTextField.text = ""
    //            phoneTextField.text = ""
    //            majorTextField.text = ""
    //            skills = []
    //
    //            // Save that the user is no longer new
    //            UserDefaults.standard.set(false, forKey: "isNewUser")
    //        } else {
    //            // Load user data if it exists
    //            fetchUserData()
    //        }
    //    }
    
    
    
    // Function to set up the profile image view
   //    func setupProfileImageView() {
   //        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
   //        profileImageView.clipsToBounds = true
   //        profileImageView.isUserInteractionEnabled = true
   //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeImageTapped))
   //        profileImageView.addGestureRecognizer(tapGesture)
   //    }
}
