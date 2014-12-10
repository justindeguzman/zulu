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
  
  class func exists(firstName: String, lastName: String) {
    
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
