//
//  Constants.swift
//  crammunity
//
//  Created by Clara Hwang on 7/13/16.
//  Copyright © 2016 orctech. All rights reserved.
//

struct Constants {
	
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
	struct CramClass {
		static let CramClass = "class"
		static let CramClassName = "name"
		static let CramClassMessages = "messages"
	}
	
	struct Firebase {
		static let UserArray = "users"
		static let CramClassArray = "classes"
	}
	
	struct User {
		static let UserEmail = "email"
		static let Username = "username"
		static let UserPassword = "password"
	}
	
	

}