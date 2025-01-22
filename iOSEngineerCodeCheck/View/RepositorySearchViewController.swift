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
    
    private let repositorySearch = RepositorySearchViewModel()
    private var repositories: [Repository] = []
    private var selectedRepository: Repository?
    private let placeholderText = "GitHubのリポジトリを検索できるよー"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.text = ""
        searchBar.delegate = self
        searchBar.placeholder = placeholderText // プレースホルダーテキストを設定
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //searchBarの文字を初期化する
        searchBar.text = ""
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 検索クエリが空でないことを確認
        guard let query = searchBar.text, !query.isEmpty else {
            self.showErrorAlert(message: RepositoryServiceError.queryMissing.localizedDescription)
            return
        }
        
        // クエリがスペースだけの場合、エラーを表示
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            self.showErrorAlert(message: RepositoryServiceError.invalidQuery.localizedDescription)
            return
        }
        
        // キーボードを閉じる
        searchBar.endEditing(true)
        
        // 検索クエリをURLで使用できる形式にエンコード
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            showErrorAlert(message: RepositoryServiceError.queryEncodingFailed.localizedDescription)
            return
        }
        
        // リポジトリデータを取得
        repositorySearch.fetchRepositories(query: encodedQuery) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let repositories):
                    // データソースを更新し、テーブルビューをリロード
                    self?.repositories = repositories
                    self?.tableView.reloadData()
                case .failure(let error):
                    // エラーメッセージをアラートで表示
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        // エラーメッセージを表示するアラートを作成して表示
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        cell.textLabel?.text = repository.fullName
        cell.detailTextLabel?.text = repository.language ?? "不明"
        cell.tag = indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルを選択した時に呼ばれる
        selectedRepository = repositories[indexPath.row]
        performSegue(withIdentifier: "Detail", sender: self)
    }
}
