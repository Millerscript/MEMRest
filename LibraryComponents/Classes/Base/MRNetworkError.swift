//
//  MRNetworkError.swift
//  MEMRest
//
//  Created by Miller Mosquera on 17/03/24.
//

import Foundation
public enum MRNetworkError: Error {
    case badURL
    case noData
    case decodingError
    case badServerResponse
    case timeOut
}
