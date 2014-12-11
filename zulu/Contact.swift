//
//  Contact.swift
//  zulu
//
//  Created by Justin de Guzman on 12/7/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import Foundation
import CoreData

class Contact: NSManagedObject {
  
  // MARK: Core Data Attributes
  
  @NSManaged var firstName: String?
  @NSManaged var lastName: String?
  @NSManaged var phone: String?
  @NSManaged var email: String?
  @NSManaged var photo: AnyObject?
  
  // MARK: Core Data Relationships
  
  @NSManaged var tags: NSSet?

  // MARK: Instance Methods
  
 /**
  * Associates a tag with a given user.
  *
  * @param title The title of the tag
  */
  
  func addTag(title: String) {
    var tag: Tag?
    
    // Create tag if it does not already exist
    if(!Tag.exists(title, managedObjectContext: self.managedObjectContext)) {
      tag = Tag.create(title, managedObjectContext: self.managedObjectContext)
    } else {
      tag = Tag.retrieve(title, managedObjectContext: self.managedObjectContext)
    }
    
    // Insert into contact tags
    self.mutableSetValueForKey("tags").addObject(tag!)
  }
  
  // MARK: Class Methods
  
  /**
   * Inserts a contact object into core data and returns true if a contact was
   * successfully created.
   * 
   * @param contact The contact object to be inserted into Core Data.
   * @param managedObjectContext The app's managed object context for core data.
   * @return true if the object was successfully created
   */
  
  class func create(contact: APContact,
    managedObjectContext: NSManagedObjectContext?) -> Bool {
    let contactAlreadyCreated =
      Contact.exists(contact, managedObjectContext: managedObjectContext)
    
    if(!contactAlreadyCreated) {
      // Insert a new row into the database
      let row = NSEntityDescription.insertNewObjectForEntityForName(
        "Contact", inManagedObjectContext: managedObjectContext!
      ) as Contact
      
      if(!Util.isEmptyString(contact.firstName)) {
        row.firstName = contact.firstName
      }
      
      if(!Util.isEmptyString(contact.lastName)) {
        row.lastName = contact.lastName
      }
      
      if(contact.phones != nil && contact.phones.count > 0) {
        row.phone = Util.parsePhoneNumber((contact.phones[0] as String))
      }
      
      if(contact.emails != nil && contact.emails.count > 0) {
        row.email = (contact.emails[0] as String)
      }
      
      if(contact.photo != nil) {
        row.photo = contact.photo
      }
      
      return true
    }
      
    return false
  }
  
 /**
  * Creates a fetch request given a specific predicate.
  *
  * @param predicate The predicate, or search filter, of the fetch request
  * @param managedObjectContext The app's managed object context for core data.
  * @return the fetch request based on a given predicate
  */
  
  class func fetchRequest(predicate: NSPredicate,
    managedObjectContext: NSManagedObjectContext?) -> NSFetchRequest {
      let request = NSFetchRequest()
      request.entity =  NSEntityDescription.entityForName(
        "Contact", inManagedObjectContext: managedObjectContext!
      )
      request.predicate = predicate
      request.fetchLimit = 1
      return request
  }
  
 /**
  * Returns whether or not a specific contact already exists.
  *
  * @param predicate The predicate, or search filter, of the fetch request
  * @param managedObjectContext The app's managed object context for core data.
  * @return the fetch request based on a given predicate
  */
  
  class func exists(contact: APContact, managedObjectContext:
    NSManagedObjectContext?) -> Bool {
      var predicate : NSPredicate = NSPredicate()
      
      let containsFirstName = !Util.isEmptyString(contact.firstName)
      let containsLastName = !Util.isEmptyString(contact.lastName)
      
      if(containsFirstName && containsLastName) {
        predicate = NSPredicate(format: "firstName = %@ AND lastName = %@",
          argumentArray: [contact.firstName, contact.lastName])
      } else if(containsFirstName && !containsLastName) {
        NSPredicate(format: "firstName = %@", argumentArray:
          [contact.firstName])
      } else if(!containsFirstName && containsLastName) {
        NSPredicate(format: "lastName = %@", argumentArray:
          [contact.lastName])
      } else {
        return false
      }
      
      let request = Contact.fetchRequest(predicate, managedObjectContext: managedObjectContext)
      
      var containsContact = managedObjectContext!.countForFetchRequest(
        request, error: nil
      )
      
      return containsContact == 1
  }
}
