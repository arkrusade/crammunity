//
//  User.swift
//  crammunity
//
//  Created by Clara Hwang on 7/11/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
class User: NSObject
{
	func newID() -> String
	{
		return String(random())
	}
}