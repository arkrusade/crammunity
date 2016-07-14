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
		FIRAnalytics.logEventWithName(kFIREventLogin, parameters: nil)
	}
	
	static func sendLogoutEvent() {
		FIRAnalytics.logEventWithName("logout", parameters: nil)
	}
	
	static func sendMessageEvent() {
		FIRAnalytics.logEventWithName("message", parameters: nil)
	}
}
