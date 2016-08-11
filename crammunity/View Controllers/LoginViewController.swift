//
//  LoginViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/12/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {
	@IBOutlet weak var EmailTextField: UITextField!
	@IBOutlet weak var PasswordTextField: UITextField!
	let InvalidLoginTitle = "Invalid Login"
	
	var isSignedUp = false
	
	
	override func viewDidAppear(animated: Bool) {
		guard !isSignedUp else {
			performSegueWithIdentifier(Constants.Segues.LoginToMain, sender: self)
			return
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		print("login view loaded")
		testLogin()
		
	}
	//TODO: remove testlogin
	func testLogin()
	{
		FIRAuth.auth()!.signInWithEmail("test@test.com", password: "testtesttest") { (user, error) in
			if let error = error {
				ErrorHandling.defaultErrorHandler("Test Sign in failed:", desc: error.localizedDescription)
			} else {
				print ("Test Signed in with uid:", user!.uid)
				self.signedIn(user)
			}
		}
	}
	
	@IBAction func viewTapped(sender: AnyObject) {
		self.EmailTextField.resignFirstResponder()
		self.PasswordTextField.resignFirstResponder()
	}
	//TODO: Reorganize with helper
	
	@IBAction func onLoginButtonTap(sender: AnyObject) {
		//TODO: add alertviewcontrollers
		//also with sign in
		viewTapped(self)
		guard PasswordTextField.text != "" else {
			ErrorHandling.defaultErrorHandler(InvalidLoginTitle, desc: "Missing Password")
			return
		}
		FIRAuth.auth()!.signInWithEmail(EmailTextField.text!, password: PasswordTextField.text!) { (user, error) in
			if let error = error {
				if(error.code == 17008)
				{
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: " Invalid email")
				}
				else if(error.code == 17009)
				{
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: " Invalid email/password combination")
				}
				else if(error.code == 17011)
				{
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: " User does not exist")
				}
				else if(error.code == 17999)
				{
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: (error.userInfo[NSUnderlyingErrorKey]?.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as! NSDictionary).valueForKey("message") as! String)
				}
				//successful sign in
				else {
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: "Unknown error: \(error)")
				}
									
			} else {
				print ("Signed in with uid:", user!.uid)
				self.signedIn(user)
			}
		}
	}
	
	@IBAction func didRequestPasswordReset(sender: AnyObject) {
		let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.Alert)
		let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action) in
			let userInput = prompt.textFields![0].text
			if (userInput!.isEmpty) {
				return
			}
			FIRAuth.auth()?.sendPasswordResetWithEmail(userInput!) { (error) in
				if let error = error {
					ErrorHandling.defaultErrorHandler("Password Reset Error", desc: error.localizedDescription)
					return
				}
			}
		}
		prompt.addTextFieldWithConfigurationHandler(nil)
		prompt.addAction(okAction)
		presentViewController(prompt, animated: true, completion: nil);
	}
	//TODO: Reorganize with helper, send login methods to helper
	
	func signedIn(user: FIRUser?)
	{
		MeasurementHelper.sendLoginEvent()
		

		
		
		AppState.sharedInstance.displayName = user?.displayName ?? user?.email
		AppState.sharedInstance.profileUrl = user?.photoURL
		AppState.sharedInstance.signedIn = true
		NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
		//TODO: make this cleaner
		Constants.Firebase.currentUser = (FIRAuth.auth()?.currentUser)!
		Constants.Firebase.FriendsArray = Constants.Firebase.UserArray.child((Constants.Firebase.currentUser.uid)).child("friends")
		FirebaseHelper.friendsRef = Constants.Firebase.FriendsArray
		performSegueWithIdentifier(Constants.Segues.LoginToMain, sender: self)
	}
	
	@IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {
		print("unwinding to login")
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let id = segue.identifier
		{
			print("Seguing to \(id)")
			if id == Constants.Segues.LoginToSignUp{
				let vc = segue.destinationViewController as! SignUpViewController
				vc.loginVC = self
			}
			else if id == Constants.Segues.LoginToMain
			{
				self.isSignedUp = false
			}
			
		}
	}
}
