//
//  Logger.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/30.
//  封装 os.log，统一日志输出
//

import os.log
import Foundation

nonisolated enum Log {
    private static let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier!, category: "App")

    static func debug(_ msg: Any, file: String = #file, line: Int = #line) {
        logger.debug("[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(String(describing: msg))")
    }

    static func info(_ msg: Any, file: String = #file, line: Int = #line) {
        logger.info("[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(String(describing: msg))")
    }

    static func warning(_ msg: Any, file: String = #file, line: Int = #line) {
        logger.warning("[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(String(describing: msg))")
    }

    static func error(_ msg: Any, file: String = #file, line: Int = #line) {
        logger.error("[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(String(describing: msg))")
    }
}
