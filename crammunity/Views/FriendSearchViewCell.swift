//
//  FriendSearchViewCell.swift
//  crammunity
//
//  Created by Clara Hwang on 7/23/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase

class FriendSearchViewCell: UITableViewCell {
	@IBOutlet weak var friendButton: UIButton!
	
	var user = FIRDataSnapshot()
	
	@IBOutlet weak var usernameLabel: UILabel!
	
	@IBAction func onFriendButtonTapped(sender: UIButton) {
		print("adding friend")
		Constants.Firebase.UserArray.child("sD2ME5OT5Og5n2EreB6MUxTVCMs1").observeEventType(.Value) { (snapshot) -> Void in
				FirebaseHelper.addFriend(snapshot)
			
		}
		
	}
	
	
	func isFriendWithUser() -> Bool
	{
		return false
	}
}