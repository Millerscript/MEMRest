//
//  BaseGenericResponseModel.swift
//  MEMRest
//
//  Created by Miller Mosquera on 22/03/24.
//

import Foundation
public struct BaseGenericResponseModel<T: Codable>: Codable {
    public let message: String
    public let code: Int
    public let data: T?
}
