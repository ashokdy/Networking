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
                return APIError(error: "", error_description: "")
            })
            .eraseToAnyPublisher()
    }
}

public struct Response<T> {
    public let value: T
    public let response: URLResponse?
    public let error: APIError?
}

/*
enum APIError4: Error, LocalizedError {
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

func fetch(url: URL) -> AnyPublisher<Data, APIError4> {
    let request = URLRequest(url: url)
    
    return URLSession.DataTaskPublisher(request: request, session: .shared)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw APIError4.unknown
            }
            return data
        }
        .mapError { error in
            if let error = error as? APIError4 {
                return error
            } else {
                return APIError4.apiError(reason: error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
}

func fetch<T: Decodable>(url: URL) -> AnyPublisher<T, APIError4> {
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
                return APIError4.parserError(reason: errorToReport)
            }  else {
                return APIError4.apiError(reason: error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
}
