//
//  Constants.swift
//  crammunity
//
//  Created by Clara Hwang on 7/13/16.
//  Copyright © 2016 orctech. All rights reserved.
//
import Firebase


typealias ErrorRef = (title: String, desc: String, ref: FIRDatabaseReference, time: NSDate)

struct ErrorFirebaseKeys {
	static let title = "title"
	static let desc = "description"
	static let ref = "referenceURL"
	static let time = "time"
}
struct ReportFirebaseKeys {
	static let title = "title"
	static let userUID = "userUID"
	static let desc = "description"
	static let ref = "reference"
	static let time = "time"
}
struct CramClassFKs {
	static let MembersArray = "members"
	static let name = "className"
	static let MessagesArray = "messages"
}

struct Constants {
	static let emailRegex:String = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$"
	struct NotificationKeys {
		static let SignedIn = "onSignInCompleted"
	}
	
	struct Segues {
		static let LoginToMain = "LoginToMain"
		static let SignUpToMain = "SignUpToMain"
		static let MainToClassChat = "MainToClassChat"
		static let ClassCreationToCrammatesAddition = "ClassCreationToCrammatesAddition"
		static let CramChatToCrammateAddition = "CramChatToCrammateAddition"
		static let CramChatToSettings = "CramChatToSettings"
	}
	
	struct MessageFields {
		static let name = "name"
		static let text = "text"
		static let photoUrl = "photoUrl"
		static let imageUrl = "imageUrl"
	}

	
	struct Firebase {
		static var currentUser = FIRAuth.auth()?.currentUser!
		static let rootRef = FIRDatabase.database().reference()
		static let CramClassArray = FIRDatabase.database().reference().child("classes")
		static let UserArray = FIRDatabase.database().reference().child("users")
		static let UserSearchArray = FIRDatabase.database().reference().child("userSearch")
		static let ErrorsArray = FIRDatabase.database().reference().child("errors")
		static let ReportsArray = FIRDatabase.database().reference().child("reports")
		static let MessageReports = ReportsArray.child("messageReports")
		static let FriendsArray = UserArray.child((currentUser?.uid)!).child("friends")
	}
	
	struct Images {
		static let add = UIImage(named: "add")
		static let camera = UIImage(named: "camera")
		static let check = UIImage(named: "check")
		static let defaultProfile = UIImage(named: "ic_account_circle")
		static let remove = UIImage(named: "remove")
		static let settings = UIImage(named: "settings")

	}
//	static let currentUser = (FIRAuth.auth()?.currentUser)!
//	struct User {
		static let Email = "email"
		static let Username = "username"
		static let Password = "password"
//	}
	
	

}