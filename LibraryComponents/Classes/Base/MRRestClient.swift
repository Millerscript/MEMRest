//
//  MRRestClient.swift
//  MEMRest
//
//  Created by Miller Mosquera on 17/03/24.
//

import Foundation
import Combine

open class MRRestClient {
    
    private var configuration: MRRequestConfiguration?
    private var environment: EnvironmentConfiguration
    
    public init(environment: EnvironmentConfiguration) {
        self.environment = environment
    }
    
    private func setup(configuration: MRRequestConfiguration) -> MRApiClient {
        self.configuration = configuration
        
        self.configuration?.baseURL = getComponents(url: self.environment.getUrl(path: configuration.path), configuration: configuration).url
        return MRApiClient(requestConfiguration: self.configuration!)
    }
    
    private func getComponents(url: URL, configuration: MRRequestConfiguration) -> URLComponents {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = configuration.queryParams

        return components
    }
    
    public func execute<T: Codable>(configuration: MRRequestConfiguration) async -> AnyPublisher<T, Error> {
        return try! await setup(configuration: configuration).send()
    }
    
}

public enum Scopes {
    case MOCK
    case DEBUG
    case RELEASE
}

public protocol EnvironmentConfiguration: AnyObject {
    var scope: Scopes {get set}
    
    func getUrl(path: String) -> URL
}
