//
//  CVCTableViewDataSourceExtension.swift
//  crammunity
//
//  Created by Clara Hwang on 8/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
extension ClassViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard !chapters.isEmpty else {
			return 0
		}
		if let ms = chapters[section].messages
		{
			return ms.count
		}
		else
		{
			return 0
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		// 1
		// Return the number of sections.
		guard self.chapters.count != 0 else
		{
			return 1
		}
		return self.chapters.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard !chapters.isEmpty else {
			return ""
		}
		
		return chapters[section].name
		//TODO: change to array of chapters
	}

	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//TODO: deal with non chapter messages
		// Dequeue cell
		let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageViewCell
		
		
		//TODO:-Cells as constants
		// Unpack message from Firebase DataSnapshot
		//TODO: edit chapter here
//		let messageSnapshot: FIRDataSnapshot! =
		
		let message = self.chapters[indexPath.section].messages![indexPath.row]
//		let message = messageSnapshot.value as! Dictionary<String, String>
		let name = message.username
		cell.displayName = name
		if message.isReported
		{
			cell.isReported = true
		}
		else if let imageURL = message.imageURL {
			var image = Constants.Images.defaultProfile
			if imageURL.hasPrefix("gs://") {
				FIRStorage.storage().reference(forURL: imageURL).data(withMaxSize: INT64_MAX){ (data, error) in
					if let error = error {
						ErrorHandling.defaultErrorHandler("Error downloading image", desc: error.description)
						
						return
					}
					image = UIImage(data: data!)
					cell.profileImageView?.image = image
					cell.displayName = "sent by: \(name)"
					cell.message = ""
				}
			}
				
			else if let url = URL(string:imageURL), let data = try? Data(contentsOf: url) {
				cell.imageView?.image = UIImage.init(data: data)
			}
			cell.profileImageView?.image = image
			//TODO: change to different cell
			//diff ways to download message
			cell.message = "loading..."
			cell.displayName = "Image"
		}
			
			
			
			
		else {
			let text = message.text as String!
			if name != nil
			{
				cell.displayName = name! + ": "
				cell.message = text
				cell.profileImageView?.image = Constants.Images.defaultProfile
				
				//TODO: change to loading prof pic from each message to loading from user
				//means putting photoUrl in user object
//				if let photoURL = message[MessageFKs.photoURL], url = NSURL(string:photoURL), data = NSData(contentsOfURL: url) {
//					cell.imageView?.image = UIImage(data: data)
//				}
				
			}
			else{
				ErrorHandling.defaultErrorHandler("missing name")
			}
		}
		
		cell.messageRef = message.messageRef
		cell.presentingViewController = self
		return cell
	}

}
