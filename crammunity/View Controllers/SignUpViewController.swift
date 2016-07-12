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
				FIRDatabase.database().reference().child("users").child(user!.uid).setValue(["username": self.UsernameTextField.text!])
				print ("Created user with uid: \(user!.uid) and username: \(self.UsernameTextField.text!)")
			}
		}
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
