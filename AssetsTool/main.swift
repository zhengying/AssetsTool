//
//  main.swift
//  ZYAssertTool
//
//  Created by zhengying on 16/8/5.
//  Copyright © 2016年 zhengying. All rights reserved.
//

import Foundation

func getOption(_ option: String) -> (option:OptionType, value: String) {
    return (OptionType(value: option), option)
}

func useage() {
    print("USAGE: \(CommandLine.arguments[0]) -s srcImageFolder -o assetsFolder")
}

enum OptionType: String {
    case src = "s"
    case out = "o"
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "s": self = .src
        case "o": self = .out
        case "h": self = .help
        default: self = .unknown
        }
    }
}

let argCount = CommandLine.argc

struct OptionParameter {
    var src:String?
    var dest:String?
}

var optionParameter = OptionParameter()

for i in 0..<CommandLine.arguments.count {
    let argument = CommandLine.arguments[i]
    //
    let (opt, value) = getOption(argument.substring(from: argument.characters.index(argument.startIndex, offsetBy: 1)))
    //print("Argument count: \(argCount) Option: \(opt) value: \(value)")
    
    if argCount < 3 {
        useage()
        exit(1)
    }
    
    if opt == OptionType.src {
        if i != CommandLine.arguments.count - 1  {
            optionParameter.src = CommandLine.arguments[i+1]
        }
    } else if opt == OptionType.out {
        if i != CommandLine.arguments.count - 1  {
            optionParameter.dest = CommandLine.arguments[i+1]
        }
    } else {
        useage()
        exit(1)
    }
    
}

createAssetsImages(optionParameter.src, destPath: optionParameter.dest)
exit(0)

