//
//  RequestExampleRepositoryProtocol.swift
//  MCRestExample
//
//  Created by Miller Mosquera on 17/03/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Combine
import MEMRest

protocol RequestExampleRepositoryProtocol {
    func getInformation() async throws -> AnyPublisher<BaseGenericResponseModel<UserModel>, Error>
    func getInformationWithTimeOut() async throws -> AnyPublisher<BaseGenericResponseModel<UserModel>, Error>
    func getInformationFail() async throws -> AnyPublisher<BaseGenericResponseModel<UserModel>, Error>
}
