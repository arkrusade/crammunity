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
class SignUpViewController: UIViewController {

	@IBOutlet weak var SignUpButton: UIButton!
	
	@IBOutlet weak var EmailTextField: UITextField!
	@IBOutlet weak var UsernameTextField: UITextField!
	@IBOutlet weak var PasswordTextField: UITextField!
	@IBOutlet weak var PasswordConfirmTextField: UITextField!
	
	@IBAction func SignUpButtonTapped()
	{
		FIRAuth.auth()?.createUserWithEmail(EmailTextField.text!, password: PasswordTextField.text!) { (user, error) in
			if let error = error {
				print("Create user failed:", error.localizedDescription)
			} else {
				
				self.signedUp(user)
			}
		}
	}
	func signedUp(user: FIRUser?)
	{
		let username = self.UsernameTextField.text!
		FIRDatabase.database().reference().child ("users").child(user!.uid).setValue(["username": username])
		print ("Created user with uid: \(user!.uid) and username: \(username)")
		
		let changeRequest = user!.profileChangeRequest()
//		changeRequest.displayName = user!.email!.componentsSeparatedByString("@")[0]
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
