////
////  LoginVC.swift
////  FoodApplication
////
////  Created by Kishore on 03/06/18.
////  Copyright © 2018 Kishore. All rights reserved.
////


import UIKit
import PasswordTextField
import CoreLocation
import OneSignal
import LanguageManager_iOS
import L10n_swift
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class LoginVC: UIViewController,UITextFieldDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var fbView: UIView!
    @IBOutlet weak var fb_icon: UIImageView!
    @IBOutlet weak var fbLoginButton: UIButton!
    
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var apple_icon: UIImageView!
    @IBOutlet weak var appleLoginButton: UIButton!
    
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var google_icon: UIImageView!
    @IBOutlet weak var googleloginButton: UIButton!
    
    @IBAction func skipButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            
            COMMON_FUNCTIONS.addCustomTabBar()
        }
    }
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    @IBAction func crossButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var createAcountButton: UIButton!
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var serverErrorView: UIView!
    //  @IBOutlet weak var imageUperView: UIView!
    var device_id = ""
    
    var email = ""
    var password = ""
    var device_size = ""
    var first_name = ""
    var last_name = ""
    var social_user_id = ""
    var user_profile_photo_url = ""
    var ios_version = ""
    var isFromLogout = false
    var isFromProfilePage = false
    
    let userDefaults = UserDefaults.standard
    var google_token = ""
      var fb_token = ""
    var appleAuthorizationCode = ""
    var appleIdentityToken = ""
 
    
    @IBAction func appLanguageButton(_ sender: UIButton) {
        
        
        
        let actionSheetController = UIAlertController(title: "Select App Language", message: nil, preferredStyle: .actionSheet)
            actionSheetController.addAction(UIAlertAction(title: "BiH", style: .default, handler: { (alert) in
            // DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // the view controller that you want to show after changing the language
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
            
            LanguageManager.shared.setLanguage(language: Languages(rawValue: "bs")!, rootViewController: viewController) { (view) in
                self.userDefaults.set(["bs","en"], forKey: "AppleLanguages")
//                self.userDefaults.setValue(["lo","en"], forKey: "AppleLanguages")
                L10n.shared.language = "bs"
                currentLanguage = "bs"
                self.userDefaults.set(currentLanguage, forKey: "currentLanguage")
                self.userDefaults.synchronize()
                LanguageManager.shared.defaultLanguage = .bs
                view.transform = CGAffineTransform(scaleX: 2, y: 2)
                view.alpha = 0
            }
            // }
         
        }))
        
        actionSheetController.addAction(UIAlertAction(title: "English", style: .default, handler: { (alert) in
            
            // DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // the view controller that you want to show after changing the language
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
            
            LanguageManager.shared.setLanguage(language: .en, rootViewController: viewController) { (view) in
                self.userDefaults.set(["en","bs"], forKey: "AppleLanguages")
//                self.userDefaults.setValue(["en","lo"], forKey: "AppleLanguages")
                
                L10n.shared.language = "en"
                currentLanguage = "en"
                self.userDefaults.set(currentLanguage, forKey: "currentLanguage")
                self.userDefaults.synchronize()
                LanguageManager.shared.defaultLanguage = .en
                view.transform = CGAffineTransform(scaleX: 2, y: 2)
                view.alpha = 0
            }
            // }
        }))
        
        
        actionSheetController.addAction(UIAlertAction( title: "z_cancel".getLocalizedValue(), style: .cancel, handler: { (alert) in
            return
        }))
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            let popoverController = actionSheetController.popoverPresentationController
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = self.view.bounds
        }
        self.present(actionSheetController, animated: true, completion: nil)
        
        
        //        // change the language
        //
        //
        //
        //         LanguageManager.shared.setLanguage(language: Languages(rawValue: "lo")!, rootViewController: viewController) { (view) in
        //            LanguageManager.shared.defaultLanguage = .lo
        //
        //            view.transform = CGAffineTransform(scaleX: 2, y: 2)
        //            view.alpha = 0
        //         }
        //
    }
    
    func changingAppLanguage() {
      
    }
   
    func updateView()   {
      
        DispatchQueue.main.async {
            print("y_signin".getLocalizedValue())
            self.pageTitleLbl.text = "y_signin".getLocalizedValue()
            self.emailTxtField.placeholder = "z_email".getLocalizedValue()
            self.passwordTxtField.placeholder = "z_password".getLocalizedValue()
            self.forgotPasswordButton.setTitle("y_login_forgot".getLocalizedValue(), for: .normal)
            self.loginButton.setTitle("z_login".getLocalizedValue(), for: .normal)
            self.createAcountButton.setTitle("y_login_join".getLocalizedValue(), for: .normal)
            
            if Language.isRTL {
                self.emailTxtField.textAlignment = .right
                self.passwordTxtField.textAlignment = .right
            }
            else
            {
                self.emailTxtField.textAlignment = .left
                self.passwordTxtField.textAlignment = .left
            }
        }
      
    }
    
    
    @IBAction func createNewAccountButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
    
    @IBAction func forgotPasswordButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var appleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appleViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fbViewCenterHorizontalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTxtField: PasswordTextField!
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        callLoginAPI()
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
                                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                                viewController.user_first_name = self.first_name
                                viewController.user_last_name = self.last_name
                                self.navigationController?.pushViewController(viewController, animated: true)
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
    
    
    
    
    
    override func viewDidLoad() {
        
        appleView.layer.cornerRadius = appleView.frame.height / 2
        fbView.layer.cornerRadius = fbView.frame.height / 2
        googleView.layer.cornerRadius = googleView.frame.height / 2
        
//        appleView.layer.borderColor = UIColor.black.cgColor
//        appleView.layer.borderWidth = 1
        
        googleView.layer.borderColor = UIColor.black.cgColor
               googleView.layer.borderWidth = 1
        
        fbView.layer.borderColor = UIColor.black.cgColor
               fbView.layer.borderWidth = 1
        
        
        updateView()
        
        
        if #available(iOS 13.0,  *) {
            self.appleViewWidthConstraint.constant = 50
            self.appleViewHeightConstraint.constant = 50
            self.appleView.isHidden = false
            self.fbViewCenterHorizontalConstraint.constant = 0
        }
        else {
            self.appleViewWidthConstraint.constant = 0
            self.appleViewHeightConstraint.constant = 0
            self.appleView.isHidden = true
            self.fbViewCenterHorizontalConstraint.constant = -35
        }
        
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            let status:OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let userID = status.subscriptionStatus.userId
            print("userID = \(String(describing: userID))")
            
        })
         UIApplication.shared.statusBarView?.backgroundColor = .white
        super.viewDidLoad()
        self.serverErrorView.isHidden = true
        
        self.loginButton.layer.cornerRadius = 6
        self.loginButton.layer.borderWidth = 1
        self.loginButton.layer.borderColor = UIColor.white.cgColor
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(FromSocialLogin(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("FromSocialLogin")), object: nil)
    }
    
    
   @objc func FromSocialLogin(notification: Notification)
    {
        
        if let userInfo = notification.userInfo {
            if (userInfo["loginInfo"] as? NSMutableDictionary) != nil
            {
                self.emailTxtField.text! = (userInfo["loginInfo"] as! NSMutableDictionary)["email"] as! String
                self.passwordTxtField.text! = (userInfo["loginInfo"] as! NSMutableDictionary)["password"] as! String
                callLoginAPI()
            }
         }
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
   
        
        if isFromAppdelegate {
            self.crossButton.isHidden = true
//            self.skipButton.isHidden = false
        }
        else
        {
            self.crossButton.isHidden = false
//            self.skipButton.isHidden = true
            
        }
        if userDefaults.value(forKey: "refresh_token") != nil {
            UserDefaults.standard.removeObject(forKey: "refresh_token")
            
        }
        if userDefaults.value(forKey: "access_token") != nil {
           UserDefaults.standard.removeObject(forKey: "access_token")
        }
        if userDefaults.value(forKey: "token_type") != nil {
            UserDefaults.standard.removeObject(forKey: "token_type")
        }
        
        if UserDefaults.standard.value(forKey: "user_data") != nil
        {
            UserDefaults.standard.removeObject(forKey: "user_data")
        }
       
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        device_size = "\(width) * \(height)"
        ios_version = UIDevice.current.systemVersion
        device_id = UIDevice.current.identifierForVendor!.uuidString
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
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
                       let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                       viewController.user_first_name = self.first_name
                       viewController.user_last_name = self.last_name
                       viewController.user_email_address = self.email
                       viewController.social_id = self.social_user_id
                       viewController.isFromLogin = true
                       self.navigationController?.pushViewController(viewController, animated: true)
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
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                    viewController.user_first_name = self.first_name
                    viewController.user_last_name = self.last_name
                    viewController.user_email_address = self.email
                    viewController.isFromLogin = true
                    self.navigationController?.pushViewController(viewController, animated: true)
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
                      DispatchQueue.main.async {
                          let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                          viewController.user_first_name = self.first_name
                          viewController.user_last_name = self.last_name
                          viewController.user_email_address = self.email
                          viewController.appleAuthorizationCode = self.appleIdentityToken
                          viewController.isFromLogin = true
                          self.navigationController?.pushViewController(viewController, animated: true)
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
       
  
    //MARK: -Login Api
    
    func callLoginAPI() {
       
        //getCodes()
        print("Time Zone = \(localTimeZoneName)")
        email = self.emailTxtField.text!
        password = self.passwordTxtField.text!
        if (email.isEmpty) {
            self.popUpAlertView(title: "h_email".getLocalizedValue())
            return
        }
       
        
        if (password.isEmpty) {
            self.popUpAlertView(title: "h_password".getLocalizedValue())
            return
        }
       
        
        if let token = userDefaults.value(forKey: "notification_token") as? String
        {
            notification_token = token
        }
        
        
        let params = ["user": email,"password": password,"device_type": "ios","device_id": device_id,"screen_size": device_size,"device_os": "ios \(ios_version)","ip_address": "","location_name": user_city_location,"latitude": latitude,"longitude": longitude,"browser": "","timezone": localTimeZoneName,"notification_token": notification_token,"refresh_token": "","access_token": "","user_type":"1"]
        
        
        print("Params = \(params)")
        
        //let params = ["email": email,"password": password,"notification_token": notification_token]
        let api_name = APINAME().LOGIN_API  
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: params, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            if response["status_code"] as! NSNumber == 1
            {
                print(response)
                
                DispatchQueue.main.async {
                    let userDatationary = (response["data"] as! NSArray).object(at: 0) as! NSDictionary
                      COMMON_FUNCTIONS.getAppDetails(data:  userDatationary["app_data"] as! NSDictionary)
                    self.setUserData(userDatationary: userDatationary)
                }
            }
            else
            {
                self.view.makeToast((response["message"] as! String), duration: 2, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                    self.passwordTxtField.text = ""
                    self.emailTxtField.becomeFirstResponder()
                    return
                })
                
                
            }
        }) { (failure) in
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        
    }
    
    
    //MARK: Get App Data
    
    
   
    
    //MARK: Set USERDATA
    
//    func setUserData(userDatationary:NSDictionary)  {
//        var user_id:String!,user_first_name:String!,user_last_name:String!,user_email_id:String!,user_photo:String!,user_session_id:String!,user_mobile_number:String!,user_referral_code:String
//
//        user_id =  COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "id") as AnyObject)).1
//
//
//        user_first_name = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "first_name") as AnyObject)).1
//
//
//        user_last_name = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "last_name") as AnyObject)).1
//
//
//
//        user_email_id = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "email") as AnyObject)).1
//
//
//        user_photo = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "photo") as AnyObject)).1
//
//
//        user_mobile_number = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "phone") as AnyObject)).1
//        user_referral_code = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "referral_code") as AnyObject)).1
//
//        user_session_id = COMMON_FUNCTIONS.checkForNull(string: (userDatationary.object(forKey: "user_session_id") as AnyObject)).1
//
//        let user_data = UserDataClass(user_id: user_id, user_first_name: user_first_name, user_last_name: user_last_name, user_email_id: user_email_id, user_mobile_number: user_mobile_number,user_photo: user_photo,user_session_id: user_session_id,user_referral_code:user_referral_code)
//
//        NSKeyedArchiver.setClassName("UserDataClass", for: UserDataClass.self)
//        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user_data)
//        userDefaults.set(encodedData, forKey: "user_data")
//        userDefaults.synchronize()
//
////        DispatchQueue.main.async {
////
////            COMMON_FUNCTIONS.addCustomTabBar()
////        }
//
//        let api_name = APINAME().ACCESS_TOKEN_API
//        let param = ["grant_type":"password","client_secret":CLIENT_SECRET,"client_id":"2","username":self.emailTxtField.text!,"password":self.passwordTxtField.text!]
//
//        WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: true, success: { (response) in
//
//            print(response)
//            access_token = (response["access_token"] as! String)
//            refresh_token = (response["refresh_token"] as! String)
//            token_type  = (response["token_type"] as! String)
//            let expireTime = (response["expires_in"] as! NSNumber)
//            // let expireDate = Date().addingTimeInterval(TimeInterval(exactly: 60)!)
//             let expireDate = Date().addingTimeInterval(TimeInterval(exactly: expireTime)!)
//            self.userDefaults.setValue(expireDate, forKey: "expireDate")
//            self.userDefaults.setValue(refresh_token, forKey: "refresh_token")
//             self.userDefaults.setValue(access_token, forKey: "access_token")
//             self.userDefaults.setValue(token_type, forKey: "token_type")
//            DispatchQueue.main.async {
//
//                if  isFromAppdelegate
//                {
//                    COMMON_FUNCTIONS.addCustomTabBar()
//                }
//                else
//                {
//                    NotificationCenter.default.post(name: NSNotification.Name("login_update_notitfication"), object: nil)
//                    self.dismiss(animated: true, completion: nil)
//                }
//
//            }
//
//
//        }) { (failure) in
//
//        }
//
//
//    }
    
    
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
           
           if isForSocialLogin {
//               DispatchQueue.main.async {
//                   let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
//                   let window = UIApplication.shared.delegate?.window!
//                   if window != nil
//                   {
//                       window?.rootViewController = tabbarVC
//                       window?.makeKeyAndVisible()
//                       tabbarVC.selectedIndex = 0
//                   }
//
//
//               }
            
            COMMON_FUNCTIONS.addCustomTabBar()
           }
           else
           {
         
           let api_name = APINAME().ACCESS_TOKEN_API
           let param = ["grant_type":"password","client_secret":CLIENT_SECRET,"client_id":"2","username":self.emailTxtField.text!,"password":self.passwordTxtField.text!]
           
           WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: true, success: { (response) in
               
               print(response)
               access_token = (response["access_token"] as! String)
               refresh_token = (response["refresh_token"] as! String)
               token_type  = (response["token_type"] as! String)
               let expireTime = (response["expires_in"] as! NSNumber)
               // let expireDate = Date().addingTimeInterval(TimeInterval(exactly: 60)!)
                let expireDate = Date().addingTimeInterval(TimeInterval(exactly: expireTime)!)
               self.userDefaults.setValue(expireDate, forKey: "expireDate")
               self.userDefaults.setValue(refresh_token, forKey: "refresh_token")
                self.userDefaults.setValue(access_token, forKey: "access_token")
                self.userDefaults.setValue(token_type, forKey: "token_type")
              
               DispatchQueue.main.async {
//                   let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
//                   let window = UIApplication.shared.delegate?.window!
//                   if window != nil
//                   {
//                       window?.rootViewController = tabbarVC
//                       window?.makeKeyAndVisible()
//                       tabbarVC.selectedIndex = 0
//                   }
//
                COMMON_FUNCTIONS.addCustomTabBar()
               }
               
               
           }) { (failure) in
               
           }
              }
           
       }
       
       
   
    
    //MARK: -POP AlertViewController
    
    func popUpAlertView(title:String)  {
        self.view.makeToast(title, duration: 2, position: .center, title: "", image: nil, style: .init()) { (result) in
            self.emailTxtField.becomeFirstResponder()
            self.view.clearToastQueue()
    
           
            
        }
    }
    
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField.tag == 1 {
            email = textField.text!
            return
        }
        if textField.tag == 2 {
             
            password = textField.text!
            return
        }
        
    }
    
    
    //MARK: -Email Validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    //MARK: Password Change API's
  
}



@available(iOS 13.0, *)
extension LoginVC :ASAuthorizationControllerDelegate
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
extension LoginVC:ASAuthorizationControllerPresentationContextProviding
{
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
}



