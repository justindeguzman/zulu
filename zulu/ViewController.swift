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

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource,
                      UISearchBarDelegate {
  
  // MARK: IBOutlets
  
  @IBOutlet weak var logo: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var resultsLabel: UILabel!
  
  // MARK: Constraints
  
  @IBOutlet weak var logoYConstraint: NSLayoutConstraint!
  
  // MARK: Instance Variables
  
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
  
  // MARK: Instance Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Close the keyboard when people click anywhere on the screen
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    
    // Add margin at the end of the table view
    tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0)
    
    // Load stored address book data from the phone
    self.fetchAddressBookData()
    
    // Add an event handler to load contacts again when the app opens
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector:"fetchAddressBookData",
      name: UIApplicationWillEnterForegroundNotification, object: nil)
  }
  
  /**
   * Loads the table view data from core data.
   *
   * @param closeCells Whether or not to close all of the table cells.
   */
  
  func loadTableData(closeCells: Bool) {
    let fetchRequest = NSFetchRequest(entityName: "Contact")
    
    // Sort results by last name
    let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true,
      selector: "caseInsensitiveCompare:")
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    if let fetchResults = managedObjectContext!.executeFetchRequest(
      fetchRequest, error: nil) as? [Contact] {
      savedContacts = fetchResults
    }
    
    if(closeCells) {
      openedCells = [Bool](count: savedContacts.count, repeatedValue: false)
    }
    
    self.tableView.reloadData()
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
        
        var closeCells = false
        
        for contact in contacts {
          if(Contact.create(contact as APContact, managedObjectContext:
            self.managedObjectContext)) {
              // Close the table cells because a new one was added
              closeCells = true
          }
        }
        
        self.loadTableData(closeCells)
      }
    })
  }
  
  /**
   * Animates the logo to the top of the view.
   */
  
  func moveLogoUp() {
    if(self.tableView.alpha != 1.0) {
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
              
              // Make the table view and search bar visible
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
  
  // MARK: UISearchBar Delegate Methods
  
  /**
   * Closes the keyboard when the user finishes typing the search query.
   *
   * @param searchBar The search bar where the query was inputted.
   */
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  /**
   * Event handler that queries core data as the user is typing.
   *
   * @param searchBar The search bar where the query was inputted.
   * @param searchText The user's search query
   */
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    var showResultsLabel = false
    
    let fetchRequest = NSFetchRequest(entityName: "Contact")
    
    // Sort results by last name
    let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true,
      selector: "caseInsensitiveCompare:")
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Add predicates if the user has entered a query
    if(countElements(searchText) > 0) {
      // Search by first name
      let firstNamePredicate = NSPredicate(format: "firstName CONTAINS[c] %@", argumentArray: [searchText])
      
      // Search by last name
      let lastNamePredicate = NSPredicate(format: "lastName CONTAINS[c] %@", argumentArray: [searchText])
      
      // Search tags
      let tagPredicateFormat = "ANY tags.title CONTAINS[c] '\(searchText)'"
      let tagPredicate = NSPredicate(format: tagPredicateFormat,
        argumentArray: [searchText])
      
      // Combine the search predicates
      let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates:
        [firstNamePredicate, lastNamePredicate, tagPredicate])
      
      fetchRequest.predicate = compoundPredicate
      
      showResultsLabel = true
    }
    
    // Fetch the results from core data
    if let fetchResults = managedObjectContext!.executeFetchRequest(
      fetchRequest, error: nil) as? [Contact] {
        savedContacts = fetchResults
    }
    
    // Close the table view cells
    openedCells = [Bool](count: savedContacts.count, repeatedValue: false)
    
    // Update the results label
    if(showResultsLabel) {
      resultsLabel.text = "\(savedContacts.count) Results"
      resultsLabel.hidden = false
    } else {
      resultsLabel.hidden = true
    }
    
    // Hide the table view if there were no results
    tableView.hidden = savedContacts.count == 0
    
    self.tableView.reloadData()
  }
  
  // MARK: UITableView Delegate Methods
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:
    NSIndexPath) {
      // Toggle open or close the cell
      let cellIsOpened = openedCells[indexPath.row]
      openedCells[indexPath.row] = !cellIsOpened

      // Bug fix for separater disappearing
      self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
      self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
      self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

      // Apply the changes to the table cell
      self.tableView.beginUpdates()
      self.tableView.endUpdates()
  }
  
  /**
   * Calculates the height of the table view cell depending on whether or not
   * it's marked open.
   *
   * @param tableView The table view that stores the contact data.
   * @param heightForRowAtIndexPath The index path of the table row to set the
   *                                height of
   * @return The height of the table view row.
   */

  func tableView(tableView: UITableView, heightForRowAtIndexPath
    indexPath: NSIndexPath) -> CGFloat {
    if(self.savedContacts.count > 0) {
      // Returns the larger value if the table cell is marked open
      return openedCells[indexPath.row] ? 350.0: 170.0
    }
    
    return 0.0
  }
  
  // MARK: UITableView Data Source Methods
  
  /**
   * Calculates the number of table view rows based on the number of saved
   * contacts.
   *
   * @param tableView The table view that stores the contact data.
   * @param section The section to determine the number of rows
   * @return The number of rows in the table view (which has only 1 section).
   */
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      return savedContacts.count
  }
  
  /**
   * Returns the cell based on the given index path.
   *
   * @param tableView The table view that stores the contact data.
   * @param indexPath The index path of the cell.
   * @return The table view cell at the specified index path.
   */
  
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
        // Retrieve the contact from the saved contacts
        let contact = savedContacts[indexPath.row]
        cell.contact = contact
        
        // Set the name of the cell
        var name = ""
        
        if(contact.firstName != nil) {
          name += contact.firstName!
        }
        
        if(contact.lastName != nil) {
          name += " " + contact.lastName!
        }
        
        cell.name.text = name
        
        // Set the tags in the cell
        if(contact.tags != nil) {
          cell.updateTagTextView()
        }
        
        // Set the call and message values
        if(contact.phone != nil) {
          cell.phoneNumber = contact.phone!
          cell.buttonCall.alpha = 1.0
          cell.buttonMessage.alpha = 1.0
        } else {
          cell.buttonCall.alpha = 0.5
          cell.buttonMessage.alpha = 0.5
        }
        
        // Set the email values
        if(contact.email != nil) {
          cell.email = contact.email!
          cell.buttonEmail.alpha = 1.0
        } else {
          cell.buttonEmail.alpha = 0.5
        }
        
        // Set the image if it exists
        if(contact.photo != nil) {
          cell.profilePicture.image = (contact.photo as UIImage)
        } else {
          cell.profilePicture.image = UIImage(named: "default-profile")
        }
      }
      
      return cell
  }
}
