//
//  SearchViewController.swift
//  LostAndFound
//
//  Created by sapere4ude on 2020/10/10.
//  Copyright © 2020 sapere4ude. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    private let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "찾고싶은 물건을 검색하세요"
        return searchBar
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.backgroundColor = .gray
        table.isHidden = false
        table.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultTableViewCell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    
}
