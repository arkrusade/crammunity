//
//  ErrorHandling.swift
//  Makestagram
//
//  Created by Benjamin Encz on 4/10/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
//import ConvenienceKit

/**
This struct provides basic Error handling functionality.
*/
struct ErrorHandling {
	
	static let ErrorTitle           = "Error"
	static let ErrorOKButtonTitle   = "Ok"
	static let ErrorDefaultMessage  = "Something unexpected happened, sorry for that!"
	
	static let DelayedFeatureTitle		= "Delayed Feature"
	static let DelayedFeatureMessage	= "Sorry, this feature is not yet available"
	
	/**
	This default error handler presents an Alert View on the topmost View Controller
	*/
	static func delayedFeatureAlert()
	{
		let alert = UIAlertController(title: DelayedFeatureTitle, message: DelayedFeatureMessage, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.default, handler: nil))
		
		let window = UIApplication.shared.windows[0]
		window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
	}
	static func defaultErrorHandler(_ error: NSError) {
		let alert = UIAlertController(title: ErrorTitle, message: error.description, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.default, handler: nil))
		
		let window = UIApplication.shared.windows[0]
		window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
	}
	static func defaultErrorHandler(_ desc: String) {
		let alert = UIAlertController(title: ErrorTitle, message: desc, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.default, handler: nil))
		
		let window = UIApplication.shared.windows[0]
		window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
	}
	static func defaultErrorHandler(_ title: String, desc: String) {
		let alert = UIAlertController(title: title, message: desc, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.default, handler: nil))
		
		let window = UIApplication.shared.windows[0]
		window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
	}
	
	/**
	A PFBooleanResult callback block that only handles error cases. You can pass this to completion blocks of Parse Requests
	*/
	static func errorHandlingCallback(_ success: Bool, error: NSError?) -> Void {
		if let error = error {
			ErrorHandling.defaultErrorHandler(error)
		}
	}
	
}
