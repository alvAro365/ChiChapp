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

class Firebase {

    func observeFirebase(completion: @escaping ([MessageType]) -> Void) {
        var messages =  [MessageType]()
        let query = Constants.refs.databaseChats.queryLimited(toLast: 10)
        _ = query.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: String],
                let id = data["sender_id"],
                let name = data["name"],
                let text = data["text"],
                let messageId = data["message_id"],
                !text.isEmpty {
                
                let sender = Sender(id: id, displayName: name)
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 50), .foregroundColor: UIColor.blue ])
                let message = ChatMessage(attributedText: attributedText, sender: sender, messageId: messageId, date: Date())
                messages.append(message)
            }
            completion(messages)
        })
    }
}
