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
                CacheHelper.clearAll()
			}
		}
	}
	
	var displayName: String?
	var uid: String?
	var photoURL: URL?
	var userRef: FIRDatabaseReference?

	
	func getProfileImage(_ callback: @escaping (UIImage?, Error?) -> Void) {
		if let imageURL = photoURL
		{
            //TODO: optional
			if imageURL.absoluteString.hasPrefix("gs://") {
				FIRStorage.storage().reference(forURL: imageURL.absoluteString).data(withMaxSize: INT64_MAX){ (data, error) in
					if let error = error {
						ErrorHandling.defaultError(error)
						return
					}
					callback(UIImage(data: data!), nil)
				}
			}
			else{
                let r = Alamofire.request(imageURL)
                r.response(completionHandler: { (response) in
                    
                        guard response.error != nil && response.data != nil else {
                            callback(nil, response.error)
                            return
                        }
                        if let image = UIImage(data: response.data!)
                        {
                            callback(image, nil)
                        }
                
                })

			}
		}
	}
}
