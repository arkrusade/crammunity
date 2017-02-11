//
//  ClassCreationViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/18/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import FirebaseDatabase
class ClassCreationViewController: UIViewController {

	@IBOutlet weak var newClassNameTextField: UITextField!
	
	var classRef: FIRDatabaseReference?
	@IBAction func onCreateClassTap(_ sender: AnyObject) {
		
		
//TODO: check for duplicate names
		if self.newClassNameTextField.text!.isEmpty {
			let alertController = UIAlertController(title: "Invalid Class", message: "You must fill in the class name", preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alertController.addAction(okAction)
			self.present(alertController, animated: true, completion: nil)
		}
		else{
			
			self.classRef = FirebaseHelper.shared.createClass(self.newClassNameTextField.text!)
			dismissToMasterViewController(self)
			//TODO: change to loading class and adding friends

		}
	
	}


	@IBAction func dismissToMasterViewController(_ sender: AnyObject) {
	
		print("dismissing to master view from class creation")
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func cancelClassCreation(_ sender: AnyObject)
	{
		print("cancelling classcreation")
	}
	@IBAction func viewTapped(_ sender: AnyObject) {
		self.newClassNameTextField.resignFirstResponder()
	}
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		print("Seguing with \(segue.description)")
		if segue.identifier! == Constants.Segues.ClassCreationToCrammatesAddition
		{
			let vc = segue.destination as! CrammateAdditionViewController
			vc.cramClass = self.classRef
		}
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
	

}
