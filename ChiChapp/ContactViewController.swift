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
    var defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        contactButton.setTitle(contact?.displayName, for: .normal)
        self.view.backgroundColor = backGroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.toChatVC {
            let chatNavigationController = segue.destination as! UINavigationController
            let chatViewController = chatNavigationController.topViewController as! ChatViewController
            chatViewController.contact = contact
        }
    }
    
    @IBAction func chatWiht(_ button: UIButton) {
        let chatKey = defaults.string(forKey: contact!.id)
        defaults.set(chatKey, forKey: Constants.userDefaults.chatKey)
        self.performSegue(withIdentifier: Constants.segues.toChatVC, sender: nil)
    }
}

