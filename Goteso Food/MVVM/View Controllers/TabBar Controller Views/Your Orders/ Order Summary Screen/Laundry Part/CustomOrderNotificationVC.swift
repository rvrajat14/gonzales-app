//
//  CustomOrderNotificationVC.swift
//  My MM
//
//  Created by Kishore on 04/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit


struct Message {
    var message: String
    var userId : String
    var date: String
    var userName :String
    
}

class CustomOrderNotificationVC: UIViewController {
    var allRecentChattingDataArray = NSMutableArray.init()
    var senderMsgDataDic = NSMutableDictionary.init()
    var order_id = ""
    var viewWidth : CGFloat!
    
    @IBOutlet weak var mainViewBottomContstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLBl: UILabel!
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    var user_data:UserDataClass!
    @IBOutlet weak var messageTxrtField: UITextField!
    
    @IBAction func sendMessageButton(_ sender: UIButton) {
        sendNewMsgAPI()
    }
    
    
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.serverErrorView.isHidden = true
        self.sendMessageButton.layer.cornerRadius = 6
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.viewWidth = self.view.frame.size.width - 30
        self.tableView.tableFooterView = UIView(frame: .zero)
     
          self.view.backgroundColor =  UIColor(patternImage: UIImage(named: "chat_background")!)
        self.tableView.register(UINib(nibName: "IncomingMessageCell", bundle: nil), forCellReuseIdentifier: "IncomingMessageCell")
         self.tableView.register(UINib(nibName: "OugoingMessageCell", bundle: nil), forCellReuseIdentifier: "OugoingMessageCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 44
        titleLBl.text = "z_order".getLocalizedValue() + "  #\(order_id)"
        messageTxrtField.placeholder = "h_message".getLocalizedValue()
        if Language.isRTL {
            messageTxrtField.textAlignment = .right
        }
        
        self.getAllRecentChatsAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name:   NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
 
    //MARK: Get List Of All Recent chattings
    
    func getAllRecentChatsAPI()  {
        
        
         let api_name = APINAME().CHATTING_API + "/\(order_id)?user_type=1&timezone=\(localTimeZoneName)"
        //let api_name = APINAME().CHATTING_API
        
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: true, success: { (response) in
            
            print(response)
            
            
            if response["status_code"] as! NSNumber == 1
            {
             let dataArray = response["data"] as! [NSDictionary]
                
                for value in dataArray
                {
                    let messageModel = Message(message: COMMON_FUNCTIONS.checkForNull(string: value["text"] as AnyObject).1, userId: COMMON_FUNCTIONS.checkForNull(string: value["sender_id"] as AnyObject).1, date: COMMON_FUNCTIONS.checkForNull(string: value["created_at_formatted"] as AnyObject).1, userName: COMMON_FUNCTIONS.checkForNull(string: value["user_name"] as AnyObject).1)
                    self.allRecentChattingDataArray.add(messageModel)
                }
                
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    if self.allRecentChattingDataArray.count > 0
                    {
                        UIView.performWithoutAnimation {
                            let indexPath = NSIndexPath(row: self.allRecentChattingDataArray.count-1, section: 0)
                            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                        }
                       
                    }
                    else
                    {
                    return
                    }
                    
                    }
            }
            else
            {
             print(response)
            }
        }) { (failure) in
            COMMON_FUNCTIONS.showAlert(msg: "Request time out!")
        }
        
    }
    
    
    func getViewWidth(label: UILabel) -> CGFloat {
        var rect: CGRect = label.frame //get frame of label
        rect.size = (label.text?.size(withAttributes:  [NSAttributedStringKey.font : UIFont(name: label.font.fontName, size: label.font.pointSize)!]))!
        return rect.width
    }
    
    
    //MARK: Post New Message
    func sendNewMsgAPI() {
        
        let api_name = APINAME().CHATTING_API + "?user_type=1&timezone=\(localTimeZoneName)"
        let params = ["text": self.messageTxrtField.text!,"sender_id":user_data.user_id,"receiver_id":0,"order_id":order_id] as [String : Any]
        
        if (self.messageTxrtField.text?.isEmpty)! {
            COMMON_FUNCTIONS.showAlert(msg: "a_order_message".getLocalizedValue())
            return
        }
        
        WebService.requestPostUrl(strURL: api_name, params: params as NSDictionary, is_loader_required: true, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                self.messageTxrtField.text = ""
                let data = (response["data"] as! NSDictionary)
                let messageModel = Message(message: COMMON_FUNCTIONS.checkForNull(string: data["text"] as AnyObject).1, userId: COMMON_FUNCTIONS.checkForNull(string: data["sender_id"] as AnyObject).1, date: COMMON_FUNCTIONS.checkForNull(string: data["created_at_formatted"] as AnyObject).1, userName: COMMON_FUNCTIONS.checkForNull(string: data["user_name"] as AnyObject).1)
                self.allRecentChattingDataArray.add(messageModel)
                //   self.getAllRecentChatsAPI()
                // self.allRecentChattingDataArray = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                
                //   DispatchQueue.main.async {
                if self.allRecentChattingDataArray.count == 0
                {
                    
                    return
                }
                let indexPath = NSIndexPath(row: self.allRecentChattingDataArray.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            }
                
           // }
            else
            {
                
            }
            
        }) { (failure) in
            self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        
    }
    
    
}

extension CustomOrderNotificationVC : UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRecentChattingDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let messageData = allRecentChattingDataArray[indexPath.row] as! Message
                if  messageData.userId == user_data.user_id {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OugoingMessageCell", for: indexPath) as! OugoingMessageCell
                    cell.selectionStyle = .none
                    cell.messageLbl.text = messageData.message
                 //  cell.messageLbl.textInsets = UIEdgeInsets(top: 9, left: 20, bottom: 9, right: 20)
                    let width = getCustomeHeightForLbl(str: messageData.message, font: cell.messageLbl.font).width + 10
                    var height = getCustomeHeightForLbl(str: messageData.message, font: cell.messageLbl.font).height + 10
                    
                   
                    if width < 223 && width > 221
                    {
                        height += 22
                        
                        if height < 63
                        {
                            cell.containerWidthConstraint.constant = width - 22
                        }
                    }
                    else
                    {
                        cell.containerWidthConstraint.constant = width + 20
                    }
                    cell.lblHeightConstraint.constant = height
                    cell.cellBottomLbl.text =  messageData.date
                    cell.cellTopLblHeightConstraints.constant = 0.0
                    
                   // cell.retryBtnWidthConstraints.constant = 0
                    
                   // Utilities.shadowLayerToChat(viewLayer: cell.containerV.layer, shadowColor: KBorderColorCode, cornerRadius: 10)
                    
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingMessageCell", for: indexPath) as! IncomingMessageCell
                cell.selectionStyle = .none
                cell.messageLbl.text = messageData.message
        
                let width = getCustomeHeightForLbl(str: messageData.message, font: cell.messageLbl.font).width + 10
                var height = getCustomeHeightForLbl(str: messageData.message, font: cell.messageLbl.font).height + 10
        
                if width < 223 && width > 221
                {
                    height += 22
                    if height < 63
                    {
                        print("height =\(height) \n msg \(messageData.message)")
                        cell.containerWidthConstraint.constant = width - 22
                    }
                }
                else
                {
                    cell.containerWidthConstraint.constant = width + 20
                }
        
        
        
                cell.messageLbl.textInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
                cell.cellBottomLbl.text =  messageData.userName +  ", " + messageData.date
               // Utilities.shadowLayerToChat(viewLayer: cell.containerV.layer, shadowColor: KBorderColorCode, cornerRadius: 10)
                cell.lblHeightConstraint.constant = height
                cell.cellTopLblHeightConstraints.constant = 0.0
        
                return cell
        
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//
    
    //MARK: KeyBoard Notification
    //MARK: - KeyBoard Functions
    @objc func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    @objc func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        // get data from the userInfo
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIView.AnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        mainViewBottomContstraint.constant = (view.bounds).maxY - (convertedKeyboardEndFrame).minY
        
        // animate the changes
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    
    func getCustomeHeightForLbl(str:String,font:UIFont) -> CGSize {
        
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 260, height: Double(CGFloat.greatestFiniteMagnitude)))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = str
        label.sizeToFit()
        print("Custom Width \(label.frame.size.width)")
        print("Custom Height \(label.frame.size.height)")
        return label.frame.size
        
    }
    
}

extension CustomOrderNotificationVC : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if newString.count > 0  {
            self.sendMessageButton.isEnabled = true
            self.sendMessageButton.setImage(#imageLiteral(resourceName: "send_button_blue"), for: .normal)
            
        }
        else
        {
            self.sendMessageButton.isEnabled = false
            self.sendMessageButton.setImage(#imageLiteral(resourceName: "send_button_gray"), for: .normal)
            
        }
        return true
    }
    
}

class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, .zero))
    }
}
