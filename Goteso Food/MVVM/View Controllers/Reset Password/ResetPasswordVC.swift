//
//  ResetPasswordVC.swift
//  My MM
//
//  Created by Kishore on 15/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import PasswordTextField
import NotificationCenter
import MaterialComponents.MaterialBottomSheet

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var createNewPasswrdLbl: UILabel!
    @IBOutlet weak var enterEmailToLbl: UILabel!
    @IBOutlet weak var resetPasswordLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    var otp = ""
    @IBOutlet weak var serverErrorView: UIView!
     var isFromChangePassword = false
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var newPasswordView: UIView!
    
    var user_id = ""
    var email_id = ""
    var window: UIWindow?
    
@IBOutlet weak var backButton: UIButton!

    @IBAction func createNewPasswordButton(_ sender: UIButton) {
        let password = self.newPasswordTxtField.text!
        
        if password.isEmpty == true {
            self.view.makeToast("h_password".getLocalizedValue())
            self.view.clearToastQueue()
            return
            
        }
        else if !(password.count > 5)
        {
            self.view.makeToast("a_password".getLocalizedValue(), duration: 2, position: .center, title: "", image: nil, style: .init(), completion: nil)
            self.view.clearToastQueue()
            return
            
        }
        
         self.createNewPasswordAPI(user_id: user_id, password: password)
    }
    @IBOutlet weak var createNewPasswordButton: UIButton!
    @IBOutlet weak var newPasswordTxtField: PasswordTextField!
  
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        email_id = self.contactTxtField.text!
        self.verifyEmailAPI(email: email_id)
    }
    
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var contactTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if Language.isRTL {
            newPasswordTxtField.textAlignment = .right
            contactTxtField.textAlignment = .right
        }
        
        pageTitleLbl.text = "y_reset_password_page_title".getLocalizedValue()
        resetPasswordLbl.text = "y_reset_password_button".getLocalizedValue()
        enterEmailToLbl.text = "y_reset_password_desc".getLocalizedValue()
        createNewPasswrdLbl.text = "z_create_new_password".getLocalizedValue()
        newPasswordTxtField.placeholder = "h_password_new".getLocalizedValue()
        contactTxtField.placeholder = "h_email".getLocalizedValue()
        resetButton.setTitle("y_reset_password_button".getLocalizedValue(), for: .normal)
         createNewPasswordButton.setTitle("z_submit".getLocalizedValue(), for: .normal)
        
        self.contactTxtField.delegate = self
        self.serverErrorView.isHidden = true
    NotificationCenter.default.addObserver(self, selector: #selector(forgotPasswordOTPNotificationAcion(notification:)), name: NSNotification.Name.init("forgotPasswordOTPNotification"), object: nil)
        self.passwordView.layer.cornerRadius = 4
        self.createNewPasswordButton.layer.cornerRadius = 4
        self.resetButton.layer.cornerRadius = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isFromChangePassword {
            contactTxtField.text = email_id
            contactTxtField.isUserInteractionEnabled = false
        }
        else
        {
            DispatchQueue.main.async {
                self.resetButton.backgroundColor = UIColor.lightGray
            }
            
            resetButton.isUserInteractionEnabled = false
            contactTxtField.text = ""
            contactTxtField.isUserInteractionEnabled = true
        }
    }
    
    func verifyEmailAPI(email:String)  {
        let params = ["email": email]
        let api_name = APINAME().FORGOT_PASSWORD  
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: params, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            
            if response["status_code"] as! NSNumber == 1
            {
              //  DispatchQueue.main.async {
                
                    let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerifyVC") as! OTPVerifyVC
                   viewController.isForForgotPassword = true
                    viewController.forgotPasswordDataDic = params as NSDictionary
                    self.navigationController?.pushViewController(viewController, animated: true)
                    return
              // }
            }
            else
            {
                
                self.view.makeToast((response["message"] as! String), duration: 2, position: .center, title: "", image: nil, style: .init()) { (result) in
                    self.contactTxtField.text = ""
                    self.contactTxtField.becomeFirstResponder()
                     self.view.clearToastQueue()
                    return
                   
                }
                
                
            }
        }) { (failure) in
              self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        
    }
 
    
    @objc func forgotPasswordOTPNotificationAcion(notification:Notification)
    {
        print(notification)
        if let userInfo = notification.userInfo {
            if let otp1 = userInfo["otp"] as? String
            {
                otp = otp1
                self.newPasswordView.isHidden = false
            }
        }
        
    }
    
    
    func createNewPasswordAPI(user_id:String,password:String)  {
        
        if password.count > 6
        {
            
        }
        else
        {
            COMMON_FUNCTIONS.showAlert(msg: "a_password".getLocalizedValue())
            return
        }
        
        let params = ["otp": otp,"password":password,"email":self.email_id]
        let api_name = APINAME().RESET_PASSWORD  
       
         WebService.requestPUTUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: params, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
             
            
            if response["status_code"] as! NSNumber == 1
            {
                DispatchQueue.main.async {
                    
                    if self.isFromChangePassword
                    {
                       self.navigationController?.popViewController(animated: true)
                    }
                    else
                    {
                        
                        self.view.makeToast((response["message"] as! String), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                            UserDefaults.standard.removeObject(forKey: "user_data")
                            
                            let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                            if let window = self.window {
                                window.rootViewController = yourVc
                            }
                            self.window?.makeKeyAndVisible()
                        })
                        
                       self.view.clearToastQueue()
                    }
                  
                }
                
            }
           else
            {
                self.view.makeToast((response["message"] as! String), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                    UserDefaults.standard.removeObject(forKey: "user_data")
                    self.newPasswordTxtField.text = ""
                    self.newPasswordTxtField.becomeFirstResponder()
                    self.view.clearToastQueue()
                    return
                })
            }
        }) { (failure) in
              self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        
    }
    
}


extension ResetPasswordVC : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if newString.count > 0 {
            self.resetButton.isUserInteractionEnabled = true
            self.resetButton.backgroundColor = MAIN_COLOR
             
        }
        else
        {
            self.resetButton.isUserInteractionEnabled = false
            self.resetButton.backgroundColor = .lightGray
            
        }
        return true
    }
}
