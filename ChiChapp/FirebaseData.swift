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

    func observeMessages(completion: @escaping ([MessageType]) -> Void) {
        var messages =  [MessageType]()
        let query = Constants.refs.databaseMessages.child(UserDefaults.standard.string(forKey: Constants.userDefaults.chatOneKey)!).queryLimited(toLast: 5)
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
    
    func observeContacts(completion: @escaping ([Sender]) -> Void) {
        var contacts = [Sender]()
        let usersRef = Constants.refs.databaseUsers
        _  = usersRef.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: String],
                let displayName = data[Constants.user.displayName],
                let id = data[Constants.user.id] {
                let user = Sender(id: id, displayName: displayName)
                contacts.append(user)
            }
            completion(contacts)
        })
    }
 /*
    func addContactWithChatId() -> <#return type#> {
        <#function body#>
    }
    */
}
