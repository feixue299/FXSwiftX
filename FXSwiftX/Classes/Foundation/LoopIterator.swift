//
//  LoopIterator.swift
//  
//
//  Created by aria on 2024/8/18.
//

import Foundation

public struct LoopIterator<Base: Collection>: IteratorProtocol {

    public let collection: Base
    private var index: Base.Index

    public init(collection: Base) {
        self.collection = collection
        self.index = collection.startIndex
    }

    public mutating func next() -> Base.Iterator.Element? {
        guard !collection.isEmpty else {
            return nil
        }

        let result = collection[index]
        collection.formIndex(after: &index) // (*) See discussion below
        if index == collection.endIndex {
            index = collection.startIndex
        }
        return result
    }
}
