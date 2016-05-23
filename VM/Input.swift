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
