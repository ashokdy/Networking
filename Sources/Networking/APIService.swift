//
//  File.swift
//  
//
//  Created by ashokdy on 23/08/2021.
//

import Foundation
import Combine

public protocol APIService {
    var apiClient: APIClient { get }
    var isBasic: Bool { get }
    var needsQueryItems: Bool { get }
    var hasData: Bool { get }
    func requestAPI<T: Decodable>(_ path: APIPath) -> AnyPublisher<T, Error>
}

public extension APIService {
    var apiClient: APIClient {
        APIClient()
    }
    var needsQueryItems: Bool { false }
    var isBasic: Bool { false }
    var hasData: Bool { false }

    func requestAPI<T: Decodable>(_ path: APIPath) -> AnyPublisher<T, Error> {
        let baseURL = URL(string: APIServiceConfig.shared.apiData.baseURL)!
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path.subURL), resolvingAgainstBaseURL: true)
        else { fatalError("Couldn't create URLComponents") }
        if needsQueryItems {
            var queryItems = [URLQueryItem]()
            for param in path.params {
                queryItems.append(URLQueryItem(name: param.key, value: param.value as? String))
            }
            components.queryItems = queryItems
        }
        var request = URLRequest(url: components.url!)
        if !path.queryURL.isEmpty {
            request = URLRequest(url: URL(string: APIServiceConfig.shared.apiData.baseURL + path.subURL + path.queryURL)!)
        }
        if hasData {
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        }
        if isBasic {
            request.addValue("Basic \(APIServiceConfig.shared.apiData.basicToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Bearer \(APIServiceConfig.shared.apiData.accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = path.httpMethod.rawValue

        switch path.httpMethod {
        case .post:
            if let data = path.data {
                print(String(data: data, encoding: .utf8))
                request.httpBody = data
            } else if !needsQueryItems {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: path.params, options: .prettyPrinted)
                } catch {
                    print(error)
                }
            }
        default: break
        }
        print(request)
        return apiClient.makeService(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
