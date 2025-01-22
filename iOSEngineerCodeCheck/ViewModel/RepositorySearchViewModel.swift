//
//  RepositorySearchViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 田村梨恭 on 2025/01/23.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

class RepositorySearchViewModel {
    private let session: URLSession
    
    init() {
        // URLSessionの初期化
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchRepositories(query: String, completion: @escaping (Result<[Repository], RepositoryServiceError>) -> Void) {
        // クエリが空の場合やスペースのみの場合はエラーを返す
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            completion(.failure(.queryMissing))
            return
        }
        
        // クエリをURLエンコードする
        guard let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.queryEncodingFailed))
            return
        }
        
        // APIのURLを作成
        guard let apiUrl = URL(string: "\(GitHubAPI.searchURL)\(encodedQuery)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // データタスクの作成
        let task = session.dataTask(with: apiUrl) { data, response, error in
            // ネットワークエラーの処理
            if let error = error {
                completion(.failure(.requestFailed))
                return
            }
            
            // データがない場合
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // データのデコード処理
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // レートリミットエラーの処理
                    if let message = json["message"] as? String,
                       let documentationURL = json["documentation_url"] as? String,
                       message.contains("API rate limit exceeded") {
                        completion(.failure(.rateLimitExceeded))
                        return
                    }
                }
                let searchResult = try JSONDecoder().decode(GitHubSearchResult.self, from: data)
                completion(.success(searchResult.items))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        // タスクを開始
        task.resume()
    }
}
