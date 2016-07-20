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

//class Regex {
//	let internalExpression: NSRegularExpression
//	let pattern: String
//	
//	init(_ pattern: String) {
//		self.pattern = pattern
//		var error: NSError?
//		self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)
//	}
//	
//	func test(input: String) -> Bool {
//		let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, countElements(input)))
//		return matches.count > 0
//	}
//}
class SignUpViewController: UIViewController {

//	@IBOutlet weak var SignUpButton: UIButton!
	
	@IBOutlet weak var EmailTextField: UITextField!
	@IBOutlet weak var UsernameTextField: UITextField!
	@IBOutlet weak var PasswordTextField: UITextField!
	@IBOutlet weak var PasswordConfirmTextField: UITextField!
	
	@IBAction func SignUpButtonTapped()
	{
		//TODO: change to alerts
		if UsernameTextField.text?.characters.count < 6 {
			print("Must have username longer than 6 characters")
			return
		}
		else if PasswordTextField.text?.characters.count < 8 || PasswordConfirmTextField.text?.characters.count < 8 {
			print("Must have password longer than 8 characters")
			return
		}
		else if (!(EmailTextField.text?.characters.contains("@") ?? false)) {
			print("Email must have @ symbol")
			return
		}
		else if (EmailTextField.text!.rangeOfString(Constants.emailRegex, options: .RegularExpressionSearch)) == nil
		{
			print("Must be valid email")
			return
		}
		else if (PasswordTextField.text! != PasswordConfirmTextField.text!) {
			print("Passwords must match")
			return
		}
		else {
			FIRAuth.auth()?.createUserWithEmail(EmailTextField.text!, password: PasswordTextField.text!) { (user, error) in
				if let error = error {
					print("Create user failed:", error.localizedDescription)
				} else {
					self.signedUp(user)
				}
			}
		}
	}
	func signedUp(user: FIRUser?)
	{
		let username = self.UsernameTextField.text!
		Constants.Firebase.UserArray.child(user!.uid).setValue(["username": username])
		print ("Created user with uid: \(user!.uid) and username: \(username)")
		
		let changeRequest = user!.profileChangeRequest()
		changeRequest.displayName = username
		changeRequest.commitChangesWithCompletion(){ (error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
		}
		MeasurementHelper.sendLoginEvent()//analytics
		
		AppState.sharedInstance.displayName = user?.displayName ?? user?.email
		AppState.sharedInstance.photoUrl = user?.photoURL
		AppState.sharedInstance.signedIn = true
		NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
		self.performSegueWithIdentifier(Constants.Segues.SignUpToMain, sender: nil)
		
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
