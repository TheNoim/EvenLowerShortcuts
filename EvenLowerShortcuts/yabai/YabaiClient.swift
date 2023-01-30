//
//  YabaiClient.swift
//  EvenLowerShortcuts
//
//  Created by Nils Bergmann on 30/01/2023.
//

import Foundation
import Socket

actor YabaiClient {
    enum YabaiClientError: Error {
        case InvalidDataReturned
        case CanNotConvertArgument
        case YabaiError(message: String)
    }
    
    func sendMessage(arguments: [String]) throws -> Data {
        var payload = Data()
        
        for arg in arguments {
            guard var str = arg.data(using: .utf8) else {
                throw YabaiClientError.CanNotConvertArgument
            }
            str.append(0)
            payload.append(str)
        }
        
        payload.append(0);
        
        var newPayload = Data()
        
        withUnsafeBytes(of: payload.count) {
            newPayload.append(Data(bytes: $0.baseAddress!, count: 4))
        }
        
        newPayload.append(payload);
        
        let socket = try Socket.create(family: .unix, proto: .unix)
        
        defer {
            socket.close()
        }

        let userName = NSUserName()
        
        try socket.connect(to: "/tmp/yabai_\(userName).socket")
        
        try socket.setReadTimeout(value: 400)
        
        print("Send \(arguments)")
        
        try socket.write(from: newPayload)
        
        shutdown(socket.socketfd, SHUT_WR);
        
        var read = 0
        var outputBuffer = NSMutableData()
        var dataBuffer = Data()
        
        repeat {
            read = try! socket.read(into: outputBuffer)
            
            dataBuffer.append(outputBuffer as Data)
            
            outputBuffer = NSMutableData()
        } while (read > 0)
        
        socket.close();
        
        if dataBuffer.count < 1 {
            return dataBuffer
        }
        
        let firstUnicodeCharacter = String(data: Data([dataBuffer[0]]), encoding: .utf8);
        
        guard let outputStr = String(data: dataBuffer, encoding: .utf8) else {
            throw YabaiClientError.InvalidDataReturned;
        }
        
        let failureCode = "\u{07}";
        
        if failureCode == firstUnicodeCharacter {
            throw YabaiClientError.YabaiError(message: outputStr)
        }
        
        return dataBuffer;
    }
}
