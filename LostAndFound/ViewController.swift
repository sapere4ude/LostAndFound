//
//  ViewController.swift
//  LostAndFound
//
//  Created by sapere4ude on 2020/09/25.
//  Copyright © 2020 sapere4ude. All rights reserved.
//

import UIKit

let url = String(format: "%@/%@/json/SearchLostArticleService",APIDefine.SEOUL_API_SERVER_ADDR,APIDefine.SEOUL_API_KEY)
    
    func getData(from url: String) {
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }
            
            // have data
            var result: Response?
            do {
                result = try JSONDecoder().decode(Response.self, from : data)
            }
            catch {
                print("failed to convert \(error.localizedDescription)")
            }
            
            guard let json = result else {
                return
            }
            print(json.row.ID)
            print(json.row.TAKE_PLACE)
        })
            
        task.resume()
    }

struct Response: Codable {
    let row: searchResult
}

struct searchResult: Codable {
    let ID: Double
    let TAKE_PLACE: String
    let GET_NAME: String
    let GET_DATE: String
    let GET_POSITION: String
}


/// JSON
/*
{"SearchLostArticleService":
     {"list_total_count":31,
      "RESULT":{"CODE":"INFO-000",
                "MESSAGE":"정상 처리되었습니다"},
      "row":[
            {"ID":1242847.0,
             "TAKE_PLACE":": 충무로(4)역",
             "GET_NAME":": 서류봉투 (서류)",
             "GET_DATE":"2016-12-30",
             "GET_POSITION":""},
            {"ID":1243423.0,
             "TAKE_PLACE":": 지축역",
             "GET_NAME":": 서류봉투",
             "GET_DATE":"2016-12-30",
             "GET_POSITION":""},
            {"ID":1243421.0,
             "TAKE_PLACE":": 지축역",
             "GET_NAME":": 서류봉투",
             "GET_DATE":"2016-12-30",
             "GET_POSITION":""},
            {"ID":1243701.0,
             "TAKE_PLACE":": 오금역",
             "GET_NAME":": 노란 서류봉투",
             "GET_DATE":"2016-12-30",
             "GET_POSITION":""},
            {"ID":1243339.0,
             "TAKE_PLACE":": 지축역",
             "GET_NAME":": 서류봉투",
             "GET_DATE":"2016-12-30",
             "GET_POSITION":""}
            ]
     }
 }
 */


class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var articleTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var resultTextField: UITextField!
    
    var selectArticle = ""
    var selectPlace = ""
    
    @IBAction func btnAction(_ sender: Any) {
//        let tmp = APIDefine.getLostArticleAPIAddress(startIndex: 0, endIndex: 5, type: .briefcase, place: .subway1_4, searchTxt: "")
//        print(tmp)
//        APIDefine.GET_LOST_ARTICLE_ORIGIN_API
        
        print(#function)
        print(selectArticle)
        print(selectPlace)
        
    }
    
    let articlePickerView = UIPickerView()
    let placePickerView = UIPickerView()
    
    let articlePickerData = LostArticleType.allEnumKoreanArray()
    let placePickerData = LostPlaceType.allEnumKoreanArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showArticlePickerView()
        showPlacePickerView()
        
    }
    
    func showArticlePickerView() {
        articlePickerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 220)
        articlePickerView.delegate = self
        articlePickerView.dataSource = self
        
        let pickerToolbar: UIToolbar = UIToolbar()
        pickerToolbar.barStyle = .default
        pickerToolbar.isTranslucent = true
        pickerToolbar.backgroundColor = .lightGray
        pickerToolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel))
        pickerToolbar.setItems([btnDone,space,btnCancel], animated: true)
        pickerToolbar.isUserInteractionEnabled = true
        
        articleTextField.inputView = articlePickerView
        articleTextField.inputAccessoryView = pickerToolbar
        articleTextField.placeholder = "잃어버린 물건을 선택하세요"
        articleTextField.sizeToFit()
    }
    
    func showPlacePickerView() {
        placePickerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 220)
        placePickerView.delegate = self
        placePickerView.dataSource = self
        
        let pickerToolbar: UIToolbar = UIToolbar()
        pickerToolbar.barStyle = .default
        pickerToolbar.isTranslucent = true
        pickerToolbar.backgroundColor = .lightGray
        pickerToolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone2))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel2))
        pickerToolbar.setItems([btnDone,space,btnCancel], animated: true)
        pickerToolbar.isUserInteractionEnabled = true
        
        placeTextField.inputView = placePickerView
        placeTextField.inputAccessoryView = pickerToolbar
        placeTextField.placeholder = "잃어버린 장소를 선택하세요"
        articleTextField.sizeToFit()
    }
    
    @objc func onPickDone() {
        articleTextField.text = selectArticle
        articleTextField.resignFirstResponder()
        selectArticle = ""
    }
    
    @objc func onPickCancel() {
        articleTextField.resignFirstResponder()
        selectArticle = ""
    }
    
    @objc func onPickDone2() {
        placeTextField.text = selectPlace
        placeTextField.resignFirstResponder()
        selectPlace = ""
    }
    
    @objc func onPickCancel2() {
        placeTextField.resignFirstResponder()
        selectPlace = ""
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == articlePickerView {
            return articlePickerData.count
        }
        else {
            return placePickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == articlePickerView {
            return articlePickerData[row]
        }
        else {
            return placePickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == articlePickerView {
            selectArticle = articlePickerData[row]
            let ee = LostArticleType.getEnumFromKoreanType(korean: articlePickerData[row])
            print(ee)
            print(selectArticle)
        }
        else {
            selectPlace = placePickerData[row]
            let kk = LostPlaceType.getEnumFromKoreanType(korean: placePickerData[row])
            print(kk)
            print(selectPlace)
        }
    }
}

