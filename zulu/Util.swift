//
//  Util.swift
//  zulu
//
//  Created by Justin de Guzman on 12/10/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import Foundation

class Util {
 /**
  * Checks if an a string is empty.
  *
  * @param contact The contact to be saved.
  */
  
  class func isEmptyString(str: String?) -> Bool {
    return str == nil || str == ""
  }
  
  class func makeCircle(square: UIView) {
    square.layer.cornerRadius = square.frame.size.height / 2
    square.layer.masksToBounds = true
    square.layer.borderWidth = 0
  }
}

