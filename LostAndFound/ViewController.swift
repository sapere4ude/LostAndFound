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
import NVActivityIndicatorView

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
    
    @IBOutlet weak var articleTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    //@IBOutlet weak var resultTextField: UITextField!
    @IBOutlet weak var resultView: UITableView!
    @IBOutlet weak var searchBtn: UIButton!
    
    
    // 검색결과가 없을 경우 label 보여주기
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "검색 결과가 없습니다!"
        label.sizeToFit()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    
    // string 값을 enum으로 교체하기
    var selectArticle: LostArticleType = .wallet
    var selectPlace: LostPlaceType = .bus
    
    var resultArticle = ""
    var resultPlace = ""
    
    //MARK:paging
    let queryOnceCnt:Int = 10
    var currentPage:Int = 0
    let callNextPageBeforeOffset:CGFloat = 150
    var isQuery:Bool = false
    var reachEnd:Bool = false
    
    
    lazy var lostItems: Array<LostArticleResult> = Array()
//    
    @IBAction func btnAction(_ sender: Any) {
        searchBtn.isEnabled = false
        //indicator show
        self.indicator.isHidden = true
        indicator.startAnimating()
        DispatchQueue.main.async {
            let _ = self.sendRequest(page: self.currentPage, completeHandler: { responseJson in
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
                print(self.lostItems)
                print(type(of: self.lostItems))
                
                self.resultView.reloadData() // 데이터가 쌓인 뒤 다시 델리게이트를 돌게하는 코드
                
                //모델링 처리 해줘야함
                //indicator hide mainTread
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.indicator.isHidden = true
                }
                if self.lostItems.isEmpty {
                    self.resultView.isHidden = true
                    self.noResultLabel.isHidden = false
                } else {
                    self.resultView.isHidden = false
                }
                //present
                
                }, failureHandler: { err in
                    print("error:\(err)")
                    //indicator hide
                    self.indicator.isHidden = true
                    //얼럿처리
                })
        }
        print(#function, resultArticle, resultPlace)
        print("버튼을 눌렀을때->",APIDefine.getLostArticleAPIAddress(startIndex: 0, endIndex: 5, type: LostArticleType.getEnumFromKoreanType(korean: (articleTextField?.text)!), place: LostPlaceType.getEnumFromKoreanType(korean: (placeTextField?.text)!), searchTxt: nil))
        
        
        //        let vc = resultViewController()
        //let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //if let vc = mainStoryboard.instantiateViewController(withIdentifier: "resultViewController") as? resultViewController {
//            self.navigationController?.pushViewController(vc, animated: true)
//            self.modalPresentationStyle = .fullScreen
           // vc.modalPresentationStyle = .fullScreen
            
//            self.present(vc, animated: true, completion: nil)
//        }
//        vc.title = "확인 결과"
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func resetBtn(_ sender: Any) {
        self.lostItems.removeAll()
        self.reachEnd = false
        self.isQuery = false
        resultView.reloadData()
        resultView.isHidden = true
        noResultLabel.isHidden = true
        searchBtn.isEnabled = true
        articleTextField.text?.removeAll()
        placeTextField.text?.removeAll()
    }
    
    
    func sendRequest(page:Int,completeHandler:@escaping (JSON) -> (),failureHandler:@escaping (String) -> ()) {
        self.isQuery = true
        var startIndex:Int = 0
        var endIndex:Int = self.queryOnceCnt
        if page != 0 {
            startIndex = (page * self.queryOnceCnt) + 1
            endIndex = startIndex + self.queryOnceCnt - 1
        }
        // endIndex 숫자 변경하기
        let url = APIDefine.getLostArticleAPIAddress(startIndex: startIndex, endIndex: endIndex, type: LostArticleType.getEnumFromKoreanType(korean: (articleTextField?.text)!), place: LostPlaceType.getEnumFromKoreanType(korean: (placeTextField?.text)!), searchTxt: nil)
        
        // 정보를 불러오기만 하는 것이므로 get 방식 사용
        let alamo = AF.request(url, method: .get).validate(statusCode: 200..<300)
        //결과값으로 문자열을 받을 때 사용
        alamo.responseString() { response in
            switch response.result
            {
                
            // 통신 성공
            case .success(let value):   // 주의할 점 : String 타입으로 들어오는걸 Data 타입으로 바꿔줘야한다.
                let json = JSON.init(value.data(using: .utf8) as Any)
                self.currentPage += 1
                self.isQuery = false
//                json[""]reachEnd
                if self.queryOnceCnt > json["SearchLostArticleService"]["row"].count {
                    self.reachEnd = true
                }
                completeHandler(json)

            
            // 통신 실패
            case .failure(let error):
                self.isQuery = false
                failureHandler(error.localizedDescription)
                print(error)
            }
        }
    }
    
    let articlePickerView = UIPickerView()
    let placePickerView = UIPickerView()
    
    let articlePickerData = LostArticleType.allEnumKoreanArray()
    let placePickerData = LostPlaceType.allEnumKoreanArray()
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 20, y: UIScreen.main.bounds.height/2, width: 50, height: 50),
                                            type: .ballBeat,
                                            color: .black,
                                            padding: 0)
    
    func initRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "새로고침")
        
        if #available(iOS 10.0, *) {
            resultView.refreshControl = refresh
        } else {
            resultView.addSubview(refresh)
        }
    }
    
    @objc func updateUI(refresh: UIRefreshControl) {
        refresh.endRefreshing()
        resultView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showArticlePickerView()
        showPlacePickerView()
        self.view.addSubview(indicator)
        self.view.addSubview(noResultLabel)
        
        resultView.isHidden = true
        
        resultView.delegate = self
        resultView.dataSource = self
        resultView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultTableViewCell")
        
        initRefresh()
    }
    
    override func viewDidLayoutSubviews() {

        noResultLabel.frame = CGRect(x: 120,
                                     y: 450,
                                     width: 150,
                                     height: 50)
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
        articleTextField.text = resultArticle
    }
    
    @objc func onPickCancelArticle() {
        articleTextField.resignFirstResponder()
    }
    
    @objc func onPickDonePlace() {
        placeTextField.text = self.selectPlace.rawValue
        placeTextField.resignFirstResponder()
        resultPlace = LostPlaceType.getKoreanFromLostPlaceType(type: LostPlaceType(rawValue: placeTextField.text!)!)
        print(#function, resultPlace)
        placeTextField.text = resultPlace
    }
    
    @objc func onPickCancelPlace() {
        placeTextField.resignFirstResponder()
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
            return selectArticle = LostArticleType(rawValue: articlePickerData[row])!
        }
        else {
            print("현재 결과값 : ", LostPlaceType.allEnumKoreanArray()[row])
            print(type(of: LostPlaceType(rawValue: placePickerData[row])))
            return selectPlace = LostPlaceType.getEnumFromKoreanType(korean: self.placePickerData[row])
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lostItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
//        print(#function)
        cell.getName.sizeToFit()
        cell.getPlace.sizeToFit()
        cell.getData.sizeToFit()
        
        cell.getName?.text = lostItems[indexPath.row].getName
        cell.getPlace?.text = lostItems[indexPath.row].getTakePlace
        cell.getData?.text = lostItems[indexPath.row].getData

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // 스크롤했을때 새로운 페이지 보여주는 방법
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollView:\(scrollView.contentOffset.y)")
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        if y + self.callNextPageBeforeOffset >= h {
            if !self.isQuery && !self.reachEnd {
                sendRequest(page: currentPage, completeHandler: { responseJson in
                    print("responseJson:\(responseJson)")
                    var items:Array<LostArticleResult> = Array()
                    for i in 0..<responseJson["SearchLostArticleService"]["row"].count {
                        var item:LostArticleResult = LostArticleResult()
                        item.id = responseJson["SearchLostArticleService"]["row"][i]["ID"].intValue
                        item.getName = responseJson["SearchLostArticleService"]["row"][i]["GET_NAME"].stringValue
                        item.getData = responseJson["SearchLostArticleService"]["row"][i]["GET_DATA"].stringValue
                        item.getTakePlace = responseJson["SearchLostArticleService"]["row"][i]["TAKE_PLACE"].stringValue
                        items.append(item)
                    }
                    self.lostItems += items
                    self.resultView.reloadData()
                }, failureHandler: { err in
                    print("error:\(err)")
                })
            }
        }
    }
    
    
}
