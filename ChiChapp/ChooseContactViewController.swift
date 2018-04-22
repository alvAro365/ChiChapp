//
//  ChooseContactViewController.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 21/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import Firebase

class ChooseContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    @IBAction func chatWith(_ sender: UIButton) {
        let defaults = UserDefaults.standard

        if defaults.string(forKey: Constants.userDefaults.chatKey) == nil {
            let chatKey = Constants.refs.databaseChats.childByAutoId().key
            defaults.set(chatKey, forKey: Constants.userDefaults.chatKey)
        }
        performSegue(withIdentifier: Constants.segues.toChatVC, sender: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
