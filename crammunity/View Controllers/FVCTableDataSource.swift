//
//  FVCTableDataSource.swift
//  crammunity
//
//  Created by Clara Hwang on 7/27/16.
//  Copyright © 2016 orctech. All rights reserved.
//


// MARK: TableView Data Source
import UIKit
extension FriendsViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// 1
		// Return the number of sections.
		return 1
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if tableView == self.notFriendTableView
		{
			return "Users"
		}
		else
		{
			return "Friends"
		}
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let count: Int?
		if tableView == self.notFriendTableView
		{
			count = self.notFriends.count
		}
		else
		{
			count = self.friends.count
		}
		return count!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: FriendSearchViewCell
		
		if tableView == self.notFriendTableView {
			cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! FriendSearchViewCell
			let user = notFriends[indexPath.row]
			cell.user = user
			cell.usernameLabel.text = user.value!.valueForKey("username") as? String
			cell.imageView?.image = Constants.Images.defaultProfile
			cell.delegate = self
			
			cell.isFriend = false
			return cell
		}
		else
		{
			cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendSearchViewCell
			let friend = friends[indexPath.row]
			cell.user = friend
			cell.usernameLabel.text = friend.value!.valueForKey("username") as? String
			cell.imageView?.image = Constants.Images.defaultProfile
			cell.delegate = self
			
			cell.isFriend = true
			return cell
		}
	}
}
