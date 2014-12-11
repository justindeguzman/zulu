//
//  Util.swift
//  zulu
//
//  Created by Justin de Guzman on 12/10/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import CoreData
import Foundation

class Util {
  
  /**
   * Checks if an a string is empty.
   *
   * @param contact The contact to be saved.
   * @return whether or not the string is empty
   */
  
  class func isEmptyString(str: String?) -> Bool {
    return str == nil || str == ""
  }
  
  /**
   * Makes a given UIView a circle.
   *
   * @param square The UIView to make into a circle.
   */
  
  class func makeCircle(square: UIView) {
    square.layer.cornerRadius = square.frame.size.height / 2
    square.layer.masksToBounds = true
    square.layer.borderWidth = 0
  }
  
  /**
   * Strips dashes, spaces, and parantheses from phone numbers.
   *
   * @param phoneNumber The phone number to parse.
   * @return The parsed phone number.
   */
  
  class func parsePhoneNumber(phoneNumber: String) -> String {
    var parsedPhoneNumber: String = (phoneNumber as String)
    var illegalChars = [" ", "(", ")", "-",
      String(Character(UnicodeScalar(160)))]
    
    for char in illegalChars {
      parsedPhoneNumber =
        parsedPhoneNumber.stringByReplacingOccurrencesOfString(char,
          withString: "")
    }
        
    return parsedPhoneNumber
  }
}
