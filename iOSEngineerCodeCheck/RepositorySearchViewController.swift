//
//  ViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositorySearchViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var repositories: [[String: Any]] = []
    private var currentTask: URLSessionTask?
    private var searchTerm: String = ""
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.text = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //searchBarの文字を初期化する
        searchBar.text = ""
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentTask?.cancel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else {
            return
        }
        
        self.searchTerm = searchTerm
        let apiUrl = "https://api.github.com/search/repositories?q=\(searchTerm)"
        guard let url = URL(string: apiUrl) else { return }
        
        currentTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard let data = data else { return }
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else { return }
            guard let obj = jsonObject as? [String: Any] else { return }
            guard let items = obj["items"] as? [[String: Any]] else { return }
            
            self.repositories = items
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        //タスクを実行する
        currentTask?.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //画面遷移時に呼ばれる
        if segue.identifier == "Detail" {
            if let detailViewController = segue.destination as? RepositoryDetailViewController {
                detailViewController.repositorySearchController = self
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let repository = repositories[indexPath.row]
        cell.textLabel?.text = repository["full_name"] as? String ?? ""
        cell.detailTextLabel?.text = repository["language"] as? String ?? ""
        cell.tag = indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルを選択した時に呼ばれる
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "Detail", sender: self)
    }
}
