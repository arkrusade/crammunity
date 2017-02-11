//
//  SignUpViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/12/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



class SignUpViewController: UIViewController {

	let InvalidSignUpTitle = "Invalid Sign Up"
	@IBOutlet weak var EmailTextField: UITextField!
	@IBOutlet weak var UsernameTextField: UITextField!
	@IBOutlet weak var PasswordTextField: UITextField!
	@IBOutlet weak var PasswordConfirmTextField: UITextField!
	@IBOutlet weak var signUpButton: UIButton!
	
	var loginVC: LoginViewController!
	
	@IBAction func SignUpButtonTapped()
	{
		//TODO: change to alerts
		if (EmailTextField.text!.range(of: Constants.emailRegex, options: .regularExpression)) == nil
		{
			ErrorHandling.defaultError(InvalidSignUpTitle, desc: "Must be valid email", sender: self)
			return
		}
		else if UsernameTextField.text?.characters.count < 6 {
			ErrorHandling.defaultError(InvalidSignUpTitle, desc: "Must have username longer than 6 characters", sender: self)
			return
		}
		else if PasswordTextField.text?.characters.count < 8 || PasswordConfirmTextField.text?.characters.count < 8 {
			ErrorHandling.defaultError(InvalidSignUpTitle, desc: "Must have password longer than 8 characters", sender: self)
			return
		}
		
		
		else if (PasswordTextField.text! != PasswordConfirmTextField.text!) {
            ErrorHandling.defaultError(InvalidSignUpTitle, desc: "Passwords must match", sender: self)
			return
		}
		else {
			FirebaseHelper.shared.createUser(EmailTextField.text!, pw: PasswordTextField.text!, username: UsernameTextField.text!, callback: { user in
				self.signedUp(user)
			})
			//TODO: add grade/age
			
		}
	}
	
	@IBAction func viewTapped(_ sender: AnyObject?)
	{
		EmailTextField.resignFirstResponder()
		UsernameTextField.resignFirstResponder()
		PasswordTextField.resignFirstResponder()
		PasswordConfirmTextField.resignFirstResponder()
	}
	func signedUp(_ user: FIRUser?)
	{
		//TODO: get this and login to be same method
		
		
		//TODO: add profile changing, change pass and profile picture (first get ability to add one)
		//TODO: and check for username/email duplicate
		
		
		MeasurementHelper.sendLoginEvent()//analytics
		
		AppState.sharedInstance.displayName = user?.displayName ?? user?.email
		AppState.sharedInstance.photoURL = user?.photoURL
		AppState.sharedInstance.signedIn = true
		
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.SignedIn), object: nil, userInfo: nil)
		Constants.Firebase.currentUser = (FIRAuth.auth()?.currentUser)!
		
		loginVC.isSignedUp = true
		self.dismiss(animated: false, completion: nil)
	}
    override func viewDidLoad() {
        super.viewDidLoad()

		
        // Do any additional setup after loading the view.
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
