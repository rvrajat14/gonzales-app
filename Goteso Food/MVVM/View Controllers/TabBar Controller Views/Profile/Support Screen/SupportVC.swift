

//
//  SupportVC.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import MessageUI

class SupportVC: UIViewController,MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var sendEmailLbl: UILabel!
    @IBOutlet weak var callNowLbl: UILabel!
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var user_email = ""
    var user_phone_number = ""
    
    let userDefaults = UserDefaults.standard
    @IBOutlet weak var sendEmailButton: UIButton!
    
    
    
    func requestForEmail(with email:String) {
        
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients([email])
        mailComposeViewController.setSubject("Inquiry\("")")
        
        mailComposeViewController.setMessageBody("", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
             print("Error")
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendEmailButton(_ sender: UIButton) {
      
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteToUsVC") as! WriteToUsVC
//        viewController.user_email = self.user_email
//        self.navigationController?.pushViewController(viewController, animated: true)
        print(self.user_email)
        requestForEmail(with: self.user_email)
        
    }
  
   
    @IBOutlet weak var sendEmailMainView: UIView!
    
    @IBAction func callNowButton(_ sender: UIButton) {
        
        self.user_phone_number = self.user_phone_number.replacingOccurrences(of: " ", with: "")
        if let  url1 = NSURL(string: "tel://\(self.user_phone_number)"),
            UIApplication.shared.canOpenURL(url1 as URL)
        {
            UIApplication.shared.open(url1 as URL, options: [:], completionHandler: nil)
        }
    
        
    }
    @IBOutlet weak var callNowMainView: UIView!
    @IBOutlet weak var upperInfoLbl: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitleLbl.text = "z_support".getLocalizedValue()
        topLbl.text = "y_support_top".getLocalizedValue()
        callNowLbl.text = "y_support_call".getLocalizedValue()
        sendEmailLbl.text = "y_support_email".getLocalizedValue()
         
        
        self.callNowMainView.layer.borderWidth = 1
        self.callNowMainView.layer.borderColor = UIColor.lightGray.cgColor
        self.callNowMainView.layer.cornerRadius = 5
        self.sendEmailMainView.layer.cornerRadius = 5
        
        self.user_phone_number = UserDefaults.standard.value(forKey: "app_email") as! String
        self.user_email = UserDefaults.standard.value(forKey: "app_phone") as! String
        
        getSupportDataAPI()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black]
        self.navigationItem.title = "Support"
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
    
    
    //MARK: Call API
    
    func getSupportDataAPI() {
        
        let api_name = APINAME().SETTINGS_API
        
         WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            
            if response["status_code"] as! NSNumber == 1
                {
                    let tempArray = response["data"] as! NSArray
                    
                    for value in tempArray
                    {
                        let value1 = value as! NSDictionary
                        if value1.object(forKey: "key") as! String == "support_email"
                        {
                            self.user_email =  value1.object(forKey: "value") as! String
                        }
                        if value1.object(forKey: "key") as! String == "support_phone"
                        {
                            self.user_phone_number =  value1.object(forKey: "value") as! String
                        }
                    }
 
                }
            else
            {
                 COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
            }
            
        }) { (failure) in
             COMMON_FUNCTIONS.showAlert(msg: "Request Time Out !")
        }
        
    }
    
}



