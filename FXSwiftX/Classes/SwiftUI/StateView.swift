//
//  StateView.swift
//  FXSwiftX
//
//  Created by aria on 2023/3/15.
//

import SwiftUI

@available(iOS 13.0.0, *)
public struct StateView<Data, Success, Loading, Failure>: View where Success: View, Loading: View, Failure: View {
    
    public struct RetryAction {
      let action: () -> Void

      public func callAsFunction() {
        action()
      }
    }
    
    enum Phase {
      case loading
      case success(Data)
      case failure(Error)
    }
    
    let fetchData: () async throws -> Data
    let success: (Data) -> Success
    let loading: () -> Loading
    let failure: (Error, RetryAction) -> Failure
    
    @State var phase = Phase.loading
    
    var retryAction: RetryAction {
      RetryAction { phase = .loading }
    }
    
    public init(
      fetchData: @escaping () async throws -> Data,
      @ViewBuilder success: @escaping (Data) -> Success,
      @ViewBuilder loading: @escaping () -> Loading,
      @ViewBuilder failure: @escaping (Error, RetryAction) -> Failure
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

@available(iOS 13.0.0, *)
struct StateView_Previews: PreviewProvider {
    static var previews: some View {
        StateView {
            do {
                try await Task.sleep(nanoseconds: 3_000_000_000)
            } catch {}
            return "Success"
        } success: { (text: String) in
            Text(text)
                .lineLimit(1)
        } loading: {
            Text("Loading")
        } failure: { _, retry in
            Button {
                retry()
            } label: {
                Text("Retry")
            }
        }

    }
}
