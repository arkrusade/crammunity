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
	@IBOutlet weak var LoginButton: UIButton!
	@IBAction func LoginButtonTouched(sender: AnyObject) {
		//TODO: add checks for proper email, pass
		//also with sign in
		FIRAuth.auth()!.signInWithEmail(EmailTextField.text!, password: PasswordTextField.text!) { (user, error) in
			if let error = error {
				print("Sign in failed:", error.localizedDescription)
			} else {
				print ("Signed in with uid:", user!.uid)
			}
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		print("login view loaded")
	}
	@IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {
		print("unwinding to login")
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let id = segue.identifier
		{
			print("Seguing to \(id)")
			
//			if(id == "SignUp")
//			{
//				print("seguing to signup")
//			}
		}
	}
}
