//
//  ChatViewController.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 18/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import MessageKit
import Firebase

class ChatViewController: MessagesViewController {
    var messages: [MessageType] = []
    var userID: String!
    var userName: String!
    var currentUser: Sender!
    var data: Firebase!
    var chatsRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        data = Firebase()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        loadUserDefaults()
        createChat()
        loadMessagesFromFirebase()
        
    }
    
    // MARK: Private methods
    
    func createChat() {
        let membersRef = Constants.refs.databaseChatMembers.child(chatsRef.key)
        let members = [currentUser.id: currentUser.displayName, "secondUser": "Anonymys"]
        let chatsMetaInfo = ["title": currentUser.displayName + " and Anonymys" ]
        membersRef.setValue(members)
        chatsRef.setValue(chatsMetaInfo)
    }
    
    func loadMessagesFromFirebase() {
        data.observeFirebase { messages in
            self.messages = messages
            print("Messages: \(self.messages)")
            if self.messages.count > 0 {
                self.messagesCollectionView.insertSections([messages.count - 1])
            }
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    func loadUserDefaults() {
        let defaults = UserDefaults.standard
        let chatKey = defaults.string(forKey: Constants.userDefaults.chatKey)
        chatsRef = Constants.refs.databaseChats.child(chatKey!)
        
        if let id = defaults.string(forKey: Constants.userDefaults.userID),
            let name = defaults.string(forKey: Constants.userDefaults.userName) {
            currentUser = Sender(id: id, displayName: name)
            title = "Chat: \(currentSender().displayName)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return self.currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        avatarView.set(avatar: Avatar(image: #imageLiteral(resourceName: "AlvarPng") , initials: "AA"))
//    }
}

extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                let imageMessage = ChatMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messages.append(imageMessage)
                messagesCollectionView.insertSections([messages.count - 1])
            } else if let text = component as? String {
                // Firebase
                let messageRef = Constants.refs.databaseMessages
                let messageChatRef = messageRef.child(chatsRef.key)
                let messageFirebase = ["name": currentSender().id, "message": text, "timestamp": ServerValue.timestamp().description]
                messageRef.child(messageChatRef.key).childByAutoId().setValue(messageFirebase)
                
            }
        }
        inputBar.inputTextView.text = String()
    }
}
