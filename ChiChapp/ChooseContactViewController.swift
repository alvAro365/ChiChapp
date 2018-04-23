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
    var data: FirebaseData!
    var contacts: [Sender]!
    var contact: Sender!
    var contactsWithoutCurrentUser: [Sender]!
    override func viewDidLoad() {
        super.viewDidLoad()
        data = FirebaseData()
        loadContacts()
    }
    

    // MARK: Actions
    @IBAction func chatWith(_ button: UIButton) {
        let defaults = UserDefaults.standard
        switch button {
        case button1:
            // Gets contact id
            contact = contactsWithoutCurrentUser[0]
            
            // Checks if chat already exists. If not then we'll create a new chat otherwise we use existing chat
            if defaults.string(forKey: Constants.userDefaults.chatOneKey) == nil {
                let chatKey = Constants.refs.databaseChats.childByAutoId().key
                let currentUserId = UserDefaults.standard.string(forKey: Constants.userDefaults.userID)
                // Adds chat key under current user in database
                _ = Constants.refs.databaseUsers.child(currentUserId!).child("chats").setValue([contact.id: chatKey])
                _ = Constants.refs.databaseUsers.child(contact.id).child("chats").setValue([currentUserId!: chatKey])
                defaults.set(chatKey, forKey: Constants.userDefaults.chatOneKey)

            }
        default:
            fatalError("Unknown button pressed")
        }

//        if defaults.string(forKey: Constants.userDefaults.chatKey) == nil {
//            let chatKey = Constants.refs.databaseChats.childByAutoId().key
//            defaults.set(chatKey, forKey: Constants.userDefaults.chatKey)
//        }
        performSegue(withIdentifier: Constants.segues.toChatVC, sender: nil)
    }
    
    // MARK: Private methods
    func loadContacts() {
        data.observeContacts { contacts in
            self.contacts = contacts
            print("The contacts are: \(self.contacts!)")
            self.showContacts()
        }
    }
    
    func showContacts() {
        contactsWithoutCurrentUser = contacts.filter { $0.id != UserDefaults.standard.string(forKey: Constants.userDefaults.userID)
        }
        if contactsWithoutCurrentUser.count == 1 {
            button1.isEnabled = true
            button1.setTitle(contactsWithoutCurrentUser[0].displayName, for: .normal)
        } else {
            button1.isEnabled = false
            button1.setTitle("No contacts", for: .disabled)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.segues.toChatVC {
            let navigationController = segue.destination as! UINavigationController
            let chatVC = navigationController.topViewController as! ChatViewController
            chatVC.contact = contact
        }
    }

}
