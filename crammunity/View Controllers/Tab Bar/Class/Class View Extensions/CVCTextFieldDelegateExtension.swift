//
//  CVCTextFieldDelegateExtension.swift
//  crammunity
//
//  Created by Clara Hwang on 8/5/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

extension ClassViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let data = [MessageFKs.text: textField.text! as String]
		sendMessage(data)
		textField.text! = ""
		return true
	}
	
	
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else { return true }
		
		let newLength = text.utf16.count + string.utf16.count - range.length
		return newLength <= self.msglength.intValue // Bool
	}
}
