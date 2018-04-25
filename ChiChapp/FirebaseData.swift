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
        usersRef.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? NSDictionary,
                let displayName = data[Constants.user.displayName] as? String,
                let id = data[Constants.user.id] as? String {
                let user = Sender(id: id, displayName: displayName)
                contacts.append(user)
            }
            completion(contacts)
        })
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
//                let chat = Constants.refs.databaseChats.childByAutoId().key
//                print("chat is: \(chat)")
//                defaults.set(chat, forKey: Constants.userDefaults.chatKey)
            }
        })
    }
}

  /*
    static func getChatId(currentUserId: String, contactId: String?, completion: @escaping (String) -> Void) {
        
        let currentUserRef = Constants.refs.databaseUsers.child(currentUserId)
        let defaults = UserDefaults.standard
        var chat = ""
        if contactId != nil {
            currentUserRef.observe(.value, with: { (snapshot) in
                if snapshot.hasChild("chats") {
                    let value =  snapshot.childSnapshot(forPath: "chats").value as? [String: String]
                    let chatKey = value?[contactId!]!
                    print("**** Contact:\(String(describing: contactId)) ******* Key:\(String(describing: chatKey))")
//                    chat = chatKey!
                    defaults.set(chat, forKey: Constants.userDefaults.chatKey)
                    
                } else {
                    let chat = Constants.refs.databaseChats.childByAutoId().key
                    print("chat is: \(chat)")
                    defaults.set(chat, forKey: Constants.userDefaults.chatKey)
                }
                completion(chat)
            
            })
            /*
            currentUserRef.observeSingleEvent(of: .value) { snapshot in
                if snapshot.hasChild("chats") {
                    let value =  snapshot.childSnapshot(forPath: "chats").value as? [String: String]
                    let chatKey = value?[contactId!]!
                    print("**** Contact:\(String(describing: contactId)) ******* Key:\(String(describing: chatKey))")
                    chat = chatKey!
                    
                } else {
                    let chat = Constants.refs.databaseChats.childByAutoId().key
                    print("chat is: \(chat)")
                    defaults.set(chat, forKey: Constants.userDefaults.chatKey)
                }
                completion(chat)
            }
 */
        } else {
            print("No members online")
        }
    }
 */
