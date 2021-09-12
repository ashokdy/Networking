//
//  File.swift
//  
//
//  Created by ashokdy on 17/08/2021.
//

import Foundation
import Combine

public struct APIError2: Error {
    var error: String
    var error_description: String
}

enum APIError3 : Error {
    case sessionFailed(error: URLError)
    case decodingFailed
    case other(Error)
}

public struct APIClient {
    public init() { }
    public func makeService<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                print("Response String in APICLient \(String(describing: String(data: result.data, encoding: .utf8)))")
                let value = try JSONDecoder().decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
//    func request<T: Decodable>(url: URL) -> AnyPublisher<Result<T, APIError>, Never> {
//        return URLSession.shared.dataTaskPublisher(for: url)
//            .mapError { Error.sessionFailed(error: $0) }
//            .map { $0.data }
//            .decode(type: T.self, decoder: JSONDecoder())
//            .map { Result<T, APIError>.success($0)}
//            .mapError { _ in Error.decodingFailed }
//            .catch { Just<Result<T, APIError>>(.failure($0)) }
//            .eraseToAnyPublisher()
//    }
}

public struct Response<T> {
    public let value: T
    public let response: URLResponse
}

enum APIError: Error, LocalizedError {
    case unknown, apiError(reason: String), parserError(reason: String)

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        }
    }
}

struct Fact: Decodable {
    var text: String
}

func fetch(url: URL) -> AnyPublisher<Data, APIError> {
    let request = URLRequest(url: url)

    return URLSession.DataTaskPublisher(request: request, session: .shared)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw APIError.unknown
            }
            return data
        }
        .mapError { error in
            if let error = error as? APIError {
                return error
            } else {
                return APIError.apiError(reason: error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
}

func fetch<T: Decodable>(url: URL) -> AnyPublisher<T, APIError> {
    fetch(url: url)
        .decode(type: T.self, decoder: JSONDecoder())
        .mapError { error in
            if let error = error as? DecodingError {
                var errorToReport = error.localizedDescription
                switch error {
                case .dataCorrupted(let context):
                    let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                    errorToReport = "\(context.debugDescription) - (\(details))"
                case .keyNotFound(let key, let context):
                    let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                    errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
                case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                    let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                    errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
                @unknown default:
                    break
                }
                return APIError.parserError(reason: errorToReport)
            }  else {
                return APIError.apiError(reason: error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
}

// Usage
//if let url = URL(string: "https://cat-fact.herokuapp.com/facts/random") {
//    fetch(url: url)
//        .sink(receiveCompletion: { completion in
//            switch completion {
//            case .finished:
//                break
//            case .failure(let error):
//                print("Error: \(error.localizedDescription)")
//            }
//        }, receiveValue: { (fact: Fact) in
//            print(fact.text)
//        })
