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
				print("Test Sign in failed:", error.localizedDescription)
			} else {
				print ("Test Signed in with uid:", user!.uid)
				self.signedIn(user)
			}
		}
	}
	//TODO: Reorganize with helper

	@IBAction func onLoginButtonTap(sender: AnyObject) {
		//TODO: add alertviewcontrollers
		//also with sign in
		FIRAuth.auth()!.signInWithEmail(EmailTextField.text!, password: PasswordTextField.text!) { (user, error) in
			if let error = error {
				if(error.code == 17008)
				{
					print("Invalid email")
				}
				else if(error.code == 17009)
				{
					print("Invalid email/password combination")
				}
				else if(error.code == 17011)
				{
					print("User does not exist")
				}
				else if(error.code == 17999)
				{
					print("Domain error")
					print((error.userInfo[NSUnderlyingErrorKey]?.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as! NSDictionary).valueForKey("message") as! String)
				}
				//successful sign in
				else {
					print("Unknown error: \(error)")
				}
				
//				{NSUnderlyingError=0x7f8ec1f13030 {Error Domain=FIRAuthInternalErrorDomain Code=3 "(null)" UserInfo={FIRAuthErrorUserInfoDeserializedResponseKey=<CFBasicHash 0x7f8ec4023dd0 [0x10fe30a40]>{type = immutable dict, count = 3,
//				entries =>
//				0 : <CFString 0x7f8ec4025930 [0x10fe30a40]>{contents = "message"} = <CFString 0x7f8ec4027b20 [0x10fe30a40]>{contents = "MISSING_PASSWORD"}
//				1 : errors = <CFArray 0x7f8ec4025580 [0x10fe30a40]>{type = immutable, count = 1, values = (
//					0 : <CFBasicHash 0x7f8ec1eecd40 [0x10fe30a40]>{type = immutable dict, count = 3,
//					entries =>
//					0 : reason = invalid
//					1 : message = <CFString 0x7f8ec1e8a860 [0x10fe30a40]>{contents = "MISSING_PASSWORD"}
//					2 : domain = global
//					}
//					
//					)}
//				2 : code = <CFNumber 0xb000000000001903 [0x10fe30a40]>{value = +400, type = kCFNumberSInt64Type}
//			}
//		}}
				
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
					print(error.localizedDescription)
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
		
		Constants.Firebase.UserArray.child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			// Get username value
				AppState.sharedInstance.displayName = snapshot.childSnapshotForPath("username").value! as? String
			})
		AppState.sharedInstance.photoUrl = user?.photoURL
		AppState.sharedInstance.signedIn = true
		NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
		performSegueWithIdentifier(Constants.Segues.LoginToMain, sender: self)
	}
	
	@IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {
		print("unwinding to login")
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let id = segue.identifier
		{
			print("Seguing to \(id)")
			
			
		}
	}
}
