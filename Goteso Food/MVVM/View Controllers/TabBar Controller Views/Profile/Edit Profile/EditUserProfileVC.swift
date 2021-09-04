//
//  EditUserProfileVC.swift
//  FoodApplication
//
//  Created by Kishore on 06/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CropViewController
import Alamofire
import SVProgressHUD
import ListPlaceholder
import IQKeyboardManager

class EditUserProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    
    @IBAction func backButton(_ sender: UIButton) {
        
        if isDataChanged {
            
           
            let alert = UIAlertController(title: "", message:  "a_unsaved".getLocalizedValue(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "z_yes".getLocalizedValue(), style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
                return
            }))
            
            alert.addAction(UIAlertAction(title: "z_no".getLocalizedValue(), style: .destructive, handler: { (action) in
                return
                
            }))
            
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                let popPresenter = alert.popoverPresentationController
                popPresenter?.sourceView = self.view
                popPresenter?.sourceRect =  self.view.bounds
            }
            
          
            self.present(alert, animated: true, completion: nil)
            return
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
      
    }
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func updateButton(_ sender: UIButton) {
        if self.updateFieldDataArray() {
            self.updateProfileAPI()
        }
       
    }
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var shimmerView: UIView!
    var isDataChanged = false
    
    var image_data:AnyObject!
    var user_data:UserDataClass!
    var imagePath = ""
    var gender = ""
    @IBOutlet weak var tableView: UITableView!
    var userImage:UIImage?
    var selectedDate:String = "", formatedDate = "", current_dob = ""
    var datePicker:UIDatePicker?
    var firstName:String = ""
    var lastName:String = ""
    var email:String = ""
    var contact_number:String = ""
    var allDataArray:NSMutableArray!
    var allFieldsDataArray:NSMutableArray!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  userImage = UIImageView.init()
        pageTitleLbl.text = "z_edit_profile".getLocalizedValue()
        updateButton.setTitle("z_update".getLocalizedValue(), for: .normal)
        self.serverErrorView.isHidden = true
      self.shimmerView.showLoader()
        allDataArray = NSMutableArray.init()
        allFieldsDataArray = NSMutableArray.init()
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        
        getFieldsDataFromAPI()
        
        
        
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
       
       self.tableView.reloadData()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Selector Methods//////////
    
//    @objc func update_button(_ sender: UIBarButtonItem)
//    {
//         self.updateFieldDataArray()
//       self.updateProfileAPI()
////
//    }

    @objc func popVC(_ sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func datePickerAction(_ sender: UIDatePicker)
    {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd"
        selectedDate = formattedDateFromString(dateString: formatter1.string(from: sender.date), withFormat: "MMM dd, yyyy")!
        formatedDate = formattedDateFromString(dateString: formatter1.string(from: sender.date), withFormat: "yyyy-MM-dd")!
    }
    
    @objc func editImageButton(_ sender: UIBarButtonItem)
    {
      
        
        let alertController = UIAlertController(title: "z_add_photo".getLocalizedValue(), message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "y_take_photo".getLocalizedValue(), style: .default, handler: { (action) in
            
            let imagePicker = UIImagePickerController.init()
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
            
        }))
        
        
        alertController.addAction(UIAlertAction(title: "z_choose_from_library".getLocalizedValue(), style: .default, handler: { (action) in
            
            let imagePicker = UIImagePickerController.init()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.delegate = self
            //imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }))
       
        alertController.addAction(UIAlertAction(title: "z_cancel".getLocalizedValue(), style: .cancel, handler: { (action) in
            print("Cancel")
        }))
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            let popPresenter = alertController.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect =  self.view.bounds
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK: - ImageCropping Methods
    
    
 @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
    
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        userImage = pickedImage
        }
    picker.dismiss(animated: true) {
        self.presentCropViewController()
    }
    
    
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
    }
    
    
  @objc func presentCropViewController() {
         
        let cropViewController = CropViewController(croppingStyle: .circular, image: userImage!)
        cropViewController.delegate = self
        self.present(cropViewController, animated: false, completion: nil)
    }
    
  @objc func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
    image_data = UIImageJPEGRepresentation(image, 0.5) as AnyObject
       apiMultipart(imageData: image_data)
      
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: Get Fields Data From API

    func getFieldsDataFromAPI( )  {
        let url = APINAME().USER_FORM_API + "/\(user_data.user_id!)?user_type=customer&timezone=\(localTimeZoneName)"
        
            print(url)
       
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
                print(response)
            
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            if response["status_code"] != nil
            {
                if response["status_code"] as! NSNumber == 1001
                {
                    DispatchQueue.main.async {
                        productCartArray.removeAllObjects()
                        UserDefaults.standard.removeObject(forKey: "user_data")
                        let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                        let window = UIWindow(frame: UIScreen.main.bounds)
                        window.rootViewController = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                        window.makeKeyAndVisible()
                        return
                    }
                    
                }
            }
             if response["status_code"] as! NSNumber == 1
             {
            
                self.allDataArray = ((response["data"] as! NSArray).mutableCopy() as! NSMutableArray)
                
                print(self.allDataArray)
                DispatchQueue.main.async {
                    
                    let userBasicInfoFieldsArray = (self.allDataArray.object(at: 0) as! NSDictionary).object(forKey: "fields") as! NSArray
                    let additionalInfoFieldsArray =  (self.allDataArray.object(at: 1) as! NSDictionary).object(forKey: "fields") as! NSArray
                    for subdic in userBasicInfoFieldsArray
                    {
                        let subdic1 = subdic as! NSDictionary
                        
                       if subdic1.object(forKey: "type") as! String == "file"
                       {
                        self.allFieldsDataArray.add(subdic)
                        }
                        if subdic1.object(forKey: "type") as! String == "text"
                        {
                            self.allFieldsDataArray.add(subdic)
                        }
                        
                        if subdic1.object(forKey: "type") as! String == "email"
                        {
                            self.allFieldsDataArray.add(subdic)
                        }
                        if subdic1.object(forKey: "type") as! String == "tel"
                        {
                            self.allFieldsDataArray.add(subdic)
                        }
                        
                    }
                    
                    for subdic in additionalInfoFieldsArray
                    {
                        let subdic1 = subdic as! NSDictionary
                        
                        if subdic1.object(forKey: "type") as! String == "datePicker"
                        {
                            self.allFieldsDataArray.add(subdic)
                        }
                        if subdic1.object(forKey: "type") as! String == "radio"
                        {
                            self.allFieldsDataArray.add(subdic)
                        }
                    }
                    
                   self.shimmerView.isHidden = true
                    self.shimmerView.hideLoader()
                    self.tableView.reloadData()
                }
                
            }
            else
             {
                self.view.makeToast((response["message"] as! String))
            }
             
            }) { (failure) in
                self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
            }
        }
    
    //MARK: - Upload Image
    
    func apiMultipart(imageData: AnyObject?) {
     isDataChanged = true
        let serviceName = BASE_URL + prefix + "upload-image?type=user"
       
         SVProgressHUD.show()
        
        print(serviceName)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
           
            if let data = imageData {
            
                multipartFormData.append(data as! Data, withName: "image", fileName: "image.jpg", mimeType: "image/jpg")
            }
            
            
        }, usingThreshold: UInt64.init(), to: serviceName, method: .post) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded  = \(response)")
                      
                    if let err = response.error{
                        SVProgressHUD.dismiss()
                        print(err)
                        return
                    }
                    else
                    {
                        
                        if let result = response.result.value {
                            let JSON = result as! NSDictionary
                            self.imagePath = (JSON["data"] as! NSDictionary).object(forKey: "thumb_image") as! String
                            DispatchQueue.main.async {
                                let image_url = URL(string: IMAGE_BASE_URL + "user/" +  self.imagePath )
                                if image_url != nil
                                {
                                   if let data1 = NSData(contentsOfFile: IMAGE_BASE_URL + "user/" +  self.imagePath )
                                   {
                                    self.userImage = UIImage(data: data1 as Data)
                                    }
                                    
                                }
                                
                                SVProgressHUD.dismiss()
                                self.tableView.reloadData()
                            }
                         
                            print(JSON)
                        }
                      
                    }
                   
                }
            case .failure(let error):
                SVProgressHUD.dismiss()
                print("Error in upload: \(error.localizedDescription)")
                
            }
        }

    }
    
    //MARK: Update Profile API Calling
    
    
    func updateProfileAPI()  {
        
        let api_url =  APINAME().USER_FORM_API + "/" + user_data.user_id!
        print(allDataArray!)
        WebService.requestPUTUrlWithJSONArrayParameters(strURL: api_url, is_loader_required: true, params: allDataArray, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            print(response)
            
            if response["status_code"] != nil
            {
                if response["status_code"] as! NSNumber == 1001
                {
                    DispatchQueue.main.async {
                        productCartArray.removeAllObjects()
                        UserDefaults.standard.removeObject(forKey: "user_data")
                        let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                        let window = UIWindow(frame: UIScreen.main.bounds)
                        window.rootViewController = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                        window.makeKeyAndVisible()
                        return
                    }
                    
                }
            }
            
              if response["status_code"] as! NSNumber == 1
            {
                DispatchQueue.main.async {
                    self.updateNSUserDefaultsData(msg: (response["message"] as! String))
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
    
    
    //MARK: Update Fields  Data Array For JSON
    
    func updateFieldDataArray() -> Bool  {
        
        for (index,data) in allDataArray.enumerated()
        {
            if data is String
            {
                allDataArray.remove(data)
            }
            else
            {
                let dataDictionary = (data as! NSDictionary).mutableCopy() as! NSMutableDictionary
                let title = dataDictionary.object(forKey: "title") as! String
                
                
                if title == "Basic Information" || title == "Additional Informations"
                {
                    let field_array = (dataDictionary.object(forKey: "fields") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    for (index_number,tempData) in field_array.enumerated()
                    {
                        let (isMatched,fieldDataDictionary,isValueEmpty) =       isMatchedWithTitle(dataDictionary: tempData as! NSDictionary)
                        if isMatched
                        {
                            if isValueEmpty
                            {
                                self.view.makeToast( "enter_valid".getLocalizedValue() + " \(fieldDataDictionary["title"] as! String)", duration: 1, position: .center, title: "", image: nil, style: .init(), completion: nil)
                                self.view.clearToastQueue()
                                
                                return false
                            }
                            else
                            {
                                field_array.replaceObject(at: index_number, with: fieldDataDictionary)
                            }
                            
                        }
                        else
                        {
                            if (tempData as! NSDictionary).object(forKey: "title") as! String == "User Type"
                            {
                                
                            }
                            else
                            {
                                field_array.remove(tempData)
                            }
                        }
                    }
                    dataDictionary.setObject(field_array, forKey: "fields" as  NSCopying)
                    
                }
                allDataArray.replaceObject(at: index, with: dataDictionary)
            }
        }
        print("Updated All Data Array = \(allDataArray!)")
        return true
        
        
    }


    func isMatchedWithTitle(dataDictionary: NSDictionary) -> (matched:Bool,matchedDictionary: NSDictionary,isValueEmpty:Bool) {
        
        for value in allFieldsDataArray {
            let tempDataDictionary = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
            if tempDataDictionary.object(forKey: "title") as! String  == dataDictionary.object(forKey: "title") as! String
            {
                if tempDataDictionary.object(forKey: "identifier") as! String == "photo"
                {
                    if imagePath.isEmpty
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,false)
                    }
                    else
                    {
                        tempDataDictionary.setObject(imagePath, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,false)
                    }
                }
                
                if tempDataDictionary.object(forKey: "identifier") as! String == "last_name"
                {
                    if (lastName.isEmpty)
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                         return (true,tempDataDictionary,false)
                    }
                    else
                    {
                        tempDataDictionary.setObject(lastName, forKey: "value" as NSCopying)
                         return (true,tempDataDictionary,false)
                    }
                    
                }
                
                if tempDataDictionary.object(forKey: "identifier") as! String == "first_name"
                {
                    if (firstName.isEmpty)
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,true)
                    }
                    else if firstName.count < 3
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,true)
                    }
                    else
                    {
                        tempDataDictionary.setObject(firstName, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,false)
                    }
                }
                if tempDataDictionary.object(forKey: "identifier") as! String == "email"
                {
                    if (email.isEmpty)
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,false)
                    }
                    else
                    {
                        tempDataDictionary.setObject(email, forKey: "value" as NSCopying)
                         return (true,tempDataDictionary,false)
                    }
                }
                
                if tempDataDictionary.object(forKey: "identifier") as! String == "phone"
                {
                    if (contact_number.isEmpty)
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,true)
                    }
                    else if contact_number.count > 4 && contact_number.count < 15
                    {
                        tempDataDictionary.setObject(contact_number, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,false)
                    }
                    else
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,true)
                    }
                }
                
                if tempDataDictionary.object(forKey: "identifier") as! String == "dob"
                {
                    if (formatedDate.isEmpty)
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                        return (true,tempDataDictionary,false)
                    }
                    else
                    {
                        tempDataDictionary.setObject(formatedDate, forKey: "value" as NSCopying)
                         return (true,tempDataDictionary,false)
                    }
                }
                if tempDataDictionary.object(forKey: "identifier") as! String == "gender"
                {
                    if (gender.isEmpty)
                    {
                        tempDataDictionary.setObject("", forKey: "value" as NSCopying)
                         return (true,tempDataDictionary,false)
                    }
                    else
                    {
                        tempDataDictionary.setObject(gender, forKey: "value" as NSCopying)
                         return (true,tempDataDictionary,false)
                    }
                }
                
            }
            
        }
        return (false,NSDictionary.init(),false)
    }
    
    
    //MARK: - Update NSUser Defaults Data
    
    func updateNSUserDefaultsData(msg:String) {
        let userDataArray = (allDataArray.object(at: 0) as! NSDictionary).object(forKey: "fields") as! NSArray
        for value in userDataArray {
            let userDataDictionary = value as! NSDictionary
            
            if userDataDictionary.object(forKey: "title") as! String == "Image"
            {
                user_data.user_photo = (userDataDictionary.object(forKey: "value") as! String)
            }
            
            if userDataDictionary.object(forKey: "title") as! String == "First Name"
            {
                user_data.user_first_name = (userDataDictionary.object(forKey: "value") as! String)
            }
            
            if userDataDictionary.object(forKey: "title") as! String == "Last Name"
            {
                user_data.user_last_name = (userDataDictionary.object(forKey: "value") as! String)
            }
            
            if userDataDictionary.object(forKey: "title") as! String == "Email"
            {
                user_data.user_email_id = (userDataDictionary.object(forKey: "value") as! String)
            }
            
            if userDataDictionary.object(forKey: "title") as! String == "Phone"
            {
                user_data.user_mobile_number = (userDataDictionary.object(forKey: "value") as! String)
            }
        }
        
        let user_data1 = UserDataClass(user_id: self.user_data.user_id, user_first_name:  self.user_data.user_first_name, user_last_name:  self.user_data.user_last_name, user_email_id:  self.user_data.user_email_id, user_mobile_number:  self.user_data.user_mobile_number,  user_photo:  self.user_data.user_photo,user_session_id:  self.user_data.user_session_id,user_referral_code:self.user_data.user_referral_code)
        
        let userDefaults1 = UserDefaults.standard
        NSKeyedArchiver.setClassName("UserDataClass", for: UserDataClass.self)
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user_data1)
        userDefaults1.set(encodedData, forKey: "user_data")
        userDefaults1.synchronize()
        
        let decoded  = userDefaults1.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        let user_data2  = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        print(user_data2.user_photo)
        
        
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "z_ok".getLocalizedValue(), style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = viewController?.view
            popPresenter?.sourceRect = (viewController?.view.bounds)!
        }
        
        viewController?.present(alert, animated: true, completion: nil)
        
    }
 
    
}
    


    


//MARK: - TableView DataSource Methods

extension EditUserProfileVC:UITableViewDataSource,UITextFieldDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allFieldsDataArray.count > 0 {
            return allFieldsDataArray.count
        }
        else
        {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if allFieldsDataArray.count > 0 {
            
            let dataDictionary = allFieldsDataArray.object(at: indexPath.row) as! NSDictionary
            
            if dataDictionary.object(forKey: "type") as! String == "file"
            {
                let nib:UINib = UINib(nibName: "EditUserImageTableCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "EditUserImageTableCell")
                
                let cell:EditUserImageTableCell = tableView.dequeueReusableCell(withIdentifier: "EditUserImageTableCell") as! EditUserImageTableCell
                cell.userImageView.layer.borderWidth = 1
                cell.userImageView.layer.borderColor = UIColor.lightGray.cgColor
                cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width/2
                
                
                if (dataDictionary.object(forKey: "value") as! String).isEmpty == true {
                   
                    cell.userImageView.setImage(string: user_data.user_first_name! + " " + user_data.user_last_name!)
                }
                else
                {
                    if imagePath.isEmpty
                    {
                        imagePath = (dataDictionary.object(forKey: "value") as! String)
                    }
                    let image_url = URL(string: IMAGE_BASE_URL + "user/" + imagePath)
                    
                    cell.userImageView.sd_setImage(with: image_url, placeholderImage:UIImage(named: "user_placeholder"))
                }
                
                if userImage != nil
                {
                    cell.userImageView.image = userImage
                    cell.userImageView.contentMode = .scaleAspectFit
                }
                
                cell.editImageButton.addTarget(self, action: #selector(editImageButton(_:)), for: .touchUpInside)
                cell.editImageView.layer.borderWidth = 1
                cell.editImageView.layer.borderColor = UIColor.lightGray.cgColor
                cell.editImageView.layer.cornerRadius = cell.editImageView.frame.size.width/2
                cell.selectionStyle = .none
                
                return cell
            }
            
            if dataDictionary.object(forKey: "type") as! String == "text" || dataDictionary.object(forKey: "type") as! String == "email" || dataDictionary.object(forKey: "type") as! String == "tel"
            {
                if dataDictionary.object(forKey: "title") as! String == "First Name"
                {
                    let nib:UINib = UINib(nibName: "TextFieldTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "TextFieldTableCell")
                    
                    let cell:TextFieldTableCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableCell") as! TextFieldTableCell
                    cell.textField.delegate = self
                    cell.textField.keyboardType = .default
                    cell.textField.placeholder = (dataDictionary.object(forKey: "title") as! String)
                    if (dataDictionary.object(forKey: "value") as! String).isEmpty
                    {
                        firstName = ""
                        
                        cell.textField.text = (dataDictionary.object(forKey: "value") as! String)
                    }
                    else
                    {
                        firstName = (dataDictionary.object(forKey: "value") as! String)
                        cell.textField.text = firstName
                    }
                    
                    cell.selectionStyle = .none
                    return cell
                }
                if dataDictionary.object(forKey: "title") as! String == "Last Name"
                {
                    let nib:UINib = UINib(nibName: "TextFieldTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "TextFieldTableCell")
                    
                    let cell:TextFieldTableCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableCell") as! TextFieldTableCell
                    cell.textField.delegate = self
                    cell.textField.keyboardType = .default
                    cell.textField.placeholder = (dataDictionary.object(forKey: "title") as! String)
                    if (dataDictionary.object(forKey: "value") as! String).isEmpty
                    {
                        lastName = ""
                        
                        cell.textField.text = (dataDictionary.object(forKey: "value") as! String)
                    }
                    else
                    {
                        lastName = (dataDictionary.object(forKey: "value") as! String)
                        cell.textField.text = lastName
                    }
                    cell.selectionStyle = .none
                    return cell
                }
                if dataDictionary.object(forKey: "title") as! String == "Email"
                {
                    let nib:UINib = UINib(nibName: "TextFieldTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "TextFieldTableCell")
                    
                    let cell:TextFieldTableCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableCell") as! TextFieldTableCell
                    cell.textField.delegate = self
                    cell.textField.keyboardType = .emailAddress
                    cell.textField.placeholder = (dataDictionary.object(forKey: "title") as! String)
                    if (dataDictionary.object(forKey: "value") as! String).isEmpty
                    {
                        email = ""
                        
                        cell.textField.text = (dataDictionary.object(forKey: "value") as! String)
                    }
                    else
                    {
                        email = (dataDictionary.object(forKey: "value") as! String)
                        cell.textField.text = email
                    }
                    cell.selectionStyle = .none
                    return cell
                }
                if dataDictionary.object(forKey: "title") as! String == "Phone"
                {
                    let nib:UINib = UINib(nibName: "TextFieldTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "TextFieldTableCell")
                    let cell:TextFieldTableCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableCell") as! TextFieldTableCell
                    cell.textField.delegate = self
                    cell.textField.keyboardType = .numberPad
                    cell.textField.placeholder = (dataDictionary.object(forKey: "title") as! String)
                    if (dataDictionary.object(forKey: "value") as! String).isEmpty
                    {
                        contact_number = ""
                        
                        if let value = (dataDictionary.object(forKey: "value") as? String)
                        {
                            cell.textField.text = value
                        }
                    }
                    else
                    {
                        contact_number = (dataDictionary.object(forKey: "value") as! String)
                        cell.textField.text = contact_number
                    }
                    cell.selectionStyle = .none
                    return cell
                }
                
            }
            if dataDictionary.object(forKey: "type") as! String == "datePicker"
            {
                let nib:UINib = UINib(nibName: "AdditionalTableCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "AdditionalTableCell")
                
                let cell:AdditionalTableCell = tableView.dequeueReusableCell(withIdentifier: "AdditionalTableCell") as! AdditionalTableCell
                cell.titleLbl.text = "Date of Birth"
                
                
                if (dataDictionary.object(forKey: "value") as! String).isEmpty
                {
                    selectedDate = ""
                    formatedDate = ""
                    if let value = (dataDictionary.object(forKey: "value") as? String)
                    {
                        if !value.isEmpty
                        {
                            selectedDate = formattedDateFromString(dateString: value, withFormat: "MMM dd, yyyy")!
                            formatedDate = formattedDateFromString(dateString: value, withFormat: "yyyy-MM-dd")!
                            cell.subTitleLbl.text = selectedDate
                        }
                        else
                        {
                            cell.subTitleLbl.text = ""
                        }
                        
                    }
                }
                else
                {
                    selectedDate = formattedDateFromString(dateString: (dataDictionary.object(forKey: "value") as! String), withFormat: "MMM dd, yyyy")!
                    current_dob = selectedDate
                    formatedDate = formattedDateFromString(dateString: (dataDictionary.object(forKey: "value") as! String), withFormat: "yyyy-MM-dd")!
                   
                    cell.subTitleLbl.text = selectedDate
                }
                cell.selectionStyle = .none
                return cell
            }
            if dataDictionary.object(forKey: "type") as! String == "radio"
            {
                let nib:UINib = UINib(nibName: "AdditionalTableCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "AdditionalTableCell")
                
                let cell:AdditionalTableCell = tableView.dequeueReusableCell(withIdentifier: "AdditionalTableCell") as! AdditionalTableCell
                cell.titleLbl.text = "Select Gender"
                
                if (dataDictionary.object(forKey: "value") as! String).isEmpty
                {
                    gender = ""
                    if let value = (dataDictionary.object(forKey: "value") as? String)
                    {
                        
                        cell.subTitleLbl.text = value
                    }
                }
                else
                {
                    gender = (dataDictionary.object(forKey: "value") as! String)
                    cell.subTitleLbl.text = gender
                }
                
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell(frame: CGRect.zero)
    }
    
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
//        view.backgroundColor = tableView.backgroundColor
//        return view
//    }
   
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        if textField.placeholder == "First Name" {
            firstName = newString
        }
        if textField.placeholder == "Last Name" {
            lastName = newString
            
        }
        
        if textField.placeholder == "Phone" {
            if newString.count > 8
            {
                contact_number = newString
                
            }
        }
        return true
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        isDataChanged  = true
       
        if textField.placeholder == "Email" {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if textField.placeholder == "First Name" {
            if textField.text!.count < 3 || textField.text!.count > 50
            {
                COMMON_FUNCTIONS.showAlert(msg: "User name must be in range of (3 - 50) characters")
               
                return
            }
            
        }
        
        if textField.placeholder == "First Name" {
            if (textField.text?.isEmpty)! {
                self.isTextFieldValid(string: textField.placeholder!,textField: textField)
               
            }
            firstName = textField.text!
            return
        }
        if textField.placeholder == "Last Name" {
            lastName = textField.text!
            return
        }
        if textField.placeholder == "Email" {
            
            if (textField.text?.isEmpty)! {
                self.isTextFieldValid(string: textField.placeholder!,textField: textField)
                
            }
           
        }
        if textField.placeholder == "Phone" {
            if (textField.text?.isEmpty)! {
                self.isTextFieldValid(string: textField.placeholder!,textField: textField)
                
            }
            
            if textField.text!.count > 8
            {
                contact_number = textField.text!
                return
            }
            else
            {
                contact_number = ""
                COMMON_FUNCTIONS.showAlert(msg: "The phone number is too short")
                
                return
            }
        }
    }
    
    //MARK: Get Date Format
    func formattedDateFromString(dateString: String, withFormat format: String) -> String? {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
}
/////////////////////

//MARK: - TableView Delegate Methods

extension EditUserProfileVC:UITableViewDelegate
{
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
        return 130
        }
        else if indexPath.row == 5 || indexPath.row == 6
        {
            return 84
        }
        else
        {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 5 {
           
            self.selectDate(indexPath: indexPath)
        }
        else if indexPath.row == 6
        {
        
           self.selectGender(indexPath: indexPath)
        }
        else
        {
        return
        }
    }
    
    
    //MARK: - Popup AlertView for TexField Validations
    
    func isTextFieldValid(string: String, textField: UITextField)   {
        
        let alertController = UIAlertController(title: "", message: "z_enter".getLocalizedValue() + " " + string, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "z_ok".getLocalizedValue(), style: .cancel, handler: { (action) in
          // textField.becomeFirstResponder()
            return
        }))
        let popPresenter = alertController.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Popup AlertView for Gender Selection
    
    func selectGender(indexPath : IndexPath) {
       isDataChanged = true
          let dataDictionary = allFieldsDataArray.object(at: indexPath.row) as! NSDictionary
        let alertController = UIAlertController(title: (dataDictionary["title"] as! String), message: nil, preferredStyle: .actionSheet)
        ///Check data for "Male" and "Female"
        alertController.addAction(UIAlertAction(title: "Male", style: .default, handler: { (action) in
            self.gender = "Male"
            let cell:AdditionalTableCell  = self.tableView.cellForRow(at: indexPath) as! AdditionalTableCell
            cell.subTitleLbl.text = "Male"
            cell.subTitleLbl.isHidden = false
            return
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Female", style: .default, handler: { (action) in
            
            self.gender = "Female"
            let cell:AdditionalTableCell  = self.tableView.cellForRow(at: indexPath) as! AdditionalTableCell
            cell.subTitleLbl.text = "Female"
            cell.subTitleLbl.isHidden = false
            return
            
        }))
        
        alertController.addAction(UIAlertAction(title: "z_cancel".getLocalizedValue(), style: .destructive, handler: { (action) in
            print("Cancel")
        }))
        
         if UIDevice().userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
      
        self.present(alertController, animated: true, completion: nil)
       
        
    }
    
    
    //MARK: -Email Validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
     //MARK: - Pop AlertView for Date Selection
    
    
   func selectDate(indexPath : IndexPath) {
    isDataChanged = true
    let dataDictionary = allFieldsDataArray.object(at: indexPath.row) as! NSDictionary
    let alertController = UIAlertController(title: (dataDictionary["title"] as! String), message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
    
    datePicker = UIDatePicker(frame: CGRect(x: alertController.view.frame.origin.x, y: 15, width: 250, height: 210))
    //let maximumDate
    
    alertController.view.addSubview(datePicker!)
    datePicker?.clipsToBounds = true
    datePicker?.datePickerMode = .date
    let inputFormatter = DateFormatter()
    if current_dob.isNotEmpty {
        inputFormatter.dateFormat = "MMM dd, yyyy"
        datePicker?.date = inputFormatter.date(from: current_dob)!
    }
    
    datePicker?.maximumDate = Date()
 
    
    alertController.addAction(UIAlertAction(title: "z_cancel".getLocalizedValue(), style: .cancel, handler: { (action) in
        print("Cancel")
    }))
    
    alertController.addAction(UIAlertAction(title: "z_ok".getLocalizedValue(), style: .default, handler: { (action) in
        print("Ok")
        
        let cell:AdditionalTableCell  = self.tableView.cellForRow(at: indexPath) as! AdditionalTableCell
        cell.subTitleLbl.text = self.selectedDate
        cell.subTitleLbl.isHidden = false
        
    }))
    if UIDevice.current.userInterfaceIdiom == .pad
    {
        let popPresenter = alertController.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect =  self.view.bounds
    }
    self.present(alertController, animated: true, completion: nil)
    datePicker?.addTarget(self, action: #selector(datePickerAction(_:)), for: .valueChanged)
    
    }
    
}





