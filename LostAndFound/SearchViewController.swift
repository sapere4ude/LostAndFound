//
//  SearchViewController.swift
//  LostAndFound
//
//  Created by sapere4ude on 2020/10/10.
//  Copyright © 2020 sapere4ude. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "검색 결과가 없습니다!"
        label.sizeToFit()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    //MARK:paging
    let queryOnceCnt:Int = 10
    var currentPage:Int = 0
    let callNextPageBeforeOffset:CGFloat = 150
    var isQuery:Bool = false
    var reachEnd:Bool = false
    
    var searchText = ""
    
    lazy var lostItems: Array<LostArticleResult> = Array()
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 20, y: UIScreen.main.bounds.height/2, width: 50, height: 50),
                                            type: .ballBeat,
                                            color: .black,
                                            padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func initUI() {
        searchBar.placeholder = "찾고싶은 물건을 입력하세요"
        tableView.isHidden = true
        self.view.addSubview(indicator)
        self.view.addSubview(noResultLabel)
        
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultTableViewCell")
    }
    
    override func viewDidLayoutSubviews() {

        noResultLabel.frame = CGRect(x: 120,
                                     y: 450,
                                     width: 150,
                                     height: 50)
    }
    
    func sendRequest(page:Int,searchTxt:String,completeHandler:@escaping (JSON) -> (),failureHandler:@escaping (String) -> ()) {
        self.isQuery = true
        var startIndex:Int = 0
        var endIndex:Int = self.queryOnceCnt
        if page != 0 {
            startIndex = (page * self.queryOnceCnt) + 1
            endIndex = startIndex + self.queryOnceCnt - 1
        }
        // endIndex 숫자 변경하기
        let url = APIDefine.getLostArticleAPIAddress(startIndex: startIndex, endIndex: endIndex, type: .getEnumFromKoreanType(korean: ""), place: .getEnumFromKoreanType(korean: ""), searchTxt: searchTxt)
        
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
                self.isQuery = false    // 통신에 성공한 경우 false 값을 주고 이것은
//                json[""]reachEnd
                if self.queryOnceCnt > json["SearchLostArticleService"]["row"].count {  // 새로운 항목이 10개 이상이 될때만 실행되는 것
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
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lostItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
        cell.getName.sizeToFit()
        cell.getPlace.sizeToFit()
        cell.getData.sizeToFit()
        
        cell.getName?.text = lostItems[indexPath.row].getName
        cell.getPlace?.text = lostItems[indexPath.row].getTakePlace
        cell.getData?.text = lostItems[indexPath.row].getData
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.modalTransitionStyle = .coverVertical
        
        // DetailViewController의 변수에 넣어준 뒤, 변수가 DetailViewController의 label 값에 전달된다.
        vc.getArticle = lostItems[indexPath.row].getName
        vc.getPlace = lostItems[indexPath.row].getTakePlace

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
//        tableView.isHidden = false
        guard let text = searchBar.text, !text.replacingOccurrences(of: "", with: "").isEmpty else {
            noResultLabel.isHidden = true
            return
        }
        
        searchText = text   // sendRequst 함수에서 만들어진 값을 전역변수로 넘겨주는 역할
        
        searchBar.resignFirstResponder()
        
        //indicator show
        self.indicator.isHidden = true
        indicator.startAnimating()
        DispatchQueue.main.async {
            let _ = self.sendRequest(page: self.currentPage, searchTxt: text, completeHandler: { responseJson in
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
                
                self.tableView.reloadData() // 데이터가 쌓인 뒤 다시 델리게이트를 돌게하는 코드
                
                //모델링 처리 해줘야함
                //indicator hide mainTread
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.indicator.isHidden = true
                }
                if self.lostItems.isEmpty {
                    self.tableView.isHidden = true
                    self.noResultLabel.isHidden = false 
                } else {
                    self.tableView.isHidden = false
                }
                //present
                
                }, failureHandler: { err in
                    print("error:\(err)")
                    //indicator hide
                    self.indicator.isHidden = true
                    //얼럿처리
                })
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        noResultLabel.isHidden = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == nil {
            noResultLabel.isHidden = true
        }
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
                sendRequest(page: currentPage, searchTxt: searchText, completeHandler: { responseJson in
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
                    self.lostItems = items
                    self.tableView.reloadData()
                }, failureHandler: { err in
                    print("error:\(err)")
                })
            }
        }
    }
}
