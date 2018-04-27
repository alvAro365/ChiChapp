//
//  ChatMessage.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 18/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation
import MessageKit

struct ChatMessage: MessageType {
    var sender: Sender
    var messageId: String
    var sentDate: Date
    var data: MessageData
    
    init(sender: Sender, messageId: String, date: Date, data: MessageData) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.data = data
    }
    

    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
        self.init(sender: sender, messageId: messageId, date: date, data: .attributedText(attributedText))
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        self.init(sender: sender, messageId: messageId, date: date, data: .photo(image))
    }
    
}


