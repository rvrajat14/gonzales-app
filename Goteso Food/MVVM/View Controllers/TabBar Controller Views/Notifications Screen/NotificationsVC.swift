//
//  NotificationsVC.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import Shimmer
import NotificationCenter

class NotificationsVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: UIView!
    var isShimmerOn = true
    var isFromPayment = false
    
    var shimmerView:FBShimmeringView!
   
    
    @IBOutlet weak var noDataDescLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var allDataArray = NSMutableArray.init()
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLbl.text = "z_offers".getLocalizedValue()
        noDataDescLbl.text = "e_offer_desc".getLocalizedValue()
        noDataLbl.text = "e_offer".getLocalizedValue()
        
        self.serverErrorView.isHidden = true
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        if isFromPayment {
            self.view.backgroundColor = .clear
            self.topView.layer.masksToBounds = true
            self.topView.layer.cornerRadius = 10
           
        }
        else
        {
            self.view.backgroundColor = .white
           
        }
         self.titleLbl.text = "z_offers".getLocalizedValue()
        navigationController?.isNavigationBarHidden = true
        addRefreshFunctionality()
        getCouponListDataAPI(loader: false, page: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: -TableView Methods /////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.allDataArray.count > 0
        {
            self.noDataView.isHidden = true
            return self.allDataArray.count
        }
        
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 72)
        }
        self.noDataView.isHidden = false
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        headerView.backgroundColor =  .groupTableViewBackground
        var title = ""
        if self.allDataArray.count > 1 {
            title = "\(total_page)  " + "z_offers".getLocalizedValue()
        }
        else
        {
        
            title = "\(total_page)  " + "z_offer".getLocalizedValue()
          
        }
        
        let titleLbl = UILabel()
         headerView.addSubview(titleLbl)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15).isActive = true
        titleLbl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
        titleLbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLbl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10).isActive = true
        
        titleLbl.font = UIFont(name: SEMIBOLD, size: 17)
        
        titleLbl.text = title
        titleLbl.textColor = UIColor.lightGray
        
       
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.allDataArray.count == 0 {
            let nib1 = UINib(nibName: "OfferShimmerTableCell", bundle: nil)
            
            tableView.register(nib1, forCellReuseIdentifier: "OfferShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"OfferShimmerTableCell") as! OfferShimmerTableCell
            cell.isUserInteractionEnabled = false
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
        }
        shimmerView.isShimmering = false
        
        
        let nib:UINib = UINib(nibName: "OrderNotificationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OrderNotificationTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderNotificationTableViewCell") as! OrderNotificationTableViewCell
        if self.allDataArray.count > 0 {
            let tmpDataDic = self.allDataArray.object(at: indexPath.row) as! NSDictionary
            cell.tag = indexPath.row
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
            
            cell.addGestureRecognizer(longPressGesture)
            cell.notificationTitleLbl.text = (tmpDataDic.object(forKey: "coupon_title") as! String)
            let coupon_code = (tmpDataDic.object(forKey: "coupon_code") as! String)
            let coupon_desc = (tmpDataDic.object(forKey: "coupon_desc") as! String)
            cell.couponCodeLbl.text = coupon_code
            if !coupon_desc.isEmpty
            {
                cell.notificationDescriptionLbl.text = (tmpDataDic.object(forKey: "coupon_desc") as! String)
            }
            else
            {
                cell.notificationDescriptionLbl.text = ""
            }
            
            cell.notificationTimeLbl.text = "y_offers_expires_on".getLocalizedValue() + ": " + (tmpDataDic.object(forKey: "expiry_formatted") as! String)
        }
       
       
        cell.selectionStyle = .none
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tmpDataDic = self.allDataArray.object(at: indexPath.row) as! NSDictionary
        let couponCode = (tmpDataDic.object(forKey: "coupon_code") as! String)
        NotificationCenter.default.post(name: NSNotification.Name.init("couponNotification"), object: nil, userInfo: ["coupon_code":couponCode])
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //    //MARK: - Selector Methods//////////
    //
    @objc func longPressGesture(_ sender: UILongPressGestureRecognizer)
    {
        let tag_value = sender.view?.tag
        let tmpDataDic = self.allDataArray.object(at: tag_value!) as! NSDictionary
        print(tmpDataDic)
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = ""
        pasteBoard.string = (tmpDataDic.object(forKey: "coupon_code") as! String)
        sender.view?.makeToast("y_offers_copied".getLocalizedValue())
        print(pasteBoard.string!)
    }
    
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    func addRefreshFunctionality()  {
        
        self.tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            self?.getCouponListDataAPI(loader: false, page: 1)
            self?.tableView.cr.resetNoMore()
            
        }
        
        
        self.tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
            self?.getCouponListDataAPI(loader: false, page: (self?.currentPage)!)
            
        }
    }
    
    
    
    
    //MARK: - Call API
    func getCouponListDataAPI(loader:Bool,page:Int) -> Void{
        
        let api_name = APINAME()
        let url = api_name.GET_COUPONS_LIST + "?page=\(page)"
        
        print(url)
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
                
            }
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                if page == 1
                {
                    
                    self.allDataArray.removeAllObjects()
                    self.currentPage = 1
                }
                
                self.allDataArray.addObjects(from: ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                if  self.allDataArray.count > 0
                {
                    self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                    self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                    if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                    {
                        self.currentPage += 1
                    }
                }
                else
                {
                    if self.shimmerView.isShimmering
                    {
                        self.shimmerView.isShimmering = false
                        self.isShimmerOn = false
                        
                    }
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    self.tableView.reloadData()
                    self.noDataView.isHidden = false
                }
                
                DispatchQueue.main.async {
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    self.tableView.reloadData()
                }
                
            }
            else
            {
                if self.shimmerView.isShimmering
                {
                    self.shimmerView.isShimmering = false
                    self.isShimmerOn = false
                    
                }
                //  self.selectedTableView.isScrollEnabled = false
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
                self.tableView.reloadData()
                self.noDataView.isHidden = false
            }
            
        }) { (failure) in
            
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
                
            }
            self.view.bringSubview(toFront: self.noDataView)
            self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.endFooterRefresh()
            self.tableView.reloadData()
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
}



