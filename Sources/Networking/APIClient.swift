//
//  File.swift
//  
//
//  Created by ashokdy on 17/08/2021.
//

import Foundation
import Combine

public struct APIClient {
    public init() { }
    public func makeService<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try JSONDecoder().decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

public struct Response<T> {
    public let value: T
    public let response: URLResponse
}
