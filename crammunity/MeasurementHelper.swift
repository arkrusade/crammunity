//
//  MeasurementHelper.swift
//  crammunity
//
//  Created by Clara Hwang on 7/13/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Firebase
import FirebaseAnalytics
class MeasurementHelper: NSObject {
	
	static func sendLoginEvent() {
		FIRAnalytics.logEvent(withName: kFIREventLogin, parameters: nil)
	}
	
	static func sendLogoutEvent() {
		FIRAnalytics.logEvent(withName: "logout", parameters: nil)
	}
	
	static func sendMessageEvent() {
		FIRAnalytics.logEvent(withName: "message", parameters: nil)
	}
}
//TODO: add with class creation, images sent, 
