//
//  Chapter.swift
//  crammunity
//
//  Created by Clara Hwang on 8/9/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

import Firebase
class Chapter {
	var UID: String!
	var name: String?
	var messages: [ChatTextMessage]? = []
	var ref: FIRDatabaseReference!
	var cramClass: Class?
//	init()
//	{
//		name = "Cool Chapter Name"
//		ref = Constants.Firebase.rootRef
//	}
	init(uid: String, name: String, messages: [ChatTextMessage], ref: FIRDatabaseReference, cramClass: Class) {
		self.UID = uid
		self.name = name
		self.messages = messages
		self.ref = ref
		self.cramClass = cramClass
		
	}
	init(snapshot: FIRDataSnapshot)
	{
		UID = snapshot.key
		ref = snapshot.ref
		name = (snapshot.value as AnyObject).value(forKey: ChapterFKs.name) as? String
		if snapshot.hasChild(ChapterFKs.MessagesArray) {
			let ms = snapshot.childSnapshot(forPath: ChapterFKs.MessagesArray)
			for childSnap in ms.children
			{
				self.messages?.append(ChatTextMessage(snapshot: childSnap as! FIRDataSnapshot))
			}
		}
		
		
	}
	func addTextMessage(_ message: ChatTextMessage)
	{
		if messages != nil {
			self.messages!.append(message)
		}
		else {
			self.messages = [message]
		}
	}

	//TODO: beware of async
//	init(chapterRef: FIRDatabaseReference)
//	{
//		chapterRef.observeSingleEvent(of: .value, with:  {(snapshot) -> Void in
//			self.setFromSnapshot(snapshot)
//            
//			
//		})
//		
//	}
}
