//
//  PromoCodesVC.swift
//  Mataem
//
//  Created by Kishore on 14/09/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import Shimmer


class PromoCodesVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var allDataArray = NSMutableArray.init()
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    var isShimmerOn = true
     @IBOutlet weak var noDataView: UIView!
    var shimmerView:FBShimmeringView!
    var user_data:UserDataClass!
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        let left_button:GotesoButtonSwift = GotesoButtonSwift(frame: CGRect(x: 0, y: 4, width: 40, height: 40))
        left_button.addTarget(self, action: #selector(popVC(_:)), for: UIControlEvents.touchUpInside)
        addRefreshFunctionality()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: left_button)
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.tableFooterView = UIView(frame: .zero)
      SHADOW_EFFECT.makeBottomShadow(forView: self.noDataView, shadowHeight: 5)
        getCouponListDataAPI(loader:false,page:1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: -TableView Methods /////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
            if self.allDataArray.count > 0
            {
                return self.allDataArray.count
            }
            
            if isShimmerOn
            {
                let deviceHeight = self.view.frame.size.height
                return  Int(deviceHeight / 72)
            }
            return 0
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.allDataArray.count == 0 {
            let nib1 = UINib(nibName: "OfferShimmerTableCell", bundle: nil)
            tableView.register(nib1, forCellReuseIdentifier: "OfferShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"OfferShimmerTableCell") as! OfferShimmerTableCell
            
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
        }
        shimmerView.isShimmering = false
        
        let nib:UINib = UINib(nibName: "notificationMainTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "notificationMainTableCell")
        let cell:notificationMainTableCell = tableView.dequeueReusableCell(withIdentifier: "notificationMainTableCell") as! notificationMainTableCell
            if self.allDataArray.count > 0
            {
                let tmpDataDic = self.allDataArray.object(at: indexPath.row) as! NSDictionary
                cell.tag = indexPath.row
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
                
                cell.addGestureRecognizer(longPressGesture)
                cell.notificationTitleLbl.text = (tmpDataDic.object(forKey: "coupon_title") as! String)
                let coupon_code = (tmpDataDic.object(forKey: "coupon_code") as! String)
                cell.notificationDescriptionLbl.text = (tmpDataDic.object(forKey: "coupon_desc") as! String) + " \n \(coupon_code)"
                cell.notificationTimeLbl.text = "Expires on " + (tmpDataDic.object(forKey: "expiry") as! String)
                var imageUrl:URL!
                
                if let coupon_image = tmpDataDic.object(forKey: "coupon_image") as? String
                {
                    imageUrl = URL(string: IMAGE_BASE_URL + "coupons/" + coupon_image)
                }
                cell.imageView1.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "store_placeholder"), options: .refreshCached, completed: nil)
//                let image_path = IMAGE_BASE_URL + "coupons/" + (tmpDataDic.object(forKey: "coupon_image") as! String)
//                let imageURL = URL(string: image_path)
//                cell.imageView1.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "notification_offer"), options: .fromCacheOnly, completed: nil)
                cell.selectionStyle = .none
                return cell
            }
        cell.selectionStyle = .none
        return cell
        
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
        sender.view?.makeToast("Coupon Code Copied")
        self.view.clearToastQueue()
        print(pasteBoard.string!)
    }
    
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Add Refresh Functionality
    
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
    func getCouponListDataAPI(loader:Bool,page:Int)  {
        
        let api_name = APINAME()
        let url = api_name.GET_COUPONS_LIST + "?page=\(page)"
        
        print(url)
        WebService.requestGetUrlWithoutParameters(strURL: url, is_loader_required: loader, success: { (response) in
            print(response)
            if response["status_text"] as! String == "Success"
            {
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                if page == 1
                {
                    
                    self.allDataArray.removeAllObjects()
                    self.currentPage = 1
                }
                
                self.allDataArray.addObjects(from: ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                
                self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                {
                    self.currentPage += 1
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
                    self.tableView.reloadData()
                }
                //  self.selectedTableView.isScrollEnabled = false
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
                self.view.bringSubview(toFront: self.noDataView)
                self.noDataView.isHidden = false
            }
            
        }) { (failure) in
            
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
                self.tableView.reloadData()
            }
            self.view.bringSubview(toFront: self.noDataView)
            self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.endFooterRefresh()
            COMMON_ALERT.showAlert(msg: "Request Time Out !")
        }
    }
    
    
    
}
