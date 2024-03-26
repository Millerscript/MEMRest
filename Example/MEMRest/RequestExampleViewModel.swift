//
//  RequestExampleViewModel.swift
//  MCRestExample
//
//  Created by Miller Mosquera on 17/03/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Combine
import MEMRest

class RequestExampleViewModel {
    var userSuccessSubject = PassthroughSubject<UserModel, Error>()
    var userTOSuccessSubject = PassthroughSubject<UserModel, Error>()
    var userFailSuccessSubject = PassthroughSubject<UserModel, Error>()
    var buttonSuccessSubject = PassthroughSubject<Void, Error>()
    var errorSubject = PassthroughSubject<Void, Error>()
    
    var btnList: [ButtonModel] = []
    
    var repository: RequestExampleRepositoryProtocol
    
    public init(repository: RequestExampleRepositoryProtocol = RequestExampleRepository()) {
        self.repository = repository
    }
    
    @MainActor
    func getUserInformationSuccess() async {
        do {
            _ = try await repository.getInformation().sink { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(_):
                    self.errorSubject.send()
                }
            } receiveValue: { response in
                self.userSuccessSubject.send(response.data!)
            }
        } catch {
            self.errorSubject.send()
        }
    }
    
    @MainActor
    func getUserInformationFail() async {
        do {
            _ = try await repository.getInformationFail().sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(_):
                    self.errorSubject.send()
                }
            }, receiveValue: { response in
                if let data = response.data {
                    self.userFailSuccessSubject.send(data)
                }
            })
        } catch {
            self.errorSubject.send()
        }
    }
    
    @MainActor
    func getUserInformationTimeout() async {
        do {
            _ = try await repository.getInformationWithTimeOut().sink { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print("Error found : \(error.localizedDescription)")
                    self.errorSubject.send()
                }
            } receiveValue: { response in
                self.errorSubject.send()
            }
        } catch {
            self.errorSubject.send()
        }
    }
    
    func getUserInformationIdle() {
        
    }
    
    
    func getList() {
        btnList = ButtonModel.getButtons()
        buttonSuccessSubject.send()
    }
    
}


struct ButtonModel {
    let buttonId: Int
    let title: String
    let type: ButtonType
    
    static func getButtons() -> [ButtonModel] {
        return [.init(buttonId: 1, title: "Success", type: .Success), 
                .init(buttonId: 2, title: "Fail", type: .Fail),
                .init(buttonId: 3, title: "Timeout", type: .Timeout),
                .init(buttonId: 4, title: "idle", type: .Idle)]
    }
}

enum ButtonType {
    case Success
    case Fail
    case Timeout
    case Idle
}

