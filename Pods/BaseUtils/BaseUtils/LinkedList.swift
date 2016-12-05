//
//  LinkedList.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 12/4/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

fileprivate class Node<T: Comparable> {
    
    init(value: T) {
        self.value = value
    }
    
    var value: T
    var prev: Node<T>?
    var next: Node<T>?
}

open class LinkedList<T: Comparable> {
    
    fileprivate var head: Node<T>?
    fileprivate var tail: Node<T>?
    
    fileprivate var count: Int
    
    public init() {
        count = 0
    }
    
    fileprivate func find(nodeWithValue value: T) -> Node<T>? {
        var currNode = self.head
        
        while (currNode != nil) {
            if (currNode!.value == value) { return currNode }
            
            currNode = currNode!.next
        }
        return nil
    }
    
    fileprivate func remove(nodeWithValue value: T) -> Node<T>? {
        guard let targetNode = self.find(nodeWithValue: value) else {
            return nil
        }
        
        
        let prev = targetNode.prev
        let next = targetNode.next
        
        // Correct the head and tail pointers
        if (targetNode === head) { self.head = next }
        if (targetNode === tail) { self.tail = prev }
        
        // 'Cut out' the target node
        prev?.next = next
        next?.prev = prev
        
        // Remove the references to linked list from the target node
        targetNode.prev = nil
        targetNode.next = nil
        
        return targetNode
    }
    
    
    open var uniqueValues = true
    
    open func addOrMove(value: T) {
        var node: Node<T>!
        
        if (uniqueValues) {
             node = self.remove(nodeWithValue: value)
        }
        
        if (node == nil) {
            node = Node<T>(value: value)
            count += 1
        }
        
        // Add to the tail
        node.prev = self.tail
        self.tail = node
        
        if (head == nil) {
            self.head = node
        }
        
    }
    
    open func remove(value: T) {
        while (remove(nodeWithValue: value) != nil) {
            count -= 1
        }
    }
    
    open func pop() -> T? {
        guard let head = self.head else {
            return nil
        }
        
        self.head = head.next
        count -= 1
        return head.value
    }
    
    open func length() -> Int {
        return count
    }
    
}
