//
//  main.swift
//  VM
//
//  Created by Daniel on 4/5/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation


var run: Bool = true
let vm: VM = VM()
enum InterfaceCommands {
    case asm,run,debug,exit,help
}
func help() {
    print("asm <filename> - assembles <filename>")
    print("run <filename> - runs <filename>")
    print("debug <filename> - debugs <filename>")
    print("exit - exits the VM")
    print("help - prints commands")
}
let options = [
    "asm": InterfaceCommands.asm,
    "run": InterfaceCommands.run,
    "debug": InterfaceCommands.debug,
    "exit": InterfaceCommands.exit,
    "help": InterfaceCommands.help
]
var tokenizer = Tokenizer()

while run{
    print("Enter command:")
    let option = getLineFromConsoleMac()
    let parts = option.split(" ")
    if let command = options[parts[0]] {
        switch command{
        case .asm:
            let lines = readTextFileFromDiskMac(parts[1]).split("\n")
            for line in lines {
                let tokens: [Token] = tokenizer.tokenize(line)
                for token in tokens {
                    print(token, terminator: " ")
                }
                print("")
            }
        case .run:
            vm.processFile(readTextFileFromDiskMac(parts[1]).split("\n"))
        case .debug:
            print("not supported yet.")
        case .exit:
            run = false
        case .help:
            help()        
        }
    } else {
        print("invalid command.")
    }
}
