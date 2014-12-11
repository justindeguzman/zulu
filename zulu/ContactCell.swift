//
//  ContactCell.swift
//  zulu
//
//  Created by Justin de Guzman on 12/8/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import UIKit
import CoreData

class ContactCell: UITableViewCell, UITextFieldDelegate {
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var buttonCall: UIButton!
  @IBOutlet weak var buttonMessage: UIButton!
  @IBOutlet weak var buttonEmail: UIButton!
  @IBOutlet weak var inputAddTag: UITextField!
  @IBOutlet weak var tagTextLabel: UILabel!
  
  var contact: Contact?
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
  
  func heightForTextView(text: String, font:UIFont, width:CGFloat) -> CGFloat {
    let label: UITextView = UITextView(frame: CGRectMake(0, 0, width, CGFloat.max))
    label.font = font
    label.text = text
    label.sizeToFit()
    return label.frame.height + 50
  }
  
  func updateTagTextView() {
    var paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 15
    paragraphStyle.alignment = NSTextAlignment.Center
    paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
    
    var str = ""
    
    for tag in contact!.tags! {
      let currentTag = tag as Tag
      str += "#\(currentTag.title) "
    }
    var attrString = NSMutableAttributedString(string: str)
    
    attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 18.0)!, range: NSMakeRange(0, attrString.length))
    
    attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
    
    self.tagTextLabel.attributedText = attrString
  }
  
  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    contact?.addTag(textField.text)
    updateTagTextView()

    textField.text = ""
    textField.resignFirstResponder()
    return true
  }
  
  func showHiddenCellElements(show: Bool) {
    self.buttonCall.hidden = !show
    self.buttonMessage.hidden = !show
    self.buttonEmail.hidden = !show
  }
  
//  func textFieldShouldEndEditing(textField: UITextField!) -> Bool {  //delegate method
//    return false
//  }
}
