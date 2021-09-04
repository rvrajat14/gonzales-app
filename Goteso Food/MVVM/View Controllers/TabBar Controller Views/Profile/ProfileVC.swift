//
//  ProfileVC.swift
//  Dry Clean City
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import SDWebImage
import CRRefresh
import LanguageManager_iOS
import L10n_swift

class ProfileVC: UIViewController {

    var window: UIWindow!
     @IBOutlet weak var profileV: UIView!
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBAction func editProfileButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EditUserProfileVC") as! EditUserProfileVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var userProfileImgV: UIImageView!
    @IBOutlet weak var userNumberLbl: UILabel!
    var user_data:UserDataClass!
    let userDefaults = UserDefaults.standard

    var dataArray1 = NSMutableArray.init()
    var dataArray2 = NSMutableArray.init()
    var dataArray3 = NSMutableArray.init()
    var user_name = ""
    var loyalty_points = ""
    var user_photo = ""
    var referral_code = ""
    var invite_string = ""
    var user_number = ""
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
      self.serverErrorView.isHidden = true
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
      
        self.tableView.rowHeight = UITableViewAutomaticDimension
         self.tableView.estimatedRowHeight = 50
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 10))
        headerView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.tableHeaderView = headerView
         self.navigationController?.isNavigationBarHidden = true
        if userDefaults.object(forKey: "user_data") != nil {
            addRefreshFunctionality()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
       //title = "PROFILE"
        self.tabBarController?.tabBar.isHidden = false
        
        
        let dic2:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "home_black")),("title","z_delivery_address".getLocalizedValue()))
        let dic3:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "key_icon")),("title","z_change_password".getLocalizedValue()))
        let dic4:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "helpicon")),("title","y_faq_title".getLocalizedValue()))
        let dic5:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "support")),("title","z_support".getLocalizedValue()))
        let dic6:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "share")),("title","y_profile_social_media".getLocalizedValue()))
        let dic7:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "info")),("title","y_profile_terms".getLocalizedValue()))
        let dic9:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "invite")),("title","y_invite_page_title".getLocalizedValue()))
        let dic8:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "wallet_icon")),("title","z_wallet".getLocalizedValue()))
        
        let dic10:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "lang_icon")),("title","z_change_language".getLocalizedValue()))
        
        
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.object(forKey: "user_data") as? Data  {
              NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
            user_data = (NSKeyedUnarchiver.unarchiveObject(with: data) as! UserDataClass)
            self.user_name = user_data.user_first_name! + " " + user_data.user_last_name!
            self.user_number = user_data.user_mobile_number!
            self.user_photo = user_data.user_photo!
            profileV.isHidden = true
            dataArray1 = NSMutableArray(objects: dic2,dic3 )
            dataArray2 = NSMutableArray(objects: dic8,dic9 )
            dataArray3 = NSMutableArray(objects: dic4,dic5,dic6,dic7,dic10)
            updateProfile()
            self.tableView.reloadData()
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            
            getUserProfileDataAPI(loader:false)
        }
        else
        {
            profileV.isHidden = false
            dataArray3 = NSMutableArray(objects: dic4,dic5,dic6,dic7)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    func addRefreshFunctionality()  {
        
        self.tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            self?.getUserProfileDataAPI(loader: false)
        }
    }

    //MARK: -Call User API
    func getUserProfileDataAPI(loader:Bool)  {
        
        let api_name = APINAME()
        let url = api_name.USER_API +  "/\(user_data.user_id!)"
        
        print(url)
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
           if !self.serverErrorView.isHidden
           {
            COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            
            if response["status_code"] as! NSNumber == 1
            {
                let userDataDic =  (response["data"] as! NSDictionary)
                self.user_name = (userDataDic.object(forKey: "first_name") as! String) + " " + (userDataDic.object(forKey: "last_name") as! String)
                self.referral_code = userDataDic["referral_code"] as! String
                self.invite_string = userDataDic["invite_string"] as! String
                  self.loyalty_points = COMMON_FUNCTIONS.checkForNull(string: userDataDic["wallet_points_count"] as AnyObject).1
                if let image = userDataDic.object(forKey: "photo") as? String
                {
                    self.user_photo = image
                }
              
                DispatchQueue.main.async {
                   self.updateProfile()
                    self.updateViewConstraints()
                    self.tableView.cr.endHeaderRefresh()
                     self.tableView.reloadData()
                }
            }
            else
            {
                 COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                self.tableView.cr.endHeaderRefresh()
            }
            
        }) { (failure) in
            self.tableView.cr.endHeaderRefresh()
            self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
    
    //MARK: UpdateProfile
    func updateProfile()   {
        var image_url: URL!
        if  self.user_photo.isEmpty  {
            self.userProfileImgV.setImage(string: self.user_name)
        }
        else
        {
            image_url = URL(string: IMAGE_BASE_URL + "user/" + self.user_photo)
        }
        
        if image_url == nil || self.user_photo.isEmpty
        {
            self.userProfileImgV.setImage(string: self.user_name)
        }
        else
        {
            self.userProfileImgV.sd_setImage(with: image_url, placeholderImage:UIImage(named: "user_placeholder"))
        }
        
       self.userProfileImgV.layer.cornerRadius = self.userProfileImgV.frame.size.width/2
        self.userProfileImgV.layer.borderWidth = 1
        self.userProfileImgV.layer.borderColor = UIColor(red: 79/255.0, green: 79/255.0, blue: 79/255.0, alpha: 0.50).cgColor
        self.userNameLbl.text = "Hi, "  + self.user_name
        self.userNumberLbl.text = user_number
    }
    
}


//MARK: -TableView DataSource Methods///////

extension ProfileVC:UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if userDefaults.object(forKey: "user_data") != nil {
            
            return 3
        }
        else
        {
            return 1
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userDefaults.object(forKey: "user_data") != nil {
            if section == 0
            {
                return (dataArray1.count)
            }
            else if section == 1
            {
                return (dataArray2.count)
            }
            else
            {
                return (dataArray3.count)
            }
        }
        
        return (dataArray3.count)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if cell.isEqual(nil) == true {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        
        let tempDataDic:NSDictionary!
        if userDefaults.object(forKey: "user_data") != nil {
            if indexPath.section == 0
            {
                tempDataDic =  (dataArray1.object(at: indexPath.row) as! NSDictionary)
            }
            else if indexPath.section == 1
            {
                tempDataDic = (dataArray2.object(at: indexPath.row) as! NSDictionary)
            }
            else
            {
                tempDataDic = (dataArray3.object(at: indexPath.row) as! NSDictionary)
            }
        }
        else
        {
            tempDataDic = (dataArray3.object(at: indexPath.row) as! NSDictionary)
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.imageView?.image = tempDataDic.object(forKey: "image") as? UIImage
        cell.textLabel?.font = UIFont(name: REGULAR_FONT, size: 14)
        cell.textLabel?.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.90)
        cell.textLabel?.text = tempDataDic.object(forKey: "title") as? String
         cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == tableView.numberOfSections - 1 {
            
        let footerMainView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70))
        footerMainView.backgroundColor = tableView.backgroundColor
        let footerButton:UIButton = UIButton(frame: CGRect(x: view.center.x - 50, y: 8, width: 100, height: 40))
        footerButton.setTitle("y_signout".getLocalizedValue(), for: UIControlState.normal)
            footerButton.setTitleColor(MAIN_COLOR, for: UIControlState.normal)
        footerButton.addTarget(self, action: #selector(signOutButton(_:)), for: UIControlEvents.touchUpInside)
        footerMainView.addSubview(footerButton)
        
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 0, y: footerButton.frame.size.height + 4, width: self.view.frame.size.width, height: 22))
        infoLabel.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.40)
            infoLabel.textAlignment = NSTextAlignment.center
            let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
            
            if let version = nsObject as? String
            {
             infoLabel.text = "v" + version
            }
            if userDefaults.object(forKey: "user_data") != nil {
                footerButton.isHidden = false
            }
            else
            {
                footerButton.isHidden = true
            }
       
        //infoLabel.alpha = 0.80
        infoLabel.font = UIFont(name: REGULAR_FONT, size: 13)
        footerMainView.addSubview(infoLabel)
        return footerMainView
        }
        else
        {
            return nil
        }
    }
   
    //MARK: - Selector Methods
    
   
    
    
    @objc func signOutButton(_ sender: UIButton)
    {
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        vc.isFromLoginVC = false
        vc.titleText = "a_signout".getLocalizedValue()
        vc.logoutDelegate = self
        self.present(vc, animated: true, completion: nil)
        
//        let alert = UIAlertController(title: nil, message: "a_signout".getLocalizedValue(), preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "z_yes".getLocalizedValue(), style: .default, handler: { (action) in
//            self.signOutAPI()
//        }))
//        
//        alert.addAction(UIAlertAction(title: "z_no".getLocalizedValue(), style: .destructive, handler: { (action) in
//            return
//        }))
//        if UIDevice.current.userInterfaceIdiom == .pad
//        {
//        let popPresenter = alert.popoverPresentationController
//        popPresenter?.sourceView = self.view
//        popPresenter?.sourceRect = self.view.bounds
//        }
//        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Sign Out API
    
    func signOutAPI() {
        
        let user_session_id = user_data.user_session_id!
        
        
         notification_token = UserDefaults.standard.value(forKey: "notification_token") as! String
        
        let params = ["user_session_id": user_session_id,"notification_token":notification_token]
       let api_name = APINAME().LOGOUT + "/\(user_data.user_id!)"
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: true, params: params, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            
            if response["status_code"] as! NSNumber == 1
            {
                DispatchQueue.main.async {
                    productCartArray.removeAllObjects()
                    UserDefaults.standard.removeObject(forKey: "user_data")
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                    if let window = self.window {
                        window.rootViewController = yourVc
                    }
                    self.window?.makeKeyAndVisible()
                    
                }
            }
            else
            {
                 COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
            }
            
        }) { (failure) in
           self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
       
    }
    
    ///////////////////////////
    
    
}

////////////////////////////////////////////



//MARK: -TableView Delegate Methods///////


extension ProfileVC:UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return 60
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 70
        }
        else
        {
            return 10
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        if cell.textLabel?.text == "z_delivery_address".getLocalizedValue(){
            
            let viewController:DeliveryAddressVC = self.storyboard?.instantiateViewController(withIdentifier: "DeliveryAddressVC") as! DeliveryAddressVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        else if cell.textLabel?.text == "z_change_password".getLocalizedValue(){
            
            let viewController:changePasswordVC = self.storyboard?.instantiateViewController(withIdentifier: "changePasswordVC") as! changePasswordVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        else if cell.textLabel?.text == "y_faq_title".getLocalizedValue(){
            
            let viewController:HelpAndFAQViewController = self.storyboard?.instantiateViewController(withIdentifier: "HelpAndFAQViewController") as! HelpAndFAQViewController
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        else if cell.textLabel?.text == "z_support".getLocalizedValue(){
            let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
        else if cell.textLabel?.text == "y_profile_social_media".getLocalizedValue(){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SocialMediaVC1") as! SocialMediaVC1
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
         
        else if cell.textLabel?.text == "y_profile_terms".getLocalizedValue(){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsVC") as! TermsAndConditionsVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
        else if cell.textLabel?.text == "z_wallet".getLocalizedValue() {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
            viewController.user_id = user_data.user_id!
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
        
        else if cell.textLabel?.text == "y_invite_page_title".getLocalizedValue(){
            
            if referral_code.isEmpty
            {
                return
            }
            else
            {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "InviteAndEarnVC") as! InviteAndEarnVC
                viewController.user_id = user_data.user_id
                viewController.referral_code = referral_code
                viewController.invite_string = invite_string
                 viewController.points = loyalty_points
                self.navigationController?.pushViewController(viewController, animated: true)
                return
            }
           
        }
        
        else if cell.textLabel?.text == "z_change_language".getLocalizedValue(){
            DispatchQueue.main.async {
                self.changeAppLanguage()
            }
         
        }
    
    }
    
    func changeAppLanguage() {
 
        let actionSheetController = UIAlertController(title: "Select App Language", message: nil, preferredStyle: .actionSheet)
            actionSheetController.addAction(UIAlertAction(title: "BiH", style: .default, handler: { (alert) in
                self.userDefaults.set(["bs","en"], forKey: "AppleLanguages")
                L10n.shared.language = "bs"
                currentLanguage = "bs"
                self.userDefaults.set(currentLanguage, forKey: "currentLanguage")
                self.userDefaults.synchronize()
                LanguageManager.shared.defaultLanguage = .bs
                change_lang_internally = true
                COMMON_FUNCTIONS.addCustomTabBar()
        }))
        
        actionSheetController.addAction(UIAlertAction(title: "English", style: .default, handler: { (alert) in
                self.userDefaults.set(["en","bs"], forKey: "AppleLanguages")
                L10n.shared.language = "en"
                currentLanguage = "en"
                self.userDefaults.set(currentLanguage, forKey: "currentLanguage")
                self.userDefaults.synchronize()
                LanguageManager.shared.defaultLanguage = .en
            change_lang_internally = true
            COMMON_FUNCTIONS.addCustomTabBar()
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
    
}
////////////////////////////////////////////

extension ProfileVC: LogoutDelegate {
    func logout(value:String) {
        if value == "z_yes".getLocalizedValue() {
            self.signOutAPI()
        }
        else {
            return
        }
    }
    
    
}
