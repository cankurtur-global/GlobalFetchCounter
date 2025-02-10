//
//  FetchCounterViewModel.swift
//  FetchCounterModule
//
//  Created by Can Kurtur on 9.02.2025.
//

import Foundation
import Combine
import ConfigKit
import CommonKit

/// The ViewModel for FetchCounterView, responsible for handling the logic and state.
final class FetchCounterViewModel: ObservableObject {
    @UserDefaultProperty(key: UserDefaultKeys.fetchCount, defaultValue: 0)
    var fetchCount: Int
    
    @Published var responseCode: String = ""
    @Published var fetchState: FetchState = .initial
    
    private let codeFetcherServiceProvider: CodeFetcherServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(codeFetcherServiceProvider: CodeFetcherServiceProtocol = CodeFetcherServiceProvider()) {
        self.codeFetcherServiceProvider = codeFetcherServiceProvider
    }
    
    // Fetch button action.
    func fetchButtonTapped() {
        fetchState = .loading
        
        let rootPublisher = createRootPublisher()
        let responseCodePublisher = createResponseCodePublisher(from: rootPublisher)
        
        responseCodePublisher
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: handleCompletion, receiveValue: handleSuccess)
            .store(in: &cancellables)
    }
}

// MARK: - Privates

private extension FetchCounterViewModel {
    // Creates root publisher. Removes base URL prefix from the path.
    func createRootPublisher() -> AnyPublisher<String, APIClientError> {
        codeFetcherServiceProvider.getRoot()
            .compactMap { $0.nextPath }
            .map { nextPath -> String in
                nextPath.replacingOccurrences(of: Config.baseUrl, with: "")
            }
            .eraseToAnyPublisher()
    }
    
    // Transforms the root path into a response code publisher.
    func createResponseCodePublisher(from rootPublisher: AnyPublisher<String, APIClientError>) -> AnyPublisher<String, APIClientError> {
        rootPublisher
            .flatMap { [weak self] path in
                self?.codeFetcherServiceProvider.getResponseCode(with: path) ?? Empty().eraseToAnyPublisher()
            }
            .compactMap { $0.responseCode }
            .eraseToAnyPublisher()
    }
    
    // Handles the completion of the publisher, updating fetch state if an error occurs.
    func handleCompletion(_ completion: Subscribers.Completion<APIClientError>) {
        switch completion {
        case .failure(let error):
            fetchState = .errorOccuered(message: error.message)
        case .finished:
            break
        }
    }
    
    // Updates the view state after successfully fetching a response code.
    func handleSuccess(_ responseCode: String) {
        self.responseCode = responseCode
        self.fetchCount += 1
        self.fetchState = .success
    }
}
