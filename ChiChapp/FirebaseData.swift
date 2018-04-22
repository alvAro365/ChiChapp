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

    func observeFirebase(completion: @escaping ([MessageType]) -> Void) {
        var messages =  [MessageType]()
        /*
        let query = Constants.refs.databaseChats.queryLimited(toLast: 10)
        _ = query.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: String],
                let senderID  = data["title"] {
                
                let sender = Sender(id: senderID , displayName: "Alvar")
                
                let attributedText = NSAttributedString(string: senderID, attributes: [.font: UIFont.systemFont(ofSize: 50), .foregroundColor: UIColor.blue ])
                let message = ChatMessage(attributedText: attributedText, sender: sender, messageId: "1234", date: Date())
                messages.append(message)
            }
            completion(messages)
        })
 */

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
}
