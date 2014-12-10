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
  
  func addTag(title: String) {
    if(!Tag.exists(title, managedObjectContext: self.managedObjectContext)) {
      let tag = NSEntityDescription.insertNewObjectForEntityForName(
        "Tag", inManagedObjectContext: self.managedObjectContext!
        ) as Tag
      
      tag.title = title
    }
  }
}
