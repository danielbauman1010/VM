//
//  Tokenizer.swift
//  VM
//
//  Created by Daniel on 5/28/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation
class Tokenizer {
    var tokens: [Token]
    init() {
        tokens = [Token]()
    }
    func tokenize(input: String)->[Token] {
        tokens.removeAll()
        let chunks: [String] = makeChunks(input)
        for c in chunks {
            if c.startsWith("r") {
                let r = handleRegister(c)
                tokens.append(r)
            } else if c.startsWith("\"") && c.last == "\"" {
                let _ = c.dropLast()
                let _ = c.dropFirst()
                var stringToken = Token(type: .ImmediateString)
                stringToken.stringValue = c
                tokens.append(stringToken)
            } else if c.startsWith("#") {
                let ii = hanleImmediateInteger(c)
                tokens.append(ii)
            } else if c.startsWith("\\") && c.last == "\\" {
                let t = handleTuple(c)
                tokens.append(t)
            } else if c.startsWith(".") {
                let d = handleDirective(c)
                tokens.append(d)
            }
            else if c.last == ":" {
                let ld = handleLabelDefinition(c)
                tokens.append(ld)
            } else {
                let iol = handleInstructionOrLabel(c)
                tokens.append(iol)
            }
        }
        return tokens
    }
    func handleInstructionOrLabel(iol: String)->Token{
        if stringToCommand.keys.contains(iol) {
            var iToken = Token(type: .Instruction)
            iToken.stringValue = iol
            return iToken
        }
        var lToken = Token(type: .Label)
        lToken.stringValue = iol
        return lToken
    }
    func handleDirective(var d: String)->Token {
        d = d.dropFirst()
        var dToken: Token
        switch d {
        case "Integer":
            dToken = Token(type: .Directive)
            dToken.directiveType = .Integer
        case "String":
            dToken = Token(type: .Directive)
            dToken.directiveType = .String
        case "Tuple":
            dToken = Token(type: .Directive)
            dToken.directiveType = .Tuple
        case "Start":
            dToken = Token(type: .Directive)
            dToken.directiveType = .Start
        case "end":
            dToken = Token(type: .Directive)
            dToken.directiveType = .end
        default:
            dToken = Token(type: .BadToken)
        }
        return dToken
    }
    func handleTuple(var tuple: String)->Token{
        tuple = tuple.dropFirst()
        tuple = tuple.dropLast()
        var tArr = tuple.componentsSeparatedByString(" ")
        tArr = tArr.filter{$0 != ""}
        if tArr.count == 5 {
            if let s = Int(tArr[0]) {
                if let i = tArr[1].unicodeScalars.first?.value {
                    if let n = Int(tArr[2]) {
                        if let o = tArr[3].unicodeScalars.first?.value {
                            if tArr[4] == "r" || tArr[4] == "l" {
                                var d: Int
                                if tArr[4] == "r" {
                                    d = 1
                                } else {
                                    d = -1
                                }
                                let t = Tuple(CurrentState: s, InputCharacter: Int(i), NewState: n, OutputCharacter: Int(o), Direction: d)
                                var tToken = Token(type: .ImmediateTuple)
                                tToken.tupleValue = t
                                return tToken
                            }
                        }
                    }
                }
            }
        }
        return Token(type: .BadToken)
    }
    
    func hanleImmediateInteger(var ii: String)->Token {
        ii = ii.dropFirst()
        var iiToken: Token
        if let value = Int(ii) {
            iiToken = Token(type: .ImmediateInteger)
            iiToken.intValue = value
            return iiToken
        }
        iiToken = Token(type: .BadToken)
        return iiToken
    }
    func handleLabelDefinition(var ld: String)->Token{
        ld = ld.dropLast()
        var ldToken = Token(type: .LabelDefinition)
        ldToken.stringValue = ld
        return ldToken
    }
    func handleRegister(var register: String)-> Token{
        register = register.dropFirst()
        var rToken: Token
        if let r = Int(register) {
            rToken = Token(type: .Register)
            rToken.intValue = r
            return rToken
        }
        rToken = Token(type: .BadToken)
        return rToken
    }
    func makeChunks(input: String)->[String]{
        var chunks = [String]()
        let notabs = input.stringByReplacingOccurrencesOfString("\t", withString: " ")
        var splitspace = notabs.componentsSeparatedByString(" ")
        splitspace = splitspace.filter({$0 != ""})
        var i = 0
        while i < (splitspace.count) {
            if splitspace[i].containsString("\"") {
                let (result, newI) = makeChunksH(splitspace, current: i, character: "\"")
                i = newI + 1
                chunks.append(result)
            } else if splitspace[i].containsString("\\") {
                let (result, newI) = makeChunksH(splitspace, current: i, character: "\\")
                i = newI + 1
                chunks.append(result)
            } else {
                chunks.append(splitspace[i])
            }
            i++
        }
        return chunks
    }
    func makeChunksH(input: [String], current: Int, character: String)->(String,Int){
        var resultString: String = ""
        var resultLocation: Int = current
        resultString += input[current] + " "
        for i in Range(start: (current+1), end: (input.count)) {
            if input[i].containsString(character) {
                resultString += input[i]
                resultLocation = i
                return (resultString, resultLocation+1)
            } else {
                resultString += input[i]
                resultString += " "
            }
        }
        return (resultString, resultLocation)
    }
}
enum TokenType {
    case Register
    case LabelDefinition
    case Label
    case ImmediateString
    case ImmediateInteger
    case ImmediateTuple
    case Instruction
    case Directive
    case BadToken
}
enum DirectiveType{
    case Integer,String,Tuple,Start,end
}
struct Token: CustomStringConvertible {
    let type: TokenType
    var intValue: Int?
    var stringValue: String?
    var tupleValue: Tuple?
    var directiveType: DirectiveType?
    init(type: TokenType) {
        self.type = type
        self.intValue = nil
        self.stringValue = nil
        self.tupleValue = nil
        self.directiveType = nil
    }
    var description: String {
        var output: String = ""
        switch type{
        case .Directive: output += "Directive: \(directiveType!)"
        case .ImmediateInteger: output += "Immediate Integer: \(intValue!)"
        case .ImmediateString: output += "Immediate String: \(stringValue!)"
        case .Instruction: output += "Instruction"
        case .LabelDefinition: output += "Label Definition"
        case .Label: output += "Label"
        case .ImmediateTuple: output += "Tuple: \(tupleValue!)"
        case .Register: output += "Register"
        default: output += "Bad Token"
        }
        return output
    }
}
struct Tuple: CustomStringConvertible {
    let CurrentState: Int
    let InputCharacter: Int
    let NewState: Int
    let OutputCharacter: Int
    let Direction: Int
    var d: Character {
        if Direction == 1 {
            return "r"
        }
        return "l"
    }
    init(CurrentState: Int, InputCharacter: Int, NewState: Int, OutputCharacter: Int, Direction: Int) {
        self.CurrentState = CurrentState
        self.InputCharacter = InputCharacter
        self.NewState = NewState
        self.OutputCharacter = OutputCharacter
        self.Direction = Direction
    }
    var description: String {
        return "\(CurrentState) \(String(UnicodeScalar(InputCharacter))) \(NewState) \(String(UnicodeScalar(OutputCharacter))) \(d)"
    }
}





