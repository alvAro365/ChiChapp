//
//  ChooseContactViewController.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 21/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import MessageKit
import Firebase

class ChooseContactViewController: UIViewController {
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
//    var data: FirebaseData!
    var contacts: [Sender]!
//    var chatKey: String?
    var contact: Sender?
    var currentUser: Sender!
    var contactsWithoutCurrentUser: [Sender]!
    override func viewDidLoad() {
        super.viewDidLoad()
//        data = FirebaseData()
//        loadUserDefaults()
        loadContacts()
//        chatKey = getChatKey()
    }
    

    // MARK: Actions
    @IBAction func chatWith(_ button: UIButton) {
        let defaults = UserDefaults.standard
        switch button {
        case button1:
            print("Button1 pressed")
            self.getChatKey()
            let chat = defaults.string(forKey: Constants.userDefaults.chatKey)

            
//            print("The chat key is: \(String(describing: chat))")
//            let chat = Constants.refs.databaseChats.childByAutoId().key
//            defaults.set(chat, forKey: Constants.userDefaults.chatKey)
//            let currentUserId = UserDefaults.standard.string(forKey: Constants.userDefaults.userID)
            

//            Constants.refs.databaseUsers.child(currentUserId!).child("chats").setValue([(contact?.id)!: chat])
//            Constants.refs.databaseUsers.child((contact?.id)!).child("chats").setValue([currentUserId!: chat])
//            performSegue(withIdentifier: Constants.segues.toChatVC, sender: nil)
            if chat == nil {
                let chat = Constants.refs.databaseChats.childByAutoId().key
                defaults.set(chat, forKey: Constants.userDefaults.chatKey)
                let currentUserId = UserDefaults.standard.string(forKey: Constants.userDefaults.userID)
                // Adds chat key under current user in database
                _ = Constants.refs.databaseUsers.child(currentUserId!).child("chats").setValue([(contact?.id)!: chat])
                _ = Constants.refs.databaseUsers.child((contact?.id)!).child("chats").setValue([currentUserId!: chat])
                performSegue(withIdentifier: Constants.segues.toChatVC, sender: nil)

            } else {
//                defaults.set(chatKey, forKey: Constants.userDefaults.chatKey)
                performSegue(withIdentifier: Constants.segues.toChatVC, sender: nil)
            }
        default:
            fatalError("Unknown button pressed")
        }
    }
    
    // MARK: Private methods
    func loadUserDefaults() {
        print("Loading user defaults")
        let defaults = UserDefaults.standard
        if let id = defaults.string(forKey: Constants.userDefaults.userID),
            let name = defaults.string(forKey: Constants.userDefaults.userName) {
            currentUser = Sender(id: id, displayName: name)
            title = "Chat: \(String(describing: contact?.displayName))"
        }
    }
    func createChat() {
        let defaults = UserDefaults.standard
        let chat = defaults.string(forKey: Constants.userDefaults.chatKey)
        let chatsRef = Constants.refs.databaseChats.child(chat!)
        let membersRef = Constants.refs.databaseChatMembers.child(chat!)
        let members = [currentUser.id: currentUser.displayName, (contact?.id)!: contact?.displayName]
        let chatsMetaInfo = ["title": currentUser.displayName + " \(String(describing: contact?.displayName))" ]
        membersRef.setValue(members)
        chatsRef.setValue(chatsMetaInfo)
    }
    
    func loadContacts() {
        FirebaseData.observeUsers { contacts in
            self.contacts = contacts
            print("The contacts are: \(String(describing: self.contacts!))")
            self.showContacts()
//            self.getChatKey()
        }
    }
    
    
    
    func getChatKey() {
        print("Getting chat key")
        let defaults = UserDefaults.standard
        let currentUserId = defaults.string(forKey: Constants.userDefaults.userID)
        FirebaseData.getChatId(currentUserId: currentUserId!, contactId: contact?.id)
    }
    
    func showContacts() {
        contactsWithoutCurrentUser = contacts.filter { $0.id != UserDefaults.standard.string(forKey: Constants.userDefaults.userID) }

        if contactsWithoutCurrentUser.count > 0 {
            button1.isEnabled = true
            contact = contactsWithoutCurrentUser[0]
            print("The Contact is: \(String(describing: contact))")
            button1.setTitle(contact?.displayName, for: .normal)
        } else {
            button1.isEnabled = false
            button1.setTitle("No contacts", for: .disabled)
        }
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.toChatVC {
            
            let navigationController = segue.destination as! UINavigationController
            let chatVC = navigationController.topViewController as! ChatViewController
            chatVC.contact = contact
        }
    }

}
