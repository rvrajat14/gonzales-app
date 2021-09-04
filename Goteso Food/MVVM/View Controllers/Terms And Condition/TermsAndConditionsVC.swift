//
//  TermsAndConditionsVC.swift
//  FoodApplication
//
//  Created by Kishore on 07/08/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class TermsAndConditionsVC: UIViewController {

    
    @IBOutlet weak var textViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var navLbl: UILabel!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var txtView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       navLbl.text = "y_profile_terms".getLocalizedValue()
        
    }

    //MARK: - Selector Methods//////////
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.txtView.attributedText = terms_and_condition.htmlToAttributedString
        
        if (self.txtView.sizeThatFits(CGSize(width: self.txtView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))).height > 512 {
            self.textViewHeightConstraints.constant = (self.txtView.sizeThatFits(CGSize(width: self.txtView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))).height
        }
        if terms_and_condition.isEmpty {
            getSettingsDataAPI()
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    //MARK: Get Settings Call API
    
    func getSettingsDataAPI() {
        
        let api_name = APINAME().SETTINGS_API  
        
         WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init() , is_loader_required: true, success: { (response) in
            print(response)
            
             
            
            if response["status_code"] as! NSNumber == 1
            {
                let tempArray = response["data"] as! NSArray
                
                for value in tempArray
                {
                    let value1 = value as! NSDictionary
                    DispatchQueue.main.async {
                        if value1.object(forKey: "key") as! String == "terms_and_conditions"
                        {
                            terms_and_condition = value1.object(forKey: "value") as! String
                           self.txtView.attributedText = terms_and_condition.htmlToAttributedString
                             self.textViewHeightConstraints.constant = (self.txtView.sizeThatFits(CGSize(width: self.txtView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))).height - 502
                        }
                        self.updateViewConstraints()
                    }
                    
                    
                }
                
            }
            
            
        }) { (failure) in
            // print(failure.debugDescription)
        }
        
    }
    
}


 

