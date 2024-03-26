//
//  ExampleEnvironment.swift
//  MCRestExample
//
//  Created by Miller Mosquera on 18/03/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import MEMRest

class ExampleEnvironment: EnvironmentConfiguration {
    
    struct Constants {
        static let baseUrlDebug = "https://languid-catkin-crayfish.glitch.me"
        static let baseUrlMock = "https://languid-catkin-crayfish.glitch.me"
        static let baseUrlRelease = "https://languid-catkin-crayfish.glitch.me"
    }
        
    var scope: Scopes
    
    init(scope: Scopes) {
        self.scope = scope
    }

    // TODO: use compiler variables
    func getUrl(path: String) -> URL {
        switch scope {
        case .MOCK:
            return URL(string: "\(Constants.baseUrlMock)\(path)")!
        case .DEBUG:
            return URL(string: "\(Constants.baseUrlDebug)\(path)")!
        case .RELEASE:
            return URL(string: "\(Constants.baseUrlRelease)\(path)")!
        }
    }
}
