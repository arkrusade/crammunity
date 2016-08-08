//
//  CVCTextFieldDelegateExtension.swift
//  crammunity
//
//  Created by Clara Hwang on 8/5/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

extension ClassViewController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		let data = [Constants.MessageFields.text: textField.text! as String]
		sendMessage(data)
		textField.text! = ""
		return true
	}
	
	
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else { return true }
		
		let newLength = text.utf16.count + string.utf16.count - range.length
		return newLength <= self.msglength.integerValue // Bool
	}
}