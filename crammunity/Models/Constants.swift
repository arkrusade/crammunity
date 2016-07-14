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
}