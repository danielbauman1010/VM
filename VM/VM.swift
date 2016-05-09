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
    var rPC: Int?
    var rCP: Int?
    var rST: Int?
    var exitCode: Int
    var stack: Stack
    enum commands {
        case halt, clrr, clrx, clrm, clrb, movir, movrr,movrm, movmr, movxr, movar, movb, addir, addrr, addmr, addxr, subir, subrr, submr, subxr, mulir, mulrr, mulmr, mulxr, divir, divrr, divmr, divxr, jmp, sojz, sojnz, aojz, aojnz, cmpir, cmprr, cmpmr, jmpn, jmpz, jmpp, jsr, ret, push, pop, stackc, outci, outcr, outcx, outcb, readi, readc, readln, movrx, movxx, printi, outs, jmpne
    }
    
    func getLineFromConsoleMac()->String{
        let BUFSIZE = 1024
        var buf = [CChar](count:BUFSIZE, repeatedValue:CChar(0))
        fgets(&buf, Int32(BUFSIZE), stdin)
        var line: String = String.fromCString(buf)!
        line = line.substringToIndex(line.endIndex.predecessor())
        return line
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
        48: commands.readi, 49: commands.printi, 50: commands.readc, 51: commands.readln,
        53: .movrx, 54: .movxx,
        55: commands.outs,
        57: commands.jmpne
    ]
    init() {
        self.memory = [Int](count: 1000, repeatedValue: 0)
        self.registers = [Int](count: 10, repeatedValue: 0)
        self.rPC = nil
        self.rCP = nil
        self.rST = nil
        self.exitCode = 0
        self.stack = Stack(size: 1000)
    }

    func processFile(var lines: [String]){
        var iterations: Int = 0
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
                        case 1: print("\nFatal Error: Devide by 0")
                        case 2: print("\nFatal Error: Attempt to access non-existent memory")
                        case 3: print("\nFatal Error: Attempt to access non-existent register")
                        case 4: print("\nFatal Error: Attempt to execute illegal operation")
                        default: print("\nProgram ended successfully")
                        }
                        
                    } else {
                        print("This program is too long for the memory to hold.")
                    }
            }
        }
        
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
                ccounter = ccounter + 1
                return ccounter
            case .jmpz:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                ccounter = ccounter + 1
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
                ccounter = ccounter + 1
                return ccounter
            case .jsr:
                ccounter = ccounter + 1
                let location = memory[ccounter]
                if location < 0 && location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                self.stack.push(registers[5])
                self.stack.push(registers[6])
                self.stack.push(registers[7])
                self.stack.push(registers[8])
                self.stack.push(registers[9])
                self.stack.push(ccounter)
                ccounter = location
                return ccounter
            case .ret:
                ccounter = self.stack.pop()!
                registers[9] = self.stack.pop()!
                registers[8] = self.stack.pop()!
                registers[7] = self.stack.pop()!
                registers[6] = self.stack.pop()!
                registers[5] = self.stack.pop()!
                ccounter = ccounter + 1
                return ccounter
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
                print("\(character)", terminator:   "")
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
                print("\(character)", terminator:   "")
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
                print("\(character)", terminator:   "")
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
                    print("\(character)", terminator:   "")
                }
                ccounter = ccounter + 1
                return ccounter
            case .readi:
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
                ccounter = ccounter + 1
                if let i: Int? = Int(self.getLineFromConsoleMac())?.hashValue{
                    registers[r1] = i!
                    registers[r2] = 0
                    return ccounter
                }
                registers[r2] = 1
                return ccounter
            case .printi:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                print("\(registers[r1])", terminator:   "")
                ccounter = ccounter + 1
                return ccounter
            case .readc:
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                if r1 < 0 || r1 > 9 {
                    exitCode = 3
                    return nil
                }
                ccounter = ccounter + 1
                let char = self.getLineFromConsoleMac() as NSString
                registers[r1] = Int(char.characterAtIndex(0))
                return ccounter
            case .readln:
                ccounter = ccounter + 1
                var location = memory[ccounter]
                ccounter = ccounter + 1
                let r1 = memory[ccounter]
                ccounter = ccounter + 1
                if r1 < 0 || r1 > 9 {
                    self.exitCode = 3
                    return nil
                }
                if location < 0 || location > self.memory.count {
                    self.exitCode = 2
                    return nil
                }
                let line = self.getLineFromConsoleMac() as NSString
                memory[location] = line.length
                registers[r1] = line.length
                location = location + 1
                for i in Range(start:   0,end:  line.length){
                    memory[location] = Int(line.characterAtIndex(i))
                    location = location + 1
                }
                
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
                    print("\(character)", terminator:   "")
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
