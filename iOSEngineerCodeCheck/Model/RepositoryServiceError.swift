//
//  RepositoryServiceError.swift
//  iOSEngineerCodeCheck
//
//  Created by 田村梨恭 on 2025/01/23.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

enum RepositoryServiceError: LocalizedError {
    case invalidURL            // リクエストで使用するURLが無効である場合
    case requestFailed         // ネットワークリクエストが失敗した場合
    case noData                // レスポンスからデータが取得できなかった場合
    case decodingError         // レスポンスデータのデコードに失敗した場合
    case queryEncodingFailed   // 検索クエリのURLエンコードに失敗した場合
    case queryMissing          // 検索内容が入力されていない場合
    case invalidQuery          // 検索内容がスペースのみなど無効な場合
    case rateLimitExceeded     // APIのレート制限を超えた場合
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "リクエストのURLが無効です。"
        case .requestFailed:
            return "リクエストが失敗しました。ネットワーク接続を確認してください。"
        case .noData:
            return "データが見つかりませんでした。"
        case .decodingError:
            return "データの処理に失敗しました。"
        case .queryEncodingFailed:
            return "検索内容に使用できない文字が含まれている可能性があります。もう一度入力してください。"
        case .queryMissing:
            return "検索内容を入力してください。"
        case .invalidQuery:
            return "検索内容が無効です。スペースだけの検索はできません。"
        case .rateLimitExceeded:
            return "APIのレート制限に達しました。しばらくしてから再試行してください。"
        }
    }
}

