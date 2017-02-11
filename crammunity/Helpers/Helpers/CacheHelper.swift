//
//  CacheHelper.swift
//  crammunity
//
//  Created by Justin Lee on 2/10/17.
//  Copyright © 2017 orctech. All rights reserved.
//
import UIKit
class CacheHelper {
    static let sharedInstance = CacheHelper()
    let MyKeychainWrapper = KeychainWrapper()
    static func clearAll() {
        clearLogin()
    }
    static func clearUserCache(_ sender: UIViewController) {
        clearAll()
        ErrorHandling.displayAlert("Cache Cleared!", desc: "", sender: sender, completion: nil)
    }
    static func clearLogin() {
        sharedInstance.MyKeychainWrapper.mySetObject("password", forKey: kSecValueData)
        sharedInstance.MyKeychainWrapper.writeToKeychain()
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.set(false, forKey: "hasLoginKey")
    }
    func retrieveLogin() -> Credentials?
    {
        if let username = UserDefaults.standard.string(forKey: "username"), let pass = MyKeychainWrapper.myObject(forKey: kSecValueData) as? String
        {
            return (username, pass)
        }
            
        else {
            return nil
        }
    }
    func storeLogin(_ login: Credentials) {
        storeLogin(login.username, password: login.password)
    }
    func storeLogin(_ username: String, password: String) {
        if !UserDefaults.standard.bool(forKey: "hasLoginKey") {//TODO: beware, will not overwrite
            UserDefaults.standard.setValue(username, forKey: "username")
        }
        
        MyKeychainWrapper.mySetObject(password, forKey: kSecValueData)
        MyKeychainWrapper.writeToKeychain()
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
        UserDefaults.standard.synchronize()
    }
}
