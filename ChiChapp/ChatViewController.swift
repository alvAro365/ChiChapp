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

class ChatViewController: MessagesViewController, ISEmojiViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var takePhoto: UIBarButtonItem!
    var photo: UIImage?
    var messages: [MessageType] = []
    var currentUser: Sender!
    var contact: Sender!
    var chatKey: String!
    var imagePath: String?
    var avatarImage: UIImage?

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
        if avatarImage == nil {
            setAvatarImage(name: contact.displayName)
        }
        setNavigationBarImage()

    }
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .savedPhotosAlbum
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            photo = image
            FirebaseData.uploadPhoto(image: photo!, completion: { (url) in
                if url != nil {
                    print("Uploading succeeded: \(String(describing: url))")
                    self.imagePath = url
                    FirebaseData.addMessage(sender: self.currentSender(), chatKey: self.chatKey, text: url!)
                }
            })
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper methods
    
    func setNavigationBarImage() {
        let imageView = UIImageView(image: avatarImage)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }

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
        }
    }
    
    func setAvatarImage(name: String) {
        switch name {
        case "Dad":
            avatarImage = #imageLiteral(resourceName: "dad")
        case "Mom":
            avatarImage = #imageLiteral(resourceName: "mom")
        case "Nanny":
            avatarImage = #imageLiteral(resourceName: "nanny")
        case "Child":
            avatarImage = #imageLiteral(resourceName: "kid")
        default:
            avatarImage = #imageLiteral(resourceName: "if_chat_36465")
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
    
}

// MARK: Extensions

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
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(image: avatarImage, initials: ""))
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                FirebaseData.addMessage(sender: currentSender(), chatKey: chatKey, text: text)
            }
            inputBar.inputTextView.text = String()
        }
    }
}

