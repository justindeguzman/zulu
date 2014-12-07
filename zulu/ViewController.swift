//
//  ViewController.swift
//  zulu
//
//  Created by Justin de Guzman on 11/17/14.
//  Copyright (c) 2014 New York University. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class ViewController: UIViewController {
  
  var addressBook : ABAddressBook!
  
 /*
  * UI Elements.
  */
  
  @IBOutlet weak var logo: UILabel!
  
  /*
   * Constraints.
   */
  
  @IBOutlet weak var logoYConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ABAddressBookRequestAccessWithCompletion(
      addressBook, { granted in
        self.moveLogoUp()
    })
  }
  
  /**
   * Animates the logo to the top of the view.
   */
  
  func moveLogoUp() {
    print("hello")
    
    self.view.layoutIfNeeded()
    let modifier : CGFloat = 0.7
    
    UIView.animateWithDuration(0.4,
      animations: {
        self.logo.transform = CGAffineTransformScale(
          self.logo.transform, modifier, modifier
        )
        self.view.layoutIfNeeded()
      }, completion: { finished in
        UIView.animateWithDuration(0.4,
          animations: {
            self.logoYConstraint.constant -= 130.0
            self.view.layoutIfNeeded()
          }, completion: { finished in }
        )
      
      }
    )
  }
}

