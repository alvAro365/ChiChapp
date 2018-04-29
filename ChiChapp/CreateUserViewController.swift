//
//  CreateUserViewController.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 19/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import MessageKit
import Firebase

class CreateUserViewController: UIViewController {
    @IBOutlet weak var childButton: UIButton!
    @IBOutlet weak var dadButton: UIButton!
    @IBOutlet weak var momButton: UIButton!
    @IBOutlet weak var nannyButton: UIButton!
    
    var userName: String!
    var userId: String!
    var contacts: [Sender]?
    var contact: Sender?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showAlert(_ sender: UIButton) {
        switch sender {
        case childButton:
            performSegue(withIdentifier: Constants.segues.chooseContactVC, sender: self)
        case dadButton:
            contact = getSender("Dad")
            saveCurrentUser(contact!)
            performSegue(withIdentifier: Constants.segues.userToChat, sender: self)
        case momButton:
            contact = getSender("Mom")
            saveCurrentUser(contact!)
            performSegue(withIdentifier: Constants.segues.userToChat, sender: self)
        case nannyButton:
            contact = getSender("Nanny")
            saveCurrentUser(contact!)
            performSegue(withIdentifier: Constants.segues.userToChat, sender: self)
        default:
            fatalError("Unknown button pressed")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.chooseContactVC {
            let contactsViewController = segue.destination as! PageViewController
            contactsViewController.contacts = self.contacts
        } else if segue.identifier == Constants.segues.userToChat {
            let chatNavigationController = segue.destination as! UINavigationController
            let chatViewController = chatNavigationController.topViewController as! ChatViewController
            chatViewController.contact = contact
            
        } else {
            print("Unknow segue triggered")
        }
    }
    
    func saveCurrentUser(_ currentUser: Sender) {
        let defaults = UserDefaults.standard
        defaults.set(currentUser.displayName , forKey: Constants.userDefaults.userName)
        defaults.set(currentUser.id, forKey: Constants.userDefaults.userID)
        let chatKey = defaults.string(forKey: currentUser.id)
        defaults.set(chatKey, forKey: Constants.userDefaults.chatKey)
        
    }
    
    func getSender(_ name: String) -> Sender {
        let sender = (contacts?.filter { $0.displayName == name })?.first
        return sender!
    }

    func loadContacts() {
        FirebaseData.observeUsers { contacts in
            self.contacts = contacts
            print("The contacts are: \(String(describing: self.contacts!))")
        }
    }
}
