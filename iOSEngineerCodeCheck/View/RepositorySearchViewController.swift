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
    private var loadingIndicator: LoadingIndicatorView!
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.text = ""
        searchBar.delegate = self
        searchBar.placeholder = placeholderText // プレースホルダーテキストを設定
        loadingIndicator = LoadingIndicatorView() // ローディングインジケーターの初期化
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
        
        // リクエスト中のフラグをオンにする
        isSearching = true
        
        // ローディング中のアニメーションを開始
        loadingIndicator.startAnimating()
        
        // 検索クエリをURLで使用できる形式にエンコード
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            showErrorAlert(message: RepositoryServiceError.queryEncodingFailed.localizedDescription)
            return
        }
        
        // リポジトリデータを取得
        repositorySearch.fetchRepositories(query: encodedQuery) { [weak self] result in
            DispatchQueue.main.async {
                // ローディングを停止し、リクエスト中フラグを解除
                self?.loadingIndicator.stopAnimating()
                self?.isSearching = false
                switch result {
                case .success(let repositories):
                    // データソースを更新し、テーブルビューをリロード
                    self?.repositories = repositories
                    print(self?.repositories)
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
        if segue.identifier == "Detail",
           let repositoryDetailVC = segue.destination as? RepositoryDetailViewController,
           let repository = sender as? Repository {
            let viewModel = RepositoryDetailViewModel(repository: repository)
            repositoryDetailVC.viewModel = viewModel
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "RepoCell")
        let repository = repositories[indexPath.row]
        
        // リポジトリの名前を設定
        cell.textLabel?.text = repository.fullName

        // ダークモードとライトモードに対応するテキストカラー
        let textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        cell.textLabel?.textColor = textColor
        cell.detailTextLabel?.textColor = textColor
        
        // 言語を設定
        let languageString = "言語: \(repository.language ?? "不明")"
        let languageAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor]
        let attributedLanguageString = NSAttributedString(string: languageString, attributes: languageAttributes)
        
        // スターの数を設定するためのアトリビュート文字列を作成
        let starImage = NSTextAttachment()
        starImage.image = UIImage(systemName: "star")?.withTintColor(textColor, renderingMode: .alwaysOriginal)
        let starImageString = NSAttributedString(attachment: starImage)
        let starCountString = NSMutableAttributedString(string: " \(repository.stargazersCount)")
        starCountString.insert(starImageString, at: 0)
        
        // 言語とスターの数を結合するアトリビュート文字列を作成
        let combinedString = NSMutableAttributedString(attributedString: attributedLanguageString)
        combinedString.append(NSAttributedString(string: " "))
        combinedString.append(starCountString)
        
        // detailTextLabelのアトリビュート文字列を設定
        cell.detailTextLabel?.attributedText = combinedString
        
        return cell
    }

        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたリポジトリを取得
        let selectedRepository = repositories[indexPath.row]
        performSegue(withIdentifier: "Detail", sender: selectedRepository) // 選択したリポジトリを渡す
    }
}
