//
//  MRApiClientProtocol.swift
//  MEMRest
//
//  Created by Miller Mosquera on 17/03/24.
//

import Foundation
import Combine

public protocol MRApiClientProtocol: AnyObject {

    func send<T: Codable>() async throws -> AnyPublisher<T, Error>
    func send<T: Codable>() async throws -> Result<T, MRNetworkError>
}
