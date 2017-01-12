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
	func keyboardWillShow(_ notification: Notification) {
		let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.height
		UIView.animate(withDuration: 0.1, animations: { () -> Void in
			self.bottomConstraint.constant = keyboardHeight + self.lengthOfBottomConstraint - (self.tabBarController?.tabBar.frame.height)!
			self.view.layoutIfNeeded()
		})
	}
	
	func keyboardDidShow(_ notification: Notification) {
		self.scrollToBottomMessage()
	}
	
	func keyboardWillHide(_ notification: Notification) {
		UIView.animate(withDuration: 0.1, animations: { () -> Void in
			self.bottomConstraint.constant = self.lengthOfBottomConstraint
			self.view.layoutIfNeeded()
		})
	}
	@IBAction func viewTapped(_ sender: AnyObject) {
		self.textField.resignFirstResponder()
	}
	func scrollToBottomMessage() {
		if self.chapters.count == 0 {
			return
		}
		let bottomMessageIndex = IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1,
		                                     section: 0)
		self.tableView.scrollToRow(at: bottomMessageIndex, at: .bottom,
		                                      animated: true)
	}

}
