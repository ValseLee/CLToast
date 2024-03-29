//
//  PriorityQueue.swift
//
//
//  Created by Celan on 3/19/24.
//

import Foundation

struct PriorityQueue<T: Comparable> {
  fileprivate(set) var heap = [T]()
  private let ordered: (T, T) -> Bool
  
  /// Numbers of elements in Priority Queue. O(1)
  var count: Int { return heap.count }
  
  /// if the Priority Queue is empty, returns true. O(1)
  var isEmpty: Bool { return heap.isEmpty }
  
  /// Get a look at the current highest priority item, without removing it. O(1)
  ///
  /// - Returns: The element with the highest priority in the Priority Queue, or nil if the Priority Queue is empty.
  func peek() -> T? { return heap.first }
  
  /// Eliminate all of the elements from the Priority Queue, optionally replacing the order.
  mutating func clear() { heap.removeAll() }
  
  // MARK: - Lifecycle
  /// Creates a new Priority Queue with the given custom ordering function.
  ///
  /// - Parameters:
  ///   - order: A function that specifies whether its first argument should come after the second argument in the Priority Queue. Giving `<` means Max Heap, otherwise Min Heap.
  ///   - startingValues: An array of elements to initialize the PriorityQueue with.
  init(
    order: @escaping (T, T) -> Bool,
    _ startingValues: [T] = []
  ) {
    self.ordered = order
    self.heap = startingValues
    
    var parentIndex = heap.count / 2 - 1
    
    while parentIndex >= 0 {
      sink(parentIndex)
      parentIndex -= 1
    }
  }
}

extension PriorityQueue {
  // MARK: - Helpers
  /// Add a new element onto the Priority Queue. O(log n)
  ///
  /// - Parameter element: The element to be inserted into the Priority Queue.
  /// - Note: This function will **append** a element into heap Array.
  mutating func push(_ element: T) {
    heap.append(element)
    swim(heap.count - 1)
  }
  
  /// Add a new element onto a Priority Queue, limiting the size of the queue. O(n^2)
  /// If the size limit has been reached, the lowest priority element will be removed and returned.
  /// It acts like a buffer.
  ///
  /// - Parameters:
  ///   - element: The element to be inserted into the Priority Queue.
  ///   - maxCount: The Priority Queue will not grow further if its count >= maxCount.
  /// - Returns: the discarded lowest priority element, or `nil` if count < maxCount
  /// - Note: Since this is a binary heap, there is no easy way to find the lowest priority item, so this method **can be inefficient**.
  /// - Note: Also note, that only one item will be removed, even if count > maxCount by more than one.
  mutating func push(_ element: T, maxCount: Int) -> T? {
    precondition(maxCount > 0)
    
    if count < maxCount {
      push(element)
    } else if heap.count >= maxCount {
      // find the min priority element (ironically using max here)
      if let discard = heap.max(by: ordered) {
        if ordered(discard, element) { return element }
        push(element)
        remove(discard)
        return discard
      }
    }
    
    return nil
  }
  
  /// Remove and return the element with the **highest priority** or **lowest** if ascending. O(log n)
  ///
  /// - Returns: The element with the highest priority in the Priority Queue, or nil if the Priority Queue is empty.
  mutating func pop() -> T? {
    if heap.isEmpty { return nil }
    let count = heap.count
    if count == 1 { return heap.removeFirst() }
    heap.swapAt(0, heap.count - 1)
    let removeTarget = heap.removeLast()
    sink(0)
    return removeTarget
  }
  
  /// Removes the first occurence of a particular item. Finds it by value comparison using `==` O(n)
  /// Silently exits if no occurrence found.
  ///
  /// - Parameter item: The item to remove the first occurrence of.
  ///
  /// ## Example
  ///
  /// ```plain
  /// Given: heap = [1,2,3,4,5] | remove 3 | index == 2
  /// heap[idx] goes to last position (swapAt)
  /// and pops (removeLast) then rearrange the Pritority Queue.
  /// If you removed the last item, swim doesn't get called.
  /// ```
  mutating func remove(_ item: T) {
    if let index = heap.firstIndex(of: item) {
      heap.swapAt(index, heap.count - 1)
      heap.removeLast()
      
      if index < heap.count {
        swim(index)
        sink(index)
      }
    }
  }
  
  /// Removes **all occurences** of a particular item.
  /// Finds it by value comparison using ==. O(n^2)
  /// Silently exits if no occurrence found.
  ///
  /// - Parameter item: The item to remove.
  mutating func removeAll(_ item: T) {
    var lastCount = heap.count
    remove(item)
    
    while heap.count < lastCount {
      lastCount = heap.count
      remove(item)
    }
  }
}

// MARK: - swim and sink
extension PriorityQueue {
  mutating func sink(_ index: Int) {
    var index = index
    
    while index * 2 + 1 < heap.count {
      var childIndex = index * 2 + 1
      if
        childIndex < (heap.count - 1),
        ordered(heap[childIndex], heap[childIndex + 1]) { childIndex += 1 }
      
      if !ordered(heap[index], heap[childIndex]) { break }
      heap.swapAt(index, childIndex)
      index = childIndex
    }
  }
  
  mutating func swim(_ index: Int) {
    var index = index
    let parent = heap[(index - 1) / 2]
    let currentNode = heap[index]
    
    while index > 0, ordered(parent, currentNode) {
      var parentIndex = (index - 1) / 2
      heap.swapAt(parentIndex, index)
      index = parentIndex
    }
  }
}
