//
//  ClassSettingsViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/29/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

class ClassSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//	@IBOutlet weak var tableView: UITableView!
	let settingsList: [(title: String, list: [String])] = [("Class Settings", ["Add Friends","Change Class Name"]),("Chapter Settings", ["Add Files"]),("Other",["Delete Class"])]

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var titleBar: UINavigationItem!

	
	override func viewDidLoad() {
		titleBar.title = "Settings"
		if AppState.sharedInstance.signedIn && AppState.sharedInstance.displayName == nil{
							ErrorHandling.defaultErrorHandler(NSError(domain: "Login", code: 0, userInfo: ["description":"Cannot find username"]))
		}
	}

// MARK: TableView Data Source
	func numberOfSections(in tableView: UITableView) -> Int {
		// 1
		// Return the number of sections.
		return settingsList.count
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
		let titleView = UITextView(frame: headerView.frame)
		titleView.text = settingsList[section].title
		titleView.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
		let gradient: CAGradientLayer = CAGradientLayer.init(layer: titleView)
		gradient.frame = headerView.bounds
		gradient.colors = [(UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.00).cgColor as AnyObject), (UIColor(red: 0.82, green: 0.82, blue: 0.85, alpha: 1.00).cgColor as AnyObject)]
		titleView.layer.insertSublayer(gradient, at: 0)

		headerView.addSubview(titleView)
		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return settingsList[section].title
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingsList[section].list.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
		//TODO: change cells to constants
		cell.textLabel?.text = settingsList[indexPath.section].list[indexPath.row]
		cell.backgroundColor = UIColor(colorLiteralRed: 230/256, green: 230/256, blue: 230/256, alpha: 1)
		return cell
	}
	
}
