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
  var savedContacts = [Contact]()
  var cellHeights = [CGFloat]()

  
 /**
  * UI Elements.
  */
  
  @IBOutlet weak var logo: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
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
   * Loads the table view data from core data.
   *
   * @param contact The contact to be saved.
   */
  
  func loadTableData() {
    let fetchRequest = NSFetchRequest(entityName: "Contact")
    
    let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    if let fetchResults = managedObjectContext!.executeFetchRequest(
      fetchRequest, error: nil) as? [Contact] {
      savedContacts = fetchResults
    }
    
    cellHeights = [CGFloat](count: savedContacts.count, repeatedValue: 150.0)
    
    self.tableView.reloadData()
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
    }
    
    if(contact.lastName != nil && contact.lastName != "") {
      row.lastName = contact.lastName
    }
    
    if(contact.phones != nil && contact.phones.count > 0) {
      row.phone = (contact.phones[0] as String)
    }
    
    if(contact.emails != nil && contact.emails.count > 0) {
      row.email = (contact.emails[0] as String)
    }
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
        
        self.loadTableData()
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
                self.searchBar.alpha = 1.0
              })
            }
          )
          
        }
      )
    }
  }
  
  /**
   * Table View Delegate
   */
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:
    NSIndexPath) {
      let currentHeight = cellHeights[indexPath.row]
      var cell = tableView.cellForRowAtIndexPath(indexPath) as ContactCell
      
      if(currentHeight > 150.0) {
        cellHeights[indexPath.row] = 150.0
        
        // Delay hiding the cell contents to allow the cell to collapse
        dispatch_after(
          dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(0.2 * Double(NSEC_PER_SEC))
          ),
          dispatch_get_main_queue(), {
            cell.buttonCall.hidden = true
            cell.buttonMessage.hidden = true
            cell.buttonEmail.hidden = true
        })
      } else {
        cellHeights[indexPath.row] = 200.0
        cell.buttonCall.hidden = false
        cell.buttonMessage.hidden = false
        cell.buttonEmail.hidden = false
      }
      
      self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
      
      self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
      self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

      self.tableView.beginUpdates()
      self.tableView.endUpdates()
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath
    indexPath: NSIndexPath) -> CGFloat {
    if(self.savedContacts.count > 0) {
      return cellHeights[indexPath.row]
    }
    
    return 0.0
  }
  
 /**
  * Table View Data Source
  */
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
//      return 10
      return savedContacts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:
    NSIndexPath) -> UITableViewCell {
      var cell = tableView.dequeueReusableCellWithIdentifier("ContactCell")
        as ContactCell
      
      // Make profile picture a circle
      cell.profilePicture.layer.cornerRadius =
        cell.profilePicture.frame.size.height / 2
      cell.profilePicture.layer.masksToBounds = true
      cell.profilePicture.layer.borderWidth = 0
      
      if(savedContacts.count > 0) {
        var name = ""
        
        let contact = savedContacts[indexPath.row]
        
        if(contact.firstName != nil) {
          name += contact.firstName!
        }
        
        if(contact.lastName != nil) {
          name += " " + contact.lastName!
        }
        
        cell.name.text = name
        
        if(contact.phone != nil) {
          cell.buttonCall.titleLabel?.text = contact.phone!
          cell.buttonMessage.titleLabel?.text = contact.phone!
        } else {
          cell.buttonCall.userInteractionEnabled = false
          cell.buttonMessage.userInteractionEnabled = false
        }
        
        if(contact.email != nil) {
          cell.buttonEmail.titleLabel?.text = contact.email!
        } else {
          cell.buttonEmail.userInteractionEnabled = false
        }
      }
      
      return cell
  }
}
