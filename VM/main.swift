//
//  main.swift
//  VM
//
//  Created by Daniel on 4/5/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

extension String : CollectionType {}

func readTextFileFromDiskMac(filePath: String)->String{
    let result = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
    return result!
}

var run: Bool = true
let vm: VM = VM()
enum commands {
    case asm,run,debug,exit,help
}
func help() {
    print("asm <filename> - assembles <filename>")
    print("run <filename> - runs <filename>")
    print("debug <filename> - debugs <filename>")
    print("exit - exits the VM")
    print("help - prints commands")
}
let ops = [
    "asm": commands.asm,
    "run": commands.run,
    "debug": commands.debug,
    "exit": commands.exit,
    "help": commands.help
]
while run{
    print("Enter command:")
    let option = vm.getLineFromConsoleMac()
    let parts = option.split(" ")
    if let command = ops[parts[0]] {
        switch command{
        case .asm:
            print("not supported yet.")
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
