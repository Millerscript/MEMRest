//
//  MRApiClient.swift
//  MEMRest
//
//  Created by Miller Mosquera on 17/03/24.
//

import Foundation
import Combine

public class MRApiClient: NSObject, MRApiClientProtocol {
    
    struct Constants {
        static var applicationJSON = "application/json"
        static var headerContentType = "Content-Type"
        static var headerAccept = "Accept"
    }
    
    private(set) var baseURL: URL?
    private(set) var requestConfiguration: MRRequestConfiguration
    private(set) var urlRequest: URLRequest?

    private var cancellable = [AnyCancellable]()
    
    required public init(requestConfiguration: MRRequestConfiguration) {
        self.baseURL = requestConfiguration.baseURL
        self.requestConfiguration = requestConfiguration
    }
    
    /**
     * Check if the baseURL is already set and then it sets the httpMethod ( GET, POST, PUT, DELETE )
     * and return the URLRequest
     *
     * - returns: URLRequest
     * - authors: Miller Mosquera
     */
    private func setURLRequest() {
        guard let url = baseURL else { return }
        
        urlRequest = URLRequest(url: url)
        urlRequest?.httpMethod = self.requestConfiguration.method.rawValue
    }
    
    /**
     * Set the url session configuration
     * - returns: URLSessionConfiguration already set
     */
    private func setURLSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = requestConfiguration.timeOut
        configuration.timeoutIntervalForResource = requestConfiguration.timeOut
        configuration.waitsForConnectivity = true
        configuration.httpAdditionalHeaders = requestConfiguration.headerData
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.allowsCellularAccess = true
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return configuration
    }
    
    /**
     * Set the request body
     * - parameters request: URLRequest to set the body
     */
    private func setRequestBody() {
        if let body = requestConfiguration.body {
            guard let bodyData = try? JSONEncoder().encode(body) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            urlRequest?.httpBody = bodyData
        }
    }
    
    /**
     * Set the default headers values and customs
     * - parameters headerValues: a dictionary with values that comes from the user configuration :)
     */
    private func setRequestHeader(headerValues: [String: String]?) {
        
        urlRequest?.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.headerContentType)
        urlRequest?.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.headerAccept)
        
        if let headerValues = headerValues {
            headerValues.forEach { item in
                urlRequest?.addValue(item.key, forHTTPHeaderField: item.value)
            }
        }
    }
    
    /**
     * decode data
     * - parameters data:
     * - returns: A json object
     */
    private func decodeDataToJson(data: Data) throws -> Any? {
        if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return jsonObject
        } else if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [Any] {
            return jsonObject
        } else {
            return nil
        }
    }
    
    /**
     * Decode data and convert it to an string
     * - parameters data:
     * - returns String:
     */
    private func decodeDataToString(data: Data) throws -> String {
        guard let jsonObject = try decodeDataToJson(data: data) else {
            throw MRNetworkError.decodingError
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

        return String(data: jsonData, encoding: .utf8) ?? ""
    }
    
    /**
     * Decode a String to json object
     */
    private func decodeStringToJson<T: Codable>(jsonString: String, responseType: T.Type) -> T? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    
    private var session: URLSession {
        return URLSession(configuration: setURLSessionConfiguration(), delegate: self, delegateQueue: nil)
    }
    
    private func execute<T: Codable>(request: URLRequest) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request)
            .map{ $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .subscribe(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func execute<T: Codable>(request: URLRequest) async throws -> Result<T, MRNetworkError> {
        return try await withCheckedThrowingContinuation { continuation in
                        
            session.dataTask(with: request) { [self] data, response, error in
                do {
                    guard let data = data else {
                        throw MRNetworkError.decodingError
                    }
                    
                    let jsonStringData = try decodeDataToString(data: data)
                    let jsonData = decodeStringToJson(jsonString: jsonStringData, responseType: T.self)
                    
                    guard let jsonData = jsonData else { throw MRNetworkError.decodingError }
                    
                    continuation.resume(returning: .success(jsonData))
                } catch {
                    continuation.resume(returning: .failure(MRNetworkError.decodingError))
                }
            }.resume()
        }
    }
    
    private func configureRequestBeforeSend() {
        setURLRequest()
        setRequestBody()
        setRequestHeader(headerValues: self.requestConfiguration.headerData)
    }

    public func send<T: Codable>() async throws -> AnyPublisher<T, Error> {
        configureRequestBeforeSend()
        return execute(request: self.urlRequest!)
    }
    
    public func send<T: Codable>() async throws -> Result<T, MRNetworkError> {
        configureRequestBeforeSend()
        return try await execute(request: self.urlRequest!)
    }
    
}

extension MRApiClient: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

        completionHandler(.useCredential, urlCredential)
    }
}
