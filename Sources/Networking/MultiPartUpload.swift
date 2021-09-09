//
//  MultiPartUpload.swift
//  
//
//  Created by Ashok Yerra on 10/09/2021.
//

import Foundation

class MultiPartUpload {
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
    
    func playground() {
        
        let fileData = try! Data(contentsOf: URL(fileURLWithPath: "/Users/ashok.yerra/Downloads/sample.jpg"), options: .mappedIfSafe)
        let fileContent = fileData.base64EncodedString() //10485760
        
        let formFields = ["profileData": "{\"userId\":299,\"firstName\":\"mukesh\",\"lastName\":\"qa\",\"dateOfBirth\":\"2007-06-06T00:00:00.000Z\",\"languages\":[{\"name\":\"Arabic\"},{\"name\":\"Danish\"}],\"phone\":\"971529123587\",\"countryId\":101,\"gender\":\"MALE\",\"email\":\"mukesh@qa.team\",\"patientTimeZone\":\"Asia/Dubai\"}"]
        let imageData = fileContent.data(using: .utf8)!
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: URL(string: "https://dev.healthy-u.ae/api/patients/")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJsYXJ5cGFnZTAxIiwic2NvcGUiOlsib3BlbmlkIl0sImV4cCI6MTYzMTIyNDMxNywiaWF0IjoxNjMxMjIxMzE3LCJhdXRob3JpdGllcyI6WyJST0xFX1BBVElFTlQiXSwianRpIjoiNDM5Njc4MjktYjE2OC00MTRkLTlkMTgtYjA5ZGUxZmE2MGI4IiwiY2xpZW50X2lkIjoid2ViX2FwcCJ9.QPqx7arhSGFUmKE1QGcMwlbKwlNL78OiwySbbYFYpD9RtWb2Hlgzeoxv2_vkX8l2JPIZFtXIyP34NGP5TSTfAB1eRbF5-ttZV6R9pcW4auFMQnEFSOTOkC7l5twlGM90biEnw9fbQKd3YFkGDZPL1d7MVWJQENAjEnli94ziXoKgsQvD4ceIIEnpNc4DF0ZJOKqAVr3ekJkHb7sYboz9JrNKRSiOxE5QTXcxuI3DqUHsZJSh3_E5-GapvGqvvhDJ5ZygqgM0KbIJBoGF7oQiqFs7bLDET1L1xXsvnWq1BiwYamliLJ0JV9UWOl9B9LdC9_ADPEGpmNmvbdtlg8cdXw", forHTTPHeaderField: "authorization")
        
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
            print(String(data: data!, encoding: .utf8))
            print(error!)
            // handle the response here
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
