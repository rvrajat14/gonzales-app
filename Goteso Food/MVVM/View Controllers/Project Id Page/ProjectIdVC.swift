//
//  ProjectIdVC.swift
//  MY MM Provider APP
//
//  Created by Kishore on 19/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class ProjectIdVC: UIViewController {

    @IBOutlet weak var titleLbl1: UILabel!
    
    @IBOutlet weak var titleLbl2: UILabel!
    
    
    var window : UIWindow!
    
    var userDefaults = UserDefaults.standard
    
    
    @IBAction func doneButton(_ sender: UIButton) {
        if (idTxtField.text?.isEmpty)! {
            return
        }
       userDefaults.setValue(self.idTxtField.text!, forKey: "projectId")
        userDefaults.setValue("true", forKey: "isAppInstalled")
        projectId = self.idTxtField.text!
        //http://goteso.ordefy.com/api
        
        if url_type == "url"
        {
              BASE_URL = "https://www.ordefy.com/api/\(projectId)/"
            IMAGE_BASE_URL = "https://www.ordefy.com/api/goteso-assets/\(projectId)/"
        }
        else
        {
            BASE_URL = "http://192.168.1.17:8888/ordefy-api/public/"
            IMAGE_BASE_URL = "\(BASE_URL)goteso-assets/8888/"
            
//            BASE_URL = "http://139.59.86.194:\(projectId)"
//            IMAGE_BASE_URL = "\(BASE_URL)goteso-assets/\(projectId)/"
        }
        
        
//        BASE_URL = "http://139.59.86.194:\(projectId)/"
//        IMAGE_BASE_URL = "\(BASE_URL)goteso-assets/\(projectId)/"
        
          CheckValidCode()
    }
    
    
    
  
    
    
    
    //MARK: Check For Valid Code
    func CheckValidCode()  {
        
         WebService.requestGetUrlForCheckPort(strURL: APINAME().CHECK_TEAM + "?team_id=\(idTxtField.text!)", is_loader_required: true, success: { (response) in
            if (response.value(forKey: "status_code")as! Int) == 1
            {
                self.getSettingsDataAPI()
            }
            else
            {
                self.view.makeToast((response.value(forKey: "message") as! String))
                self.view.clearToastQueue()
                
            }
        }) { (failure) in
            
        }
    }
    
    
    
    //MARK: Get Settings Call API
    
    func getSettingsDataAPI() {
        
        let api_name = APINAME().SETTINGS_API
        
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init() , is_loader_required: false, success: { (response) in
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
                let tempArray = response["data"] as! NSArray
                
                for value in tempArray
                {
                    let value1 = value as! NSDictionary
                    if value1.object(forKey: "key") as! String == "currency_symbol"
                    {
                        currency_type = value1.object(forKey: "value") as! String
                    }
                    if value1.object(forKey: "key") as! String == "terms_and_conditions"
                    {
                        terms_and_condition = value1.object(forKey: "value") as! String
                    }
                    if value1.object(forKey: "key") as! String == "support_email"
                    {
                        self.userDefaults.set(value1.object(forKey: "value") as! String, forKey: "app_email")
                    }
                    if value1.object(forKey: "key") as! String == "support_phone"
                    {
                        self.userDefaults.set(value1.object(forKey: "value") as! String, forKey: "app_phone")
                    }
                }
                
                
                DispatchQueue.main.async {
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                    if let window = self.window {
                        window.rootViewController = yourVc
                    }
                    self.window?.makeKeyAndVisible()
                }
                
            }
            
            
        }) { (failure) in
            // print(failure.debugDescription)
        }
        
    }
    
    
   
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var idTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.idTxtField.delegate = self
        if Language.isRTL {
            self.idTxtField.textAlignment = .right
            titleLbl1.textAlignment = .right
            titleLbl2.textAlignment = .right
        }
        else
        {
            titleLbl1.textAlignment = .left
            titleLbl2.textAlignment = .left
            self.idTxtField.textAlignment = .left
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let userDefault =  UserDefaults.standard
        
        if userDefault.value(forKey: "refresh_token") != nil {
            userDefault.removeObject(forKey: "refresh_token")
            
        }
        if userDefault.value(forKey: "access_token") != nil {
            userDefault.removeObject(forKey: "access_token")
        }
        if userDefault.value(forKey: "token_type") != nil {
            userDefault.removeObject(forKey: "token_type")
        }
        
        if userDefault.value(forKey: "categoryPhotoStatus") != nil {
            userDefault.removeObject(forKey: "categoryPhotoStatus")
        }
        
        if userDefault.value(forKey: "subCategoryPhotoStatus") != nil {
            userDefault.removeObject(forKey: "subCategoryPhotoStatus")
        }
        
        if userDefault.value(forKey: "categoryLevelStatus") != nil {
            userDefault.removeObject(forKey: "categoryLevelStatus")
        }
        
        if userDefault.value(forKey: "categoryDescriptionStatus") != nil {
            userDefault.removeObject(forKey: "categoryDescriptionStatus")
        }
        
        if userDefault.value(forKey: "subCategoryDescriptionStatus") != nil {
            userDefault.removeObject(forKey: "subCategoryDescriptionStatus")
        }
        
        if userDefault.value(forKey: "manage_location") != nil {
            userDefault.removeObject(forKey: "manage_location")
        }
        
        if userDefault.value(forKey: "manage_services") != nil {
            userDefault.removeObject(forKey: "manage_services")
        }
        
        if userDefault.value(forKey: "manage_items") != nil {
            userDefault.removeObject(forKey: "manage_items")
        }
    }
}


extension ProjectIdVC : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == " " {
            return false
        }
      
        return true
        
    }
}
