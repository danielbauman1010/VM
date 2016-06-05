//
//  Input.swift
//  VM
//
//  Created by Daniel on 5/23/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation
extension String : CollectionType {}

func readTextFileFromDiskMac(filePath: String)->String{
    let result = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
    return result!
}

func getLineFromConsoleMac()->String{
    let BUFSIZE = 1024
    var buf = [CChar](count:BUFSIZE, repeatedValue:CChar(0))
    fgets(&buf, Int32(BUFSIZE), stdin)
    var line: String = String.fromCString(buf)!
    line = line.substringToIndex(line.endIndex.predecessor())
    return line
}


enum commands {
    case halt, clrr, clrx, clrm, clrb, movir, movrr,movrm, movmr, movxr, movar, movb, addir, addrr, addmr, addxr, subir, subrr, submr, subxr, mulir, mulrr, mulmr, mulxr, divir, divrr, divmr, divxr, jmp, sojz, sojnz, aojz, aojnz, cmpir, cmprr, cmpmr, jmpn, jmpz, jmpp, jsr, ret, push, pop, stackc, outci, outcr, outcx, outcb, movrx, movxx, printi, outs, jmpne
}

let numberToCommand  = [0: commands.halt, 1: commands.clrr, 2: commands.clrx, 3: commands.clrm, 4: commands.clrb, 5: commands.movir, 6:  commands.movrr, 7:  commands.movrm, 8:  commands.movmr, 9:  commands.movxr, 10: commands.movar, 11: commands.movb, 12: commands.addir, 13: commands.addrr, 14: commands.addmr, 15: commands.addxr, 16: commands.subir, 17: commands.subrr, 18: commands.submr, 19: commands.subxr, 20: commands.mulir, 21: commands.mulrr,22: commands.mulmr,23: commands.mulxr, 24: commands.divir, 25: commands.divrr,26: commands.divmr,27: commands.divxr, 28: commands.jmp, 29: commands.sojz, 30: commands.sojnz, 31: commands.aojz, 32: commands.aojnz, 33: commands.cmpir, 34: commands.cmprr, 35: commands.cmpmr, 36: commands.jmpn, 37: commands.jmpz, 38: commands.jmpp, 39: commands.jsr, 40: commands.ret, 41: commands.push, 42: commands.pop, 43: commands.stackc, 44: commands.outci, 45: commands.outcr, 46: commands.outcx, 47: commands.outcb, 49: commands.printi, 53: .movrx, 54: .movxx, 55: commands.outs, 57: commands.jmpne ]
let stringToCommand = ["halt": commands.halt, "clrr": commands.clrr, "clrx": commands.clrx, "clrm": commands.clrm, "clrb": commands.clrb, "movir": commands.movir, "movrr": commands.movrr, "movrm": commands.movrm, "movmr": commands.movmr, "movxr": commands.movxr, "movar": commands.movar, "movb": commands.movb, "addir": commands.addir, "addrr": commands.addrr, "addmr": commands.addmr, "addxr": commands.addxr, "subir": commands.subir, "subrr": commands.subrr, "submr": commands.submr, "subxr": commands.subxr, "mulir": commands.mulir, "mulrr": commands.mulrr, "mulmr": commands.mulmr, "mulxr": commands.mulxr, "divir": commands.divir, "divrr": commands.divrr, "divmr": commands.divmr, "divxr": commands.divxr, "jmp": commands.jmp, "sojz": commands.sojz, "sojnz": commands.sojnz, "aojz": commands.aojz, "aojnz": commands.aojnz, "cmpir": commands.cmpir, "cmprr": commands.cmprr, "cmpmr": commands.cmpmr, "jmpn": commands.jmpn, "jmpz": commands.jmpz, "jmpp": commands.jmpp, "jsr": commands.jsr, "ret": commands.ret, "push": commands.push, "pop": commands.pop, "stackc": commands.stackc, "outci": commands.outci, "outcr": commands.outcr, "outcx": commands.outcx, "outcb": commands.outcb, "movrx": commands.movrx, "movxx": commands.movxx, "printi": commands.printi, "outs": commands.outs, "jmpne": commands.jmpne]