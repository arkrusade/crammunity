//
//  ChatTextMessage.swift
//  crammunity
//
//  Created by Clara Hwang on 8/9/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Firebase
struct ChatTextMessage {
	var UID: String!
	var message: String?
//	var user: User? {
//		didSet{
//			username = user?.username
//		}
//	}
	var username: String?
	var chapter: String?
	//	var chatViewCell: MessageViewCell
	
	mutating func setFromSnapshot(snapshot: FIRDataSnapshot)
	{
		let message: [String: String] = snapshot.value as! NSDictionary as! [String : String]

		self.UID = snapshot.key
		//		self.user = user
		self.username = message["name"]
		self.message = message["text"]
		self.chapter = message["chapter"]
	}
	
	init(uid: String, username: String?, message: String?, chapter: String?) {
		self.UID = uid
//		self.user = user
		self.username = username
		self.message = message
		self.chapter = chapter
	}
	init(snapshot: FIRDataSnapshot)
	{
		let message: [String: String] = snapshot.value as! NSDictionary as! [String : String]
		self.init(uid: snapshot.key, username: message["name"], message: message["text"], chapter: message["chapter"])
		
	}
	init(ref: FIRDatabaseReference)
	{
		ref.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
			self.setFromSnapshot(snapshot)
		})
	}
}
//TODO