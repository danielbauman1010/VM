//
//  Debugger.swift
//  VM
//
//  Created by Daniel on 6/12/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation
protocol DebuggerHelper{
    func getMemoryAtAddress(address: Int)->Int
    func setMemoryAtAddress(address: Int, value: Int)
    func getRegisterNumber(number: Int)->Int
    func setRegisterNumber(number: Int, value: Int)
    func getPC()->Int
    func setPC(value: Int)
}
class Debugger {
    let helper: DebuggerHelper
    init(helper: DebuggerHelper) {
        self.helper = helper
    }
}