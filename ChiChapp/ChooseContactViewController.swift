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
    var counter = 0
    var contacts: [Sender]!
    var chatKey: String?
    var contact: Sender?
    var currentUser: Sender!
    var contactsWithoutCurrentUser: [Sender]!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
    }

    // MARK: Actions
    @IBAction func chatWith(_ button: UIButton) {
        switch button {
        case button1:
            print("Button1 pressed")
            getChatKey()
        default:
            fatalError("Unknown button pressed")
        }
    }
    
    // MARK: Private methods

    func loadContacts() {
        FirebaseData.observeUsers { contacts in
            self.contacts = contacts
            print("The contacts are: \(String(describing: self.contacts!))")
            self.showContacts()
        }
    }

    func getChatKey() {
        print("Getting chat key")
        let defaults = UserDefaults.standard
        let currentUserId = defaults.string(forKey: Constants.userDefaults.userID)
        FirebaseData.getChatId(currentUserId: currentUserId!, contactId: contact?.id) { (success) in
            if success {
                print("success")
                self.performSegue(withIdentifier: Constants.segues.toChatVC, sender: nil)
            } else {
                print("failed")
            }
        }
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
