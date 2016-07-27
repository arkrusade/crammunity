//
//  Constants.swift
//  crammunity
//
//  Created by Clara Hwang on 7/13/16.
//  Copyright © 2016 orctech. All rights reserved.
//
import Firebase
struct Constants {
	static let emailRegex:String = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$"
	struct NotificationKeys {
		static let SignedIn = "onSignInCompleted"
	}
	
	struct Segues {
		static let LoginToMain = "LoginToMain"
		static let SignUpToMain = "SignUpToMain"
		static let MainToClassChat = "MainToClassChat"
	}
	
	struct MessageFields {
		static let name = "name"
		static let text = "text"
		static let photoUrl = "photoUrl"
		static let imageUrl = "imageUrl"
	}
//	struct CramClass {
		static let Class = "class"
		static let Members = "members"
		static let ClassName = "className"
		static let Messages = "messages"
//	}
	
	struct Firebase {
		static let rootRef = FIRDatabase.database().reference()
		static let CramClassArray = FIRDatabase.database().reference().child("classes")
		static let UserArray = FIRDatabase.database().reference().child("users")
	}
	
	struct Images {
		static let add = UIImage(named: "add")
		static let camera = UIImage(named: "camera")
		static let check = UIImage(named: "check")
		static let defaultProfile = UIImage(named: "ic_account_circle")
		static let remove = UIImage(named: "remove")

	}
//	static let currentUser = (FIRAuth.auth()?.currentUser)!
//	struct User {
		static let Email = "email"
		static let Username = "username"
		static let Password = "password"
//	}
	
	

}