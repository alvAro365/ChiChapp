//
//  PageViewController.swift
//  ChiChapp
//
//  Created by Alvar Aronija on 27/04/2018.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import Firebase
import MessageKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var pages = [UIViewController]()
    let pageControl = UIPageControl()
    var contacts: [Sender]!
    var contact: Sender?
    var contactsWithoutCurrentUser: [Sender]!
    let initialPage = 0
    
    // MARK: Delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex == 0 {
                return self.pages.last
            } else {
                return self.pages[viewControllerIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                return self.pages[viewControllerIndex + 1]
            } else {
                return self.pages.first
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // set the pageControl.currentPage to the index of the current viewController in pages
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.pages.index(of: viewControllers[0]) {
                self.pageControl.currentPage = viewControllerIndex
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        getContactsWithoutCurrentUser()
        initializeViewControllers()
        setupPageControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Helper methods
    func loadContacts() {
        FirebaseData.observeUsers { contacts in
                self.contacts = contacts
                print("The contacts are: \(String(describing: self.contacts!))")
                self.initializeViewControllers()
        }
    }
    
    func setupPageControl() {
        self.pageControl.frame = CGRect()
        self.pageControl.numberOfPages = self.pages.count
        self.pageControl.currentPageIndicatorTintColor = UIColor.white
        self.pageControl.pageIndicatorTintColor = UIColor.blue
        self.pageControl.currentPage = initialPage
        self.view.addSubview(self.pageControl)
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
        self.pageControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -20).isActive = true
        self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    func initializeViewControllers() {
        if contacts.count > 0 {
            for contact in contactsWithoutCurrentUser {
                let contactPage = self.storyboard?.instantiateViewController(withIdentifier: Constants.viewControllers.contact) as! ContactViewController
                contactPage.contact = contact
                self.pages.append(contactPage)
            }
            setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
            print("Initialized")
        }
    }
    func getContactsWithoutCurrentUser() {
        contactsWithoutCurrentUser = contacts.filter { $0.id != UserDefaults.standard.string(forKey: Constants.userDefaults.userID) }
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
