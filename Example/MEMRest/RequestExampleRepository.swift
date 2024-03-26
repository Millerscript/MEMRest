//
//  RequestExampleRepository.swift
//  MCRestExample
//
//  Created by Miller Mosquera on 17/03/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Combine
import MEMBase
import MEMRest

class RequestExampleRepository: RequestExampleRepositoryProtocol {
    
    struct Constants {
        static var timeout: Double = 10
        static var informationPath = "/information"
        static var informationTimeoutPath = "/timeout"
        static var failPath = "/fail"
    }
    
    private var client: MRRestClient
    
    init(client: MRRestClient = MRRestClient(environment: ExampleEnvironment(scope: .DEBUG))) {
        self.client = client
    }
    
    func getInformation() async throws -> AnyPublisher<BaseGenericResponseModel<UserModel>, Error> {
        let params: [URLQueryItem] = [URLQueryItem(name: "user", value: "1")]
        return await client.execute(configuration: MRRequestConfiguration(method: .GET, path: Constants.informationPath, queryParams: params, timeOut: Constants.timeout))
    }
    
    func getInformationWithTimeOut() async throws -> AnyPublisher<BaseGenericResponseModel<UserModel>, Error> {
        let params: [URLQueryItem] = [URLQueryItem(name: "user", value: "1")]
        return await client.execute(configuration: MRRequestConfiguration(method: .GET, path: Constants.informationTimeoutPath, queryParams: params, timeOut: Constants.timeout))
    }
    
    func getInformationFail() async throws -> AnyPublisher<BaseGenericResponseModel<UserModel>, Error> {
        let params: [URLQueryItem] = [URLQueryItem(name: "user", value: "1")]
        return await client.execute(configuration: MRRequestConfiguration(method: .GET, path: Constants.failPath, queryParams: params, timeOut: Constants.timeout))
    }
}
