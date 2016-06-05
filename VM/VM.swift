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
        self.exitCode = 0
        if let _: Int? = Int(lines.removeFirst()) {
            if let counter = Int(lines.removeFirst()) {
                rPC = counter
                if fillMemory(lines) {
                    while executeCommand() {
                        rPC = rPC! + 1
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
    func readmem()->Int{
        self.rPC = self.rPC! + 1
        let result = memory[self.rPC!]
        return result
    }
    func getregister(r: Int)->Int?{
        if (r >= 0 && r < 10) {
            return registers[r]
        }
        self.exitCode = 3
        return nil
    }
    func getmemory(location: Int)->Int?{
        if (location >= 0 && location < memory.count) {
            return memory[location]
        }
        
        return nil
    }
    func executeCommand()->Bool {
        if let command = numberToCommand[memory[rPC!]] {
            switch command {
            case .halt:
                return false
            case .clrr:
                let r1 = readmem()
                if let _ = getregister(r1) {
                    registers[r1] = 0
                } else {
                    self.exitCode = 3
                    return false
                }
            case .clrx:
                let r1 = readmem()
                if let location = getregister(r1) {
                    if let _ = getmemory(location) {
                        memory[location] = 0
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .clrm:
                let location = readmem()
                if let _ = getmemory(location) {
                    memory[location] = 0
                } else {
                    self.exitCode = 2
                    return false
                }
            case .clrb:
                let start = readmem()
                let duration = readmem()
                for i in Range(start: start,end: duration+start){
                    memory[i] = 0
                }
            case .movir:
                let constant = readmem()
                let r1 = readmem()
                if let _ = getregister(r1) {
                    registers[r1] = constant
                } else {
                    self.exitCode = 3
                    return false
                }
            case .movrr:
                let r1 = readmem()
                let r2 = readmem()
                if let _ = getregister(r2) {
                    if let value = getregister(r1) {
                        registers[r2] = value
                    } else {
                        self.exitCode = 3
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .movrm:
                let r1 = readmem()
                let location = readmem()
                if let value = getregister(r1) {
                    if let _ = getmemory(location) {
                        memory[location] = value
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .movmr:
                let location = readmem()
                let r1 = readmem()
                if let value = getmemory(location) {
                    if let _ = getregister(r1) {
                        registers[r1] = value
                    } else {
                        self.exitCode = 3
                        return false
                    }
                } else {
                    self.exitCode = 2
                    return false
                }
            case .movxr:
                let r1 = readmem()
                let r2 = readmem()
                if let location = getregister(r1) {
                    if let value = getmemory(location) {
                        if let _ = getregister(r2) {
                            registers[r2] = value
                        } else {
                            self.exitCode = 2
                            return false
                        }
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .movar:
                let address = readmem()
                let r1 = readmem()
                if let _ = getregister(r1) {
                    registers[r1] = address
                }
            case .movb:
                let source = readmem()
                let dest = readmem()
                let count = readmem()
                for i in Range(start: source,end: source+count) {
                    memory[dest+(i-source)] = memory[i]
                }
            case .addir:
                let constant = readmem()
                let r1 = readmem()
                if let value = getregister(r1) {
                    registers[r1] = value + constant
                } else {
                    self.exitCode = 3
                    return false
                }
            case .addrr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        registers[r2] = valr1 + valr2
                    } else {
                        exitCode = 3
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .addmr:
                let location = readmem()
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    if let value = getmemory(location) {
                        registers[r1] = valr1 + value
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .addxr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        if let value = getmemory(valr1) {
                            registers[r2] = valr2 + value
                        } else {
                            self.exitCode = 2
                            return false
                        }
                    } else {
                        exitCode = 3
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .subir:
                let constant = readmem()
                let r1 = readmem()
                if let value = getregister(r1) {
                    registers[r1] = value - constant
                } else {
                    self.exitCode = 3
                    return false
                }
            case .subrr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        registers[r2] = valr2 - valr1
                    } else {
                        exitCode = 3
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .submr:
                let location = readmem()
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    if let value = getmemory(location) {
                        registers[r1] = valr1 - value
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .subxr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        if let value = getmemory(valr1) {
                            registers[r2] = valr2 - value
                        } else {
                            self.exitCode = 2
                            return false
                        }
                    } else {
                        exitCode = 3
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .mulir:
                let constant = readmem()
                let r1 = readmem()
                if let value = getregister(r1) {
                    registers[r1] = value * constant
                } else {
                    self.exitCode = 3
                    return false
                }
            case .mulrr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        registers[r2] = valr1 * valr2
                    } else {
                        exitCode = 3
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .mulmr:
                let location = readmem()
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    if let value = getmemory(location) {
                        registers[r1] = valr1 * value
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .mulxr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        if let value = getmemory(valr1) {
                            registers[r2] = valr2 * value
                        } else {
                            self.exitCode = 2
                            return false
                        }
                    } else {
                        exitCode = 3
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .divir:
                let constant = readmem()
                let r1 = readmem()
                if let value = getregister(r1) {
                    if constant != 0 {
                        registers[r1] = value / constant
                    } else {
                        self.exitCode = 1
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .divrr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        registers[r2] = valr2 / valr1
                    } else {
                        exitCode = 3
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .divmr:
                let location = readmem()
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    if let value = getmemory(location) {
                        registers[r1] = valr1 / value
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .divxr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        if let value = getmemory(valr1) {
                            registers[r2] = valr2 / value
                        } else {
                            self.exitCode = 2
                            return false
                        }
                    } else {
                        exitCode = 3
                        return false
                    }
                } else {
                    exitCode = 3
                    return false
                }
            case .jmp:
                let location = readmem()
                if let _ = getmemory(location) {
                    rPC = location - 1
                } else {
                    self.exitCode = 2
                    return false
                }
            case .sojz:
                let r1 = readmem()
                let location = readmem()
                if let valr1 = getregister(r1) {
                    registers[r1] = valr1 - 1
                } else {
                    self.exitCode = 3
                    return false
                }
                if let _ = getmemory(location) {
                    if registers[r1] == 0 {
                        rPC = location - 1
                    }
                } else {
                    self.exitCode = 2
                    return false
                }
            case .sojnz:
                let r1 = readmem()
                let location = readmem()
                if let valr1 = getregister(r1) {
                    registers[r1] = valr1 - 1
                } else {
                    self.exitCode = 3
                    return false
                }
                if let _ = getmemory(location) {
                    if registers[r1] != 0 {
                        rPC = location - 1
                    }
                } else {
                    self.exitCode = 2
                    return false
                }
            case .aojz:
                let r1 = readmem()
                let location = readmem()
                if let valr1 = getregister(r1) {
                    registers[r1] = valr1 + 1
                } else {
                    self.exitCode = 3
                    return false
                }
                if let _ = getmemory(location) {
                    if registers[r1] == 0 {
                        rPC = location - 1
                    }
                } else {
                    self.exitCode = 2
                    return false
                }
            case .aojnz:
                let r1 = readmem()
                let location = readmem()
                if let valr1 = getregister(r1) {
                    registers[r1] = valr1 + 1
                } else {
                    self.exitCode = 3
                    return false
                }
                if let _ = getmemory(location) {
                    if registers[r1] != 0 {
                        rPC = location - 1
                    }
                } else {
                    self.exitCode = 2
                    return false
                }
            case .cmpir:
                let constant = readmem()
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    let result = valr1 - constant
                    self.rCP = result
                } else {
                    self.exitCode = 3
                    return false
                }
            case .cmprr:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        let result = valr2 - valr1
                        self.rCP = result
                    } else {
                        self.exitCode = 3
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .cmpmr:
                let location = readmem()
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    if let value = getmemory(location) {
                        let result = valr1 - value
                        self.rCP = result
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .jmpn:
                let location = readmem()
                if let _ = getmemory(location) {
                    if self.rCP < 0 {
                        rPC = location - 1
                    }
                } else {
                    self.exitCode = 2
                    return false
                }
            case .jmpz:
                let location = readmem()
                if let _ = getmemory(location) {
                    if self.rCP == 0 {
                        rPC = location - 1
                    }
                } else {
                    self.exitCode = 2
                    return false
                }
            case .jmpp:
                let location = readmem()
                if let _ = getmemory(location) {
                    if self.rCP > 0 {
                        rPC = location - 1
                    }
                } else {
                    self.exitCode = 2
                    return false
                }
            case .jsr:
                let location = readmem()
                if let _ = getmemory(location) {
                    self.stack.push(registers[5])
                    self.stack.push(registers[6])
                    self.stack.push(registers[7])
                    self.stack.push(registers[8])
                    self.stack.push(registers[9])
                    self.stack.push(rPC!)
                    rPC = location - 1
                } else {
                    self.exitCode = 2
                    return false
                }
            case .ret:
                rPC = self.stack.pop()!
                registers[9] = self.stack.pop()!
                registers[8] = self.stack.pop()!
                registers[7] = self.stack.pop()!
                registers[6] = self.stack.pop()!
                registers[5] = self.stack.pop()!
            case .push:
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    if self.stack.push(valr1) {
                        self.rST = 0
                    } else {
                        self.rST = 1
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .pop:
                let r1 = readmem()
                if let result = self.stack.pop() {
                    if let _ = getregister(r1) {
                        registers[r1] = result
                        self.rST = 0
                    } else {
                        self.exitCode = 3
                        return false
                    }
                } else {
                    self.rST = 2
                }
            case .stackc:
                let r1 = readmem()
                if let _ = getregister(r1) {
                    registers[r1] = rST!
                } else {
                    self.exitCode = 3
                    return false
                }
            case .outci:
                let char = readmem()
                let character = "\(String(UnicodeScalar(char)))"
                print("\(character)", terminator:   "")
            case .outcr:
                let r1 = readmem()
                if let _ = getregister(r1) {
                    let character = "\(String(UnicodeScalar(registers[r1])))"
                    print("\(character)", terminator:   "")
                } else {
                    self.exitCode = 3
                    return false
                }
            case .outcx:
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    if let value = getmemory(valr1) {
                        let character = "\(String(UnicodeScalar(value)))"
                        print("\(character)", terminator:   "")
                    } else {
                        self.exitCode = 2
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .outcb:
                let r1 = readmem()
                let r2 = readmem()
                for i in Range(start: registers[r1], end: registers[r1]+registers[r2]) {
                    let character = "\(String(UnicodeScalar(memory[i])))"
                    print("\(character)", terminator:   "")
                }
            case .printi:
                let r1 = readmem()
                if let valr1 = getregister(r1) {
                    print("\(valr1)", terminator:   "")
                } else {
                    self.exitCode = 3
                    return false
                }
            case .movrx:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        if let _ = getmemory(valr2) {
                            memory[valr2] = valr1
                        } else {
                            self.exitCode = 2
                            return false
                        }
                    } else {
                        self.exitCode = 3
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .movxx:
                let r1 = readmem()
                let r2 = readmem()
                if let valr1 = getregister(r1) {
                    if let valr2 = getregister(r2) {
                        if let _ = getmemory(valr2) {
                            if let value = getmemory(valr1) {
                                memory[valr2] = value
                            } else {
                                self.exitCode = 2
                                return false
                            }
                        } else {
                            self.exitCode = 2
                            return false
                        }
                    } else {
                        self.exitCode = 3
                        return false
                    }
                } else {
                    self.exitCode = 3
                    return false
                }
            case .outs:
                let location = readmem()
                if let value = getmemory(location) {
                    let length = value
                    let beginning = location + 1
                    let end = beginning + length
                    for counter in beginning...end {
                        let charascii = memory[counter]
                        let character = String(UnicodeScalar(charascii))
                        print("\(character)", terminator:   "")
                    }
                }
            case .jmpne:
                if let result = rCP {
                    let location = readmem()
                    if result != 0 {
                        rCP = location - 1
                    }
                }
            }
            return true
        }
        self.exitCode = 4
        return false
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
