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
        // キャッシュを使用せず常に最新データを取得する設定
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

                    // リポジトリ情報の処理
                    if let items = json["items"] as? [[String: Any]] {
                        let repositories = items.compactMap { self.parseRepository($0) }
                        completion(.success(repositories))
                    } else {
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.decodingError))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }

        // タスクを開始
        task.resume()
    }

    // リポジトリ情報をJSONから解析してRepositoryオブジェクトを作成
    private func parseRepository(_ json: [String: Any]) -> Repository? {
        guard let fullName = json["full_name"] as? String,
              let stargazersCount = json["stargazers_count"] as? Int,
              let watchersCount = json["watchers_count"] as? Int,
              let forksCount = json["forks_count"] as? Int,
              let openIssuesCount = json["open_issues_count"] as? Int,
              let htmlURL = json["html_url"] as? String else { return nil }

        let language = json["language"] as? String
        let owner = (json["owner"] as? [String: Any]).flatMap { parseOwner($0) }

        return Repository(fullName: fullName,
                          language: language,
                          stargazersCount: stargazersCount,
                          watchersCount: watchersCount,
                          forksCount: forksCount,
                          openIssuesCount: openIssuesCount,
                          htmlURL: htmlURL,
                          owner: owner)
    }

    // リポジトリの所有者情報をJSONから解析してOwnerオブジェクトを作成
    private func parseOwner(_ json: [String: Any]) -> Owner? {
        guard let avatarURL = json["avatar_url"] as? String else { return nil }
        return Owner(avatarURL: avatarURL)
    }
}
