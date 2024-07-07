//
//  StateView.swift
//  FXSwiftX
//
//  Created by aria on 2023/3/15.
//

import SwiftUI

@available(macOS 10.15, *)
@available(iOS 13.0.0, *)
public struct StateView<Data, Success, Loading, Failure>: View where Success: View, Loading: View, Failure: View {
    
    public typealias RetryAction = () -> Void
    
    enum Phase {
      case loading
      case success(Data)
      case failure(Error)
    }
    
    let fetchData: () async throws -> Data
    let success: (Data) -> Success
    let loading: () -> Loading
    let failure: (Error, @escaping RetryAction) -> Failure
    
    @State var phase = Phase.loading
    
    var retryAction: RetryAction { { phase = .loading } }
    
    public init(
      fetchData: @escaping () async throws -> Data,
      @ViewBuilder success: @escaping (Data) -> Success,
      @ViewBuilder loading: @escaping () -> Loading,
      @ViewBuilder failure: @escaping (Error, @escaping RetryAction) -> Failure
    ) {
      self.fetchData = fetchData
      self.success = success
      self.loading = loading
      self.failure = failure
    }
    
    public var body: some View {
      Group {
        switch phase {
        case .loading:
          loading()
            .asyncTask {
              do {
                let data = try await fetchData()
                phase = .success(data)
              } catch {
                phase = .failure(error)
              }
            }
        case let .success(data):
          success(data)
        case let .failure(error):
          failure(error, retryAction)
        }
      }
    }
}
