//
//  CrammateAdditionViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/22/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol CrammateAdditionViewCellDelegate: class {
	func cell(_ cell: CrammateSearchViewCell, didSelectAddCrammateUser user: FIRDataSnapshot)
	func cell(_ cell: CrammateSearchViewCell, didSelectRemoveCrammateUser user: FIRDataSnapshot)
}


class CrammateAdditionViewController: UIViewController
{
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var friendsTableView: UITableView!
	@IBOutlet weak var crammatesTableView: UITableView!
	
	var friends: [FIRDataSnapshot] = []{
		didSet{
			friendsTableView.reloadData()
		}
	}
	var crammates: [FIRDataSnapshot] = []{
		didSet{
			crammatesTableView.reloadData()
		}
	}
	var crammatesUIDS: [String] = []
	var friendsUIDS: [String] = []
	var cramClass: FIRDatabaseReference?
	
	
	var _friendsHandle: FIRDatabaseHandle!
	var _crammatesHandle: FIRDatabaseHandle!
	var _removeCrammatesHandle: FIRDatabaseHandle!
	var _removeFriendsHandle: FIRDatabaseHandle!
	
	
	//whenever a query changes, update the list and handlers
	var crammatesQuery: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
			
			crammates = []
			crammatesUIDS = []
			
			_crammatesHandle = crammatesQuery!.observe(.childAdded, with: { snapshot in
				if snapshot.exists() {
					if !(snapshot.key == Constants.Firebase.currentUser.uid) {
						self.crammates.append(snapshot)
						self.crammatesUIDS.append(snapshot.key)
						self.friends = self.friends.filter({$0.key != snapshot.key})
						self.friendsUIDS = self.friendsUIDS.filter({$0 != snapshot.key})
					}
				} else {
                    ErrorHandling.defaultError("Error", desc: "Failed crammate loading", sender: self)
				}
			})
			_removeCrammatesHandle = crammatesQuery!.observe(.childRemoved, with: { snapshot in
				if snapshot.exists() {
					//TODO: change to didset?
					self.crammates = self.crammates.filter({$0.key != snapshot.key})
					self.crammatesUIDS = self.crammatesUIDS.filter({$0 != snapshot.key})
					
					self.friends.append(snapshot)
					self.friendsUIDS.append(snapshot.key)
				} else {
                    ErrorHandling.defaultError("Error", desc: "Failed crammate removing", sender: self)
				}
			})
			friendsTableView.reloadData()
			crammatesTableView.reloadData()
		}
	}
	
	// the current parse query
	var friendsQuery: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
			
			friends = []
			friendsUIDS = []
			_friendsHandle = friendsQuery!.observe(.childAdded, with: { snapshot in
				if snapshot.exists() {
					if !(self.crammatesUIDS.contains(snapshot.key) || snapshot.key == Constants.Firebase.currentUser.uid)
					{
						self.friends.append(snapshot)
						self.friendsUIDS.append(snapshot.key)
					}
				} else {
                    ErrorHandling.defaultError(desc: "Error in user loading", sender: self)
				}
			})
			_removeFriendsHandle = friendsQuery!.observe(.childRemoved, with: { snapshot in
				if snapshot.exists() {
					//TODO: change to didset?
					self.friends = self.friends.filter({$0.key != snapshot.key})
					self.friendsUIDS = self.friendsUIDS.filter({$0 != snapshot.key})
				} else {
                    ErrorHandling.defaultError(desc: "Error in friend removing", sender: self)
				}
			})
			friendsTableView.reloadData()
			crammatesTableView.reloadData()
		}
	}
	
	//	// this view can be in two different states
	enum State {
		case defaultMode
		case searchMode
	}
	//
	//	// whenever the state changes, perform one of the two queries
	var state: State = .defaultMode {
		didSet {
			switch (state) {
			case .defaultMode:
				friendsQuery = FirebaseHelper.shared.friendsQuery()
				crammatesQuery = FirebaseHelper.shared.crammatesQuery(cramClass!)
				
			case .searchMode:
				let searchText = searchBar?.text ?? ""
                friendsQuery = FirebaseHelper.shared.friendsQuery(byUsername: searchText)
				crammatesQuery = FirebaseHelper.shared.crammatesQuery(cramClass!, byUsername: searchText)
				
			}
		}
	}
	
	// MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		state = .defaultMode
	}
	deinit {
		crammates = []
		friends = []
	}
	
	@IBAction func unwindToClassViewControllerFromCrammateAddition(_ segue: UIButton) {
		print("unwinding to class view from crammate addition")
		self.dismiss(animated: true, completion: nil)
	}

}

// MARK: Searchbar Delegate

extension CrammateAdditionViewController: UISearchBarDelegate {
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
		state = .searchMode
	}
	
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.text = ""
		searchBar.setShowsCancelButton(false, animated: true)
		state = .defaultMode
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        friendsQuery = FirebaseHelper.shared.friendsQuery(byUsername: searchText)
		crammatesQuery = FirebaseHelper.shared.crammatesQuery(cramClass!, byUsername: searchText)
		
	}
}

// MARK: CrammateAdditionViewController Delegate

extension CrammateAdditionViewController: CrammateAdditionViewCellDelegate {
	
	func cell(_ cell: CrammateSearchViewCell, didSelectAddCrammateUser user: FIRDataSnapshot) {
		//set crammates in database
		Constants.Firebase.UserArray.child(user.key).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
			FirebaseHelper.shared.addUserToClass(snapshot, cramClass: self.cramClass!)
		})
	}
	
	func cell(_ cell: CrammateSearchViewCell, didSelectRemoveCrammateUser user: FIRDataSnapshot) {
		Constants.Firebase.UserArray.child(user.key).child("friends").child(user.key).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
			FirebaseHelper.shared.removeUserFromClass(snapshot, cramClass: self.cramClass!)
		})
	}
	
}




// MARK: TableView Data Source
extension CrammateAdditionViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		// 1
		// Return the number of sections.
		return 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if tableView == self.crammatesTableView
		{
			return "Crammates"
		}
		else
		{
			return "Friends"
		}
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let count: Int?
		if tableView == self.friendsTableView
		{
			count = self.friends.count
		}
		else
		{
			count = self.crammates.count
		}
		return count!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: CrammateSearchViewCell
		
		if tableView == self.friendsTableView {
			cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! CrammateSearchViewCell
			let user = friends[indexPath.row]
			cell.user = user
			cell.usernameLabel.text = (user.value! as AnyObject).value(forKey: "username") as? String
			cell.imageView?.image = Constants.Images.defaultProfile
			cell.delegate = self
			
			cell.isClassmate = false
			return cell
		}
		else
		{
			cell = tableView.dequeueReusableCell(withIdentifier: "CrammateCell", for: indexPath) as! CrammateSearchViewCell
			let crammate = crammates[indexPath.row]
			cell.user = crammate
			cell.usernameLabel.text = (crammate.value! as AnyObject).value(forKey: "username") as? String
			cell.imageView?.image = Constants.Images.defaultProfile
			cell.delegate = self
			
			cell.isClassmate = true
			return cell
		}
	}
}
