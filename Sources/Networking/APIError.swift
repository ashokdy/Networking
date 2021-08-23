//
//  File.swift
//  
//
//  Created by ashokdy on 17/08/2021.
//

import Foundation

public struct ErrorMessage {
    static let internetError = "Please check your Internet connection"
    static let noDataError = "Data Received empty from the server please try again"
    static let limitExeededError = "Github API rate limit exceeded. Wait for 60 seconds and try again."
    static let emptyModel = "Received Empty results for the given search text, try with different search text"
    static let emptyResponse = "Empty Response Received"
}

public enum APIError: Error {
    case internetError
    case noDataError
    case limitExeededError
    case emptyModel
    case emptyResponse
    case genericError(String)
    
    public func errorDescription() -> String {
        switch self {
        case .internetError: return ErrorMessage.internetError
        case .noDataError: return ErrorMessage.noDataError
        case .limitExeededError: return ErrorMessage.limitExeededError
        case .emptyModel: return ErrorMessage.emptyModel
        case .emptyResponse: return ErrorMessage.emptyResponse
        case .genericError(let errorDesc): return errorDesc
        }
    }
    
    public func errorIcon() -> String? {
        switch self {
        case .internetError: return "wifi.exclamationmark"
        default: return "nosign"
        }
    }
}
