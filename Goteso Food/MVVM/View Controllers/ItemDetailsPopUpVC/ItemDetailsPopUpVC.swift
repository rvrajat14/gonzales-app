//
//  ItemDetailsPopUpVC.swift
//  FoodApplication
//
//  Created by Kishore on 11/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import ISPageControl
import Shimmer
import IQKeyboardManager
import ListPlaceholder
class ItemDetailsPopUpVC: UIViewController {
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    var collectionViewWidth = 0.0
    @IBOutlet weak var itemDescriptionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollSubView: UIView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var shimmerView: UIView!
    @IBOutlet weak var item_nameLbl: UILabel!
    @IBOutlet weak var item_priceLbl: UILabel!
    var item_photo = ""
    var itemImagesArray = NSMutableArray.init()
    
    var itemDetailsDataArray = NSMutableArray.init()
    
     
    @IBOutlet weak var item_descriptionTxtView: IQTextView!
    
    var item_id = ""
    
@IBOutlet weak var pageControl: ISPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.collectionViewWidth = Double(self.view.frame.size.width/2 )
        }
        else
        {
            self.collectionViewWidth = Double(self.view.frame.size.width )
        }
        
        self.shimmerView.showLoader()
        pageControl.numberOfPages = 1
        self.getItemDetails()
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

    override func viewWillAppear(_ animated: Bool) {
       
    }
    
}


extension ItemDetailsPopUpVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        //pageControl1.currentPage = Int(pageNumber)
    }
}

extension ItemDetailsPopUpVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.itemImagesArray.count > 0
        {
        return self.itemImagesArray.count
        }
            return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nib = UINib(nibName: "ItemDetailsPopUpCollectionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ItemDetailsPopUpCollectionCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemDetailsPopUpCollectionCell", for: indexPath) as! ItemDetailsPopUpCollectionCell
        if self.itemImagesArray.count > 0 {
            
            if let image = ((self.itemImagesArray.object(at: indexPath.row) as! NSDictionary)["photo"] as? String) {
                let imageUrl = URL(string: IMAGE_BASE_URL + "item/" +  image)
                cell.imageView1.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "banner-placeholder"), options: .refreshCached, completed: nil)
            }
        }
        else
        {
            cell.imageView1.image = #imageLiteral(resourceName: "banner-placeholder")
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        self.collectionViewHeight.constant = CGFloat(collectionViewWidth * 0.57 + 20.0)
        self.collectionView.frame.size = CGSize(width: self.collectionView.frame.size.width, height: self.collectionViewHeight.constant)
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.collectionView.frame.size.height + self.bottomViewHeight.constant)
        print(collectionViewWidth)
        return CGSize(width: collectionViewWidth , height: collectionViewWidth * 0.57)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsetsMake(0, 0, 0, 0)
    }
   
    
    //MARK: - Get Item Details

    func getItemDetails()  {
        let api_name = APINAME()
        let url = api_name.ITEM_API + "/\(item_id)"
        print(url)
        
        
       WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            print(response)
            // self.allDataDictionary = (response["data"] as! NSDictionary).
        
         if response["status_code"] as! NSNumber == 1
         {
        
            let dataDictionary = (response["data"] as! NSDictionary)
            
            DispatchQueue.main.async {
                 self.shimmerView.hideLoader()
                self.scrollView.isHidden = false
                self.collectionView.isHidden = false
                self.shimmerView.isHidden = true
                
                
                var item_unit = ""
                
                   item_unit = (dataDictionary.object(forKey: "unit") as! String)
                if item_unit.isEmpty
                {
                    item_unit = "Item"
                }
                
                self.item_descriptionTxtView.text = (dataDictionary.object(forKey: "description") as! String)
                
                
                
                    let fixedWidth = self.item_descriptionTxtView.frame.size.width
                    let oldHeight = self.item_descriptionTxtView.frame.size.height
                    
                    let newSize = self.item_descriptionTxtView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                    if newSize.height > oldHeight
                    {
                        self.bottomViewHeight.constant -= oldHeight
                        self.bottomViewHeight.constant += newSize.height
                        self.itemDescriptionViewHeight.constant = newSize.height
                    }
                  //  self.item_descriptionTxtView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                
                self.item_nameLbl.text = (dataDictionary.object(forKey: "item_title") as! String)
                self.item_priceLbl.text = currency_type + COMMON_FUNCTIONS.checkForNull(string: dataDictionary.object(forKey: "item_price") as AnyObject).1 + "/\(item_unit)"
                self.itemImagesArray = (dataDictionary.object(forKey: "images") as! NSArray).mutableCopy() as! NSMutableArray
                
                self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.collectionView.frame.size.height + self.bottomViewHeight.constant)
                
                self.collectionView.reloadData()
            }
        }
        else
         {
            self.view.makeToast((response["message"] as! String))
        }
        }) { (failure) in
            COMMON_FUNCTIONS.showAlert(msg: "Request Time Out !")
            
        }
        
    }
}


extension UIView {
    
    func startShimmering(){
        let light = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, light, alpha, alpha, light, alpha]
        gradient.frame = CGRect(x: -self.bounds.size.width, y: 0, width: 3 * self.bounds.size.width, height: self.bounds.size.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
        gradient.locations = [0.4, 0.5, 0.6]
        self.layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.5
        animation.repeatCount = HUGE
        gradient.add(animation, forKey: "shimmer")
    }
    
    func stopShimmering(){
        self.layer.mask = nil
    }
    
}

