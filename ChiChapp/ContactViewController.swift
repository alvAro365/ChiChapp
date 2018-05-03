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
    @IBOutlet weak var contactImage: UIImageView!
    var backGroundColor: UIColor?
    var image: UIImage?
    var contact: Sender!
    var contacts: [Sender]!
    var defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        setContactImage()
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
    
    @IBAction func onBackArrowClick(_ sender: Any) {
        
        _ = navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func chatWiht(_ button: UIButton) {
        let chatKey = defaults.string(forKey: contact!.id)
        defaults.set(chatKey, forKey: Constants.userDefaults.chatKey)
        self.performSegue(withIdentifier: Constants.segues.toChatVC, sender: nil)
    }
    
    func setContactImage() {
        switch contact!.displayName {
        case "Dad":
            contactImage.image = #imageLiteral(resourceName: "dad")
        case "Mom":
            contactImage.image = #imageLiteral(resourceName: "mom")
        case "Nanny":
            contactImage.image = #imageLiteral(resourceName: "nanny")
        default:
            contactImage.image = #imageLiteral(resourceName: "dad")
        }
    }
}

