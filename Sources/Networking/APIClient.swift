//
//  File.swift
//  
//
//  Created by ashokdy on 17/08/2021.
//

import Foundation
import Combine

public struct APIError: Codable, Error {
    public var error: String?
    public var error_description: String?
    public var entityName: String?
    public var errorKey: String?
    public var title: String?
    public var status: Int?
    public var message: String?
    public var params: String?
}

public struct APIClient {
    public init() { }
    public func makeService<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, APIError> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                do {
                    print("Response String in APICLient \(String(describing: String(data: result.data, encoding: .utf8)))")
                    let value = try JSONDecoder().decode(T.self, from: result.data)
                    return Response(value: value, response: result.response, error: nil)
                } catch let exception {
                    print(exception)
                    let error = try JSONDecoder().decode(APIError.self, from: result.data)
                    throw error
                }
            }
            .receive(on: DispatchQueue.main)
            .mapError({ error in
                if let apierror = error as? APIError {
                    print(apierror)
                    return apierror
                }
                return APIError(error: error.localizedDescription, error_description: error.localizedDescription)
            })
            .eraseToAnyPublisher()
    }
}

public struct Response<T> {
    public let value: T
    public let response: URLResponse?
    public let error: APIError?
}
