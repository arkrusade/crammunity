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
		return messages.count
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
				
				if let photoUrl = message[Constants.MessageFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
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
