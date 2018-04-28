//
//  ContactViewController.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 27/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import Firebase
import MessageKit

class ContactViewController: UIViewController {

    @IBOutlet weak var contactButton: UIButton!
    var backGroundColor: UIColor?
    var contact: Sender?
    var contacts: [Sender]!

    override func viewDidLoad() {
        super.viewDidLoad()
        contactButton.setTitle(contact?.displayName, for: .normal)
        self.view.backgroundColor = backGroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.toChatVC {
            let chatNavigationController = segue.destination as! UINavigationController
            let chatViewController = chatNavigationController.topViewController as! ChatViewController
            chatViewController.contact = contact
        }
    }
    
    @IBAction func chatWiht(_ button: UIButton) {
        getChatKey()
        
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
    


    @IBAction func unwindToContacts(sender: UIStoryboardSegue) {
        
    }
}

