//
//  Firebase.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 21/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation
import MessageKit
import Firebase

class FirebaseData {
    
    static func createDefaultUsers() -> [Sender] {
        var contacts = [Sender]()
        let currentSender = addUserToFirebase(displayName: "Child")
        saveCurrentUser(sender: currentSender)

        contacts.append(currentSender)
        contacts.append(addUserToFirebase(displayName: "Dad"))
        contacts.append(addUserToFirebase(displayName: "Mom"))
        contacts.append(addUserToFirebase(displayName: "Nanny"))
        return contacts
    }
    
    private static func saveCurrentUser(sender: Sender) {
        let defaults = UserDefaults.standard
        defaults.set(sender.displayName, forKey: Constants.userDefaults.userName)
        defaults.set(sender.id, forKey: Constants.userDefaults.userID)
    }
    
    private static func addUserToFirebase(displayName: String) -> Sender {
        let reference = Constants.refs.databaseUsers.childByAutoId()
        print("*****New user with ID: \(reference.key)")
        let sender = Sender(id: reference.key, displayName: displayName)
        let userFirebase = ["name": displayName , "id": reference.key] as [String : String]
        reference.setValue(userFirebase)
        return sender

    }
    
    typealias CompletionHandler = (Bool) -> Void

    static func observeMessages(completion: @escaping ([MessageType]) -> Void) {
        var messages =  [MessageType]()
        let query = Constants.refs.databaseMessages.child(UserDefaults.standard.string(forKey: Constants.userDefaults.chatKey)!).queryLimited(toLast: 5)
        _ = query.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: String],
                let senderId = data[Constants.messages.senderId],
                let senderName = data[Constants.messages.senderName],
                let messageContent = data[Constants.messages.message],
                !messageContent.isEmpty {
                let sender = Sender(id: senderId, displayName: senderName)
                let attributedText = NSAttributedString(string: messageContent, attributes: [.font: UIFont.systemFont(ofSize: 50), .foregroundColor: UIColor.blue])
                let message = ChatMessage(attributedText: attributedText, sender: sender, messageId: snapshot.ref.key, date: Date())
                messages.append(message)
            }
            completion(messages)
            
        })
    }
    
    static func observeUsers(completion: @escaping ([Sender]) -> Void) {
        var contacts = [Sender]()
        let usersRef = Constants.refs.databaseUsers
        
         // TODO: contacts will not load after sign out because snapshot value is not array of dictionaries after
//        usersRef.observe(.childAdded, with: { snapshot in
//            if let data = snapshot.value as? NSDictionary,
//                let displayName = data[Constants.user.displayName] as? String,
//                let id = data[Constants.user.id] as? String {
//                let user = Sender(id: id, displayName: displayName)
//                contacts.append(user)
//            }
//                completion(contacts)
//        })
//        usersRef.observeSingleEvent(of: .childAdded) { (snapshot) in
//            if let data = snapshot.value as? [String: String],
//            let displayName = data[Constants.user.displayName],
//                let id = data[Constants.user.id] {
//                let user = Sender(id: id, displayName: displayName)
//                contacts.append(user)
//            }
//            completion(contacts)
//        }
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            print("Amount of users: \(snapshot.childrenCount)")
            if snapshot.childrenCount > 0 {
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                        let data = snap.value as? [String: Any],
                        let displayName = data[Constants.user.displayName] as? String,
                        let id = data[Constants.user.id] as? String {
                        let user = Sender(id: id, displayName: displayName)
                        contacts.append(user)
                    } else {
                        print("Creating contact failed")
                    }
                }
            } else {
                contacts = FirebaseData.createDefaultUsers()
            }
            completion(contacts)
        }
    }
    
    static func getChatId(currentUserId: String, contactId: String?, completionHandler: @escaping CompletionHandler) {
        let currentUserRef = Constants.refs.databaseUsers.child(currentUserId)
        let defaults = UserDefaults.standard
        currentUserRef.observe(.value, with: { (snapshot) in
            if snapshot.hasChild("chats") {
                print("Chats child found")
                let value =  snapshot.childSnapshot(forPath: "chats").value as? [String: String]
                let chatKey = value?[contactId!]
                print("**** Contact:\(String(describing: contactId!)) ******* Key:\(String(describing: chatKey!))")
                defaults.set(chatKey, forKey: Constants.userDefaults.chatKey)
                completionHandler(true)
            } else {
                print("Creating chat")
                let chat = Constants.refs.databaseChats.childByAutoId().key
                defaults.set(chat, forKey: Constants.userDefaults.chatKey)
                let currentUserId = UserDefaults.standard.string(forKey: Constants.userDefaults.userID)
                // Adds chat key under current user in database
                Constants.refs.databaseUsers.child(currentUserId!).child("chats").setValue([(contactId)!: chat])
                Constants.refs.databaseUsers.child((contactId)!).child("chats").setValue([currentUserId!: chat])
            }
        })
    }
}

