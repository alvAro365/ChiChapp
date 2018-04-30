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

    static func createDefaultUser() {
        let currentSender = Sender(id: UUID().uuidString, displayName: "Child")
        saveCurrentUser(sender: currentSender)
    }
    
    static func createDefaultUsers() -> [Sender] {
        var contacts = [Sender]()
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
    
    private static func getCurrentUser() -> Sender {
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: Constants.userDefaults.userName)
        let id = defaults.string(forKey: Constants.userDefaults.userID)
        
        return Sender(id: id!, displayName: name!)
    }

    private static func addUserToFirebase(displayName: String) -> Sender {
        let reference = Constants.refs.databaseUsers.childByAutoId()
        print("*****New user with ID: \(reference.key)")
        let sender = Sender(id: reference.key, displayName: displayName)
        let chatKey = createChatKey(reference, sender)
        let userFirebase = ["name": displayName , "id": reference.key, "chat": chatKey] as [String : String]
        reference.setValue(userFirebase)
        return sender
    }
    
    typealias CompletionHandler = (Bool) -> Void

    static func observeMessages(_ contact: Sender, completion: @escaping ([MessageType]) -> Void) {
        var messages =  [MessageType]()
        let query = Constants.refs.databaseMessages.child(UserDefaults.standard.string(forKey: contact.id)!).queryLimited(toLast: 5)
        _ = query.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: String],
                let senderId = data[Constants.messages.senderId],
                let senderName = data[Constants.messages.senderName],
                let messageContent = data[Constants.messages.message],
                !messageContent.isEmpty {
                let sender = Sender(id: senderId, displayName: senderName)
                if messageContent.hasPrefix("https://") {
                    Storage.storage().reference(forURL: messageContent).getData(maxSize: INT64_MAX) {(data, error) in
                        if let error = error {
                            print("Error downloading: \(error)")
                            return
                        } else {
                            let image = UIImage.init(data: data!)
                            let imageMessage = ChatMessage(image: image!, sender: sender, messageId: snapshot.ref.key, date: Date())
                            messages.append(imageMessage)
                            print("Messages count: \(messages.count)")
                            print("Image downloaded")
                            completion(messages)
                        }
                    }
                } else {
                    let attributedText = NSAttributedString(string: messageContent, attributes: [.font: UIFont.systemFont(ofSize: 50), .foregroundColor: UIColor.blue])
                    let message = ChatMessage(attributedText: attributedText, sender: sender, messageId: snapshot.ref.key, date: Date())
                    messages.append(message)
                            completion(messages)
                }
            }
//            completion(messages)
        })
    }
    
    static func observeUsers(completion: @escaping ([Sender]) -> Void) {
        var contacts = [Sender]()
        let usersRef = Constants.refs.databaseUsers
        let defaults = UserDefaults.standard
        
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            print("Amount of users: \(snapshot.childrenCount)")
            if snapshot.childrenCount > 0 {
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                        let data = snap.value as? [String: Any],
                        let displayName = data[Constants.user.displayName] as? String,
                        let id = data[Constants.user.id] as? String,
                        let chatKey = data["chat"] as? String {
                        let user = Sender(id: id, displayName: displayName)
                        contacts.append(user)
                        defaults.set(chatKey, forKey: user.id)
                        print("Name: \(displayName), ChatKey: \(chatKey)")
                    } else {
                        print("Creating contact failed")
                    }
                }
            } else {
                self.createDefaultUser()
                contacts = self.createDefaultUsers()
            }
            completion(contacts)
        }
    }
    
    private static func createChatKey(_ reference: DatabaseReference, _ contact: Sender) -> String {
        print("Creating chat key")
        let defaults = UserDefaults.standard
        let chatRef = Constants.refs.databaseChats.childByAutoId()
        let chatsMetaInfo = ["title": "chat"]
        let membersRef = Constants.refs.databaseChatMembers.child(chatRef.key)
        let members = [getCurrentUser().id: getCurrentUser().displayName, contact.id: contact.displayName]
        membersRef.setValue(members)
        chatRef.setValue(chatsMetaInfo)
        defaults.set(chatRef.key, forKey: contact.id)
        return chatRef.key
    }
    
    static func uploadPhoto(image: UIImage, completion: @escaping (_ url: String?) -> Void) {
        let photoRef = Constants.refs.storageRef.child(UUID().uuidString)
        if let uploadData = UIImagePNGRepresentation(image) {
            photoRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil {
                    print("Uploading failed")
                    completion(nil)
                } else {
                    completion(metaData?.downloadURL()?.absoluteString)
                }
            })
        }
    }
    
    static func addMessage(sender: Sender, chatKey: String, text: String?) {
        
        let messageRef = Constants.refs.databaseMessages
        let messageChatRef = messageRef.child(chatKey)
        let messageFirebase = [Constants.messages.senderName: sender.displayName,
                               Constants.messages.message: text,
                               Constants.messages.timestamp: ServerValue.timestamp().description,
                               Constants.messages.senderId: sender.id]
        messageRef.child(messageChatRef.key).childByAutoId().setValue(messageFirebase)
    }
}

