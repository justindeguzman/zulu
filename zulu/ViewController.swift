//
//  ViewController.swift
//  zulu
//
//  Created by Justin de Guzman on 11/17/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import UIKit
import CoreData

import AddressBook
import AddressBookUI

class ViewController: UIViewController, UITableViewDelegate,
UITableViewDataSource {
  
  lazy var managedObjectContext : NSManagedObjectContext? = {
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    if let managedObjectContext = appDelegate.managedObjectContext {
      return managedObjectContext
    } else {
      return nil
    }
  }()
  
  let addressBook = APAddressBook()
  var logoDidMoveUp = false
  
 /**
  * UI Elements.
  */
  
  @IBOutlet weak var logo: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  /**
   * Constraints.
   */
  
  @IBOutlet weak var logoYConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.fetchAddressBookData()
    
    // Add an event handler to load contacts when the app opens
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector:"fetchAddressBookData",
      name: UIApplicationWillEnterForegroundNotification, object: nil)
  }
  
  /**
   * Fetches the contact data from the address book.
   *
   * @param contact The contact to be saved.
   */

  func saveContact(contact : APContact) {
    let row = NSEntityDescription.insertNewObjectForEntityForName(
      "Contact", inManagedObjectContext: self.managedObjectContext!
      ) as Contact
    
    if(contact.firstName != nil && contact.firstName != "") {
      row.firstName = contact.firstName
      print("\(row.firstName) ")
    }
    
    if(contact.lastName != nil && contact.lastName != "") {
      row.lastName = contact.lastName
      print("\(row.lastName) ")
    }
    
    if(contact.phones != nil && contact.phones.count > 0) {
      row.phone = contact.phones[0] as String
      print("\(contact.phones[0]) ")
    }
    
    if(contact.emails != nil && contact.emails.count > 0) {
      row.email = contact.emails[0] as String
      print("\(contact.emails[0]) ")
    }
    
    print("\n")
  }
  
 /**
  * Fetches the contact data from the address book.
  */
  
  func fetchAddressBookData() {
    // Specify the address book fields to fetch
    self.addressBook.fieldsMask =
      APContactField.FirstName |
      APContactField.LastName  |
      APContactField.Phones    |
      APContactField.Photo     |
      APContactField.Emails
    
    self.addressBook.loadContacts({
      (contacts: [AnyObject]!, error: NSError!) in
      
      if (contacts != nil) {
        self.moveLogoUp()
        
        for contact in contacts {
          self.saveContact(contact as APContact)
        }
      } else if (error != nil) {
        var alert = UIAlertController(
          title: "Error",
          message: "Could not load contacts.",
          preferredStyle: UIAlertControllerStyle.Alert
        )
        
        alert.addAction(UIAlertAction(
          title: "Ok",
          style: UIAlertActionStyle.Default,
          handler: nil)
        )
        
        self.presentViewController(alert, animated: true, completion: nil)
      }
    })
  }
  
  /**
   * Animates the logo to the top of the view.
   */
  
  func moveLogoUp() {
    if(!self.logoDidMoveUp) {
      self.logoDidMoveUp = true
      
      self.view.layoutIfNeeded()
      let modifier : CGFloat = 0.7
      
      UIView.animateWithDuration(0.4,
        animations: {
          self.logo.transform = CGAffineTransformScale(
            self.logo.transform, modifier, modifier
          )
          self.view.layoutIfNeeded()
        }, completion: { finished in
          UIView.animateWithDuration(0.4,
            animations: {
              self.logoYConstraint.constant -= 130.0
              self.view.layoutIfNeeded()
            }, completion: { finished in
              UIView.animateWithDuration(0.4, animations: {
                self.tableView.alpha = 1.0
              })
            }
          )
          
        }
      )
    }
  }
  
  /**
  * TableViewDataSource
  */
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:
    NSIndexPath) -> UITableViewCell {
      return UITableViewCell.alloc()
      
  }
}
