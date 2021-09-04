//
//  OrderActionVC.swift
//  My MM
//
//  Created by Kishore on 29/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MaterialComponents.MaterialBottomSheet
import NotificationCenter

class OrderActionVC: UIViewController {
    var orderActionType = ""
    var order_id = ""
    var user_data:UserDataClass!
   
    @IBOutlet weak var cancelOrderLbl: UILabel!
    
    
    @IBOutlet weak var cancelOrderAlertLbl: UILabel!
    @IBOutlet weak var orderFeedbackLbl: UILabel!
    
    @IBOutlet weak var rateScaleLbl: UILabel!
    
    @IBOutlet weak var ratingStatusLbl: UILabel!
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var cTopView: UIView!
    
    @IBOutlet weak var fTopView: UIView!
    
    @IBAction func backButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil, userInfo: ["actionResponse":"CancelOrderAPI"])
        
    }
    @IBOutlet weak var yesButton: UIButton!
    @IBAction func oopsNoButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil)
         self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var oopsNoButton: UIButton!
    @IBOutlet weak var cancelOrderView: UIView!
    
    @IBAction func feedbackSubmitButton(_ sender: UIButton) {
        if ratingView.rating < 1.0 {
            self.view.makeToast("y_order_rate_desc".getLocalizedValue())
            self.view.clearToastQueue()
            return
        }
        
        self.submitOrdeRatingAPI()
    }
    @IBOutlet weak var feedbackSubmitButton: UIButton!
    @IBOutlet weak var feedbackTxtView: IQTextView!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var feedbackMainV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderFeedbackLbl.text = "y_order_rate_title".getLocalizedValue()
        rateScaleLbl.text = "y_order_rate_desc".getLocalizedValue()
        feedbackSubmitButton.setTitle("z_submit".getLocalizedValue(), for: .normal)
        
        cancelOrderLbl.text = "z_cancel_order".getLocalizedValue()
        cancelOrderAlertLbl.text = "a_cancel".getLocalizedValue()
        yesButton.setTitle("z_yes".getLocalizedValue(), for: .normal)
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        ratingView.delegate = self
        self.fTopView.layer.masksToBounds = true
        self.fTopView.layer.cornerRadius = 10
        self.cTopView.layer.masksToBounds = true
        self.cTopView.layer.cornerRadius = 10
        
        if orderActionType == "cancel" {
            cancelOrderView.isHidden = false
            cTopView.isHidden = false
            fTopView.isHidden = true
            feedbackMainV.isHidden = true
        }
        else
        {
            cTopView.isHidden = true
            fTopView.isHidden = false
            cancelOrderView.isHidden = true
            feedbackMainV.isHidden = false
        }
        self.yesButton.layer.borderWidth = 1
        self.yesButton.layer.borderColor = MAIN_COLOR.cgColor
        self.feedbackTxtView.layer.borderWidth = 1
        self.feedbackTxtView.layer.borderColor = UIColor.darkGray.cgColor
        
    }

    //MARK: Hide View on OutSide Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil)
            dismiss(animated: true, completion: nil)
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Submit Feedback
    
    func submitOrdeRatingAPI() {
        
        let api_name = APINAME().ORDER_REVIEW_API + "?timezone=\(localTimeZoneName)"
        let order_review = self.feedbackTxtView.text!
       let rating_value = self.ratingView.rating
        
        let param =  ["customer_id":user_data.user_id!,"order_id":order_id, "review":order_review,"rating":rating_value] as [String : Any]
        print(param)
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: true, params: param, success: { (response) in
            print(response)
            
             
            
            if response["status_code"] as! NSNumber == 1
            {
               NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil, userInfo: ["toastMsg":(response["message"] as! String)])
                self.dismiss(animated: true, completion: nil)
                return
            }
            else
            {
                self.view.makeToast((response["message"] as! String))
                self.view.clearToastQueue()
                return
            }
            
            
        }) { (error) in
            
        }
        
        
    }
 
    
}

extension OrderActionVC : FloatRatingViewDelegate
{
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        let ratingDouble = ratingView.rating
        
        if(ratingDouble == 0)
        {
            ratingStatusLbl.text = "y_rating_0".getLocalizedValue()
        }
        else if (ratingDouble <= 1 ) {
            ratingStatusLbl.text = "y_rating_2".getLocalizedValue()
        }
        else if(ratingDouble <= 2)
        {
            ratingStatusLbl.text = "y_rating_1".getLocalizedValue()
        }
        else if(ratingDouble <= 3)
        {
            ratingStatusLbl.text = "y_rating_3".getLocalizedValue()
        }
        else if(ratingDouble <= 4)
        {
            ratingStatusLbl.text = "y_rating_4".getLocalizedValue()
        }
        else
        {
            ratingStatusLbl.text = "y_rating_5".getLocalizedValue()
        }
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        
        print("rating view updated value: \(Double(ratingView.rating))")
       let ratingDouble = ratingView.rating
       
        if(ratingDouble == 0)
        {
            ratingStatusLbl.text = "y_rating_0".getLocalizedValue()
        }
        else if (ratingDouble <= 1 ) {
            ratingStatusLbl.text = "y_rating_2".getLocalizedValue()
        }
        else if(ratingDouble <= 2)
        {
            ratingStatusLbl.text = "y_rating_1".getLocalizedValue()
        }
        else if(ratingDouble <= 3)
        {
            ratingStatusLbl.text = "y_rating_3".getLocalizedValue()
        }
        else if(ratingDouble <= 4)
        {
            ratingStatusLbl.text = "y_rating_4".getLocalizedValue()
        }
        else
        {
            ratingStatusLbl.text = "y_rating_5".getLocalizedValue()
        }
    }
}
