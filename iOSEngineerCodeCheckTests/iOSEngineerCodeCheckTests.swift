//
//  iOSEngineerCodeCheckTests.swift
//  iOSEngineerCodeCheckTests
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import XCTest
@testable import iOSEngineerCodeCheck

final class iOSEngineerCodeCheckTests: XCTestCase {
    
    func testGitHubAPIFetchSuccess() {
        let expectation = XCTestExpectation(description: "Fetch GitHub repositories successfully")
        let query = "swift"
        let urlString = "\(GitHubAPI.searchURL)\(query)" 
        guard let url = URL(string: urlString) else {
            XCTFail("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                XCTFail("Error occurred: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                XCTFail("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = json as? [String: Any],
                      let items = dictionary["items"] as? [[String: Any]] else {
                    XCTFail("Invalid JSON format")
                    return
                }
                
                XCTAssertGreaterThan(items.count, 0, "Repositories should not be empty")
                expectation.fulfill()
            } catch {
                XCTFail("JSON parsing failed: \(error.localizedDescription)")
            }
        }
        task.resume()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGitHubAPIFetchInvalidQuery() {
        let expectation = XCTestExpectation(description: "Handle invalid search query gracefully")
        let query = ""
        let urlString = "\(GitHubAPI.searchURL)\(query)"
        guard let url = URL(string: urlString) else {
            XCTFail("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                XCTFail("Error occurred: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                XCTFail("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = json as? [String: Any] else {
                    XCTFail("Invalid JSON format")
                    return
                }
                
                if let message = dictionary["message"] as? String {
                    // APIエラーが発生している場合
                    XCTAssertTrue(message.contains("Validation Failed"), "Expected a validation error message")
                } else if let items = dictionary["items"] as? [[String: Any]] {
                    // 正常なレスポンスが返った場合
                    XCTAssertEqual(items.count, 0, "Repositories should be empty for an invalid query")
                } else {
                    XCTFail("Unexpected response structure")
                }
                
                expectation.fulfill()
            } catch {
                XCTFail("JSON parsing failed: \(error.localizedDescription)")
            }
        }
        task.resume()

        wait(for: [expectation], timeout: 10.0)
    }
}
