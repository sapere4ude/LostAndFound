//
//  ViewController.swift
//  LostAndFound
//
//  Created by sapere4ude on 2020/09/25.
//  Copyright © 2020 sapere4ude. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

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
    
    // string 값을 enum으로 교체하기
//    var selectArticle = ""
    var selectArticle: LostArticleType = .wallet
    var selectPlace: LostPlaceType = .bus
    
    var resultArticle = ""
    var resultPlace = ""
    
    var lostItems: Array<LostArticleResult> = Array()
//    
    @IBAction func btnAction(_ sender: Any) {
        //indicator show
        print(#function, resultArticle, resultPlace)
        print("버튼을 눌렀을때->",APIDefine.getLostArticleAPIAddress(startIndex: 0, endIndex: 5, type: LostArticleType.getEnumFromKoreanType(korean: (articleTextField?.text)!), place: LostPlaceType.getEnumFromKoreanType(korean: (placeTextField?.text)!), searchTxt: nil))
        
        let _ = self.sendRequest(completeHandler: { responseJson in
            print("response:\(responseJson)")
            var items:Array<LostArticleResult> = Array()
            for i in 0..<responseJson["SearchLostArticleService"]["row"].count {
                var item:LostArticleResult = LostArticleResult()
                item.id = responseJson["SearchLostArticleService"]["row"][i]["ID"].intValue
                item.getName = responseJson["SearchLostArticleService"]["row"][i]["GET_NAME"].stringValue
                item.getData = responseJson["SearchLostArticleService"]["row"][i]["GET_DATA"].stringValue
                item.getTakePlace = responseJson["SearchLostArticleService"]["row"][i]["TAKE_PLACE"].stringValue
                items.append(item)
            }
            self.lostItems = items // 지역변수로 값을 넘겨줘서 다른곳에서 사용할 수 있게 해줌
            
                //모델링 처리 해줘야함
                //indicator hide mainTread
                //present

            }, failureHandler: { err in
                print("error:\(err)")
                //indicator hide
                //얼럿처리
            })
        
        //        let vc = ResultViewController()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
//            self.navigationController?.pushViewController(vc, animated: true)
//            self.modalPresentationStyle = .fullScreen
            vc.modalPresentationStyle = .fullScreen
            
//            self.present(vc, animated: true, completion: nil)
        }
//        vc.title = "확인 결과"
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func sendRequest(completeHandler:@escaping (JSON) -> (),failureHandler:@escaping (String) -> ()) {
        
        let url = APIDefine.getLostArticleAPIAddress(startIndex: 0, endIndex: 5, type: LostArticleType.getEnumFromKoreanType(korean: (articleTextField?.text)!), place: LostPlaceType.getEnumFromKoreanType(korean: (placeTextField?.text)!), searchTxt: nil)
        
        // 정보를 불러오기만 하는 것이므로 get 방식 사용
        let alamo = AF.request(url, method: .get).validate(statusCode: 200..<300)
        //결과값으로 문자열을 받을 때 사용
        alamo.responseString() { response in
            switch response.result
            {
                
            // 통신 성공
            case .success(let value):   // 주의할 점 : String 타입으로 들어오는걸 Data 타입으로 바꿔줘야한다.
                let json = JSON.init(value.data(using: .utf8) as Any)
//                let resultJson = json["SearchLostArticleService"]["row"][0]["TAKE_PLACE"].stringValue
//                print("JSON: \(resultJson)")
                completeHandler(json)
                // 질문해할 것 -> 개별적인 이름으로 순서대로 저장하고 있어야하는건지 or 딕셔너리 형태로 값을 갖고있어야하는건지
                
                
//                for i in 0..<json["SearchLostArticleService"]["row"].count {
//                    var item:LostArticleResult = LostArticleResult()
//                    item.id = json["SearchLostArticleService"]["row"][i]["ID"].intValue
//                    LostArticleResult().id = json["SearchLostArticleService"]["row"][i]["ID"].intValue
//                    LostArticleResult().getName = json["SearchLostArticleService"]["row"][i]["GET_NAME"].stringValue
                    
//                }
//                    self.getTakePlace.append(json["SearchLostArticleService"]["row"][i]["TAKE_PLACE"].stringValue)
//                    self.getName.append(json["SearchLostArticleService"]["row"][i]["GET_NAME"].stringValue)
//                    //self.getData.append(json["SearchLostArticleService"]["row"][i]["GET_DATA"].stringValue)
//                    self.getPosition.append(json["SearchLostArticleService"]["row"][i]["GET_POSITION"].stringValue)
//                }
            
            // 통신 실패
            case .failure(let error):
                failureHandler(error.localizedDescription)
                print(error)
            }
        }
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
        
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDoneArticle))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancelArticle))
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
        
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDonePlace))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancelPlace))
        pickerToolbar.setItems([btnDone,space,btnCancel], animated: true)
        pickerToolbar.isUserInteractionEnabled = true
        
        placeTextField.inputView = placePickerView
        placeTextField.inputAccessoryView = pickerToolbar
        placeTextField.placeholder = "잃어버린 장소를 선택하세요"
        articleTextField.sizeToFit()
    }
    
    @objc func onPickDoneArticle() {
        articleTextField.text = self.selectArticle.rawValue
        articleTextField.resignFirstResponder()
        resultArticle = LostArticleType.getEnumFromKoreanType(korean: (articleTextField.text)!).rawValue
        print(resultArticle)
        print(#function, LostArticleType.getEnumFromKoreanType(korean: (articleTextField?.text)!))
//        selectArticle = ""
    }
    
    @objc func onPickCancelArticle() {
        articleTextField.resignFirstResponder()
//        selectArticle = ""
    }
    
    @objc func onPickDonePlace() {
        placeTextField.text = self.selectPlace.rawValue
        placeTextField.resignFirstResponder()
        resultPlace = LostPlaceType.getEnumFromKoreanType(korean: (placeTextField.text)!).rawValue
        print(resultPlace)
        print(#function, LostPlaceType.getEnumFromKoreanType(korean: (placeTextField.text)!))
        //selectPlace = ""
    }
    
    @objc func onPickCancelPlace() {
        placeTextField.resignFirstResponder()
        //selectPlace = ""
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
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if pickerView == articlePickerView {
//            return selectArticle = articlePickerData[row]
//        }
//        else {
//            selectPlace = placePickerData[row]
//        }
//    }
}

