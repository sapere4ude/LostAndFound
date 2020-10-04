//
//  ResultTableViewCell.swift
//  LostAndFound
//
//  Created by sapere4ude on 2020/10/01.
//  Copyright © 2020 sapere4ude. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var getName: UILabel!
    @IBOutlet weak var getPlace: UILabel!
    @IBOutlet weak var getData: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.getName.sizeToFit()
        self.getPlace.sizeToFit()
        self.getData.sizeToFit()

        let result = ViewController()
        
        for i in 0..<result.lostItems.count {
            self.getName.text = result.lostItems[i].getName
            self.getPlace.text = result.lostItems[i].getTakePlace
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
