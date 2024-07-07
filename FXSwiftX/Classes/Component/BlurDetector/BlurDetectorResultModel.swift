//
//  BlurDetectorResultModel.swift
//  
//
//  Created by aria on 2022/9/2.
//

import Foundation

#if os(iOS)
// MARK: BlurDetectorResultModel

@available(iOS 13.0, *)
class BlurDetectorResultModel: ObservableObject, BlurDetectorResultsDelegate {
  
  enum Mode {
    case camera
    case processing
    case resultsTable
  }
  
  @Published var blurDetectionResults = [BlurDetectionResult]()
  
  @Published var mode: Mode = .camera {
    didSet {
      if mode == .processing {
        blurDetectionResults.removeAll()
      }
      showResultsTable = mode == .resultsTable
    }
  }
  
  @Published var showResultsTable = false
  
  func itemProcessed(_ item: BlurDetectionResult) {
    blurDetectionResults.append(item)
  }
  
  func finishedProcessing() {
    // Sort results: variance of laplacian - higher is less blurry.
    blurDetectionResults.sort {
      $0.score > $1.score
    }
    
    mode = .resultsTable
  }
}

#endif
