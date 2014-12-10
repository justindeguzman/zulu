//
//  ContactCell.swift
//  zulu
//
//  Created by Justin de Guzman on 12/8/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell, UITextFieldDelegate {
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var buttonCall: UIButton!
  @IBOutlet weak var buttonMessage: UIButton!
  @IBOutlet weak var buttonEmail: UIButton!
  @IBOutlet weak var inputAddTag: UITextField!
  
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
  
  /**
   * UITextField Delegate Methods.
   */
  
  func textFieldDidBeginEditing(textField: UITextField!) {
    
  }
  
  func parentTableView() -> UITableView? {
    var currentView = self.superview
    
    while(currentView != nil) {
      if((currentView?.isKindOfClass(UITableView)) != nil) {
        return currentView as UITableView?
      }
      
      currentView = currentView?.superview
    }
    
    return nil
  }
  
  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
//  func textFieldShouldEndEditing(textField: UITextField!) -> Bool {  //delegate method
//    return false
//  }
}
