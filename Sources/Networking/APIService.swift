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
    var neesQueryItems: Bool { get }
    func requestAPI<T: Decodable>(_ path: APIPath) -> AnyPublisher<T, Error>
}

public extension APIService {
    var apiClient: APIClient {
        APIClient()
    }
    var neesQueryItems: Bool { false }
    var isBasic: Bool { false }
    
    func requestAPI<T: Decodable>(_ path: APIPath) -> AnyPublisher<T, Error> {
        let baseURL = URL(string: APIServiceConfig.shared.apiData.baseURL)!
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path.subURL), resolvingAgainstBaseURL: true)
        else { fatalError("Couldn't create URLComponents") }
        if neesQueryItems {
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
        if isBasic {
            request.allHTTPHeaderFields = ["Authorization": "Basic \(APIServiceConfig.shared.apiData.basicToken)"]
        } else {
            request.allHTTPHeaderFields = ["Authorization": "Bearer \(APIServiceConfig.shared.apiData.accessToken)"]
        }
        switch path.httpMethod {
        case .post:
            request.httpBody = try? JSONSerialization.data(withJSONObject: path.params, options: .prettyPrinted)
        default: break
        }
        request.httpMethod = path.httpMethod.rawValue
        return apiClient.makeService(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
