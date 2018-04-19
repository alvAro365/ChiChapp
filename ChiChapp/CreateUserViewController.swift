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
    
    var userName: String!
    var userId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showAlert(_ sender: UIButton) {
        showDisplayNameDialog()
    }
    
    func showDisplayNameDialog() {
        let defaults = UserDefaults.standard
        
        let alert = UIAlertController(title: "Create user", message: "Please choose your user name.", preferredStyle: .alert)
        alert.addTextField { textField in
            if let name = defaults.string(forKey: Constants.userDefaults.userName) {
                textField.text = name
            } else {
                textField.text = ""
            }
        }
        alert.addAction(UIAlertAction(title: "DONE", style: .default, handler: { [weak self, weak alert] _ in
            if let textField = alert?.textFields![0], !textField.text!.isEmpty {
                self?.userName = textField.text
                
                defaults.set(textField.text, forKey: Constants.userDefaults.userName)
                
                if defaults.string(forKey: Constants.userDefaults.userID) == nil {
                    defaults.set(UUID().uuidString, forKey: Constants.userDefaults.userID)
                }
                self?.performSegue(withIdentifier: Constants.segues.toChatVC, sender: self)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.toChatVC {

        }
    }
}
