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
	var presentingViewController: UIViewController?
	//TODO: change to long press for menu
	//like download image, copy, quote, chapter
	var displayName: String? {
		didSet {
			usernameLabel.text = displayName
		}
	}
	var userUID: String? = nil
	var messageRef: FIRDatabaseReference?
	var message: String? = nil {
		didSet {
			textMessageLabel.text = message
		}
	}
//	var time: NSDate? {
//		didSet{
//			timeLabel.text = time?.description
//		}
//	}
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var textMessageLabel: UILabel!
//	@IBOutlet weak var timeLabel: UILabel!

	@IBOutlet weak var profileImageView: UIImageView!
	@IBAction func onReportButtonTap(sender: UIButton)
	{
		print("reporting")
		//1. Create the alert controller.
		let alert = UIAlertController(title: "Report this", message: "Enter a description", preferredStyle: .Alert)
		
		//2. Add the text field. You can configure it however you need.
		alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
			textField.text = "Some default text."
		})
		
		//3. Grab the value from the text field, and print it when the user clicks OK.
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
			let desc = alert.textFields![0].text
			FirebaseHelper.postReport(.Message, title: "Message Report by \(FIRAuth.auth()!.currentUser!.uid)", userUID: self.userUID!, desc: desc!, ref: self.messageRef!)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		// 4. Present the alert.
		presentingViewController?.presentViewController(alert, animated: true, completion: nil)
//		presentViewController(alert, animated: true, completion: nil)
		
	}
	
}
