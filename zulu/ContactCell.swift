//
//  ContactCell.swift
//  zulu
//
//  Created by Justin de Guzman on 12/8/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var buttonCall: UIButton!
  @IBOutlet weak var buttonMessage: UIButton!
  @IBOutlet weak var buttonEmail: UIButton!
  
  var phoneNumber : NSString = ""
  var email: NSString = ""
  
  @IBAction func didPressButtonCall() {
    if(phoneNumber != "") {
      let url = NSURL(string: "tel://\(self.parsePhone())")!
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  @IBAction func didPressButtonMessage() {
    if(phoneNumber != "") {
      let url = NSURL(string: "sms://\(self.parsePhone())")!
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  @IBAction func didPressButtonEmail() {
    if(email != "") {
      let url = NSURL(string: "mailto://\(email)")!
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  func parsePhone() -> String {
    var parsedPhoneNumber: String = (phoneNumber as String)
    
    parsedPhoneNumber = parsedPhoneNumber.stringByReplacingOccurrencesOfString(
      String(Character(UnicodeScalar(160))), withString: "")
    
    parsedPhoneNumber = parsedPhoneNumber.stringByReplacingOccurrencesOfString(
      " ", withString: "", options: NSStringCompareOptions.LiteralSearch,
      range: nil)
    
    parsedPhoneNumber = parsedPhoneNumber.stringByReplacingOccurrencesOfString(
      "(", withString: "", options: NSStringCompareOptions.LiteralSearch,
      range: nil)
    
    parsedPhoneNumber = parsedPhoneNumber.stringByReplacingOccurrencesOfString(
      ")", withString: "", options: NSStringCompareOptions.LiteralSearch,
      range: nil)
    
    parsedPhoneNumber = parsedPhoneNumber.stringByReplacingOccurrencesOfString(
      "-", withString: "", options: NSStringCompareOptions.LiteralSearch,
      range: nil)
    return parsedPhoneNumber
  }
}
