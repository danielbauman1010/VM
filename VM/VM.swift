//
//  VM.swift
//  VM
//
//  Created by Daniel on 4/5/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation
class VM {
    var memory: [Int]
    var registers: [Int]
    var output: String
    var rPC: Int?
    var rCP: Int?
    var rST: Int?
    var retAdress: Int? //return address
    var exitCode: Int
    var stack: Stack
    enum commands {
        case halt
        case clrr, clrx, clrm, clrb
        case movir, movrr,movrm, movmr, movxr, movar, movb
        case addir, addrr, addmr, addxr
        case subir, subrr, submr, subxr
        case mulir, mulrr, mulmr, mulxr
        case divir, divrr, divmr, divxr
        case jmp
        case sojz, sojnz
        case aojz, aojnz
        case cmpir, cmprr, cmpmr
        case jmpn, jmpz, jmpp
        case jsr, ret
        case push, pop, stackc
        case outci, outcr, outcx, outcb
        case movrx, movxx
        case printi, outs
        case jmpne
    }
    var ops  = [
        0: commands.halt,
        1: commands.clrr, 2: commands.clrx, 3: commands.clrm, 4: commands.clrb,
        5: commands.movir, 6:  commands.movrr, 7:  commands.movrm, 8:  commands.movmr,
        9:  commands.movxr, 10: commands.movar, 11: commands.movb,
        12: commands.addir, 13: commands.addrr, 14: commands.addmr, 15: commands.addxr,
        16: commands.subir, 17: commands.subrr, 18: commands.submr, 19: commands.subxr,
        20: commands.mulir, 21: commands.mulrr,22: commands.mulmr,23: commands.mulxr,
        24: commands.divir, 25: commands.divrr,26: commands.divmr,27: commands.divxr,
        28: commands.jmp,
        29: commands.sojz, 30: commands.sojnz,
        31: commands.aojz, 32: commands.aojnz,
        33: commands.cmpir, 34: commands.cmprr, 35: commands.cmpmr,
        36: commands.jmpn, 37: commands.jmpz, 38: commands.jmpp,
        39: commands.jsr, 40: commands.ret,
        41: commands.push, 42: commands.pop, 43: commands.stackc,
        44: commands.outci, 45: commands.outcr, 46: commands.outcx, 47: commands.outcb,
        53: .movrx, 54: .movxx,
        49: commands.printi,
        55: commands.outs,
        57: commands.jmpne
    ]
    init() {
        self.memory = [Int](count: 1000, repeatedValue: 0)
        self.registers = [Int](count: 10, repeatedValue: 0)
        self.output = ""
        self.rPC = nil
        self.rCP = nil
        self.rST = nil
        self.exitCode = 0
        self.stack = Stack(size: 1000)
        self.retAdress = nil
    }

    func processFile(var lines: [String])->String {
        var iterations: Int = 0
        self.output = ""
        self.exitCode = 0
        if let _: Int? = Int(lines.removeFirst()) {
            if let counter = Int(lines.removeFirst()) {
                rPC = counter
                    if fillMemory(lines) {
                        while let newCounter = executeCommand(rPC!) {
                            rPC = newCounter
                            iterations++
                        }
                        
                        switch exitCode{
                        case 1: self.output += "\nFatal Error: Devide by 0"
                        case 2: self.output += "\nFatal Error: Attempt to access non-existent memory"
                        case 3: self.output += "\nFatal Error: Attempt to access non-existent register"
                        case 4: self.output += "\nFatal Error: Attempt to execute illegal operation"
                        default: self.output += "\nProgram ended successfully"
                        }
                        
                    } else {
                        print("This program is too long for the memory to hold.")
                    }
            }
        }
        /*self.output += "\nmemory:\n["
        for element in memory {
            self.output += "\(element),"
        }
        self.output += "]\n"
        self.output += "registers:\n["
        for r in registers {
            self.output += "\(r),"
        }
        self.output += "]\n"
        self.output += "special registers:\n"
        self.output += "rPC: \(self.rPC), rCP: \(rCP)\n"
        self.output += "iterations:\t\(iterations)"*/
        return self.output
    }
    
    func executeCommand(var ccounter: Int)->Int? {
        if let command = ops[memory[ccounter]] {
            switch command {
            case .halt:
                return nil
            case .clrr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = 0
                ccounter = ccounter + 1
                return ccounter
            case .clrx:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                let location = registers[r1]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                memory[location] = 0
                ccounter = ccounter + 1
                return ccounter
            case .clrm:
                ccounter = ccounter + 1
            case .clrb:
                ccounter = ccounter + 1
                let start = memory[ccounter]
                ccounter = ccounter + 1
                let duration = memory[ccounter]
                for i in Range(start: start,end: duration+start){
                    memory[i] = 0
                }
                ccounter = ccounter + 1
                return ccounter
            case .movir:
                ccounter = ccounter + 1
                let constant = memory[ccounter]
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                ccounter = ccounter + 1
                registers[r1] = constant
                return ccounter
            case .movrr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r2] = registers[r1]
                ccounter = ccounter + 1
                return ccounter
            case .movrm:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                memory[location] = registers[r1]
                return ccounter
            case .movmr:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = memory[location]
                ccounter = ccounter + 1
                return ccounter
            case .movxr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                if registers[r1] < 0 && registers[r1] > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                registers[r2] = memory[registers[r1]]
                ccounter = ccounter + 1
                return ccounter
            case .movar:
                ccounter = ccounter + 1
                let address = memory[ccounter]
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                ccounter = ccounter + 1
                registers[r1] = address
                return ccounter
            case .movb:
                ccounter = ccounter + 1
                let source = memory[ccounter]
                ccounter = ccounter + 1
                let dest = memory[ccounter]
                ccounter = ccounter + 1
                let count = memory[ccounter]
                ccounter = ccounter + 1
                for i in Range(start: source,end: source+count) {
                    memory[dest+(i-source)] = memory[i]
                }
                return ccounter
            case .addir:
                ccounter = ccounter + 1
                let constant = memory[ccounter]
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = registers[r1] + constant
                ccounter = ccounter + 1
                return ccounter
            case .addrr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r2] = registers[r1] + registers[r2]
                ccounter = ccounter + 1
                return ccounter
            case .addmr:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = registers[r1] + memory[location]
                return ccounter
            case .addxr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                if registers[r1] < 0 && registers[r1] > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                registers[r2] = registers[r2] + memory[registers[r1]]
                return ccounter
            case .subir:
                ccounter = ccounter + 1
                let constant = memory[ccounter]
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = registers[r1] - constant
                return ccounter
            case .subrr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r2] = registers[r2] - registers[r1]
                return ccounter
            case .submr:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                ccounter = ccounter + 1
                registers[r1] = registers[r1] - memory[location]
                return ccounter
            case .subxr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                if registers[r1] < 0 && registers[r1] > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                registers[r2] = registers[r2] - memory[registers[r1]]
                return ccounter
            case .mulir:
                ccounter = ccounter + 1
                let constant = memory[ccounter]
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = registers[r1] * constant
                return ccounter
            case .mulrr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r2] = registers[r2] * registers[r1]
                return ccounter
            case .mulmr:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = registers[r1] * memory[location]
                return ccounter
            case .mulxr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                if registers[r1] < 0 && registers[r1] > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                registers[r2] = registers[r2] * memory[registers[r1]]
                return ccounter
            case .divir:
                ccounter = ccounter + 1
                let constant = memory[ccounter]
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if constant == 0 {
                    self.exitCode = 1
                    return nil
                }
                registers[r1] = registers[r1] / constant
                return ccounter
            case .divrr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                if registers[r1] == 0 {
                    self.exitCode = 1
                    return nil
                }
                registers[r2] = registers[r2] / registers[r1]
                return ccounter
            case .divmr:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if memory[location] == 0 {
                    self.exitCode = 1
                    return nil
                }
                registers[r1] = registers[r1] / memory[location]
                return ccounter
            case .divxr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                if registers[r1] < 0 && registers[r1] > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                if memory[registers[r1]] == 0 {
                    self.exitCode = 1
                    return nil
                }
                registers[r2] = registers[r2] / memory[registers[r1]]
                return ccounter
            case .jmp:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = location
                return ccounter
            case .sojz:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                registers[r1] = registers[r1] - 1
                if registers[r1] == 0 {
                    ccounter = location
                }
                return ccounter
            case .sojnz:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = registers[r1] - 1
                if registers[r1] != 0 {
                    ccounter = location
                }
                return ccounter
            case .aojz:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = registers[r1] + 1
                if registers[r1] == 0 {
                    ccounter = location
                }
                return ccounter
            case .aojnz:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                registers[r1] = registers[r1] + 1
                if registers[r1] != 0 {
                    ccounter = location
                }
                return ccounter
            case .cmpir:
                ccounter = ccounter + 1
                let constant = memory[ccounter]
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                ccounter = ccounter + 1
                let result = registers[r1] - constant
                self.rCP = result
                return ccounter
            case .cmprr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                let result = registers[r2] - registers[r1]
                self.rCP = result
                ccounter = ccounter + 1
                return ccounter
            case .cmpmr:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                let result = registers[r1] - memory[location]
                self.rCP = result
                return ccounter
            case .jmpn:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                if self.rCP < 0 {
                    ccounter = location
                }
                return ccounter
            case .jmpz:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                if self.rCP == 0 {
                    ccounter = location
                }
                return ccounter
            case .jmpp:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                if self.rCP > 0 {
                    ccounter = location
                }
                return ccounter
            case .jsr:
                self.retAdress = ccounter
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                for r in Range(start: 5,end: 9){
                    self.stack.push(registers[r])
                }
                ccounter = location
                return ccounter
            case .ret:
                if self.retAdress == nil{
                    self.output += "Fatal error: trying to return without entering a subroutine"
                    return nil
                }
                for r in Range(start: 9,end: 5){
                    registers[r] = self.stack.pop()!
                }
                ccounter = self.retAdress!
            case .push:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    self.exitCode = 3
                    return nil
                }
                if self.stack.push(registers[r1]) {
                    self.rST = 0
                } else {
                    self.rST = 1
                }
                ccounter = ccounter + 1
                return ccounter
            case .pop:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    self.exitCode = 3
                    return nil
                }
                if let result = self.stack.pop() {
                    registers[r1] = result
                    self.rST = 0
                } else {
                    self.rST = 2
                }
                ccounter = ccounter + 1
                return ccounter
            case .stackc:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    self.exitCode = 3
                    return nil
                }
                registers[r1] = rST!
            case .outci:
                ccounter = ccounter + 1
                let char = memory[ccounter]
                let character = "\(String(UnicodeScalar(char)))"
                self.output += character
                ccounter = ccounter + 1
                return ccounter
            case .outcr:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                let character = "\(String(UnicodeScalar(registers[r1])))"
                self.output += character
                ccounter = ccounter + 1
                return ccounter
            case .outcx:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                if registers[r1] < 0 || registers[r1] > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                let character = "\(String(UnicodeScalar(memory[registers[r1]])))"
                self.output += character
                ccounter = ccounter + 1
                return ccounter
            case .outcb:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                if r2 < 0 || r2 > 9 {
                    exitCode = 3
                    return nil
                }
                if registers[r1] < 0 || registers[r1] > memory.count {
                    self.exitCode = 2
                    return nil
                }
                if registers[r2] < 0 || registers[r2] > memory.count {
                    self.exitCode = 2
                    return nil
                }
                for i in Range(start: registers[r1], end: registers[r1]+registers[r2]) {
                    let character = "\(String(UnicodeScalar(memory[i])))"
                    self.output += character
                }
                ccounter = ccounter + 1
                return ccounter
            case .printi:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                self.output += "\(registers[r1])"
                ccounter = ccounter + 1
                return ccounter
            case .movrx:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                if r1 < 0 || r1 > 9 || r2 < 0 || r2 > 9 {
                    self.exitCode = 3
                    return nil
                }
                if registers[r2] < 0 || registers[r2] > self.memory.count {
                        self.exitCode = 2
                        return nil
                }
                ccounter = ccounter + 1
                memory[registers[r2]] = registers[r1]
                return ccounter
            case .movxx:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                let r2 = memory[ccounter]
                if r1 < 0 || r1 > 9 || r2 < 0 || r2 > 9 {
                    self.exitCode = 3
                    return nil
                }
                if registers[r1] < 0 || registers[r1] > self.memory.count
                    || registers[r2] < 0 || registers[r2] > self.memory.count {
                        self.exitCode = 2
                        return nil
                }
                ccounter = ccounter + 1
                memory[registers[r2]] = memory[registers[r1]]
                return ccounter
            case .outs:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                let newcounter = location
                let length = memory[newcounter]
                let beginning = location + 1
                let end = beginning + length
                for counter in beginning...end {
                    let charascii = memory[counter]
                    let character = String(UnicodeScalar(charascii))
                    self.output += character
                }
                ccounter = ccounter + 1
                return ccounter
            case .jmpne:
                if let result = rCP {
                    ccounter = ccounter + 1
                    let location = memory[ccounter]
                    if result != 0 {
                        ccounter = location
                        return ccounter
                    }
                    ccounter = ccounter + 1
                    return ccounter
                }
            }
        }
        self.exitCode = 4
        return nil
    }
    func fillMemory(newMemory: [String])->Bool {
        if newMemory.count <= self.memory.count {
            self.memory.removeAll()
            var memoryAsInt = [Int]()
            for element in newMemory {
                memoryAsInt.append(Int(element)!)
            }
            self.memory.appendContentsOf(memoryAsInt)
            return true
        }
        return false
    }
    }
