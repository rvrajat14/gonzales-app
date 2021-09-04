 
//
//  changePasswordVC.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import PasswordTextField
class changePasswordVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var serverErrorView: UIView!
    var old_password = ""
    var new_password = ""
    var reEnteredPassword = ""
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    var user_data:UserDataClass!
    var window: UIWindow?
    
    @IBAction func forgotPasswordButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        if !user_data.user_email_id.isEmpty {
             viewController.email_id = user_data.user_email_id!
        }
        else
        {
             viewController.email_id = user_data.user_mobile_number!
        }
        viewController.isFromChangePassword = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBAction func updateButton(_ sender: UIButton) {
        
        changePasswordAPI()
    }
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var reEnterNewPasswordTxtField: PasswordTextField!
    @IBOutlet weak var newPasswordTxtField: PasswordTextField!
    @IBOutlet weak var changePasswordTxtField: PasswordTextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitleLbl.text = "z_change_password".getLocalizedValue()
        changePasswordTxtField.placeholder = "h_password_current".getLocalizedValue()
        newPasswordTxtField.placeholder = "h_password_new".getLocalizedValue()
        reEnterNewPasswordTxtField.placeholder = "h_password_renter".getLocalizedValue()
        forgotPasswordButton.setTitle("y_login_forgot".getLocalizedValue(), for: .normal)
        updateButton.setTitle("z_update".getLocalizedValue(), for: .normal)
        
        
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        self.serverErrorView.isHidden = true
         
        
        self.updateButton.layer.cornerRadius = 6
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.updateButton.backgroundColor = UIColor.lightGray
            self.updateButton.isUserInteractionEnabled = false
        }
       
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black]
        self.navigationItem.title = "Change Password"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Selector Methods//////////
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -Change Password API
    
    func changePasswordAPI( )  {
       
        old_password = changePasswordTxtField.text!
        new_password = newPasswordTxtField.text!
        reEnteredPassword = reEnterNewPasswordTxtField.text!
        
        if old_password.isEmpty
        {
            
            self.view.makeToast("h_password_current".getLocalizedValue(), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
               self.changePasswordTxtField.becomeFirstResponder()
            })
            self.view.clearToastQueue()
            
            return
        }
        
        
        if !new_password.isEmpty {
       
            if reEnteredPassword.isEmpty
            {
                
                self.view.makeToast("re_enter_password".getLocalizedValue(), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                    self.reEnterNewPasswordTxtField.becomeFirstResponder()
                })
                self.view.clearToastQueue()
                
                return
            }
            
            if new_password != reEnteredPassword {
                
                self.view.makeToast("a_match_password".getLocalizedValue(), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                   self.reEnterNewPasswordTxtField.becomeFirstResponder()
                })
                self.view.clearToastQueue()
                
                return
            }
        }
        
        if (changePasswordTxtField.text?.isEmpty)! {
             return
        }
        
        
        let params = ["old_password":old_password,"new_password": new_password,"password_confirmation":reEnterNewPasswordTxtField.text!]
        let api_name = APINAME().UPDATE_PASSWORD + "/\(user_data.user_id!)"
         WebService.requestPUTUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: params, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
             
            
            if response["status_code"] as! NSNumber == 1
            {
                
                DispatchQueue.main.async {
                    
                    self.view.makeToast((response["message"] as! String), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                       self.navigationController?.popViewController(animated: true)
                    })
                    self.view.clearToastQueue()
                    
                }
            }
            else
            
            {
                self.view.makeToast((response["message"] as! String), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                    self.changePasswordTxtField.text = ""
                    self.newPasswordTxtField.text = ""
                    self.reEnterNewPasswordTxtField.text = ""
                })
                self.view.clearToastQueue()
                
            }
        }) { (failure) in
           self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        
        if textField.tag == 3
        {
            print((newString))
            
            DispatchQueue.main.async {
                if newString == self.new_password
                {
                    self.updateButton.isUserInteractionEnabled = true
                    self.updateButton.backgroundColor = MAIN_COLOR
                }
                else
                {
                    self.updateButton.isUserInteractionEnabled = false
                    self.updateButton.backgroundColor = UIColor.lightGray
                }
            }
            
        }
        return true
        
    }
    
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField.tag == 1 {
            old_password = textField.text!
            return
        }
        if textField.tag == 2 {
            
            if !(textField.text!.count > 5)
            {
                self.view.makeToast("a_password".getLocalizedValue(), duration: 2, position: .center, title: "", image: nil, style: .init(), completion: nil)
                textField.text = ""
                self.view.clearToastQueue()
                return
                
            }
            else
            {
               new_password = textField.text!
                return
            }
            
        }
        
    }
    
}

