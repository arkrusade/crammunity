//
//  FirebaseHelper.swift
//  crammunity
//
//  Created by Clara Hwang on 7/11/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import FirebaseAuth

class FirebaseHelper
{
	
	static let FirebaseArrayOfUsers = "users"
	static let FirebaseUsername = "username"
	static let FirebaseClassChat = "class"
	static let FirebaseChatMessage = "message"
	static let FirebasePasswordForUser = "password"
	static let FirebaseEmailForUser = "email"
	
	static func createUser(email: String, pw: String)
	{
		FIRAuth.auth()?.createUserWithEmail(email, password: pw, completion: { result, error in
			
			if error != nil {
				print("error creating user")
			} else {
				let uid = result?.uid
				NSUserDefaults.standardUserDefaults().setValue(uid, forKey: "uid")
				//pass the parameters to another function to auth the user
//				self.authUserWithAuthData( email, password: pw )
			}
			
		})
	}
//		vc.ref.child("users").child(User.newID()).setValue(["username": username])
//		FIRAuth.auth()?.createUserWithEmail(email, password: pw) { (user, error) in
//			if error != nil {
//				print("error creating user")
//			} else {
//				let uid = result["uid"] as! String
//				NSUserDefaults.standardUserDefaults().setValue(uid, forKey: "uid")
//				//pass the parameters to another function to auth the user
//				self.authUserWithAuthData( email, password: pw )
//			}		}
//	}
}