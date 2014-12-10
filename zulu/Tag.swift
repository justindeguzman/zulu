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

  class func exists(title: String, managedObjectContext: NSManagedObjectContext?) -> Bool {
    let request = NSFetchRequest()
    request.entity =  NSEntityDescription.entityForName(
      "Tag", inManagedObjectContext: managedObjectContext!
    )
    request.predicate = NSPredicate(format: "title = %@",
      argumentArray: [title])
    request.fetchLimit = 1
    
    var containsTag = managedObjectContext!.countForFetchRequest(
      request, error: nil
    )
    
//    if(containsTag == 0) {
//      //self.mutableSetValueForKey("tags").addObject(tag)
//    }
    
    return containsTag == 0
  }
}
