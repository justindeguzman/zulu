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

  @NSManaged var title: String
  @NSManaged var contacts: NSSet

  class func create(title: String, managedObjectContext:
    NSManagedObjectContext?) -> Tag {
      let tag = NSEntityDescription.insertNewObjectForEntityForName(
        "Tag", inManagedObjectContext: managedObjectContext!
      ) as Tag
      
      tag.title = title
      
      return tag
  }
  
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
    
    return nil
  }
  
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
