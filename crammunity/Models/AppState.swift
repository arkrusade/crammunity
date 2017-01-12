//
//  AppState.swift
//  crammunity
//
//  Created by Clara Hwang on 7/13/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import AlamofireImage
import Alamofire
import UIKit
import Firebase
class AppState: NSObject {
	
	static let sharedInstance = AppState()
	
	var signedIn = false {
		didSet {
			if !signedIn {
				displayName = nil
				uid = nil
				photoURL = nil
				userRef = nil
			}
		}
	}
	
	var displayName: String?
	var uid: String?
	var photoURL: URL?
	var userRef: FIRDatabaseReference?

	
	func getProfileImage(_ callback: @escaping (UIImage?, NSError?) -> Void) {
		if let imageURL = photoURL
		{
            //TODO: optional
			if imageURL.absoluteString.hasPrefix("gs://") {
				FIRStorage.storage().reference(forURL: imageURL.absoluteString).data(withMaxSize: INT64_MAX){ (data, error) in
					if let error = error {
						ErrorHandling.defaultErrorHandler(error)
						return
					}
					callback(UIImage(data: data!), nil)
				}
			}
			else{
			Alamofire.request(.GET,imageURL).response(){
				(_, _, data, error) in
				guard error == nil else {
					callback(nil, error)
					return
				}
				let image = UIImage(data: data! as Data)
				callback(image, nil)
			}
			}
		}
	}
}
