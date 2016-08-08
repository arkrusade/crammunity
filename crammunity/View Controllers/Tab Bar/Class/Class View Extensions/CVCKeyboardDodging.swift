//
//  CVCKeyboardDodging.swift
//  crammunity
//
//  Created by Clara Hwang on 8/5/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
extension ClassViewController {
	// MARK: Keyboard Dodging Logic
	func keyboardWillShow(notification: NSNotification) {
		let keyboardHeight = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.height
		UIView.animateWithDuration(0.1, animations: { () -> Void in
			self.bottomConstraint.constant = keyboardHeight! + self.lengthOfBottomConstraint - (self.tabBarController?.tabBar.frame.height)!
			self.view.layoutIfNeeded()
		})
	}
	
	func keyboardDidShow(notification: NSNotification) {
		self.scrollToBottomMessage()
	}
	
	func keyboardWillHide(notification: NSNotification) {
		UIView.animateWithDuration(0.1, animations: { () -> Void in
			self.bottomConstraint.constant = self.lengthOfBottomConstraint
			self.view.layoutIfNeeded()
		})
	}
	@IBAction func viewTapped(sender: AnyObject) {
		self.textField.resignFirstResponder()
	}
	func scrollToBottomMessage() {
		if self.messages.count == 0 {
			return
		}
		let bottomMessageIndex = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1,
		                                     inSection: 0)
		self.tableView.scrollToRowAtIndexPath(bottomMessageIndex, atScrollPosition: .Bottom,
		                                      animated: true)
	}

}