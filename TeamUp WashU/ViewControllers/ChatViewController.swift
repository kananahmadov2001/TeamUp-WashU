//
//  MessageViewController.swift
//  TeamUp WashU
//
//  Created by Samuel Gil on 11/30/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import MessageKit
import InputBarAccessoryView

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}


struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    public var isNewConversation = false
    public var otherUserEmail: String = ""
    public var myEmail: String = ""
    public var text: String = ""
    let db = Firestore.firestore()
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }
    var currentUser: Sender?
    public var messages = [MessageType]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        myEmail = Auth.auth().currentUser?.email ?? ""
        currentUser = Sender(senderId: myEmail, displayName: myEmail)
        fetchMessages()
        
    }
    
    
    func currentSender() -> any SenderType {
        guard let currentSender = currentUser else {return Sender(senderId: "", displayName: "")}
        return currentSender
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
       
        
        
        
        createMessages(text: text)
        fetchMessages()
        
        
    }
    
    func fetchMessages() {
            
        // Listen for changes in the "messages" collection under the user's document
            db.collection("messages")
                .order(by: "timestamp") // Order messages by timestamp
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error fetching messages: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    // Map the snapshot documents into an array of `Message` objects
                    self.messages = documents.map { document in
                        let data = document.data()
                        let text = data["text"] as? String ?? ""
                        let sender = data["sender"] as? String ?? ""
                        let messageId = data["messageId"] as? String ?? ""
                        let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                        
                 
                        
                        // Create a Message object for the message
                        let message = Message(sender: Sender(senderId: sender, displayName: sender),
                                              messageId: messageId,
                                              sentDate: timestamp.dateValue(),
                                              kind: .text(text))
                        return message
                    }
                    
                    // Reload the UI with the updated messages
                    self.messagesCollectionView.reloadData()
                }
        }
    func createMessages(text: String?) {
        guard let safeText = text else { return }
        
        let messageData: [String: Any] = [
                "text": safeText,
                "sender": Auth.auth().currentUser?.email ?? "",
                "messageId": UUID().uuidString,
                "timestamp": Date()
            ]
            
            // Save the message as a document in the "messages" sub-collection
            db.collection("messages").addDocument(data: messageData) { error in
                if let error = error {
                    print("Error creating message document: \(error.localizedDescription)")
                } else {
                    print("Message document created!")
                    self.fetchMessages()
                }
            }
        }
    
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> any MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
