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
  @NSManaged var firstName: String?
  @NSManaged var lastName: String?
  @NSManaged var phone: String?
  @NSManaged var email: String?
  @NSManaged var photo: AnyObject?
  @NSManaged var tags: NSSet?
  
  class func create(contact: APContact,
    managedObjectContext: NSManagedObjectContext?) -> Bool {
    if(!Contact.exists(contact, managedObjectContext: managedObjectContext)) {
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
        row.phone = (contact.phones[0] as String)
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
}
