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

        if let login = CacheHelper.sharedInstance.retrieveLogin()
        {
            EmailTextField.text = login.username
            PasswordTextField.text = login.password
            self.login(username: login.username, password: login.password)
        }
		
		
	}
    

    private func login(username: String, password: String) {
        
        FIRAuth.auth()!.signIn(withEmail: username, password: password) { (user, error) in
            if let error = error {
                if(error._code == 17008)
                {
                    ErrorHandling.defaultError(self.InvalidLoginTitle, desc: "Invalid email", sender: self)
                }
                else if(error._code == 17009)
                {
                    ErrorHandling.defaultError(self.InvalidLoginTitle, desc: "Invalid email/password combination", sender: self)
                }
                else if(error._code == 17011)
                {
                    ErrorHandling.defaultError(self.InvalidLoginTitle, desc: "User does not exist", sender: self)
                }
                else if(error._code == 17999)
                {
                    ErrorHandling.defaultError(self.InvalidLoginTitle, error: error, sender: self)//(error.userInfo[NSUnderlyingErrorKey]?.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as! NSDictionary).value(forKey: "message") as! String)
                }
                    //successful sign in
                else {
                    ErrorHandling.defaultError(self.InvalidLoginTitle, desc: "Unknown error: \(error)", sender: self)
                }
                
            } else {
                print ("Signed in with uid:", user!.uid)
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
		guard PasswordTextField.text != "" && EmailTextField.text != nil else {
            ErrorHandling.defaultError(InvalidLoginTitle, desc: "Missing Values", sender: self)
			return
		}
		login(username: EmailTextField.text!, password: PasswordTextField.text!)
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
					ErrorHandling.defaultError("Password Reset Error", desc: error.localizedDescription, sender: self)
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
		
//        if CacheHelper.sharedInstance.retrieveLogin() == nil {
            CacheHelper.sharedInstance.storeLogin(EmailTextField.text!, password: PasswordTextField.text!)
//        }
		
		//TODO: make this cleaner, and move to appstate
		Constants.Firebase.currentUser = (FIRAuth.auth()?.currentUser)!
		Constants.Firebase.FriendsArray = Constants.Firebase.UserArray.child((Constants.Firebase.currentUser.uid)).child("friends")
		FirebaseHelper.shared.friendsRef = Constants.Firebase.FriendsArray
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
                EmailTextField.text = ""
                PasswordTextField.text = ""
				self.isSignedUp = false
			}
			
		}
	}
}
extension LoginViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if EmailTextField.isFirstResponder
        {
            PasswordTextField.becomeFirstResponder()
            return true
        }
        else if PasswordTextField.isFirstResponder
        {
            PasswordTextField.resignFirstResponder()
            onLoginButtonTap(self)
            return true
        }
        return false
    }

}
