//
//  SelfProfileViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/26/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase

class SelfProfileViewController: UIViewController {
	var email: String = ""
	var pass: String = ""
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var displayNameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var gradeTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!

	/*
nameTextField
displayNameTextField
emailTextField
gradeTextField
passwordTextField
*/
	@IBOutlet weak var profileImageView: UIImageView!
	
	@IBOutlet weak var displayNameButton: UIButton!
	@IBOutlet weak var emailButton: UIButton!
	@IBOutlet weak var gradeButton: UIButton!
	
	@IBOutlet weak var profileButton: UIButton!
	
//	@IBOutlet var textFieldArray: [UITextField]!
//TODO: didset with old and new active fields
//change to separate window or to tableview
	func becameFirstResponder(textField: UITextField)
	{
		switch textField {
		case nameTextField:
			displayNameTextField.userInteractionEnabled = false
			emailTextField.userInteractionEnabled = false
			gradeTextField.userInteractionEnabled = false
			passwordTextField.userInteractionEnabled = false
			passwordTextField.secureTextEntry = true
		case displayNameTextField:
			nameTextField.userInteractionEnabled = false
			emailTextField.userInteractionEnabled = false
			gradeTextField.userInteractionEnabled = false
			passwordTextField.userInteractionEnabled = false
			passwordTextField.secureTextEntry = true
		case emailTextField:
			displayNameTextField.userInteractionEnabled = false
			nameTextField.userInteractionEnabled = false
			gradeTextField.userInteractionEnabled = false
			passwordTextField.userInteractionEnabled = false
			passwordTextField.secureTextEntry = true
		case gradeTextField:
			displayNameTextField.userInteractionEnabled = false
			emailTextField.userInteractionEnabled = false
			nameTextField.userInteractionEnabled = false
			passwordTextField.userInteractionEnabled = false
			passwordTextField.secureTextEntry = true
		case passwordTextField:
			displayNameTextField.userInteractionEnabled = false
			emailTextField.userInteractionEnabled = false
			gradeTextField.userInteractionEnabled = false
			nameTextField.userInteractionEnabled = false
			
		default:
			nameTextField.userInteractionEnabled = false
			displayNameTextField.userInteractionEnabled = false
			emailTextField.userInteractionEnabled = false
			gradeTextField.userInteractionEnabled = false
			passwordTextField.userInteractionEnabled = false
			passwordTextField.secureTextEntry = true
		}
	}
//	@IBAction func onEditNameButtonTap(sender: UIButton)
//	{
//		nameTextField.userInteractionEnabled = !nameTextField.userInteractionEnabled
//		if nameTextField.canBecomeFirstResponder() {
//			nameTextField.becomeFirstResponder()
//			self.becameFirstResponder(nameTextField)
//		}
//	}
	@IBAction func onEditDisplayNameButtonTap(sender: UIButton)
	{
		ErrorHandling.delayedFeatureAlert()

//		displayNameTextField.userInteractionEnabled = !displayNameTextField.userInteractionEnabled
//		if displayNameTextField.canBecomeFirstResponder() {
//			displayNameTextField.becomeFirstResponder()
//			self.becameFirstResponder(displayNameTextField)
//		}
	}
	@IBAction func onEditEmailButtonTap(sender: UIButton)
	{
		ErrorHandling.delayedFeatureAlert()

//		emailTextField.userInteractionEnabled = !emailTextField.userInteractionEnabled
//		if emailTextField.canBecomeFirstResponder() {
//			emailTextField.becomeFirstResponder()
//			self.becameFirstResponder(emailTextField)
//		}
	}
	@IBAction func onEditGradeButtonTap(sender: UIButton)
	{
		ErrorHandling.delayedFeatureAlert()
//		gradeTextField.userInteractionEnabled = !gradeTextField.userInteractionEnabled
//		if gradeTextField.canBecomeFirstResponder() {
//			gradeTextField.becomeFirstResponder()
//			self.becameFirstResponder(gradeTextField)
//		}
	}
	@IBAction func onEditProfilePictureButtonTap(sender: UIButton)
	{
		//TODO:		print("changing profile picture")
		ErrorHandling.delayedFeatureAlert()
//		if let user = FIRAuth.auth()?.currentUser {
//			let changeRequest = user.profileChangeRequest()
//			
//			//			changeRequest.displayName = "Jane Q. User"
//			changeRequest.photoURL =
//				NSURL(string: "http://2.bp.blogspot.com/-tJ2_NJor6_I/Ti9NIhFswUI/AAAAAAAAAdE/yiETNvP1c1g/s1600/Business+Card1.jpg")
//			changeRequest.commitChangesWithCompletion { error in
//				if let error = error {
//					ErrorHandling.defaultErrorHandler(error)
//				} else {
//					//					AppState.sharedInstance.photoURL = usera.photoURL
//					// Profile updated.
//				}
//			}
//		}
	}
	@IBAction func onEditPasswordButtonTap(sender: UIButton)
	{
		ErrorHandling.delayedFeatureAlert()
//		passwordTextField.userInteractionEnabled = !passwordTextField.userInteractionEnabled
//		if passwordTextField.canBecomeFirstResponder() {
//			passwordTextField.secureTextEntry = false
//			passwordTextField.becomeFirstResponder()
//			self.becameFirstResponder(passwordTextField)
//		}
		
	}
	
	
	@IBAction func signOut(sender: AnyObject) {
		let firebaseAuth = FIRAuth.auth()
		do {
			try firebaseAuth?.signOut()
			AppState.sharedInstance.signedIn = false
			MeasurementHelper.sendLogoutEvent()//send to analytics
			dismissViewControllerAnimated(false, completion: nil)

		} catch let signOutError as NSError {
			ErrorHandling.defaultErrorHandler("Error signing out", desc: "\(signOutError.description)")
		}
	}
	
//	@IBAction func makeRandomUser(sender: AnyObject) {
//		var emails: [String] = []
//		for i in 0...5
//		{
//			emails.append("user\(i)@gmail.com")
//		}
//		for i in 0...5
//		{
//			FIRAuth.auth()?.createUserWithEmail(emails[i], password: pass) { (user, error) in
//				if let error = error {
//					print("Create user failed:", error.localizedDescription)
//				} else {
//					let username = emails[i]
//					Constants.Firebase.UserSearchArray.child(user!.uid).setValue(["username": username])
//					print ("Created user with uid: \(user!.uid) and username: \(username) and displayName: \(user?.displayName)")
//				}
//			}
//		}
//		
//	}
	@IBOutlet weak var signOutButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		nameTextField.userInteractionEnabled = false
		displayNameTextField.userInteractionEnabled = false
		emailTextField.userInteractionEnabled = false
		gradeTextField.userInteractionEnabled = false
		passwordTextField.userInteractionEnabled = false
		loadProfile()
        // Do any additional setup after loading the view.
    }

	func loadProfile() {
		AppState.sharedInstance.getProfileImage() {(image, error) -> Void in
			guard image != nil else {
				self.profileImageView.image = Constants.Images.defaultProfile256
				return
			}
			self.profileImageView.image = image
		}
		displayNameTextField.text = AppState.sharedInstance.displayName
		emailTextField.text = FIRAuth.auth()?.currentUser?.email
		//TODO: finish these
		//make password segue to diff page
		
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
