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

    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showAlert(_ sender: UIButton) {
        if UserDefaults.standard.string(forKey: Constants.userDefaults.userID) != nil {
            performSegue(withIdentifier: Constants.segues.chooseContactVC, sender: self)
        } else {
            showDisplayNameDialog(sender)
        }
    }
    
    func showDisplayNameDialog(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        switch sender {
        case childButton:
            let contact = getSender("Child")
            saveCurrentUser(contact)
        case dadButton:
            let contact = getSender("Dad")
            saveCurrentUser(contact)
        case momButton:
            let contact = getSender("Mom")
            saveCurrentUser(contact)
        case nannyButton:
            let contact = getSender("Nanny")
            saveCurrentUser(contact)
        default:
            fatalError("Unknown button triggered")
        }
        
//        let alert = UIAlertController(title: "Create user", message: "Please choose your user name.", preferredStyle: .alert)
//        alert.addTextField { textField in textField.placeholder = "Enter name here" }
//        
//        alert.addAction(UIAlertAction(title: "DONE", style: .default, handler: { [weak self, weak alert] _ in
//            let textField = alert?.textFields![0]
//            let ref = Constants.refs.databaseUsers.childByAutoId()
//            print("*****New user with ID: \(ref.key)")
//                
//            defaults.set(textField?.text, forKey: Constants.userDefaults.userName)
//            defaults.set(ref.key, forKey: Constants.userDefaults.userID)
//                
//            let userFirebase = ["name": textField!.text!, "id": ref.key] as [String : String]
//            ref.setValue(userFirebase)
//            self?.performSegue(withIdentifier: Constants.segues.chooseContactVC, sender: self)
//        }))
//        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.chooseContactVC {
            let contactsViewController = segue.destination as! PageViewController
            contactsViewController.contacts = self.contacts
        } else {
            print("Unknow segue triggered")
        }

    }
    
    func saveCurrentUser(_ currentUser: Sender) {
        let defaults = UserDefaults.standard
        defaults.set(currentUser.displayName , forKey: Constants.userDefaults.userName)
        defaults.set(currentUser.id, forKey: Constants.userDefaults.userID)
    }
    
    func getSender(_ name: String) -> Sender {
        let sender = (contacts?.filter { $0.displayName == name })?.first
//        contacts.filter { $0.id != UserDefaults.standard.string(forKey: Constants.userDefaults.userID) }
        return sender!
    }
 

    // MARK: - Actions
    @IBAction func unwindToSignIn(sender: UIStoryboardSegue) {
        
    }
    
    func loadContacts() {
        FirebaseData.observeUsers { contacts in
            self.contacts = contacts
            print("The contacts are: \(String(describing: self.contacts!))")
        }
    }
}
