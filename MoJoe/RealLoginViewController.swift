//
//  RealLoginViewController.swift
//  MoJoe
//
//  Created by Daniel Grant on 10/18/18.
//  Copyright © 2018 Daniel Grant. All rights reserved.
//

import UIKit

class RealLoginViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var userNameTField: UITextField!
    
    @IBOutlet weak var passwordTField: UITextField!
    
    @IBOutlet weak var userRemember: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTField.delegate = self
        passwordTField.delegate = self 
    }
    

    
    @IBAction func tapByeKeyboard(_ sender: Any) {
        self.userNameTField.resignFirstResponder()
        self.passwordTField.resignFirstResponder()
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide keyboard
        textField.resignFirstResponder()
        return true
    }
    //2) this function runs when the text field returns true after it is no longer the first responder
    func textFieldDidEndEditing(_ textField: UITextField)  {
        
    }
    
    
    
    //keep the username field as the username, but now im thinking this doesnt make sense because they user would not need to log in. it has to be more of something like if the person checks a box that says so, keep the username there. I also could add a box for stay lgged in but that might also just be default.
   
    
    
    @IBAction func loginToApp(_ sender: Any) {
        
        let userName = userNameTField.text
        let password = passwordTField.text
        
        let userNameStored = UserDefaults.standard.string(forKey: "userName")
        let passwordStored = UserDefaults.standard.string(forKey: "password")
        
        if(userNameStored == userName) 
        {
            if(passwordStored == password)
            {
                let mainTabController = storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
                
                mainTabController.selectedViewController = mainTabController.viewControllers?[0]
                
                present(mainTabController, animated: true, completion: nil)
                
                UserDefaults.standard.set(true, forKey: "loggedIn")
                UserDefaults.standard.synchronize()
            }
        }
        
       
        
        
        
        
        
        
    
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
