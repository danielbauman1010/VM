//
//  Stack.swift
//  VM
//
//  Created by Daniel on 4/21/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation
class Stack {
    var items: [Int]
    let maxSize: Int
    init(size: Int) {
        self.items = [Int]()
        self.maxSize = size
    }
    
    func isEmpty()->Bool{
        return self.items.last != nil
    }
    
    func isFull()->Bool{
        return self.items.count >= self.maxSize
    }
    func push(element: Int)->Bool {
        if(!self.isFull()) {
            self.items.append(element)
            return true
        }
        return false
    }
    
    func pop()->Int? {
        return self.items.removeLast()
    }
}