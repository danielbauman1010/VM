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
    init() {
        self.tokenizer = Tokenizer()
        self.binFile = []
        self.listFile = []
        self.symFile = []
        self.symbolTable = [String: Int?]()
        self.errorCounter = 0
    }
    func assmeble(var lines: [String]){
        binFile.removeAll()
        symFile.removeAll()
        listFile.removeAll()
        self.errorCounter = 0
        lines = lines.filter({$0 != ""})
        for line in lines {
            listFile.append(line)
            let tokens = tokenizer.tokenize(line)
            if tokens.count > 0 {
                switch tokens[0].type {
                case .LabelDefinition:
                    symbolTable[tokens[0].stringValue!] = binFile.count
                    
                case .Directive:
                    
                case .Instruction:
                default: listFile.append("............A line must start with a label definition, a directive, or an instruction.")
                }
            }
        }
    }
    
}