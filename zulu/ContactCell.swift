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
    let url = NSURL(string: "telprompt://9172384239")!
    UIApplication.sharedApplication().openURL(url)
  }
  
  @IBAction func didPressButtonMessage() {
    let url = NSURL(string: "sms://9172384239")!
    UIApplication.sharedApplication().openURL(url)
  }
  
  @IBAction func didPressButtonEmail() {
    println("Email \(self.email)")
  }
}
