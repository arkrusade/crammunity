//
//  MessageCell.swift
//  crammunity
//
//  Created by Clara Hwang on 8/1/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase

class MessageViewCell: UITableViewCell {
	var presentingViewController: UIViewController!
	//TODO: change to long press for menu
	//like download image, copy, quote, chapter
	var displayName: String! {
		didSet {
			usernameLabel.text = displayName
		}
	}
	var chapter: String = ""
	var reportingUserUID: String! = nil
	var messageRef: FIRDatabaseReference!
	var message: String! = nil {
		didSet {
			textMessageLabel.text = message
		}
	}
	var isReported = false {
		didSet{
			if isReported{
				message = "has been reported"
			}
			reportButton.isEnabled = !isReported

			
		}
	}
//	var time: NSDate? {
//		didSet{
//			timeLabel.text = time?.description
//		}
//	}
	@IBOutlet weak var reportButton: UIButton!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var textMessageLabel: UILabel!
//	@IBOutlet weak var timeLabel: UILabel!
	//TODO: figure out time
	
	@IBOutlet weak var profileImageView: UIImageView!
	@IBAction func onReportButtonTap(_ sender: UIButton)
	{
		print("reporting")
		let alert = UIAlertController(title: "Report this message/user", message: "Describe the incident:\n (BEWARE: reports on messages are permanent)", preferredStyle: .alert)
		
		alert.addTextField(configurationHandler: { (textField) -> Void in
			textField.placeholder = "Don't abuse this"
		})
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
			let desc = alert.textFields![0].text
			if desc! != "" {
				self.reportingUserUID = FIRAuth.auth()!.currentUser!.uid
				FirebaseHelper.postReport(.Message, title: "Message Report by \(self.reportingUserUID)", reportingUserUID: self.reportingUserUID!, desc: desc!, ref: self.messageRef!)
				let confirm = UIAlertController(title: "Reported User", message: "", preferredStyle: .alert)
				confirm.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.presentingViewController.present(confirm, animated: true, completion: nil)
			}
			self.isReported = true
			
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		
		presentingViewController?.present(alert, animated: true, completion: nil)
		
	}
	
}
