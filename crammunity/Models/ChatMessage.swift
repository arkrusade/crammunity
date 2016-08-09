//
//  ChatMessage.swift
//  crammunity
//
//  Created by Clara Hwang on 8/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
class ChatMessage {
	var message: String?
	var user: User? {
		didSet{
			username = user?.username
		}
	}
	var username: String?
	var chapter: String?
//	var chatViewCell: MessageViewCell 
	
	init(user: User, message: String, chapter: String) {
		self.user = user
		self.message = message
		self.chapter = chapter
	}
}
//TODO