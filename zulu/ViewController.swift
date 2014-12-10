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
UITableViewDataSource, UISearchBarDelegate {
  
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
  var openedCells = [Bool]()
  var didAddNewContact = false

  
 /**
  * UI Elements.
  */
  
  @IBOutlet weak var logo: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var resultsLabel: UILabel!
  
  /**
   * Constraints.
   */
  
  @IBOutlet weak var logoYConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Register observers to know when the keyboard pops up
    NSNotificationCenter.defaultCenter().addObserver(self, selector:
      "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector:
      "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification,
      object: nil)
    
    // Close the keyboard when people click anywhere on the screen
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    
    tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0)
    
    self.fetchAddressBookData()
    
    // Add an event handler to load contacts when the app opens
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector:"fetchAddressBookData",
      name: UIApplicationWillEnterForegroundNotification, object: nil)
  }
  
  func keyboardWasShown(notification: NSNotification) {
    //    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    //    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight ) {
    //      CGSize origKeySize = keyboardSize;
    //      keyboardSize.height = origKeySize.width;
    //      keyboardSize.width = origKeySize.height;
    //    }
    //    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    //    scroller.contentInset = contentInsets;
    //    scroller.scrollIndicatorInsets = contentInsets;
    //
    //    // If active text field is hidden by keyboard, scroll it so it's visible
    //    // Your application might not need or want this behavior.
    //    CGRect rect = scroller.frame;
    //    rect.size.height -= keyboardSize.height;
    //    NSLog(@"Rect Size Height: %f", rect.size.height);
    //
    //    if (!CGRectContainsPoint(rect, activeField.frame.origin)) {
    //      CGPoint point = CGPointMake(0, activeField.frame.origin.y - keyboardSize.height);
    //      NSLog(@"Point Height: %f", point.y);
    //      [scroller setContentOffset:point animated:YES];
    //    }
  }
  
  func keyboardWillBeHidden(notification: NSNotification) {
    self.tableView.contentInset = UIEdgeInsetsZero
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  /**
   * Loads the table view data from core data.
   *
   * @param contact The contact to be saved.
   */
  
  func loadTableData() {
    let fetchRequest = NSFetchRequest(entityName: "Contact")
    let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true,
      selector: "caseInsensitiveCompare:")

    fetchRequest.sortDescriptors = [sortDescriptor]
    
    if let fetchResults = managedObjectContext!.executeFetchRequest(
      fetchRequest, error: nil) as? [Contact] {
      savedContacts = fetchResults
    }
    
    if(didAddNewContact) {
      openedCells = [Bool](count: savedContacts.count, repeatedValue: false)
      didAddNewContact = false
    }
    
    self.tableView.reloadData()
  }
  
  /**
   * Fetches the contact data from the address book.
   *
   * @param contact The contact to be saved.
   */

  func saveContact(contact : APContact) {
    var predicate : NSPredicate = NSPredicate()
    
    let containsFirstName = !Util.isEmptyString(contact.firstName)
    let containsLastName = !Util.isEmptyString(contact.lastName)
    
    if(containsFirstName && containsLastName) {
      predicate = NSPredicate(format: "firstName = %@ AND lastName = %@",
        argumentArray: [contact.firstName, contact.lastName])
    } else if(containsFirstName && !containsLastName) {
      NSPredicate(format: "firstName = %@", argumentArray: [contact.firstName])
    } else if(!containsFirstName && containsLastName) {
      NSPredicate(format: "lastName = %@", argumentArray: [contact.lastName])
    } else {
      return
    }
    
    // Check if the contact already exists
    let request = NSFetchRequest()
    request.entity =  NSEntityDescription.entityForName(
      "Contact", inManagedObjectContext: self.managedObjectContext!
    )
    request.predicate = predicate
    request.fetchLimit = 1

    var error: NSError?
    
    var containsContact = self.managedObjectContext!.countForFetchRequest(
      request, error: &error
    )
    
    if(containsContact == 0) {
      didAddNewContact = true
      
      let row = NSEntityDescription.insertNewObjectForEntityForName(
        "Contact", inManagedObjectContext: self.managedObjectContext!
        ) as Contact
      
      if(!Util.isEmptyString(contact.firstName)) {
        row.firstName = contact.firstName
        
//        if(contact.firstName == "Abhi") {
//          let tag = NSEntityDescription.insertNewObjectForEntityForName(
//          "Tag", inManagedObjectContext: self.managedObjectContext!
//          ) as Tag
//          tag.title = "engineer"
//          
//          row.mutableSetValueForKey("tags").addObject(tag)
//        }
      }
      
      if(!Util.isEmptyString(contact.lastName)) {
        row.lastName = contact.lastName
      }
      
      if(contact.phones != nil && contact.phones.count > 0) {
        row.phone = (contact.phones[0] as String)
      }
      
      if(contact.emails != nil && contact.emails.count > 0) {
        row.email = (contact.emails[0] as String)
      }
      
      if(contact.photo != nil) {
        row.photo = contact.photo
      }
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
  
//  func showHiddenCellElements(cell: ContactCell, show: Bool) {
//    cell.buttonCall.hidden = !show
//    cell.buttonMessage.hidden = !show
//    cell.buttonEmail.hidden = !show
//  }
  
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
      let cellIsOpened = openedCells[indexPath.row]
      var cell = tableView.cellForRowAtIndexPath(indexPath) as ContactCell
      
      if(cellIsOpened) {
        // Delay hiding the cell contents to allow the cell to collapse
        dispatch_after(
          dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(0.25 * Double(NSEC_PER_SEC))
          ),
          dispatch_get_main_queue(), {
            cell.buttonCall.hidden = true
            cell.buttonMessage.hidden = true
            cell.buttonEmail.hidden = true
        })
      } else {
        cell.showHiddenCellElements(true)
        
        if(cell.phoneNumber == "") {
          cell.buttonCall.alpha = 0.5
          cell.buttonMessage.alpha = 0.5
        }
        
        if(cell.email == "") {
          cell.buttonEmail.alpha = 0.5
        }
      }
      
      openedCells[indexPath.row] = !cellIsOpened

      self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
      
      self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
      self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

      self.tableView.beginUpdates()
      self.tableView.endUpdates()
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath
    indexPath: NSIndexPath) -> CGFloat {
    if(self.savedContacts.count > 0) {
      return openedCells[indexPath.row] ? 300.0 : 180.0
    }
    
    return 0.0
  }
    
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    var showResultsLabel = false
    
    let fetchRequest = NSFetchRequest(entityName: "Contact")
    
    let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true,
      selector: "caseInsensitiveCompare:")
    
    if(countElements(searchText) > 0) {
      let firstNamePredicate = NSPredicate(format: "firstName CONTAINS[c] %@", argumentArray: [searchText])
      let lastNamePredicate = NSPredicate(format: "lastName CONTAINS[c] %@", argumentArray: [searchText])
      
      let tagPredicateFormat = "ANY tags.title CONTAINS[c] '\(searchText)'"
      
      let tagPredicate = NSPredicate(format: tagPredicateFormat,
        argumentArray: [searchText])
      let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates:
        [firstNamePredicate, lastNamePredicate, tagPredicate])
      
      fetchRequest.predicate = compoundPredicate
      
      showResultsLabel = true
    }
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    if let fetchResults = managedObjectContext!.executeFetchRequest(
      fetchRequest, error: nil) as? [Contact] {
        savedContacts = fetchResults
    }
    
    openedCells = [Bool](count: savedContacts.count, repeatedValue: false)
    
    if(showResultsLabel) {
      resultsLabel.text = "\(savedContacts.count) Results"
      resultsLabel.hidden = false
    } else {
      resultsLabel.hidden = true
    }
    
    tableView.hidden = savedContacts.count == 0
    
    self.tableView.reloadData()
  }
  
 /**
  * Table View Data Source
  */
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      return savedContacts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:
    NSIndexPath) -> UITableViewCell {
      var cell = tableView.dequeueReusableCellWithIdentifier("ContactCell")
        as ContactCell
      
      // Make profile picture a circle
      Util.makeCircle(cell.profilePicture)
      
      // Make action buttons circles
      Util.makeCircle(cell.buttonCall)
      Util.makeCircle(cell.buttonMessage)
      Util.makeCircle(cell.buttonEmail)
      
      if(savedContacts.count > 0) {
        var name = ""
        
        let contact = savedContacts[indexPath.row]
        
        cell.contact = contact
        
        if(contact.firstName != nil) {
          name += contact.firstName!
        }
        
        if(contact.lastName != nil) {
          name += " " + contact.lastName!
        }
        
        cell.name.text = name
        
        if(contact.phone != nil) {
          cell.phoneNumber = contact.phone!
          cell.buttonCall.alpha = 1.0
          cell.buttonMessage.alpha = 1.0
        } else {
          cell.buttonCall.alpha = 0.5
          cell.buttonMessage.alpha = 0.5
        }
        
        if(contact.email != nil) {
          cell.email = contact.email!
          cell.buttonEmail.alpha = 1.0
        } else {
          cell.buttonEmail.alpha = 0.5
        }
        
        if(contact.photo != nil) {
          cell.profilePicture.image = (contact.photo as UIImage)
        } else {
          cell.profilePicture.image = UIImage(named: "default-profile")
        }
        
        cell.showHiddenCellElements(openedCells[indexPath.row])
      }
      
      return cell
  }
}
