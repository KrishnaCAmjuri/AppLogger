//
//  AppLogger.swift
//
//  Created by Krishna Chaitanya Amjuri on 29/12/17.
//

import UIKit

extension DispatchQueue {
    public static var labelForCurrentQueue: String? {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))
    }
}

class AppLogger: NSObject {
    
    static var `default`: AppLogger = {
        struct Statics {
            static let instance: AppLogger = AppLogger()
        }
        return Statics.instance
    }()
    
    private var dateFormatter: DateFormatter {
        let defaultDateFormatter = DateFormatter()
        defaultDateFormatter.locale = NSLocale.current
        defaultDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return defaultDateFormatter
    }
    
    private var isDebuggingEnabled: Bool = false
    
    private var debugMessageFormat: String = "%@ [Debug] [%@] [%@:%@] %@ > %@" // "FormattedDate [Debug] [Threadlabel] [Filename:Linenumber] Functionname > message"
    
    private func getDebuggingMessage(_ closureResult: Any, functionName: String, fileName: String, lineNumber: Int) -> String {
        let nsFilePath: NSString = NSString(string: fileName)
        let fileName: String = nsFilePath.lastPathComponent
        var threadName = "main"
        if !Thread.isMainThread {
            if let thread = Thread.current.name {
                threadName = thread
            }else if let queue = DispatchQueue.labelForCurrentQueue {
                threadName = queue
            }
        }
        let dateString = self.dateFormatter.string(from: Date())
        let messageToBePrinted = String(describing: closureResult)
        let debugMessage: String = String(format: debugMessageFormat, dateString, threadName, fileName, String(describing: lineNumber), functionName, messageToBePrinted)
        return debugMessage
    }
    
    func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    fileprivate func logln(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        guard let closureResult = closure() else { return}
        if self.isDebuggingEnabled {
            print(self.getDebuggingMessage(closureResult, functionName: String(describing: functionName), fileName: String(describing: fileName), lineNumber: lineNumber))
        }
    }
    
    func enableDebugging() {
        self.isDebuggingEnabled = true
    }
    
    func disableDebugging() {
        self.isDebuggingEnabled = false
    }
}

