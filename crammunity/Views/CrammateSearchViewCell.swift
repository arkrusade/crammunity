//
//  CramClassSearchViewCell.swift
//  crammunity
//
//  Created by Clara Hwang on 7/27/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
class CrammateSearchViewCell: UITableViewCell {
	@IBOutlet weak var addToClassButton: UIButton!
	
	var user = FIRDataSnapshot()
	var isClassmate = false
	
	@IBOutlet weak var usernameLabel: UILabel!
	
	var delegate: CrammateAdditionViewCellDelegate?
	
	@IBAction func onAddCrammateButtonTapped(_ sender: UIButton) {
		if !isClassmate
		{
			print("adding classmates between cur: \(Constants.Firebase.currentUser.uid)) and other: \(user.key)")
			delegate?.cell(self, didSelectAddCrammateUser: user)
			addToClassButton.setImage(Constants.Images.add, for: UIControlState())
		}
		else
		{
			print("removing friends between cur: \(Constants.Firebase.currentUser.uid)) and other: \(user.key)")
			delegate?.cell(self, didSelectRemoveCrammateUser: user)
			addToClassButton.setImage(Constants.Images.remove, for: UIControlState())
		}
	}
}
