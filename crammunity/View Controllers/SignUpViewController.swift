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
		if (EmailTextField.text!.rangeOfString(Constants.emailRegex, options: .RegularExpressionSearch)) == nil
		{
			ErrorHandling.errorAlert(InvalidSignUpTitle, desc: "Must be valid email")
			return
		}
		else if UsernameTextField.text?.characters.count < 6 {
			ErrorHandling.errorAlert(InvalidSignUpTitle, desc: "Must have username longer than 6 characters")
			return
		}
		else if PasswordTextField.text?.characters.count < 8 || PasswordConfirmTextField.text?.characters.count < 8 {
			ErrorHandling.errorAlert(InvalidSignUpTitle, desc: "Must have password longer than 8 characters")
			return
		}
		
		
		else if (PasswordTextField.text! != PasswordConfirmTextField.text!) {
			ErrorHandling.errorAlert(InvalidSignUpTitle, desc: "Passwords must match")
			return
		}
		else {
			FIRAuth.auth()?.createUserWithEmail(EmailTextField.text!, password: PasswordTextField.text!) { (user, error) in
				if let error = error {
					ErrorHandling.errorAlert(self.InvalidSignUpTitle, desc: error.localizedDescription)
				} else {
					self.signedUp(user)
				}
			}
		}
	}
	
	@IBAction func viewTapped(sender: AnyObject?)
	{
		EmailTextField.resignFirstResponder()
		UsernameTextField.resignFirstResponder()
		PasswordTextField.resignFirstResponder()
		PasswordConfirmTextField.resignFirstResponder()
	}
	func signedUp(user: FIRUser?)
	{
		//TODO: get this and login to be same method
		let username = self.UsernameTextField.text!
		Constants.Firebase.UserSearchArray.child(user!.uid).setValue(["username": username])
		Constants.Firebase.UserArray.child(user!.uid).setValue(["username": username])
		print ("Created user with uid: \(user!.uid) and username: \(username)")
		
		//TODO: add profile changing, change pass and profile picture (first get ability to add one)
		//TODO: and check for username/email duplicate
		
	
		
		let changeRequest = user!.profileChangeRequest()
		changeRequest.displayName = username
		changeRequest.photoURL =
			NSURL(string: "gs://crammunity.appspot.com/defaults/profilePicture/profile-256.png")
		changeRequest.commitChangesWithCompletion(){ (error) in
			if let error = error {
				ErrorHandling.defaultErrorHandler(error)
				return
			}
			
		}
		
		MeasurementHelper.sendLoginEvent()//analytics
		
		AppState.sharedInstance.displayName = username ?? user?.email
		AppState.sharedInstance.photoUrl = user?.photoURL
		AppState.sharedInstance.signedIn = true
		NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
		Constants.Firebase.currentUser = FIRAuth.auth()?.currentUser
		
		loginVC.isSignedUp = true
		self.dismissViewControllerAnimated(false, completion: nil)
//		self.performSegueWithIdentifier(Constants.Segues.SignUpToMain, sender: nil)
		
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
