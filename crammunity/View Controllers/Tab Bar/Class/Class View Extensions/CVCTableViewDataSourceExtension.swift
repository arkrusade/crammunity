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
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let ms = chapters[section].messages ?? []
		return ms.count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// 1
		// Return the number of sections.
		guard self.chapters.count != 0 else
		{
			return 1
		}
		return self.chapters.count
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		if tableView == self.notFriendTableView
//		{
//			return "Users"
//		}
//		else
//		{
//			return "Friends"
//		}
		return self.currentChapter
		//TODO: change to array of chapters
	}

	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// Dequeue cell
		let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageViewCell
		
		
		//TODO:-Cells as constants
		// Unpack message from Firebase DataSnapshot
		let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
		let message = messageSnapshot.value as! Dictionary<String, String>
		let name = message[Constants.MessageFields.name] as String!
		cell.displayName = name
		if message["isReported"] == "true"
		{
			cell.isReported = true
		}
		else if let imageUrl = message[Constants.MessageFields.imageUrl] {
			var image = Constants.Images.defaultProfile
			if imageUrl.hasPrefix("gs://") {
				FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX){ (data, error) in
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
				
			else if let url = NSURL(string:imageUrl), data = NSData(contentsOfURL: url) {
				cell.imageView?.image = UIImage.init(data: data)
			}
			cell.profileImageView?.image = image
			//TODO: change to different cell
			//diff ways to download message
			cell.message = "loading..."
			cell.displayName = "Image"
		}
			
			
			
			
		else {
			let text = message[Constants.MessageFields.text] as String!
			if name != nil
			{
				cell.displayName = name + ": "
				cell.message = text
				cell.profileImageView?.image = Constants.Images.defaultProfile
				
				//TODO: change to loading prof pic from each message to loading from user
				//means putting photoUrl in user object
				if let profileUrl = message[Constants.MessageFields.profileUrl], url = NSURL(string:profileUrl), data = NSData(contentsOfURL: url) {
					cell.imageView?.image = UIImage(data: data)
				}
			}
			else{
				ErrorHandling.defaultErrorHandler("missing name")
			}
		}
		
		cell.messageRef = messageSnapshot.ref
		cell.presentingViewController = self
		return cell
	}

}
