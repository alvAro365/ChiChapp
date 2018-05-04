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
    var currentSender: Sender?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func chooseUser(_ sender: UIButton) {
        switch sender {
        case childButton:
            performSegue(to: Constants.segues.chooseContactVC)
        case dadButton:
            currentSender = getSender("Dad")
            saveCurrentUser(currentSender!)
            performSegue(to: Constants.segues.userToChat)
        case momButton:
            currentSender = getSender("Mom")
            saveCurrentUser(currentSender!)
            performSegue(to: Constants.segues.userToChat)
        case nannyButton:
            currentSender = getSender("Nanny")
            saveCurrentUser(currentSender!)
            performSegue(to: Constants.segues.userToChat)
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
            chatViewController.contact = currentSender
            chatViewController.avatarImage = #imageLiteral(resourceName: "kid")

        } else {
            print("Unknow segue triggered")
        }
    }
    
    // MARK: Helper methods
    func setUsersButtonState() {
        
        let currentUser = FirebaseData.getCurrentUser()
        
        if (currentUser != nil) && currentUser?.displayName == "Child" {
            dadButton.isEnabled = false
            momButton.isEnabled = false
            nannyButton.isEnabled = false
        } else {
            childButton.isEnabled = false
        }

    }
    
    func performSegue(to viewController: String) {
        performSegue(withIdentifier: viewController, sender: self)
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
            self.setUsersButtonState()
        }
    }
}
