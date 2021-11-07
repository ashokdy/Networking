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
    var needsHeaders: Bool { get }
    var hasData: Bool { get }
    func requestAPI<T: Decodable>(_ path: APIPath) -> AnyPublisher<T, APIError>
    func multiPartAPI<T: Decodable>(_ path: APIPath, imageKey: String, imagePath: String, dictKey: String, dictString: String) -> AnyPublisher<T, APIError>
}

public extension APIService {
    var apiClient: APIClient {
        APIClient()
    }
    var needsQueryItems: Bool { false }
    var isBasic: Bool { false }
    var hasData: Bool { false }
    var needsHeaders: Bool { true }
    
    func requestAPI<T: Decodable>(_ path: APIPath) -> AnyPublisher<T, APIError> {
        let baseURL = URL(string: APIServiceConfig.shared.apiData.baseURL)!
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path.subURL), resolvingAgainstBaseURL: true)
        else { fatalError("Couldn't create URLComponents") }
        if needsQueryItems {
            var queryItems = [URLQueryItem]()
            for param in path.params {
                queryItems.append(URLQueryItem(name: param.key, value: param.value as? String))
            }
            components.queryItems = queryItems
            print("Added the params as query items \(queryItems)")
        }
        guard let urlString = components.url?.absoluteString.removingPercentEncoding,
              let url = URL(string: urlString) else {
            fatalError("Couldn't create URLComponents")
        }
        var request = URLRequest(url: url)
        if !path.queryURL.isEmpty {
            request = URLRequest(url: URL(string: APIServiceConfig.shared.apiData.baseURL + path.subURL + path.queryURL)!)
        } else if !needsQueryItems {
            let apiURL = APIServiceConfig.shared.apiData.baseURL + path.subURL
            request = URLRequest(url: URL(string: apiURL.removingPercentEncoding!)!)
        }
        if needsHeaders {
            if hasData {
                request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if isBasic {
                request.addValue("Basic \(APIServiceConfig.shared.apiData.basicToken)", forHTTPHeaderField: "Authorization")
            } else {
                request.addValue("Bearer \(APIServiceConfig.shared.apiData.accessToken)", forHTTPHeaderField: "Authorization")
            }
        }
        request.httpMethod = path.httpMethod.rawValue
        print("URL -> ", request.url ?? "")
        print("httpMwethod -> ", request.httpMethod ?? "")
        print("headers -> ", request.allHTTPHeaderFields ?? "")
        print("params -> ", path.params)
        print("paramsArray -> ", path.paramsArray)
        switch path.httpMethod {
        case .post:
            if let data = path.data {
                print("HTTP Direct data \(String(data: data, encoding: .utf8) ?? "")")
                request.httpBody = data
            } else if !needsQueryItems {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: path.params, options: .prettyPrinted)
                    print("HTTP params data \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
                } catch {
                    print("exception on converting params to body data \(error)")
                }
            }
        case .put:
            if let data = path.data {
                print("HTTP Direct data \(String(data: data, encoding: .utf8) ?? "")")
                request.httpBody = data
            } else if !needsQueryItems {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: path.paramsArray, options: .prettyPrinted)
                    print("HTTP params data \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
                } catch {
                    print("exception on converting params to body data \(error)")
                }
            }
        default: break
        }
        return apiClient.makeService(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    func multiPartAPI<T: Decodable>(_ path: APIPath, imageKey: String, imagePath: String, dictKey: String, dictString: String) -> AnyPublisher<T, APIError> {
        let fileData = try? Data(contentsOf: URL(fileURLWithPath: imagePath/*"/Users/ashok.yerra/Downloads/sample.jpg"*/), options: .mappedIfSafe)
        let fileContent = fileData?.base64EncodedString()
        
        let formFields = [dictKey: dictString]
        let imageData = fileContent?.data(using: .utf8)!
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: URL(string: APIServiceConfig.shared.apiData.baseURL + path.subURL)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(APIServiceConfig.shared.apiData.accessToken)", forHTTPHeaderField: "authorization")
        
        let httpBody = NSMutableData()
        
        for (key, value) in formFields {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }
        
        httpBody.append(convertFileData(fieldName: imageKey,
                                        fileName: "imagename.png",
                                        mimeType: "image/png",
                                        fileData: imageData ?? Data(),
                                        using: boundary))
        
        httpBody.appendString("--\(boundary)--")
        
        request.httpBody = httpBody as Data
        
//        print(String(data: httpBody as Data, encoding: .utf8)!)
        print("URL -> ", request.url ?? "")
        print("httpMwethod -> ", request.httpMethod ?? "")
        print("headers -> ", request.allHTTPHeaderFields ?? "")
        print("params -> ", path.params)

        return apiClient.makeService(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    private func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
}
