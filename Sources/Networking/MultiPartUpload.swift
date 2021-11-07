//
//  MultiPartUpload.swift
//  
//
//  Created by Ashok Yerra on 10/09/2021.
//

import Foundation

public class MultiPartUpload {
    public func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    public func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
    
    public func playground() {
        
        let fileData = try! Data(contentsOf: URL(fileURLWithPath: "/Users/ashok.yerra/Downloads/sample.jpg"), options: .mappedIfSafe)
        let fileContent = fileData.base64EncodedString() //10485760
        
        let formFields = ["profileData": "{\"userId\":299,\"firstName\":\"mukesh\",\"lastName\":\"qa\",\"dateOfBirth\":\"2007-06-06T00:00:00.000Z\",\"languages\":[{\"name\":\"Arabic\"},{\"name\":\"Danish\"}],\"phone\":\"971529123587\",\"countryId\":101,\"gender\":\"MALE\",\"email\":\"mukesh@qa.team\",\"patientTimeZone\":\"Asia/Dubai\"}"]
        let imageData = fileContent.data(using: .utf8)!
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: URL(string: "https://dev.healthieru.ae/api/patients/")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(APIServiceConfig.shared.apiData.accessToken)", forHTTPHeaderField: "authorization")
        
        let httpBody = NSMutableData()
        
        for (key, value) in formFields {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }
        
        httpBody.append(convertFileData(fieldName: "profilePicture",
                                        fileName: "imagename.png",
                                        mimeType: "image/png",
                                        fileData: imageData,
                                        using: boundary))
        
        httpBody.appendString("--\(boundary)--")
        
        request.httpBody = httpBody as Data
        
        print(String(data: httpBody as Data, encoding: .utf8)!)
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
        }.resume()
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
