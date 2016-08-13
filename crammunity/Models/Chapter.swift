//
//  Chapter.swift
//  crammunity
//
//  Created by Clara Hwang on 8/9/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

import Firebase
struct Chapter {
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
		name = snapshot.value?.valueForKey(ChapterFKs.name) as? String
		if snapshot.hasChild(ChapterFKs.MessagesArray) {
			let ms = snapshot.childSnapshotForPath(ChapterFKs.MessagesArray)
			for childSnap in ms.children
			{
				self.messages?.append(ChatTextMessage(snapshot: childSnap as! FIRDataSnapshot))
			}
		}
		
		
	}
	mutating func addTextMessage(message: ChatTextMessage)
	{
		if messages != nil {
			self.messages!.append(message)
		}
		else {
			self.messages = [message]
		}
	}
	mutating func setFromSnapshot(snapshot: FIRDataSnapshot) {
		self = Chapter.init(snapshot: snapshot)
	}
	//TODO: beware of async
	init(chapterRef: FIRDatabaseReference)
	{
		chapterRef.observeSingleEventOfType(.Value, withBlock:  {(snapshot) -> Void in
			self.setFromSnapshot(snapshot)
			
		})
		
	}
}
