//
//  Assembler.swift
//  VM
//
//  Created by Daniel on 5/28/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation
class Assembler {
    var tokenizer: Tokenizer
    var binFile: [String]
    var listFile: [String]
    var symFile: [String]
    var symbolTable: [String: Int?]
    var errorCounter: Int
    var secondPass: Bool
    var done: Bool
    var length: Int
    init() {
        self.tokenizer = Tokenizer()
        self.binFile = []
        self.listFile = []
        self.symFile = []
        self.symbolTable = [String: Int?]()
        self.errorCounter = 0
        self.secondPass = false
        self.done = false
        self.length = 0
    }
    func assemble(var lines: [String], filename: String){
        binFile.removeAll()
        listFile.removeAll()
        if !self.secondPass {
            symFile.removeAll()
            self.length = 0
            binFile.append("PlaceHolder")
        } else {
            binFile.append("\(self.length)")
        }
        
        self.errorCounter = 0
        lines = lines.filter({$0 != ""})
        for line in lines {
            listFile.append(line)
            if !done {
                let tokens = tokenizer.tokenize(line)
                if tokens.count > 0 {
                    switch tokens[0].type {
                    case .LabelDefinition:
                        handleLabelDefinition(tokens)
                    case .Directive:
                        handleDirective(tokens)
                    case .Instruction:
                        handleInstruction(tokens)
                    default: listFile.append("............A line must start with a label definition, a directive, or an instruction.")
                    self.errorCounter = self.errorCounter + 1
                    }
                }
            }
        }
        if !self.secondPass {
            if (self.errorCounter == 0 && symTableDone())  {
                self.secondPass = true
                var symbolOutput = ""
                for (label, location) in symbolTable {
                    symbolOutput += "\(label) \(location!)\n"
                }
                writeTextFileMac("\(filename).sym", data: symbolOutput)
                self.done = false
                self.length = binFile.count-2
                self.assemble(lines, filename: filename)
            } else {
                if !symTableDone() {
                    self.errorCounter = self.errorCounter + 1
                    self.listFile.append("not all labels are declared")
                }
                print("found \(self.errorCounter) errors, see list file for details")
            }
        } else {
            self.secondPass = false
            var binOutput = ""
            for b in binFile {
                binOutput = binOutput + "\(b)\n"
            }
            writeTextFileMac("\(filename).bin", data: binOutput)
            print("Assemble was successful, bin file created")
        }
        var listOutput = ""
        for l in listFile {
            listOutput += "\(l)\n"
        }
        writeTextFileMac("\(filename).lst", data: listOutput)
    }
    func handleLabelDefinition(var tokens: [Token]) {
        symbolTable[tokens[0].stringValue!] = self.binFile.count-2
        tokens = Array(tokens.dropFirst())
        if tokens.count > 0 {
            switch tokens[0].type {
            case .Directive:
                handleDirective(tokens)
            case .Instruction:
                handleInstruction(tokens)
            default: listFile.append("............expecting a directive, or an instruction.")
                    self.errorCounter = self.errorCounter + 1
            }
        }
    }
    func handleDirective(tokens: [Token]) {
        var success = false
        switch tokens[0].stringValue!{
        case "integer":
            if checkForToken(tokens, types: [.Directive, .ImmediateInteger]) {
                success = true
                binFile.append("\(tokens[1].intValue!)")
            }
        case "string":
            if checkForToken(tokens, types: [.Directive, .ImmediateString]) {
                success = true
                binFile.append("\(tokens[1].stringValue!.characters.count)")
                for i in tokens[1].stringValue!.characters {
                    binFile.append("\(String(i).utf8.first!)")
                }
            }
        case "tuple":
            if checkForToken(tokens, types: [.Directive, .ImmediateTuple]) {
                success = true
                let t = tokens[1].tupleValue!
                binFile.append("\(t.CurrentState)")
                binFile.append("\(t.InputCharacter)")
                binFile.append("\(t.NewState)")
                binFile.append("\(t.OutputCharacter)")
                binFile.append("\(t.Direction)")
            }
        case "start":
            if checkForToken(tokens,types: [.Directive, .Label]) {
                success = true
                if secondPass {
                    binFile.append("\(symbolTable[tokens[1].stringValue!]!!)")
                } else {
                    newLabel(tokens[1].stringValue!)
                    binFile.append("PlaceHolder")
                }
            }
        case "end":
            if checkForToken(tokens, types: [.Directive]) {
                success = true
                self.done = true
            }
        default:
            success = false
        }
        if !success {
            self.errorCounter = self.errorCounter + 1
            self.listFile.append("............expected value to match the directive")
        }
    }
    func checkForToken(tokens: [Token], types: [TokenType])->Bool {
        if tokens.count != types.count {
            return false
        }
        for i in Range(start: 0, end: tokens.count) {
            if tokens[i].type != types[i] {
                return false
            }
        }
        return true
    }
    func handleInstruction(tokens: [Token]) {
        var success = false
        if let instruction = stringToCommand[tokens[0].stringValue!] {
            switch instruction {
            case .halt, .ret, .brk, .nop:
                if checkForToken(tokens, types: [.Instruction]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                }
            case .clrr, .clrx, .push, .pop, .stackc, .outcr, .outcx, .printi, .readc:
                if checkForToken(tokens, types: [.Instruction, .Register]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                    binFile.append("\(tokens[1].intValue!)")
                }
            case .clrm, .jmp, .jmpn, .jmpz, .jmpp, .jsr, .jmpne, .outs:
                if checkForToken(tokens, types: [.Instruction, .Label]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                    if secondPass {
                        binFile.append("\(symbolTable[tokens[1].stringValue!]!!)")
                    } else {
                        binFile.append("PlaceHolder")
                        newLabel(tokens[1].stringValue!)
                    }
                }
            case .clrb, .movrr, .movxr, .addrr, .addxr, .subrr, .subxr, .mulrr, .mulxr, .divrr, .divxr, .cmprr, .outcb, .movrx, .movxx, .readi:
                if checkForToken(tokens, types: [.Instruction, .Register, .Register]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                    binFile.append("\(tokens[1].intValue!)")
                    binFile.append("\(tokens[2].intValue!)")
                }
            case .movir, .addir, .subir, .mulir, .divir, .cmpir:
                if checkForToken(tokens, types: [.Instruction, .ImmediateInteger, .Register]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                    binFile.append("\(tokens[1].intValue!)")
                    binFile.append("\(tokens[2].intValue!)")
                }
            case .movrm, .sojz, .sojnz, .aojz, .aojnz:
                if checkForToken(tokens, types: [.Instruction, .Register, .Label]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                    binFile.append("\(tokens[1].intValue!)")
                    if secondPass {
                        binFile.append("\(symbolTable[tokens[2].stringValue!]!!)")
                    } else {
                        binFile.append("PlaceHolder")
                        newLabel(tokens[2].stringValue!)
                    }
                }
            case .movmr, .movar, .addmr, .submr, .mulmr, .divmr, .cmpmr, .readln:
                if checkForToken(tokens, types: [.Instruction, .Label, .Register]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                    if secondPass {
                        binFile.append("\(symbolTable[tokens[1].stringValue!]!!)")
                    } else {
                        binFile.append("PlaceHolder")
                        newLabel(tokens[1].stringValue!)
                    }
                    binFile.append("\(tokens[2].intValue!)")
                }
            case .movb:
                if checkForToken(tokens, types: [.Instruction, .Register, .Register, .Register]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                    binFile.append("\(tokens[1].intValue!)")
                    binFile.append("\(tokens[2].intValue!)")
                    binFile.append("\(tokens[3].intValue!)")
                }
            case .outci:
                if checkForToken(tokens, types: [.Instruction, .ImmediateInteger]) {
                    success = true
                    binFile.append("\(commandToNumber()[instruction]!)")
                    binFile.append("\(tokens[1].intValue!)")
                }
            
            }
        }
        if !success {
            self.errorCounter = self.errorCounter + 1
            listFile.append("............Variables do not match the instruction's requirements")
        }
    }
    func newLabel(label: String) {
        if !symbolTable.keys.contains(label) {
            symbolTable[label] = Optional(nil)
        }
    }
    func symTableDone()->Bool{
        for (_,location) in symbolTable {
            if location == nil {
                return false
            }
        }
        return true
    }
}