//
//  CVCImagePickerExtension.swift
//  crammunity
//
//  Created by Clara Hwang on 8/2/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Photos
import Firebase
extension ClassViewController: UIImagePickerControllerDelegate
{
	// MARK: - Image Picker
	//TODO: add image download/preview
	@IBAction func didTapAddPhoto(sender: AnyObject) {
		
		let picker = UIImagePickerController()
		picker.delegate = self
		if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
			picker.sourceType = UIImagePickerControllerSourceType.Camera
		} else {
			picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		}
		
		presentViewController(picker, animated: true, completion:nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		picker.dismissViewControllerAnimated(true, completion:nil)
		
		// if it's a photo from the library, not an image from the camera
		if /*#available(iOS 8.0, *),*/ let referenceUrl = info[UIImagePickerControllerReferenceURL] {
			let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl as! NSURL], options: nil)
			let asset = assets.firstObject
			asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
				let imageFile = contentEditingInput?.fullSizeImageURL
				let filePath = "\((FIRAuth.auth()?.currentUser!.uid)!)/\((NSDate.timeIntervalSinceReferenceDate() * 1000))/\(referenceUrl.lastPathComponent!)"
				self.storageRef.child(filePath)
					.putFile(imageFile!, metadata: nil) { (metadata, error) in
						if let error = error {
							ErrorHandling.defaultErrorHandler("Error uploading image", desc: error.description)
							return
						}
						self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description])
				}
			})
		} else {
			let image = info[UIImagePickerControllerOriginalImage] as! UIImage
			let imageData = UIImageJPEGRepresentation(image, 0.8)
			let imagePath = (FIRAuth.auth()?.currentUser!.uid)! +
				"/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000)).jpg"
			let metadata = FIRStorageMetadata()
			metadata.contentType = "image/jpeg"
			self.storageRef.child(imagePath)
				.putData(imageData!, metadata: metadata) { (metadata, error) in
					if let error = error {
						ErrorHandling.defaultErrorHandler("Error uploading image", desc: error.description)
						return
					}
					self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description])
			}
		}
	}
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		picker.dismissViewControllerAnimated(true, completion:nil)
	}
}