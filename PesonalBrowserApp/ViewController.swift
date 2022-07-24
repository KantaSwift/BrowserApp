//
//  ViewController.swift
//  PesonalBrowserApp
//
//  Created by 上條栞汰 on 2022/07/24.
//

import UIKit
import WebKit
import SnapKit
import Kanna

class ViewController: UIViewController {
    
    let web = WKWebView()
    let searchBar = UISearchBar(frame: .zero)
    let tableView = UITableView()
    var suggest = [String]()
    let api = GoogleSuggestion()
    var custom = CustomTabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://google.com") else { return }
        let requset = URLRequest(url: url)
        web.load(requset)
        
        layout()
        // Do any additional setup after loading the view.
    }
    
    func search(search: String) {
        guard let url = URL(string: "https://www.google.com/search?q=\(search)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        let requset = URLRequest(url: url)
        web.load(requset)
    }
    
    func layout() {
        view.addSubview(web)
        view.addSubview(searchBar)
        view.addSubview(custom)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchBar.placeholder = "検索/Webサイト名を入力"
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        custom.delegate = self
        
        searchBar.snp.makeConstraints{
            $0.height.equalTo(40)
            $0.right.left.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        web.snp.makeConstraints{
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
        
        custom.snp.makeConstraints{
            $0.right.left.bottom.equalToSuperview()
            $0.top.equalTo(web.snp.bottom)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints{
            $0.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(search: searchBar.text ?? "")
        tableView.removeFromSuperview()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task {
            guard let suggestion = try? await api.getSuggestions(searchText: searchText) else { return }
            self.suggest = suggestion
            tableView.reloadData()
//            print(suggest)
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = suggest[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
        search(search: suggest[indexPath.row])
    }
    
}

extension ViewController: CustomTabBarDelagate {
    func backButtonDidTap() {
        web.goBack()
    }
    
    func forwardButtonDidTap() {
        web.goForward()
    }
}


class GoogleSuggestion {
    
    private let apiURL = "https://www.google.com/complete/search?hl=en&output=toolbar&q="
    
    //サジェストを表示することに時間がかかる場合があるため,非同期処理を使う(非同期関数)
    func getSuggestions(searchText: String) async throws -> [String] {
        guard let percentEncoding = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: apiURL + percentEncoding) else {
            return []
        }
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                do {
                    let doc = try XML(url: url, encoding: .utf8)
                    let suggestions = doc.xpath("//suggestion").compactMap { $0["data"] }
                    continuation.resume(returning: suggestions)
                }
                catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
