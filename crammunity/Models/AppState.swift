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
import FirebaseStorage
class AppState: NSObject {
	
	static let sharedInstance = AppState()
	
	var signedIn = false
	
	var displayName: String?
	var uid: String?
	var photoUrl: NSURL?
	
		
				
//				imageGet(request, callback: {(image, errorString) -> Void in
//					guard errorString == nil else {
//						ErrorHandling.defaultErrorHandler(NSError.init(domain: "Image downloading", code: 0, userInfo: ["desc":"invalid profile image URL"]))
//						return
//					}
//					self.profileImage = image
//				})
		
		
	
	
	
	func getProfileImage(callback: (UIImage?, NSError?) -> Void) {
		if let imageUrl = photoUrl
		{
			if imageUrl.absoluteString.hasPrefix("gs://") {
				FIRStorage.storage().referenceForURL(imageUrl.absoluteString).dataWithMaxSize(INT64_MAX){ (data, error) in
					if let error = error {
						ErrorHandling.defaultErrorHandler(error)
						return
					}
					callback(UIImage(data: data!), nil)

				}
			}
			else{
			Alamofire.request(.GET,imageUrl).response(){
				(_, _, data, error) in
				guard error == nil else {
					callback(nil, error)
					return
				}
				let image = UIImage(data: data! as NSData)
				callback(image, nil)
			}
			}
		}
	}
}
