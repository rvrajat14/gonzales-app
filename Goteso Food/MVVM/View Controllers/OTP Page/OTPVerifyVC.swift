//
//  OTPVerifyVC.swift
//  TaxiApp
//
//  Created by Apple on 11/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import NotificationCenter

class OTPVerifyVC: UIViewController  {
     var window: UIWindow!
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    @IBOutlet weak var oneTimeDescLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        if isForSignUp {
            
            NotificationCenter.default.post(name: NSNotification.Name.init("signUpOTPNotification"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpTxtField: UITextField!
    var isForSignUp = false
    var isForForgotPassword = false
    var signUpDataDic = NSDictionary.init()
     var forgotPasswordDataDic = NSDictionary.init()
    var forgotPaswordEmail = ""
    
    
    var timer: Timer?
    var totalTime = 60

    @IBOutlet weak var regenrateTitleLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var regenerateOtpBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitle("z_back".getLocalizedValue(), for: .normal)
        pageTitleLbl.text = "y_otp_title".getLocalizedValue()
        //oneTimeDescLbl.text = ""
        otpTxtField.placeholder = "h_otp".getLocalizedValue()
        regenrateTitleLbl.text = "y_reset_regenerate_otp".getLocalizedValue()
        regenerateOtpBtn.setTitle("y_reset_resend_otp".getLocalizedValue(), for: .normal)
        submitOTPButton.setTitle("z_submit".getLocalizedValue(), for: .normal)
        
        self.serverErrorView.isHidden = true
        self.otpView.layer.cornerRadius = 1
        self.otpView.layer.borderWidth = 1
        self.otpView.layer.borderColor = UIColor.lightGray.cgColor
        self.navigationController?.isNavigationBarHidden = true
        startOtpTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
      
    }
    @IBOutlet weak var submitOTPButton: UIButton!
    
    @IBAction func submitOTPButton(_ sender: UIButton) {
        
        if (otpTxtField.text?.isEmpty)! {
            self.view.makeToast("h_otp".getLocalizedValue())
            return
        }
        
        if isForSignUp {
            createNewUserAPI()
            
        }
        else
        {
            verifyOTPAPI()
        }
    }
    
    
    @IBAction func regenrateOtpBtnTaped(_ sender: Any) {
        regenerateOtpBtn.isHidden = true
        regenrateTitleLbl.textColor = UIColor.lightGray
        timeLbl.textColor = UIColor.lightGray
        timer?.invalidate()
        //startOtpTimer()
        sendOTP()
    }
    
    private func startOtpTimer() {
        
        self.totalTime = 60
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print(self.totalTime)
        
        self.timeLbl.text = "(" + self.timeFormatted(self.totalTime) + ")" // will show timer
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        } else {
            if let timer = self.timer {
                self.regenerateOtpBtn.isHidden = false
                timer.invalidate()
                self.timer = nil
            }
          
            regenerateOtpBtn.isHidden = false
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    //MARK: OTP Varification for forgot password
    func verifyOTPAPI()  {
        let params = forgotPasswordDataDic.mutableCopy() as! NSMutableDictionary
        params.setObject(otpTxtField.text!, forKey: "otp" as NSCopying)
        let api_name = APINAME().VERIFY_OTP  
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: params as! [String : Any], success: { (response) in
            print(response)
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.init("forgotPasswordOTPNotification"), object: nil, userInfo: ["otp":self.otpTxtField.text!])
                   self.navigationController?.popViewController(animated: true)
                    return
                }
            }
            else
            {
                self.otpTxtField.text = ""
                self.view.makeToast((response["message"] as! String), point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
                self.view.clearToastQueue()
                return
            }
        }) { (failure) in
            self.view.makeToast("Request Time Out !")
        }
        
    }
    
    
    
    //MARK: OTP API FOR SIGNUP
    
    //MARK: Create New User
    func createNewUserAPI()  {
        var api_name = ""
        api_name = APINAME().SIGNUP_API
        let params =   signUpDataDic.mutableCopy() as! NSMutableDictionary
        params.setObject(otpTxtField.text!, forKey: "otp" as NSCopying)
        
        print(params)
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: true, params: params as! [String : Any], success: { (response) in
            
            DispatchQueue.main.async {
               
                
                if response["status_code"] as! NSNumber == 1
                {
                   
                    self.view.makeToast((response["message"] as! String), duration: 2, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
                        let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                        if let window = self.window {
                            window.rootViewController = yourVc
                        }
                        self.window?.makeKeyAndVisible()
                         NotificationCenter.default.post(name: NSNotification.Name.init("FromSocialLogin"), object: nil, userInfo: ["loginInfo":params])
                    })
                }
                else
                {
                    self.otpTxtField.text = ""
                    self.view.makeToast((response["message"] as! String), point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
                    
                    self.view.clearToastQueue()
                }
                
            }
            
            
        }) { (failure) in
            self.view.makeToast("Request Time Out !")
            self.view.clearToastQueue()
        }
        
    }
    
    func sendOTP()  {
        
        var param = NSDictionary.init()
        var api_name = ""
        
        if isForSignUp {
            param = signUpDataDic
            api_name = APINAME().SIGNUP_OTP_API
        }
        else
        {
          api_name = APINAME().FORGOT_PASSWORD 
            param = forgotPasswordDataDic
        }
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: true, params: param as! [String : Any], success: { (response) in
            print(response)
            
            if !self.serverErrorView.isHidden
            {
                 COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
             
            
            if response["status_code"] as! NSNumber == 1
            {
                self.startOtpTimer()
            }
            
            
        }) { (failure) in
           self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
