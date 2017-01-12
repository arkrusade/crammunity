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
	
	
	override func viewDidAppear(_ animated: Bool) {
		guard !isSignedUp else {
			performSegue(withIdentifier: Constants.Segues.LoginToMain, sender: self)
			return
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		print("login view loaded")
//		testLogin()
		
	}
	//TODO: remove testlogin
	func testLogin()
	{
		FIRAuth.auth()!.signIn(withEmail: "test@test.com", password: "testtesttest") { (user, error) in
			if let error = error {
				ErrorHandling.defaultErrorHandler("Test Sign in failed:", desc: error.localizedDescription)
			} else {
				print ("Test Signed in with uid:", user!.uid)
				self.signedIn(user)
			}
		}
	}
	
	@IBAction func viewTapped(_ sender: AnyObject) {
		self.EmailTextField.resignFirstResponder()
		self.PasswordTextField.resignFirstResponder()
	}
	//TODO: Reorganize with helper
	
	@IBAction func onLoginButtonTap(_ sender: AnyObject) {
		//TODO: add alertviewcontrollers
		//also with sign in
		viewTapped(self)
		guard PasswordTextField.text != "" else {
			ErrorHandling.defaultErrorHandler(InvalidLoginTitle, desc: "Missing Password")
			return
		}
		FIRAuth.auth()!.signIn(withEmail: EmailTextField.text!, password: PasswordTextField.text!) { (user, error) in
			if let error = error {
				if(error.code == 17008)
				{
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: "Invalid email")
				}
				else if(error.code == 17009)
				{
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: "Invalid email/password combination")
				}
				else if(error.code == 17011)
				{
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: "User does not exist")
				}
				else if(error.code == 17999)
				{
					ErrorHandling.defaultErrorHandler(self.InvalidLoginTitle, desc: (error.userInfo[NSUnderlyingErrorKey]?.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as! NSDictionary).value(forKey: "message") as! String)
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
	
	@IBAction func didRequestPasswordReset(_ sender: AnyObject) {
		let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.alert)
		let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action) in
			let userInput = prompt.textFields![0].text
			if (userInput!.isEmpty) {
				return
			}
			FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
				if let error = error {
					ErrorHandling.defaultErrorHandler("Password Reset Error", desc: error.localizedDescription)
					return
				}
			}
		}
		prompt.addTextField(configurationHandler: nil)
		prompt.addAction(okAction)
		present(prompt, animated: true, completion: nil);
	}
	//TODO: Reorganize with helper, send login methods to helper
	
	func signedIn(_ user: FIRUser?)
	{
		

		
		
		AppState.sharedInstance.displayName = user?.displayName ?? user?.email
		AppState.sharedInstance.photoURL = user?.photoURL
		AppState.sharedInstance.signedIn = true
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.SignedIn), object: nil, userInfo: nil)
		
		
		//TODO: make this cleaner
		Constants.Firebase.currentUser = (FIRAuth.auth()?.currentUser)!
		Constants.Firebase.FriendsArray = Constants.Firebase.UserArray.child((Constants.Firebase.currentUser.uid)).child("friends")
		FirebaseHelper.friendsRef = Constants.Firebase.FriendsArray
		AppState.sharedInstance.userRef = Constants.Firebase.UserArray.child(Constants.Firebase.currentUser.uid)
		
		if user?.displayName != "test@test.com"  {
			MeasurementHelper.sendLoginEvent()
		}

		performSegue(withIdentifier: Constants.Segues.LoginToMain, sender: self)
	}
	
	@IBAction func unwindToLoginViewController(_ segue: UIStoryboardSegue) {
		print("unwinding to login")
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let id = segue.identifier
		{
			print("Seguing to \(id)")
			if id == Constants.Segues.LoginToSignUp{
				let vc = segue.destination as! SignUpViewController
				vc.loginVC = self
			}
			else if id == Constants.Segues.LoginToMain
			{
				self.isSignedUp = false
			}
			
		}
	}
}
