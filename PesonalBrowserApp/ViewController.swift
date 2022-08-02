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
    
    var collectionView: UICollectionView!
    let web = WKWebView()
    let searchBar = UISearchBar(frame: .zero)
    let progressBar = UIProgressView()
    var observation: NSKeyValueObservation?
    let tableView = UITableView()
    var suggest = [String]()
    let api = GoogleSuggestion()
    var custom = CustomTabBar()
    let sectionName = [["SNS"],["お買い物"]]
    let data = [["Yotube","インスタ","Twitter"],["Amazon","楽天","Yahoo"]]
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchBar,CancelButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    lazy var CancelButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        button.setTitle("キャンセル", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        layout()
        
        // Do any additional setup after loading the view.
    }
    
    func setupCollectionView() {
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: 80, height: 80)
        flowlayout.minimumInteritemSpacing = 7
        flowlayout.minimumLineSpacing = 5
        
        //        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowlayout)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(CollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.dataSource = self
        collectionView.delegate = self
        web.addSubview(collectionView)
        
        collectionView.snp.makeConstraints{
            $0.left.right.top.bottom.equalToSuperview()
        }
    }
    
    @objc func cancelButtonDidTap() {
        tableView.removeFromSuperview()
        UIView.animate(withDuration: 0.1) {
            self.stackView.arrangedSubviews[1].isHidden.toggle()
            self.stackView.layoutIfNeeded()
        }
        searchBar.resignFirstResponder()
    }
    
    func search(search: String) {
        guard let url = URL(string: "https://www.google.com/search?q=\(search)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        let requset = URLRequest(url: url)
        web.load(requset)
        
        setupProgress()
        reloadObservation()
        collectionView.removeFromSuperview()
    }
    
    private func reloadObservation() {
        observation = web.observe(\.estimatedProgress, options: .new){_, change in
            //            print("\(String(describing: change.newValue))")
            self.progressBar.setProgress(Float(change.newValue!), animated: true)
            
            if change.newValue == 1.0 {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseIn], animations: { self.progressBar.alpha = 0.0 }, completion: { (finished: Bool) in
                    self.progressBar.setProgress(0.0, animated: true) } )
            }
            else {
                self.progressBar.alpha = 1.0
            }
        }
    }
    
    func setupYoutubeSite() {
        view.addSubview(web)
        
        web.snp.makeConstraints{
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    func setupInstagram() {
        view.addSubview(web)
        
        web.snp.makeConstraints{
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    func setupTwitter() {
        view.addSubview(web)
        web.snp.makeConstraints{
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    func setupAmazonSite() {
        view.addSubview(web)
        web.snp.makeConstraints{
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    func setupRakutenSite() {
        view.addSubview(web)
        web.snp.makeConstraints{
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    func setupYahooSite() {
        view.addSubview(web)
        web.snp.makeConstraints{
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    func setupProgress( ) {
        searchBar.addSubview(progressBar)
        
        progressBar.snp.makeConstraints{
            $0.right.left.bottom.equalToSuperview()
            $0.height.equalTo(5)
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints{
            $0.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
        
        self.stackView.arrangedSubviews[1].isHidden.toggle()
        self.stackView.layoutIfNeeded()
    }
    
    func layout() {
        view.addSubview(web)
        view.addSubview(custom)
        view.addSubview(stackView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
        
        searchBar.placeholder = "検索/Webサイト名を入力"
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        custom.delegate = self
        
        stackView.snp.makeConstraints{
            $0.height.equalTo(40)
            $0.right.left.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        web.snp.makeConstraints{
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(searchBar.snp.bottom)
        }
        
        custom.snp.makeConstraints{
            $0.right.left.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(web.snp.bottom)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        Task {
            guard let suggestion = try? await api.getSuggestions(searchText: searchBar.text ?? "" ) else { return }
            self.suggest = suggestion
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(search: searchBar.text ?? "")
        tableView.removeFromSuperview()
        UIView.animate(withDuration: 0.1) {
            self.stackView.arrangedSubviews[1].isHidden.toggle()
            self.stackView.layoutIfNeeded()
        }
        searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        setupTableView()
        Task {
            guard let suggestion = try? await api.getSuggestions(searchText: searchText) else { return }
            self.suggest = suggestion
            tableView.reloadData()
            //            print(suggest)
        }
        tableView.reloadData()
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
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20))
        label.textAlignment = .center
        label.text = "Google検索"
        label.font = UIFont.italicSystemFont(ofSize: 20)
        label.isEnabled = true
        return label
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(indexPath.row)
        search(search: suggest[indexPath.row])
        searchBar.resignFirstResponder()
        tableView.removeFromSuperview()
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let textName = data[indexPath.section][indexPath.item]
        cell.setupContent(nameLabel: textName)
        cell.backgroundColor = .cyan
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! CollectionViewHeader
        let headerText = sectionName[indexPath.section][indexPath.item]
        header.setupContent(titleText: headerText)
        return header
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(data[indexPath.section][indexPath.row])
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                setupYoutubeSite()
                setupProgress()
                reloadObservation()
                collectionView.removeFromSuperview()
                guard let url = URL(string: "https://www.youtube.com/") else { return }
                let request = URLRequest(url: url)
                web.load(request)
            }
            else if indexPath.row == 1 {
                setupInstagram()
                setupProgress()
                reloadObservation()
                collectionView.removeFromSuperview()
                guard let url = URL(string: "https://www.instagram.com/") else { return }
                let request = URLRequest(url: url)
                web.load(request)
            }
            else {
                setupTwitter()
                setupProgress()
                reloadObservation()
                collectionView.removeFromSuperview()
                guard let url = URL(string: "https://twitter.com/") else { return }
                let request = URLRequest(url: url)
                web.load(request)
            }
        }
        else {
            if indexPath.row == 0 {
                setupAmazonSite()
                setupProgress()
                reloadObservation()
                collectionView.removeFromSuperview()
                guard let url = URL(string: "https://www.amazon.co.jp/") else { return }
                let request = URLRequest(url: url)
                web.load(request)
            }
            else if indexPath.row == 1 {
                setupProgress()
                reloadObservation()
                collectionView.removeFromSuperview()
                guard let url = URL(string: "https://www.rakuten.co.jp/") else { return }
                let request = URLRequest(url: url)
                web.load(request)
            }
            else {
                setupProgress()
                reloadObservation()
                collectionView.removeFromSuperview()
                guard let url = URL(string: "https://www.yahoo.co.jp/") else { return }
                let request = URLRequest(url: url)
                web.load(request)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
}

extension ViewController: CustomTabBarDelagate {
    func homeButtonDidTap() {
        print("タップされました")
    }
    
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
