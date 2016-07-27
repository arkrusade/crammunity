//
//  AppState.swift
//  crammunity
//
//  Created by Clara Hwang on 7/13/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation

class AppState: NSObject {
	
	static let sharedInstance = AppState()
	
	var signedIn = false
	var displayName: String?
	var uid: String?
	var photoUrl: NSURL?
}
