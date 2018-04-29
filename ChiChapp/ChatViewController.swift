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
import ISEmojiView

class ChatViewController: MessagesViewController, ISEmojiViewDelegate {
    
    var messages: [MessageType] = []
    var currentUser: Sender!
    var contact: Sender!
    var chatKey: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        let emojiView = ISEmojiView()
        emojiView.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.inputView = emojiView
        loadUserDefaults()
        loadMessagesFromFirebase()

    }
    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper methods

    func loadMessagesFromFirebase() {
        FirebaseData.observeMessages(contact){ messages in
            self.messages = messages
            if self.messages.count > 0 {
                self.messagesCollectionView.insertSections([messages.count - 1])
            }
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    func loadUserDefaults() {
        print("Loading user defaults")
        let defaults = UserDefaults.standard
        chatKey = defaults.string(forKey: Constants.userDefaults.chatKey)

        if let id = defaults.string(forKey: Constants.userDefaults.userID),
            let name = defaults.string(forKey: Constants.userDefaults.userName) {
            currentUser = Sender(id: id, displayName: name)
            title = "Chat: \(contact.displayName)"
        }
    }
    
    // MARK: Emoji methods
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        messageInputBar.inputTextView.insertText(emoji)
    }
    
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        messageInputBar.inputTextView.deleteBackward()
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
                let messageChatRef = messageRef.child(chatKey)
                let messageFirebase = [Constants.messages.senderName: currentSender().displayName,
                                       Constants.messages.message: text,
                                       Constants.messages.timestamp: ServerValue.timestamp().description,
                                       Constants.messages.senderId: currentSender().id]
                messageRef.child(messageChatRef.key).childByAutoId().setValue(messageFirebase)
                
            }
        }
        inputBar.inputTextView.text = String()
    }
}
