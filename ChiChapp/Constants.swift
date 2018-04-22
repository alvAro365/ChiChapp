//
//  Constants.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 18/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation
import Firebase

struct Constants {
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
        static let databaseUsers = databaseRoot.child("users")
        static let databaseChatMembers = databaseRoot.child("members")
        static let databaseMessages = databaseRoot.child("messages")
    }
    
    struct userDefaults {
        static let userName = "user_name"
        static let userID = "user_id"
        static let chatKey = "chat_key"
    }
    
    struct segues {
        static let toChatVC = "goToChat"
        static let chooseContactVC = "chooseContact"
    }
}
