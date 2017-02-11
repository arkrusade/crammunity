//
//  ChatTextMessage.swift
//  crammunity
//
//  Created by Clara Hwang on 8/9/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Firebase
class ChatTextMessage {
//	var UID: String!
	var messageRef: FIRDatabaseReference!
	var text: String?
	var username: String?
	var chapterUID: String? //TODO: is this necessary?
	var userUID: String?
	var isReported: Bool = false
	var imageURL: String?
	
//	func getAsDict() -> [String: String]
//	{
//		var mdata = [MessageFKs.username: username!]
//		mdata[MessageFKs.text] = text!
//		mdata[MessageFKs.chapter] = chapterUID!
//
//		return mdata
//	}
	
	func setFromDict(_ dict: [String: String])
	{
		for key in dict.keys {
			switch key {
			case MessageFKs.username:
				self.username = dict[key]
			
			//TODO: is this necessary?
//			case MessageFKs.UID:
//				self.UID = dict[key]
				
			case MessageFKs.text:
				self.text = dict[key]
			case MessageFKs.isReported:
				self.isReported = true
			case MessageFKs.chapter:
				self.chapterUID = dict[key]
			case MessageFKs.userUID:
				self.userUID = dict[key]
			case MessageFKs.imageURL:
				self.imageURL = dict[key]
				//TODO: fix to match
			default:
				print("non matching key \(key)")
			}
		}
		
		
	}//TODO: clean up
    convenience init(_ snapshot: FIRDataSnapshot)
	{
		let message = ChatTextMessage(dict: snapshot.value as! [String : String])
		self.init(ref: snapshot.ref, username: message.username, message: message.text, chapterUID: message.chapterUID)
		self.imageURL = message.imageURL
		self.isReported = message.isReported

	}
	init(dict: [String: String])
	{
		self.setFromDict(dict)
	}
	init(ref: FIRDatabaseReference, username: String?, message: String?, chapterUID: String?) {
		messageRef = ref
//		self.UID = uid
//		self.user = user
		self.username = username
		self.text = message
		self.chapterUID = chapterUID
	}
	convenience init(snapshot: FIRDataSnapshot)
	{
		let message: [String: String] = snapshot.value as! NSDictionary as! [String : String]
		self.init(ref: snapshot.ref, username: message["name"], message: message["text"], chapterUID: message["chapter"])
		
	}
//	init(ref: FIRDatabaseReference)
//	{
//		ref.observeSingleEvent(of: .value, with: {(snapshot) -> Void in
//			self.init(snapshot)
//		})
//	}
}
//TODO
