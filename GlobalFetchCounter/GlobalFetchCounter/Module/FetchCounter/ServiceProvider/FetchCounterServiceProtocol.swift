//
//  FetchCounterServiceProtocol.swift
//  GlobalFetchCounter
//
//  Created by Can Kurtur on 9.02.2025.
//

import Foundation
import Combine

/// A protocol defining methods for fetching data from a service.
protocol FetchCounterServiceProtocol {
    // A method to fetch the root response from the API.
    func getRoot() -> AnyPublisher<RootResponse, APIClientError>
    // A method to fetch the response code for a given path from the API.
    func getResponseCode(with path: String) -> AnyPublisher<ResponseCodeResponse, APIClientError>
}
