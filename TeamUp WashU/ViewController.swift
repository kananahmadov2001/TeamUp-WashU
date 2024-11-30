//
//  ViewController.swift
//  TeamUp WashU
//
//  Created by Samuel Gil on 11/10/24.
//

import UIKit
import FirebaseAuth
import FSCalendar

class ViewController:

    UIViewController {
    
    
    @IBOutlet weak var idField: UITextField!
    
    @IBOutlet weak var pswField: UITextField!
    @IBOutlet weak var mainCalendar: FSCalendar!

    func showAlert(message:String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Confirm", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    @IBAction func loginButton(_ sender: Any) {
        guard let email = idField.text,!email.isEmpty else{
            showAlert(message: "Enter email")
            return
        }
        guard let psw = pswField.text, !psw.isEmpty else{
            showAlert(message: "Enter password")
            return
        }
        guard !email.isEmpty || !psw.isEmpty else{
            print("Enter account")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: psw) { authResult, error in
            if let error = error {
                
                print("Error sign in: \(error.localizedDescription) ")
                self.showAlert(message: "Login Error")
                
               return
            }
                    //self.NavigateToDashboard()
            print("User logged in successfully: \(authResult?.user.email ?? "")")
            self.showAlert(message: "Logged in")
            self.NavigateToLoginPage()
            
            }
        
        
    }
    
    @IBAction func RegisterButton(_ sender: Any) {
        guard let email = idField.text,!email.isEmpty else{
            showAlert(message: "Enter ID")
            return
        }
        guard let password = pswField.text, !password.isEmpty else{
            showAlert(message: "Enter password")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error sign up: \(error.localizedDescription) ")

                self.showAlert(message: " Signup Error")
                
                return
            }
            //self.NavigateToLoginPage()
            print("User signed up successfully: \(authResult?.user.email ?? "")")
            self.showAlert(message: "Registered successfully")
            self.NavigateToLoginPage()
           
        }
    }
    
    
    func NavigateToLoginPage() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        
        guard let window = UIApplication.shared.windows.first else {return}
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    
        
                  
              }

    
   
    
    
    @IBOutlet weak var loginResultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            NavigateToLoginPage()
        }
    }


}

