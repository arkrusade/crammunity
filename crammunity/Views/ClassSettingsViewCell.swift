//
//  ClassSettingsViewCell.swift
//  crammunity
//
//  Created by Clara Hwang on 8/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit


class ClassSettingsViewCell: UITableViewCell {
	var segueID: String! = ""
	var title: String!
	@IBOutlet weak var settingButton: UIButton!
	
	@IBAction func onButtonTap(_ sender: AnyObject)
	{
		let window = UIApplication.shared.windows[0]
		window.rootViewController?.performSegue(withIdentifier: segueID, sender: self)
	}
}
