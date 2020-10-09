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
    
    @IBOutlet var detailView: UIView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailGetArticle: UILabel!
    @IBOutlet weak var detailGetPlace: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIinit()
        
    }


    func UIinit() {
        detailView.backgroundColor = .lightGray
        detailGetArticle.textAlignment = .center
        detailGetArticle.text = getArticle
        detailGetPlace.textAlignment = .center
        detailGetPlace.text = getPlace
    }

}
