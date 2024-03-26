//
//  MRRequestConfiguration.swift
//  MEMRest
//
//  Created by Miller Mosquera on 17/03/24.
//

import Foundation
/**
 * - parameters baseURL: https://www.host.com...
 * - parameters path: ../get-profile
 */

public struct MRRequestConfiguration {
    public var method: MRRequestMethod
    public var baseURL: URL?
    public var path: String
    public var headerData: [String: String] = [:]
    public var body: Data?
    public var queryParams: [URLQueryItem] = []
    public var timeOut: Double

    public init(method: MRRequestMethod,
                baseURL: URL? = nil,
                path: String? = "",
                headerData: [String: String]? = [:],
                body: Data? = nil,
                queryParams: [URLQueryItem]? = [],
                timeOut: Double = 10) {
        self.method = method
        self.baseURL = baseURL
        self.path = path ?? ""
        self.headerData = headerData ?? [:]
        self.body = body
        self.queryParams = queryParams ?? []
        self.timeOut = timeOut
    }
}
