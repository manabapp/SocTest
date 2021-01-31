//
//  SocTestIOData.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import Foundation

struct SocTestIOData {
    var name: String
    var editable: Bool = false
    var data: Data = Data([])
    var size: Int = 0
    var type: Int32 = Self.contentTypeBuffer
    var label: String { "\(size) " + NSLocalizedString(size == 1 ? "Label_byte" : "Label_bytes", comment: "") }
    var sendok: Bool { type == Self.contentTypeCustom && size > 0 }
    
    static let contentTypeCustom: Int32 = 0
    static let contentTypeAllZeroDigit: Int32 = 1
    static let contentTypeDigit: Int32 = 2
    static let contentTypeRandomDigit: Int32 = 3
    static let contentTypeRandomAlphaDigit: Int32 = 4
    static let contentTypeRandomPrintable: Int32 = 5
    static let contentTypeAllZeroBinaly: Int32 = 6
    static let contentTypeAllOneBinaly: Int32 = 7
    static let contentTypeRandomBinaly: Int32 = 8
    static let contentTypeBuffer: Int32 = 9  // for recvXXXX
    static let digitLetters = "0123456789"
    static let alphaDigitLetters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static let printableLetters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ "
    static var nameFormatter = DateFormatter()
    
    static func initNameFormat() {
        nameFormatter.calendar = Calendar(identifier: .gregorian)
        nameFormatter.locale = Locale(identifier: "C")
        nameFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        nameFormatter.dateFormat = "MMMdd_HHmmss"
        SocLogger.debug("SocTestIOData.initNameFormat: done")
    }
    
    static func loadIODatas(iodatas: inout [SocTestIOData]) {
        let documentDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: documentDirURL.path) else {
            SocLogger.error("SocTestIOData.loadDatas: readdir '\(documentDirURL.path)' failed.")
            return
        }
        for filename in fileNames {
            let fileURL = documentDirURL.appendingPathComponent(filename)
            do {
                var iodata: SocTestIOData
                if filename.pregMatche(pattern: "^Received_[A-Z][a-z]*[0-9]*_[0-9]*$") {
                    iodata = SocTestIOData(name: filename)
                }
                else {
                    iodata = SocTestIOData(name: filename, editable: true, type: contentTypeCustom)
                }
                iodata.data = try Data(contentsOf: fileURL, options: [])
                iodata.size = iodata.data.count
                iodatas.append(iodata)
                SocLogger.debug("iodata - \(iodata.name), \(iodata.size) bytes")
            }
            catch {
                SocLogger.error("SocTestIOData.loadIODatas: \(fileURL.path): \(error)")
                assertionFailure("SocTestIOData.loadIODatas: \(fileURL.path): \(error)")
                return //No popup
            }
        }
    }
    
    static func createData(type: Int32, size: Int) -> Data {
        let data: Data
        switch type {
        case Self.contentTypeAllZeroDigit:
            let dataString = String(repeating: "0", count: size)
            data = dataString.data(using: .utf8)!
        case Self.contentTypeDigit:
            let dataString = String(repeating: Self.digitLetters, count: Int(size / 10)) + Self.digitLetters.prefix(size % 10)
            data = dataString.data(using: .utf8)!
        case Self.contentTypeRandomDigit:
            let dataString = String((0 ..< size).map { _ in Self.digitLetters.randomElement()! })
            data = dataString.data(using: .utf8)!
        case Self.contentTypeRandomAlphaDigit:
            let dataString = String((0 ..< size).map { _ in Self.alphaDigitLetters.randomElement()! })
            data = dataString.data(using: .utf8)!
        case Self.contentTypeRandomPrintable:
            let dataString = String((0 ..< size).map { _ in Self.printableLetters.randomElement()! })
            data = dataString.data(using: .utf8)!
        case Self.contentTypeAllZeroBinaly:
            let buffer = [UInt8](repeating: UInt8.min, count: size)
            data = Data(buffer)
        case Self.contentTypeAllOneBinaly:
            let buffer = [UInt8](repeating: UInt8.max, count: size)
            data = Data(buffer)
        case Self.contentTypeRandomBinaly:
            var buffer: [UInt8] = []
            for _ in 0 ..< size { buffer.append(UInt8.random(in: .min ... .max)) }
            data = Data(buffer)
        default:  // contentTypeBuffer
            let buffer = [UInt8](repeating: 0, count: size)
            data = Data(buffer)
        }
        return data
    }
    
    mutating func save() throws {
        guard self.size <= 65536 else {
            SocLogger.debug("SocTestIOData.save: Data size \(self.size)' too large")
            throw SocTestError.TooLargeData
        }
        
        if self.name.isEmpty {
            self.name = "Received_" + SocTestIOData.nameFormatter.string(from: Date())
        }
        let documentDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataFileURL = documentDirURL.appendingPathComponent(self.name)
        if FileManager.default.fileExists(atPath: dataFileURL.path) {
            SocLogger.debug("SocTestIOData.save: '\(dataFileURL.path)' exists")
            guard self.editable else {
                SocLogger.debug("SocTestIOData.save: skip saving")
                throw SocTestError.AlreadySaved
            }
        }
        else {
            FileManager.default.createFile(atPath: dataFileURL.path, contents: nil, attributes: nil)
            SocLogger.debug("SocTestIOData.save: '\(dataFileURL.path)' created")
        }
        guard let fh = FileHandle(forUpdatingAtPath: dataFileURL.path) else {
            SocLogger.error("SocTestIOData.save: FileHandle('\(dataFileURL.path)') failed")
            throw SocTestError.FileOpenError
        }
        fh.truncateFile(atOffset: 0)
        fh.write(self.data)
        SocLogger.debug("SocTestIOData.save: FileHandle('\(dataFileURL.path)') wrote \(self.size) bytes")
    }
    
    func delete() throws {
        let documentDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataFileURL = documentDirURL.appendingPathComponent(self.name)
        guard FileManager.default.fileExists(atPath: dataFileURL.path) else {
            SocLogger.error("SocTestIOData.delete: '\(dataFileURL.path)' is not exists")
            assertionFailure("SocTestIOData.delete: '\(dataFileURL.path)' is not exists")
            return //No popup
        }
        SocLogger.debug("SocTestIOData.delete: try remove '\(dataFileURL.path)'")
        do {
            try FileManager.default.removeItem(atPath: dataFileURL.path)
        }
        catch {
            SocLogger.error("SocTestIOData.delete: \(error)")
            throw SocTestError.FileDeleteError
        }
    }
    
    //
    //  Function          Convertion (Data <==> String)
    //  ------------------------------------------------------------------------------------------
    //  getDump()         Data ==>  0000: 30313233 34353637 38396162 63646566   01234567 89abcdef
    //  getAscii()        Data ==> 0123456789abcdef
    //  getIndex()        Data ==>  0000:
    //  getHex()          Data ==> 30313233 34353637 38396162 63646566
    //  getChars()        Data ==> 01234567 89abcdef
    //  getHeaderChars()  Data ==> "01245.yxz"...
    //
    //  setAscii()        0123456789abcdef ==> Data
    //  setHex()          30313233 34353637 38396162 63646566 ==> Data
    //
    func getDump(maxLen: Int = -1) -> String {
        var count: Int = 0
        var num: Int = 0
        var dumpString: String = ""
        var detailString: String = ""
        let bytes = self.data.uint8array!
        
        while count < self.size {
            if count < 10000 {
                dumpString += String(format: " %04d:  ", count)
            }
            else {
                dumpString += String(format: "%05d:  ", count)
            }
            if maxLen >= 0 && count >= maxLen {
                dumpString += "=== MORE ===\n"
                return dumpString
            }
            detailString = "    "
            while count < self.size {
                dumpString += String(format: "%02x", bytes[count])
                detailString += SocTestIOData.printableLetters.contains(bytes[count].char) ? String(format: "%c", bytes[count]) : "."
                count += 1
                if count % 16 == 0 {
                    break
                }
                if count % 8 == 0 {
                    detailString += " "
                }
                if count % 4 == 0 {
                    dumpString += " "
                }
            }
            num = 16 - (count % 16)
            if num > 0 && num < 16 {
                dumpString += String(repeating: " ", count: num * 2 + Int(num / 4))
            }
            dumpString += detailString + "\n"
        }
        return dumpString
    }
    
    func getAscii(isCRLF: inout Bool) -> String? {
        guard let asciiString = String(data: self.data, encoding: .utf8) else {
            return nil
        }
        if asciiString.contains("\r\n") {
            isCRLF = true
        }
        else {
            isCRLF = !asciiString.contains("\n")
        }
        return asciiString
    }
    
    func getIndex() -> String {
        var count: Int = 0
        var dumpString: String = ""
        
        while count < self.size {
            if count % 16 == 0 {
                if count < 10000 {
                    dumpString += String(format: " %04d:\n", count)
                }
                else {
                    dumpString += String(format: "%05d:\n", count)
                }
            }
            count += 1
        }
        return dumpString
    }
    
    func getHex() -> String {
        var count: Int = 0
        var dumpString: String = ""
        let bytes = self.data.uint8array!
        
        while count < self.size {
            dumpString += String(format: "%02x", bytes[count])
            count += 1
            if count % 16 == 0 {
                dumpString += "\n"
                continue
            }
            if count % 4 == 0 {
                dumpString += " "
            }
        }
        return dumpString
    }
        
    func getChars() -> String {
        var count: Int = 0
        var dumpString: String = ""
        let bytes = self.data.uint8array!
        
        while count < self.size {
            dumpString += SocTestIOData.printableLetters.contains(bytes[count].char) ? String(format: "%c", bytes[count]) : "."
            count += 1
            if count % 16 == 0 {
                dumpString += "\n"
                continue
            }
            if count % 8 == 0 {
                dumpString += " "
            }
        }
        return dumpString
    }
    
    func getHeaderChars(maxLen: Int, isQuote: Bool) -> String {
        var count: Int = 0
        var dumpString: String = isQuote ? "\"" : ""
        let bytes = self.data.uint8array!
        
        while count < self.size {
            if count >= maxLen {
                if isQuote {
                    dumpString += "\"..."
                }
                return dumpString
            }
            dumpString += SocTestIOData.printableLetters.contains(bytes[count].char) ? String(format: "%c", bytes[count]) : "."
            count += 1
        }
        if isQuote {
            dumpString += "\""
        }
        return dumpString
    }
    
    mutating func setAscii(_ text: String, isCRLF: Bool) {
        let before = Array(text)
        var after: String = ""
        let length = before.count
        var count: Int = 0
        
        if length == 0 {
            self.data = Data([])
            return
        }
        if isCRLF {
            count = 1
            after += String(before[0])
            while count < length {
                if before[count] == "\n" && before[count - 1] != "\r" {
                    after += String("\r\n")
                }
                else {
                    after += String(before[count])
                }
                count += 1
            }
        }
        else {
            count = 0
            while count < length {
                if before[count] != "\r" || (count + 1) == length || before[count + 1] != "\n" {
                    after += String(before[count])
                }
                count += 1
            }
        }
        self.data = after.data(using: .utf8)!
        self.size = self.data.count
    }
    
    mutating func setHex(_ text: String) throws {
        var text2 = text.replacingOccurrences(of: " ", with: "")
        text2 = text2.replacingOccurrences(of: "\n", with: "")
        let textArray = Array(text2)
        let length = textArray.count
        if length == 0 {
            self.data = Data([])
            self.size = 0
            return
        }
        
        var hexString: String = ""
        var uint8array: [UInt8] = []
        var count: Int = 0
        while count < length {
            hexString = String(textArray[count])
            hexString += (count + 1) < length ? String(textArray[count + 1]) : "0"
            guard let uint8 = UInt8(hexString, radix: 16) else {
                throw SocTestError.InvalidHexCode
            }
            uint8array.append(uint8)
            count += 2
        }
        self.data = Data(uint8array)
        self.size = self.data.count
    }
}
