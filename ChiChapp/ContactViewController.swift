//
//  ContactViewController.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 27/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import MessageKit

class ContactViewController: UIViewController {

    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton!
    var contact: String?
    var backGroundColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        contactLabel.text = contact
        contactButton.setTitle(contact, for: .normal)
        self.view.backgroundColor = backGroundColor
        // Do any additional setup after loading the view.
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
    }
    
    @IBAction func unwindToContacts(sender: UIStoryboardSegue) {
        
    }
}

