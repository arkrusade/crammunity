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
	@IBAction func didTapAddPhoto(_ sender: AnyObject) {
		
		let picker = UIImagePickerController()
		picker.delegate = self
		if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
			picker.sourceType = UIImagePickerControllerSourceType.camera
		} else {
			picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
		}
		
		present(picker, animated: true, completion:nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		picker.dismiss(animated: true, completion:nil)
		
		// if it's a photo from the library, not an image from the camera
		if /*#available(iOS 8.0, *),*/ let referenceUrl = info[UIImagePickerControllerReferenceURL] {
			let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceUrl as! URL], options: nil)
			let asset = assets.firstObject
			asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
				let imageFile = contentEditingInput?.fullSizeImageURL
				let filePath = "\(Constants.Firebase.currentUser.uid)/\((Date.timeIntervalSinceReferenceDate * 1000))/\((referenceUrl as AnyObject).lastPathComponent!)"
				self.storageRef.child(filePath)
					.putFile(imageFile!, metadata: nil) { (metadata, error) in
						if let error = error {
							ErrorHandling.defaultErrorHandler("Error uploading image", desc: error.description)
							return
						}
						self.sendMessage([MessageFKs.imageURL: self.storageRef.child((metadata?.path)!).description])
				}
			})
		}
		else {
			let image = info[UIImagePickerControllerOriginalImage] as! UIImage
			let imageData = UIImageJPEGRepresentation(image, 0.8)
			let imagePath = (Constants.Firebase.currentUser.uid) +
				"/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
			let metadata = FIRStorageMetadata()
			metadata.contentType = "image/jpeg"
			self.storageRef.child(imagePath)
				.put(imageData!, metadata: metadata) { (metadata, error) in
					if let error = error {
						ErrorHandling.defaultErrorHandler("Error uploading image", desc: error.description)
						return
					}
					self.sendMessage([MessageFKs.imageURL: self.storageRef.child((metadata?.path)!).description])
			}
		}
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion:nil)
	}
}
