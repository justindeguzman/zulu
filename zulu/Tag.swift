//
//  zulu.swift
//  zulu
//
//  Created by Justin de Guzman on 12/10/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import Foundation
import CoreData

class Tag: NSManagedObject {

  // MARK: Core Data Attributes
  
  @NSManaged var title: String
  @NSManaged var contacts: NSSet

  // MARK: Class Methods
  
 /**
  * Inserts a tag object into core data and returns it.
  *
  * @param title The title of the tag.
  * @param managedObjectContext The app's managed object context for core data.
  * @return the instance of the tag
  */
  
  class func create(title: String, managedObjectContext:
    NSManagedObjectContext?) -> Tag {
      let tag = NSEntityDescription.insertNewObjectForEntityForName(
        "Tag", inManagedObjectContext: managedObjectContext!
      ) as Tag
      
      tag.title = title
      
      return tag
  }
  
 /**
  * Creates a fetch request given a title of the tag.
  *
  * @param title The title of the tag
  * @param managedObjectContext The app's managed object context for core data.
  * @return the fetch request based on a tag title
  */
  
  class func fetchRequest(title: String, managedObjectContext:
    NSManagedObjectContext?) -> NSFetchRequest {
      let request = NSFetchRequest()
      request.entity =  NSEntityDescription.entityForName(
        "Tag", inManagedObjectContext: managedObjectContext!
      )
      request.predicate = NSPredicate(format: "title = %@",
        argumentArray: [title])
      request.fetchLimit = 1
      return request
  }
  
 /**
  * Retrieves a tag based on the given title.
  *
  * @param title The title of the tag
  * @param managedObjectContext The app's managed object context for core data.
  * @return the instance of a tag with a specific title
  */
  
  class func retrieve(title: String, managedObjectContext:
    NSManagedObjectContext?) -> Tag? {
    let request = Tag.fetchRequest(title, managedObjectContext:
      managedObjectContext)
    
    if let fetchResults = managedObjectContext!.executeFetchRequest(
      request, error: nil) as? [Tag] {
        if(fetchResults.count > 0) {
          return fetchResults[0] as Tag
        }
    }
    
    // tag not found
    return nil
  }
  
  /**
  * Returns whether or not a specific tag already exists.
  *
  * @param title The title of the tag
  * @param managedObjectContext The app's managed object context for core data.
  * @return whether or not the tag exists
  */
  
  class func exists(title: String, managedObjectContext:
    NSManagedObjectContext?) -> Bool {
    let request = Tag.fetchRequest(title, managedObjectContext:
      managedObjectContext)
    
    var containsTag = managedObjectContext!.countForFetchRequest(
      request, error: nil
    )
    
    return containsTag == 1
  }
}
