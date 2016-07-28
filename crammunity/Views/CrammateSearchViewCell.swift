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
	
	@IBAction func onAddCrammateButtonTapped(sender: UIButton) {
		if !isClassmate
		{
			print("adding classmates between cur: \(FIRAuth.auth()?.currentUser!.uid)) and other: \(user.key)")
			delegate?.cell(self, didSelectAddCrammateUser: user)
			addToClassButton.setImage(Constants.Images.add, forState: .Normal)
		}
		else
		{
			print("removing friends between cur: \(FIRAuth.auth()?.currentUser!.uid)) and other: \(user.key)")
			delegate?.cell(self, didSelectRemoveCrammateUser: user)
			addToClassButton.setImage(Constants.Images.remove, forState: .Normal)
		}
	}
}
