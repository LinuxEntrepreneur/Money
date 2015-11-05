#!/usr/bin/env xcrun -sdk macosx swift

//
//  Generate.swift
//  Money
//
//  Created by Daniel Thorpe on 01/11/2015.
//
//

import Foundation

typealias Writer = (String) -> Void
typealias Generator = (Writer) -> Void

func createMoneyTypeForCurrency(code: String) -> String {
    return "_Money<Currency.\(code)>"
}

func createExtensionFor(typename: String, writer: Writer, content: Generator) {
    writer("extension \(typename) {")
    content(writer)
    writer("}")
}

func createFrontMatter(line: Writer) {
    line("// ")
    line("// Money, https://github.com/danthorpe/Money")
    line("// Created by Dan Thorpe, @danthorpe")
    line("// ")
    line("// Autogenerated from build scripts, do not manually edit this file.")
    line("")
}

func createCurrencyTypes(line: Writer) {
    for code in NSLocale.ISOCurrencyCodes() {
        line("")
        line("    /// Currency \(code)")
        line("    public final class \(code): Currency.Base, _CurrencyType {")
        line("        /// Lazy static storage for currency.")
        line("        public static var sharedInstance = \(code)(code: \"\(code)\")")
        line("    }")
    }
}

func createMoneyTypes(line: Writer) {
    line("")

    for code in NSLocale.ISOCurrencyCodes() {
        line("/// \(code) Money")
        let name = createMoneyTypeForCurrency(code)
        line("public typealias \(code) = \(name)")
    }
}

func generate(outputPath: String) {

    guard let outputStream = NSOutputStream(toFileAtPath: outputPath, append: false) else {
        fatalError("Unable to create output stream at path: \(outputPath)")
    }

    let write: Writer = { str in
        guard let data = str.dataUsingEncoding(NSUTF8StringEncoding) else {
            fatalError("Unable to encode str: \(str)")
        }
        outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }

    let writeLine: Writer = { write("\($0)\n") }

    outputStream.open()
    createFrontMatter(writeLine)
    createExtensionFor("Currency", writer: writeLine, content: createCurrencyTypes)
    write("\n")
    createMoneyTypes(writeLine)
    outputStream.close()
}

// MARK: - Main()

if Process.arguments.count == 1 {
    print("Invalid usage. Requires an output path.")
    exit(1)
}

let outputPath = Process.arguments[1]
print("Will output to path: \(outputPath)")
generate(outputPath)