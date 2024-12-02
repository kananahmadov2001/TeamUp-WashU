//
//  ChatViewController.swift
//  TeamUp WashU
//
//  Created by Ahmadov, Kanan on 11/11/24.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class ConversationViewController: UIViewController  {
    
    @IBOutlet var messages: UITableView!
    
    @IBAction func newConvo(_ sender: UIButton) {
        
    }
    private var email: String = ""
    
    private var users: [String] = []
    
    let db = Firestore.firestore()
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    @IBAction func enterChat(_ sender: UIButton) {
        let vc = ChatViewController()
        vc.isNewConversation = true
        vc.title = email
        present(vc, animated: true)
    }
}
