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

}
