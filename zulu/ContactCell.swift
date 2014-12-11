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
  
  // MARK: IBOutlets
  
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var buttonCall: UIButton!
  @IBOutlet weak var buttonMessage: UIButton!
  @IBOutlet weak var buttonEmail: UIButton!
  @IBOutlet weak var inputAddTag: UITextField!
  @IBOutlet weak var tagTextLabel: UILabel!
  
  // MARK: Instance Variables
  
  var contact: Contact?
  var phoneNumber : NSString = ""
  var email: NSString = ""
  
  // MARK: Event Handlers
  
  /**
   * Event handler for pressing the call button that initiates a call.
   */
  
  @IBAction func didPressButtonCall() {
    if(phoneNumber != "") {
      let url = NSURL(string: "tel://\(self.phoneNumber)")!
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  /**
   * Event handler for pressing the call button that initiates an SMS message.
   */
  
  @IBAction func didPressButtonMessage() {
    if(phoneNumber != "") {
      let url = NSURL(string: "sms://\(self.phoneNumber)")!
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  /**
   * Event handler for pressing the call button that initiates an email.
   */
  
  @IBAction func didPressButtonEmail() {
    if(email != "") {
      let url = NSURL(string: "mailto://\(email)")!
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  // MARK: UITextField Delegate Methods
  
  /**
   * Adds a tag to core data when the user presses "Done" after adding a tag.
   */
  
  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    contact?.addTag(textField.text)
    updateTagTextView()
    
    textField.text = ""
    textField.resignFirstResponder()
    return true
  }
  
  // MARK: Instance Methods
  
  /**
   * Updates the table cell with the correct tags.
   */
  
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
    
    attrString.addAttribute(NSFontAttributeName, value: UIFont(name:
      "HelveticaNeue-Light", size: 18.0)!, range: NSMakeRange(0,
        attrString.length))
    
    attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
    
    self.tagTextLabel.attributedText = attrString
  }
}
