//
//  ItemDetailsVC.swift
//  GotesoMM2
//
//  Created by Kishore on 30/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class ItemDetailsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var serverErrorView: UIView!
    var bannerCollectionView : UICollectionView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ItemBasicInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemBasicInfoTableViewCell")
        tableView.register(UINib(nibName: "ItemStoreDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemStoreDetailsTableViewCell")
        tableView.register(UINib(nibName: "SuggestedItemsTableViewCell", bundle: nil), forCellReuseIdentifier: "SuggestedItemsTableViewCell")
      self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.tableHeaderView =  self.getTableViewHeader()
    }
    
}

extension ItemDetailsVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemBasicInfoTableViewCell", for: indexPath) as! ItemBasicInfoTableViewCell
           // cell.tagsMainViewHeightConstraints.constant = 0
            cell.productDescriptionLbl.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
            var xPosition : CGFloat = 15
            var yPosition : CGFloat = 0
            let labelWidth : CGFloat = 80
            var ahTagArray  = [AHTag]()
            
            for _ in 0...10
            {
                let dict = NSDictionary(dictionaryLiteral: ("URL",""),
                                        ("COLOR", "0xFF8F8F"),
                                        ("ENABLED", true),
                                        ("CATEGORY", "Demo12346"),
                                        ("TITLE","Demo12346"))
              ahTagArray.append(AHTag(dictionary:  dict as! [String : Any]))
                
                let lbl = UILabel(frame: CGRect(x: xPosition, y: yPosition, width: labelWidth, height: 24))
                xPosition += labelWidth + 6
            //    lbl.textAlignment = .center
                lbl.backgroundColor = UIColor.groupTableViewBackground
                lbl.text = "Demo12346"
                lbl.layer.cornerRadius = 10
                lbl.padding = UIEdgeInsetsMake(0, 10, 2, 10)
                lbl.clipsToBounds = true
                lbl.font = UIFont(name: REGULAR_FONT, size: 12)
                print("Xposition = \(xPosition)")
                if xPosition >= (self.view.frame.size.width)
                {
                    xPosition = 15
                    yPosition += 34
                }
                else
                {
                   // cell.tagsMainView.addSubview(lbl)
                    
                }
                
            }
           
           print(ahTagArray)
            cell.tagLbl.setTags(ahTagArray)
           
           // cell.tagsMainViewHeightConstraints.constant = yPosition + 34
            
               tableView.separatorStyle = .singleLine
            cell.selectionStyle = .none
            return cell
            
        }
        else if indexPath.row == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemStoreDetailsTableViewCell", for: indexPath) as! ItemStoreDetailsTableViewCell
              tableView.separatorStyle = .singleLine
            cell.storeDescriptionLbl.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
            cell.selectionStyle = .none
            return cell
            
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedItemsTableViewCell", for: indexPath) as! SuggestedItemsTableViewCell
            cell.collectionView.register(UINib(nibName: "SuggestedItemsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SuggestedItemsCollectionViewCell")
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.reloadData()
           tableView.separatorStyle = .none
            cell.selectionStyle = .none
            return cell
            
        }
    }
    
  
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    //MARK: Table View Header
    
    func getTableViewHeader() -> UIView {
        var mainViewHeight = 0.0
        
        mainViewHeight = getBannerViewHeight()
        
        let bannerMainView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.size.width), height: mainViewHeight ))
        bannerMainView.backgroundColor = UIColor.groupTableViewBackground
        
        //Collection View Coding
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        bannerCollectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0, width: Double(self.view.frame.size.width), height:Double(bannerMainView.frame.size.height) ), collectionViewLayout: flowLayout)
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        bannerCollectionView.showsHorizontalScrollIndicator = false
        bannerCollectionView.backgroundColor = UIColor.groupTableViewBackground
        let nib = UINib(nibName: "BannerCollectionViewCell", bundle: nil)
        self.bannerCollectionView.register(nib, forCellWithReuseIdentifier: "BannerCollectionViewCell")
        self.bannerCollectionView.reloadData()
        
        //if allBannersListData.count > 0 {
        bannerMainView.addSubview(bannerCollectionView)
        
        //}
        
        return bannerMainView
    }
    
    //MARK: Get Banner Height
   
    func getBannerViewHeight() -> Double {
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            
            return BANER_VIEW_HEIGHT + 150.0
        }
        return BANER_VIEW_HEIGHT
    }
    
}


extension ItemDetailsVC : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if bannerCollectionView == collectionView {
            return  4
        }
        return 4
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == bannerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
            cell.imageView1.image = #imageLiteral(resourceName: "froot_demo1")
//                let tempDataDictionary =  self.bannersImgDataArray.object(at: indexPath.row) as! NSDictionary
//
//                let imageUrl = URL(string: IMAGE_BASE_URL + "banners/" + (tempDataDictionary.object(forKey: "photo") as! String))
//
//                cell.imageView1.sd_setImage(with: imageUrl, placeholderImage: UIImage.init(), options: .refreshCached, completed: nil)
          
            cell.imageView1.clipsToBounds = true
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedItemsCollectionViewCell", for: indexPath) as! SuggestedItemsCollectionViewCell
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == bannerCollectionView {
             return UIEdgeInsetsMake(0, 5, 0, 5)
        }
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0  )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == bannerCollectionView {
            let height = getBannerViewHeight()
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                
                return CGSize(width: height * 1.9, height: height)
                
            }
            
            return CGSize(width: height * 1.9, height: height)
        }
        
        return  CGSize(width: 120, height: 133)
    }
    
}
