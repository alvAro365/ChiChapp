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
        if UserDefaults.standard.string(forKey: Constants.userDefaults.userID) != nil {
            performSegue(withIdentifier: Constants.segues.chooseContactVC, sender: self)
        } else {
            showDisplayNameDialog()
        }
    }
    
    func showDisplayNameDialog() {
        let defaults = UserDefaults.standard
        
        let alert = UIAlertController(title: "Create user", message: "Please choose your user name.", preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = "Enter name here" }
        
        alert.addAction(UIAlertAction(title: "DONE", style: .default, handler: { [weak self, weak alert] _ in
            let textField = alert?.textFields![0]
            let ref = Constants.refs.databaseUsers.childByAutoId()
            print("*****New user with ID: \(ref.key)")
                
            defaults.set(textField?.text, forKey: Constants.userDefaults.userName)
            defaults.set(ref.key, forKey: Constants.userDefaults.userID)
                
            let userFirebase = ["name": textField!.text!, "id": ref.key] as [String : String]
            ref.setValue(userFirebase)
            self?.performSegue(withIdentifier: Constants.segues.chooseContactVC, sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

    }
 

    // MARK: - Actions
    @IBAction func unwindToSignIn(sender: UIStoryboardSegue) {
        
    }
}
