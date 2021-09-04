//
//  SignUpVC.swift
//  FoodApplication
//
//  Created by Kishore on 04/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import PasswordTextField
import MaterialComponents.MaterialBottomSheet
import NotificationCenter
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class SignUpVC: UIViewController,UITextFieldDelegate , GIDSignInDelegate {
   
    var isForOTP = true
    var otp = ""
    
    @IBOutlet weak var orLbl: UILabel!
    @IBOutlet weak var diamondImage: UIImageView!
    @IBOutlet weak var orLineView: UIView!
    
    @IBOutlet weak var fbViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var googeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbView: UIView!
    @IBOutlet weak var fb_icon: UIImageView!
    @IBOutlet weak var fbLoginButton: UIButton!
    
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var apple_icon: UIImageView!
    @IBOutlet weak var appleLoginButton: UIButton!
    
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var google_icon: UIImageView!
    @IBOutlet weak var googleloginButton: UIButton!
    
    @IBOutlet weak var serverErrorView: UIView!
    
    
    @IBOutlet weak var termsAndConditionButton: UIButton!
    @IBAction func termsAndConditionButton(_ sender: UIButton) {
    
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsVC") as! TermsAndConditionsVC
        self.navigationController?.pushViewController(viewController, animated: true)
    
    }
    
    
    
    var user_first_name = ""
    var user_last_name = ""
    var user_email_address = ""
    var user_mobile_number = ""
    var user_password = ""
    var is_confirm_password = false
    
    var agreementStatus = false
    
    
    @IBOutlet weak var referralCodeTxtField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    @IBOutlet weak var userFirstNameTxtField: UITextField!
    
    @IBOutlet weak var userLastNameTxtField: UITextField!
    @IBOutlet weak var userEmailTxtField: UITextField!
    
    @IBOutlet weak var confirmPasswordTxtField: PasswordTextField!
    
    @IBOutlet weak var newPasswordTxtField: PasswordTextField!
    
    @IBOutlet weak var userMobileNumberTxtField: UITextField!
    
    //Update view After OTP
//    func popoverDismissed() {
//
//    }
    var isFromLogin = false
    
     var social_id = ""
    var appleAuthorizationCode = ""
     var appleIdentityToken = ""
     let userDefaults = UserDefaults.standard
     var google_token = ""
       var fb_token = ""
    
     var email = ""
    var first_name = ""
       var last_name = ""
       var social_user_id = ""
       var user_profile_photo_url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appleView.layer.cornerRadius = appleView.frame.height / 2
        fbView.layer.cornerRadius = fbView.frame.height / 2
        googleView.layer.cornerRadius = googleView.frame.height / 2
//        appleView.layer.borderColor = UIColor.black.cgColor
//             appleView.layer.borderWidth = 1
             
             googleView.layer.borderColor = UIColor.black.cgColor
                    googleView.layer.borderWidth = 1
             
             fbView.layer.borderColor = UIColor.black.cgColor
                    fbView.layer.borderWidth = 1
        if Language.isRTL {
            userEmailTxtField.textAlignment = .right
            newPasswordTxtField.textAlignment = .right
            referralCodeTxtField.textAlignment = .right
            userLastNameTxtField.textAlignment = .right
            userFirstNameTxtField.textAlignment = .right
            confirmPasswordTxtField.textAlignment = .right
            userMobileNumberTxtField.textAlignment = .right
        }
        
        
        
        userFirstNameTxtField.placeholder = "z_first_name".getLocalizedValue()
        userLastNameTxtField.placeholder = "z_lastname".getLocalizedValue()
        userEmailTxtField.placeholder = "z_email".getLocalizedValue()
        userMobileNumberTxtField.placeholder = "z_mobile".getLocalizedValue()
        newPasswordTxtField.placeholder = "h_password".getLocalizedValue()
        confirmPasswordTxtField.placeholder = "z_confirm_new_password".getLocalizedValue()
        referralCodeTxtField.placeholder = "h_referral".getLocalizedValue()
        
         termsAndConditionButton.setTitle("y_signup_terms".getLocalizedValue(), for: .normal)
        signUpButton.setTitle("y_signup".getLocalizedValue(), for: .normal)
        
        
         self.serverErrorView.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = true
        if !self.user_first_name.isEmpty {
             self.userFirstNameTxtField.text = self.user_first_name
        }
        if !self.user_email_address.isEmpty {
            self.userEmailTxtField.text = self.user_email_address
        }
        if !self.user_last_name.isEmpty {
            self.userLastNameTxtField.text = self.user_last_name
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(signUpOTPNotificationAcion(notification:)), name: NSNotification.Name.init("signUpOTPNotification"), object: nil)
        if #available(iOS 13.0, *) {
                      self.appleViewHeightConstraint.constant = 50
                  self.fbViewCenterConstraint.constant = 0
            self.appleView.isHidden = false
                     } else {
                       self.appleViewHeightConstraint.constant = 0
                       self.appleView.isHidden = true
                       self.fbViewCenterConstraint.constant = -35
                     }
       
        if isFromLogin {
            fbViewHeightConstraint.constant = 0
            googeViewHeightConstraint.constant = 0
            appleViewHeightConstraint.constant = 0
            orLineView.isHidden = true
            orLbl.isHidden = true
            diamondImage.isHidden = true
        }
        else {
            fbViewHeightConstraint.constant = 50
            googeViewHeightConstraint.constant = 50
            appleViewHeightConstraint.constant = 50
            orLineView.isHidden = false
                      orLbl.isHidden = false
                      diamondImage.isHidden = false
        }
        
      GIDSignIn.sharedInstance().delegate = self
      GIDSignIn.sharedInstance()?.presentingViewController = self
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "y_signup".getLocalizedValue()
    }
    
    //Google SignIn
      func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                withError error: Error!) {
          if let error = error {
              print("\(error.localizedDescription)")
          } else {
              
              let userId = user.userID
              let fullName = user.profile.name
              let givenName = user.profile.givenName
              google_token =  user.authentication.accessToken
              first_name = user.profile.givenName
              last_name = user.profile.familyName
              email = user.profile.email
              social_user_id = user.userID
              
              print("user_id = \(userId!)")
              //  print("idToken = \(idToken!)")
              print("fullName = \(fullName!)")
              print("givenName = \(givenName!)")
              
              print("email = \(email)")
              
              callGoogleLoginAPI()
              
              
          }
      }
    
    
    @IBAction func googleLoginButton(_ sender: UIButton) {
         GIDSignIn.sharedInstance().signOut()
         GIDSignIn.sharedInstance().signIn()
     }
     
     
     @IBAction func appleLoginButton(_ sender: UIButton) {
         
         if #available(iOS 13.0, *) {
              let provider = ASAuthorizationAppleIDProvider()
              let request = provider.createRequest()
              request.requestedScopes = [.fullName,.email]
             
             let controller = ASAuthorizationController(authorizationRequests: [request])
             controller.delegate = self
             controller.presentationContextProvider = self
             controller.performRequests()
         } else {
             // Fallback on earlier versions
         }
       
         
     }
     
     @IBAction func facebookLoginButton(_ sender: UIButton) {
             
             if UserDefaults.standard.value(forKey: "Default_Selected_Address") != nil
             {
                 UserDefaults.standard.removeObject(forKey: "Default_Selected_Address")
             }
             
             if UserDefaults.standard.value(forKey: "user_data") != nil
             {
                 UserDefaults.standard.removeObject(forKey: "user_data")
             }
             
             let fbLoginManager = LoginManager()
             fbLoginManager.logOut()
             
             let cookies = HTTPCookieStorage.shared
             let facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
             for cookie in facebookCookies! {
                 cookies.deleteCookie(cookie )
             }
             
             if #available(iOS 10.0, *) {
     //            fbLoginManager.loginBehavior = FBSDKLoginBehavior.browser
                 
             }
             //        else
             //        {
             //
             //            fbLoginManager.loginBehavior = .
             //        }
             
             fbLoginManager.logIn(permissions: ["public_profile","email"], from: self) { (fbLoginResult, fbLoginError) in
            
                 if (fbLoginError != nil)
                 {
                     
                     print("FBLoginError = \(fbLoginError!)")
                 }
                 else if (fbLoginResult?.isCancelled)!
                 {
                     
                     print("FBResult Login Cancelled = \(fbLoginResult!)")
                 }
                 else
                 {
                     let fbLoginParameters = ["fields":"email,first_name, last_name,birthday,picture,gender,hometown"]
                     
                     
                     
                     let fbSDKGraphRequest = GraphRequest.init(graphPath: "me", parameters: fbLoginParameters, httpMethod:HTTPMethod(rawValue: "GET"))
                     
                     fbSDKGraphRequest.start(completionHandler: { (connection, fbSDKGraphResult, fbSDKGraphError) in
                         
                         if (fbLoginError != nil)
                         {
                             
                         }
                         else
                         {
                             let fbResult = (fbSDKGraphResult as! NSDictionary)
                             self.fb_token = AccessToken.current!.tokenString
                             self.social_user_id = fbResult.object(forKey: "id") as! String
                             self.first_name = fbResult.object(forKey: "first_name") as! String
                             self.last_name = fbResult.object(forKey: "last_name") as! String
                             self.user_profile_photo_url = ((fbResult.object(forKey: "picture") as! NSDictionary).object(forKey: "data") as! NSDictionary).object(forKey: "url") as! String
                             
                             if let userEmail = fbResult.object(forKey: "email") as? String
                             {
                                 self.email = userEmail
                             }
                             else
                             {
//                                 let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
//                                 viewController.user_first_name = self.first_name
//                                 viewController.user_last_name = self.last_name
//                                 self.navigationController?.pushViewController(viewController, animated: true)
                                self.user_first_name = self.first_name
                                self.user_last_name = self.last_name
                                
                                 return
                             }
                             self.callFacebookLoginAPI()
                         }
                         print("FBGraph Result = \(fbSDKGraphResult!)")
                         
                     })
                     print("Fb Login Successfully Result = \(fbLoginResult!)")
                     
                 }
                 
             }
         }
     
     
     
    
    
    
    @objc func left_button(_ sender: UIButton?){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func signUpOTPNotificationAcion(notification:Notification)
    {
        isForOTP = true
    }
    
    
    @IBAction func checkBoxButton(_ sender: UIButton) {
        
        if sender.currentImage == #imageLiteral(resourceName: "emptyCheckBox") {
            
            sender.setImage(#imageLiteral(resourceName: "checkBox"), for: UIControlState.normal)
            agreementStatus = true
        }
        else
        {
          sender.setImage(#imageLiteral(resourceName: "emptyCheckBox"), for: .normal)
            agreementStatus = false
        }
        
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        
        user_first_name = userFirstNameTxtField.text!
        user_last_name = userLastNameTxtField.text!
        user_mobile_number = userMobileNumberTxtField.text!
        user_email_address = userEmailTxtField.text!
        user_password = newPasswordTxtField.text!
        
         let (isValid,title) = self.isValid()
        
        if isValid == true  {
            if !agreementStatus {
                COMMON_FUNCTIONS.showAlert(msg: "a_signup_terms".getLocalizedValue())
                return
            }
            createNewUserAPI()
        }
        else
        {
           self.view.makeToast(title, duration: 2, position: .center, title: "", image: nil, style: .init(), completion: nil)
            self.view.clearToastQueue()
            
        }
        
       
        
      
//        let viewController: OTPVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVC") as! OTPVC
//
//        // self.navigationController?.pushViewController(viewController, animated: true)
//        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
//        bottomSheet.trackingScrollView?.scrollsToTop = false
//        self.present(bottomSheet, animated: true, completion: nil)
        
    }
    
    
    //MARK: -Check For Empty TextFields
    func isValid() -> (isValid: Bool,title: String) {
        
        if user_first_name.isEmpty == true
        {
            return (false,"h_first_name".getLocalizedValue())
        }
        if user_email_address.isEmpty == true && user_mobile_number.isEmpty == true {
            return (false,"a_emailmobile_format".getLocalizedValue())
        }
        if user_password.isEmpty == true {
            return (false,"h_password".getLocalizedValue())
        }
        
        if !is_confirm_password {
         return (false,"z_confirm_new_password".getLocalizedValue())
        }
        
       
        if !(user_password.count > 5) {
            
            return (false,"a_password".getLocalizedValue())
        }
//        else if !COMMON_FUNCTIONS.isValidPassword(password: user_password)
//        {
//
//            return (false,"Your Password is not secure. Your password should contain alphabet,number and special characters along with capital letter i.e. Sample@123")
//        }
        return (true,"Congratulations!")
    }
    
    //MARK: - Call API
     
    func createNewUserAPI()  {
       var alert:UIAlertController!
     var api_name = ""
        
        if isForOTP {
            api_name = APINAME().SIGNUP_OTP_API
        }
        else
        {
              api_name = APINAME().SIGNUP_API
        }
        
        let params = ["first_name":user_first_name,"last_name":user_last_name,"email":user_email_address,"phone":user_mobile_number,"password":user_password,"login_type":"email","otp":otp,"user_type":"1","invitation_code":referralCodeTxtField.text!,"apple_id":appleAuthorizationCode,"facebook_id":social_id] as [String : Any]
        
        print(params)
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: true, params: params, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            DispatchQueue.main.async {
                if response["status_code"] as! NSNumber == 1
                {
                    
                    if self.isForOTP
                    {
                        let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerifyVC") as! OTPVerifyVC
                        viewController.signUpDataDic = params as NSDictionary
                        viewController.isForSignUp = true
                        self.present(viewController, animated: true, completion: nil)
                        self.isForOTP = false
                        return
                    }
                    else
                    {
                        self.view.makeToast((response["message"] as! String), duration: 2, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                            self.navigationController?.popViewController(animated: true)
                            return
                        })
                      
                    }
                    
                }
                else
                {
                    self.view.makeToast((response["message"] as! String), duration: 2, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                       self.userFirstNameTxtField.becomeFirstResponder()
                        return
                    })
                    
                }
               
                print(response)
            }
            
           
        }) { (failure) in
           self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    
    }
    
    
    
    //MARK: Facebook Login API
         func callFacebookLoginAPI()   {
             if email.isEmpty && first_name.isEmpty && last_name.isEmpty && social_user_id.isEmpty && user_profile_photo_url.isEmpty {
                 return
             }
             // let api_name = APINAME().LOGIN_API
             
             notification_token = userDefaults.value(forKey: "notification_token") as! String
             
             let api_name = APINAME().ACCESS_TOKEN_API
             let param = ["grant_type":"facebook","client_secret":CLIENT_SECRET,"client_id":"2","username":first_name + " " + last_name,"fb_token":fb_token]
             
             
             WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: true, success: { (response) in
                 print(response)
                 if (response["error"] as? String) != nil
                 {
                     DispatchQueue.main.async {
                        self.user_first_name = self.first_name
                        self.user_last_name = self.last_name
                        self.user_email_address = self.email
                        self.social_id = self.social_user_id
                        self.userFirstNameTxtField.text = self.first_name
                        self.userLastNameTxtField.text = self.last_name
                        self.userEmailTxtField.text = self.email
//                        self.isFromLogin = true
                         return
                     }
                 }
                 else
                 {
                     access_token = (response["access_token"] as! String)
                                   refresh_token = (response["refresh_token"] as! String)
                                   token_type  = (response["token_type"] as! String)
                                   let expireTime = (response["expires_in"] as! NSNumber)
                                   let expireDate = Date().addingTimeInterval(TimeInterval(exactly: expireTime)!)
                                   UserDefaults.standard.setValue(access_token, forKey: "access_token")
                                   UserDefaults.standard.setValue(expireDate, forKey: "expireDate")
                                   UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
                                   UserDefaults.standard.setValue(token_type, forKey: "token_type")
                  
                     self.socialLogin(userId: COMMON_FUNCTIONS.checkForNull(string: response["user_id"] as AnyObject).1, tokenResponse: response)
                 }
                 
             }) { (failure) in
                 self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
                     return
                 })
             }
             
         }
       
      
      //MARK: Google Login API
      
      func callGoogleLoginAPI()   {
          
          notification_token = userDefaults.value(forKey: "notification_token") as! String
          
          let api_name = APINAME().ACCESS_TOKEN_API
          let param = ["grant_type":"google","client_secret":CLIENT_SECRET,"client_id":"2","username":first_name + " " + last_name,"google_token":google_token]
          
          WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: true, success: { (response) in
              print(response)
              if (response["error"] as? String) != nil
              {
                  DispatchQueue.main.async {
                     
                    self.user_first_name = self.first_name
                    self.user_last_name = self.last_name
                    self.user_email_address = self.email
                    self.userFirstNameTxtField.text = self.first_name
                    self.userLastNameTxtField.text = self.last_name
                    self.userEmailTxtField.text = self.email
                    
//                    self.isFromLogin = true
                      return
                  }
              }
              else
              {
                  
                  access_token = (response["access_token"] as! String)
                  refresh_token = (response["refresh_token"] as! String)
                  token_type  = (response["token_type"] as! String)
                  let expireTime = (response["expires_in"] as! NSNumber)
                  let expireDate = Date().addingTimeInterval(TimeInterval(exactly: expireTime)!)
                  UserDefaults.standard.setValue(access_token, forKey: "access_token")
                  UserDefaults.standard.setValue(expireDate, forKey: "expireDate")
                  UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
                  UserDefaults.standard.setValue(token_type, forKey: "token_type")
                  
                  
                  self.socialLogin(userId: COMMON_FUNCTIONS.checkForNull(string: response["user_id"] as AnyObject).1, tokenResponse: response)
              }
              
          }) { (failure) in
              self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
                  return
              })
          }
          
      }
      
      //MARK: Apple Login API
      func callAppleLoginAPI()   {
                
                notification_token = userDefaults.value(forKey: "notification_token") as! String
                
                let api_name = APINAME().ACCESS_TOKEN_API
                let param = ["grant_type":"apple","client_secret":CLIENT_SECRET,"client_id":"2","username":first_name + " " + last_name,"apple_token":appleIdentityToken]
                
                WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: true, success: { (response) in
                    print(response)
                    if (response["error"] as? String) != nil
                    {
//                        DispatchQueue.main.async {
//                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
//                            viewController.user_first_name = self.first_name
//                            viewController.user_last_name = self.last_name
//                            viewController.user_email_address = self.email
//                            viewController.appleAuthorizationCode = self.appleIdentityToken
//                            viewController.isFromLogin = true
//                            self.navigationController?.pushViewController(viewController, animated: true)
//                            return
//                        }
                        
                        self.user_first_name = self.first_name
                        self.user_last_name = self.last_name
                        self.user_email_address = self.email
                        self.userFirstNameTxtField.text = self.first_name
                        self.userLastNameTxtField.text = self.last_name
                        self.userEmailTxtField.text = self.email
//                        self.isFromLogin = true
                    }
                    else
                    {
                        
                        access_token = (response["access_token"] as! String)
                        refresh_token = (response["refresh_token"] as! String)
                        token_type  = (response["token_type"] as! String)
                        let expireTime = (response["expires_in"] as! NSNumber)
                        let expireDate = Date().addingTimeInterval(TimeInterval(exactly: expireTime)!)
                        UserDefaults.standard.setValue(access_token, forKey: "access_token")
                        UserDefaults.standard.setValue(expireDate, forKey: "expireDate")
                        UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
                        UserDefaults.standard.setValue(token_type, forKey: "token_type")
                        
                        
                        self.socialLogin(userId: COMMON_FUNCTIONS.checkForNull(string: response["user_id"] as AnyObject).1, tokenResponse: response)
                    }
                    
                }) { (failure) in
                    self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
                        return
                    })
                }
                
            }
         
      
      
      //MARK: Social Login (FB & Google)
         
         
         func socialLogin(userId:String,tokenResponse:NSDictionary)  {
             
             if let token = userDefaults.value(forKey: "notification_token") as? String
             {
                 notification_token = token
             }
             
             
             let params = ["user_id": userId, "notification_token": notification_token]
             
             
             print("Params = \(params)")
             
             //let params = ["email": email,"password": password,"notification_token": notification_token]
             let api_name = APINAME.init().SOCIAL_LOGIN_API
             
             WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: params, success: { (response) in
                 
                 if response["status_code"] as! NSNumber == 1
                 {
                     print(response)
                     
                     DispatchQueue.main.async {
                         let userDatationary = (response["data"] as! NSArray).object(at: 0) as! NSDictionary
                         self.setUserData(userDatationary: userDatationary,isForSocialLogin:true)
                     }
                 }
                 else
                 {
                     self.view.makeToast((response["message"] as! String), duration: 2, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                         
                         return
                     })
                     
                     
                 }
             }) { (failure) in
                 self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
                     return
                 })
             }
             
         }
    
    
    private func signIn(signIn: GIDSignIn!,
                              presentViewController viewController: UIViewController!) {
              self.present(viewController, animated: true, completion: nil)
          }
          
          // Dismiss the "Sign in with Google" view
          private func signIn(signIn: GIDSignIn!,
                              dismissViewController viewController: UIViewController!) {
              self.dismiss(animated: true, completion: nil)
          }
    
    
    
     //MARK: Set USERDATA
           
           func setUserData(userDatationary:NSDictionary,isForSocialLogin:Bool = false)  {
               var user_id:String!,user_first_name:String!,user_last_name:String!,user_email_id:String!,user_photo:String!,user_session_id:String!,user_mobile_number:String!,user_referral_code:String
               
               user_id =  COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "id") as AnyObject)).1
               
               
               user_first_name = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "first_name") as AnyObject)).1
               
               
               user_last_name = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "last_name") as AnyObject)).1
               
               
               
               user_email_id = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "email") as AnyObject)).1
               
               
               user_photo = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "photo") as AnyObject)).1
               
               
               user_mobile_number = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "phone") as AnyObject)).1
               user_referral_code = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "referral_code") as AnyObject)).1
               
               user_session_id = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "user_session_id") as AnyObject)).1
               
               let user_data = UserDataClass(user_id: user_id, user_first_name: user_first_name, user_last_name: user_last_name, user_email_id: user_email_id, user_mobile_number: user_mobile_number,user_photo: user_photo,user_session_id: user_session_id,user_referral_code:user_referral_code)
               
               
               let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user_data)
               userDefaults.set(encodedData, forKey: "user_data")
               userDefaults.synchronize()
              COMMON_FUNCTIONS.addCustomTabBar()
              
               
               
           }
           
           
    
    
    
    
    //MARK: - TextField Delegates
    
 
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1  {
            textField.text?.capitalizeFirstLetter()
            if (textField.text?.count)! < 3
            {
                 self.view.makeToast("a_firstname_limit_min".getLocalizedValue(), point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
                 textField.text = ""
               // textField.becomeFirstResponder()
                return
            }
            else if (textField.text?.count)! > 50
            {
                self.view.makeToast("a_firstname_limit_min".getLocalizedValue(), point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
                textField.text = ""
                //textField.becomeFirstResponder()
                return
            }
//            else if !COMMON_FUNCTIONS.isValidUserName(name: textField.text!)
//            {
//                COMMON_FUNCTIONS.showAlert(msg: "User Name can contain only alphabetic (e.g Sam)")
//                textField.text = ""
//                textField.becomeFirstResponder()
//                return
//            }
            
        }
        
        if textField.tag == 2 {
            textField.text?.capitalizeFirstLetter()
        }
        
        if textField.tag == 4 {
            if (textField.text?.count)! < 8
            {
               // textField.becomeFirstResponder()
                 self.view.makeToast("a_phone_limit_min", point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
               return
            }
        }
        
        if textField.tag == 3 {
           if isValidEmail(testStr: textField.text!)
           {
            return
            }
            else
           {
             self.view.makeToast("a_email_format".getLocalizedValue(), point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
            textField.text =  ""
           // textField.becomeFirstResponder()
            return
            }
        }
        
        if textField.tag == 5 {
            user_password = textField.text!
            
            if user_password.count > 5
            {
                return
            }
            else
            {
                 self.view.makeToast("a_password".getLocalizedValue(), point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
                //textField.becomeFirstResponder()
                return
            }
            
        }
        
        if textField.tag == 6 {
            if user_password == textField.text!
            {
                is_confirm_password = true
                return
            }
            else
            {
                is_confirm_password = false
                self.view.makeToast("a_match_password".getLocalizedValue(), point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
            textField.text = ""
           // textField.becomeFirstResponder()
                return
            }
        }
    }
    
    //MARK: -Email Validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
   

}


@available(iOS 13.0, *)
extension SignUpVC :ASAuthorizationControllerDelegate
{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error = ",error)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
     
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            appleIdentityToken = String(decoding: credentials.identityToken!, as: UTF8.self)
             appleAuthorizationCode = String(decoding: credentials.authorizationCode!, as: UTF8.self)
            if let email = credentials.email
            {
                if !email.contains(".appleid.com") {
                    self.email = email
                }
            }
            
            if let fname = credentials.fullName?.givenName
            {
                self.first_name = fname
            }
            if let lname = credentials.fullName?.familyName
                       {
                           self.last_name = lname
                       }
            
            if let email = credentials.email
            {
                if !email.contains(".appleid.com") {
                    self.email = email
                }
            }

         
            print(appleIdentityToken)
            print(appleAuthorizationCode)
            self.callAppleLoginAPI()
            
        default:
                break
        }
        
    }
    
}
extension SignUpVC:ASAuthorizationControllerPresentationContextProviding
{
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
}



