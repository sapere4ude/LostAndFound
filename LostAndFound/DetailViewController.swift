//
//  DetailViewController.swift
//  LostAndFound
//
//  Created by sapere4ude on 2020/10/09.
//  Copyright © 2020 sapere4ude. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var getArticle: String = ""
    var getPlace: String = ""
    var getDate: String = ""
    
    @IBOutlet var detailView: UIView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailGetArticle: UILabel!
    @IBOutlet weak var detailGetPlace: UILabel!
    @IBOutlet weak var detailGetDate: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIinit()
        
    }


    func UIinit() {
        detailView.backgroundColor = .systemBackground
        detailImageView.image = UIImage(named: "lostItem")
        detailGetArticle.textAlignment = .center
        detailGetArticle.text = getArticle
        detailGetPlace.textAlignment = .center
        detailGetPlace.text = "습득장소 : " + getPlace
        detailGetDate.textAlignment = .center
        detailGetDate.text = "습득날짜 : " + getDate
    }

}


//{
//   "SearchLostArticleImageService":{
//      "list_total_count":56639,
//      "RESULT":{
//         "CODE":"INFO-000",
//         "MESSAGE":"정상 처리되었습니다"
//      },
//      "row":[
//         {
//            "ID":"1228831",
//            "IMAGE_URL":"aaa.jpg"
//         },
//         {
//            "ID":"1360729",
//            "IMAGE_URL":"aaa.jpg"
//         },
//         {
//            "ID":"1224264",
//            "IMAGE_URL":"aaa.jpg"
//         },
//         {
//            "ID":"1364084",
//            "IMAGE_URL":"aaa.jpg"
//         },
//         {
//            "ID":"61714065",
//            "IMAGE_URL":""
//         }
//      ]
//   }
//}
