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
let assembler: Assembler = Assembler()
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

while run{
    print("Enter command:")
    let option = getLineFromConsoleMac()
    let parts = option.split(" ")
    if let command = options[parts[0]] {
        switch command{
        case .asm:
            let lines = readTextFileFromDiskMac("\(parts[1]).txt").split("\n")
            assembler.assemble(lines, filename: parts[1])
        case .run:
            vm.processFile(readTextFileFromDiskMac("\(parts[1]).bin").split("\n"),debug: false)
        case .debug:
            vm.processFile(readTextFileFromDiskMac("\(parts[1]).bin").split("\n"),debug: true)
        case .exit:
            run = false
        case .help:
            help()        
        }
    } else {
        print("invalid command.")
    }
}
