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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUserDefaults()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        observeFirebase()
    }
    
    func setUserDefaults() {
        let defaults = UserDefaults.standard

        if let id = defaults.string(forKey: Constants.userDefaults.userID),
            let name = defaults.string(forKey: Constants.userDefaults.userName) {
            currentUser = Sender(id: id, displayName: name)
        } else {
            userID = String(arc4random_uniform(999999))
            userName = ""
            currentUser = Sender(id: userID, displayName: userName)

            defaults.set(userID, forKey: Constants.userDefaults.userID)
        }
        title = "Chat: \(currentSender().displayName)"

    }
    
    func observeFirebase() {
        let query = Constants.refs.databaseChats.queryLimited(toLast: 10)
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if let data = snapshot.value as? [String: String],
                let id = data["sender_id"],
                let name = data["name"],
                let text = data["text"],
                let messageId = data["message_id"],
                !text.isEmpty {
                
                let sender = Sender(id: id, displayName: name)
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 50), .foregroundColor: UIColor.blue ])
                let message = ChatMessage(attributedText: attributedText, sender: sender, messageId: messageId, date: Date())
                self?.messages.append(message)
                self?.messagesCollectionView.insertSections([(self?.messages.count)! - 1])
                self?.messagesCollectionView.scrollToBottom()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
        print("Send button clicked")
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                let imageMessage = ChatMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messages.append(imageMessage)
                messagesCollectionView.insertSections([messages.count - 1])
            } else if let text = component as? String {
                // Firebase
                let ref = Constants.refs.databaseChats.childByAutoId()
                let messageFirebase = ["sender_id": currentSender().id, "name": currentSender().displayName, "text": text, "message_id": UUID().uuidString]
                ref.setValue(messageFirebase)
            }
        }
        inputBar.inputTextView.text = String()
    }
}
