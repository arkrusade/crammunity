//
//  FriendViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/22/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FriendViewController: UIViewController
{
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	var users: [FIRDataSnapshot]?
	
	/*
	This is a local cache. It stores all the users this user is following.
	It is used to update the UI immediately upon user interaction, instead of
	having to wait for a server response.
	*/
	var followingUsers: [FIRUser]? {
		didSet {
			/**
			the list of following users may be fetched after the tableView has displayed
			cells. In this case, we reload the data to reflect "following" status
			*/
			tableView.reloadData()
		}
	}
	
	// the current parse query
	var query: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
		}
	}
	
//	// this view can be in two different states
	enum State {
		case DefaultMode
		case SearchMode
	}
//
//	// whenever the state changes, perform one of the two queries and update the list
	var state: State = .DefaultMode {
		didSet {
			switch (state) {
			case .DefaultMode:
				query = FirebaseHelper.allUsers()
				
			case .SearchMode:
				let searchText = searchBar?.text ?? ""
				query = FirebaseHelper.allUsers(searchText)
			}
		}
	}
	
	// MARK: Update userlist
	
	/**
	Is called as the completion block of all queries.
	As soon as a query completes, this method updates the Table View.
	*/
//	func updateList(results: [PFObject]?, error: NSError?) {
//		if let error = error {
//			ErrorHandling.defaultErrorHandler(error)
//		}
//		self.users = results as? [PFUser] ?? []
//		self.tableView.reloadData()
//		
//	}
	
	// MARK: View Lifecycle
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
//		state = .DefaultMode
		
		// fill the cache of a user's followees
//		ParseHelper.getFollowingUsersForUser(PFUser.Constants.currentUser()!) { (results: [PFObject]?, error: NSError?) -> Void in
//			if let error = error {
//				ErrorHandling.defaultErrorHandler(error)
//			}
//			let relations = results ?? []
//			// use map to extract the User from a Follow object
//			self.followingUsers = relations.map {
//				$0[ParseHelper.ParseFollowToUser] as! PFUser
//			}
//			
//		}
	}
	
}

// MARK: TableView Data Source

extension FriendViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
		return self.users?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")// as! FriendTableViewCell
		
//		let user = users![indexPath.row]
//		cell.user = user
//		
//		if let followingUsers = followingUsers {
//			// check if current user is already following displayed user
//			// change button appereance based on result
//			cell.canFollow = !followingUsers.contains(user)
//		}
//		
//		cell.delegate = self
//		
		return cell!
	}
}

// MARK: Searchbar Delegate

extension FriendViewController: UISearchBarDelegate {
	
	func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
		state = .SearchMode
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.text = ""
		searchBar.setShowsCancelButton(false, animated: true)
		state = .DefaultMode
	}
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		FirebaseHelper.allUsers(searchText)
	}
	
}

// MARK: FriendTableViewCell Delegate

//extension FriendViewController: FriendTableViewCellDelegate {
//	
//	func cell(cell: FriendTableViewCell, didSelectFollowUser user: PFUser) {
//		ParseHelper.addFollowRelationshipFromUser(PFUser.Constants.currentUser()!, toUser: user)
//		// update local cache
//		followingUsers?.append(user)
//	}
//	
//	func cell(cell: FriendTableViewCell, didSelectUnfollowUser user: PFUser) {
//		if let followingUsers = followingUsers {
//			ParseHelper.removeFollowRelationshipFromUser(PFUser.Constants.currentUser()!, toUser: user)
//			// update local cache
//			self.followingUsers = followingUsers.filter({$0 != user})
//		}
//	}
//	
//}