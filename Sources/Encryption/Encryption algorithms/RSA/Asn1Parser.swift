import Foundation

enum Asn1Parser {
    
    enum NodeType: UInt8 {
        case integer          = 0x02
        case bitString        = 0x03
        case octetString      = 0x04
        case null             = 0x05
        case objectIdentifier = 0x06
        case sequence         = 0x30
    }

    enum Node {
        case null
        case sequence(nodes: [Node])
        case integer(data: Data)
        case objectIdentifier(data: Data)
        case bitString(data: Data)
        case octetString(data: Data)
    }
    
    enum ParserError: Error {
        case noType
        case invalidType(value: UInt8)
    }
    
    static func parse(data: Data) throws -> Node {
        let scanner = Scanner(data: data)
        let node = try parseNode(scanner: scanner)
        return node
    }
    
    private static func parseNode(scanner: Scanner) throws -> Node {
        let firstByte = try scanner.consume(length: 1).firstByte
        guard let nodeType = NodeType(rawValue: firstByte) else { 
            throw ParserError.invalidType(value: firstByte)
        }
        
        func length() throws -> Int { try scanner.consumeLength() }
        
        switch nodeType {
        case .integer:
            return .integer(data: try scanner.consume(length: length()))
        case .bitString:
            let len = try length() - 1
            try scanner.consume(length: 1) // Remove 0 at the end of string.
            let data = try scanner.consume(length: len)
            return .bitString(data: data)
        case .octetString:
            return .octetString(data: try scanner.consume(length: length()))
        case .null:
            try scanner.consume(length: 1)
            return .null
        case .objectIdentifier:
            return .objectIdentifier(data: try scanner.consume(length: length()))
        case .sequence:
            let nodes = try parseSequence(data: try scanner.consume(length: length()))
            return .sequence(nodes: nodes)
        }
    }
    
    private static func parseSequence(data: Data) throws -> [Node] {
        let scanner = Scanner(data: data)
        var nodes = [Node]()
        while !scanner.isComplete {
            nodes.append(try parseNode(scanner: scanner))
        }
        return nodes
    }
}

/// Simple data scanner that consumes bytes from a raw data and keeps an updated position.
private class Scanner {
    
    private let data: Data
    private var index: Int = 0
    fileprivate var isComplete: Bool { index >= data.count }
    
    init(data: Data) {
        self.data = data
    }
    
    @discardableResult fileprivate func consume(length: Int) throws -> Data {
        guard length > 0 else { return Data() }
        guard index + length <= data.count else { 
            throw ScannerError.outOfBounds 
        }
        let subdata = data.subdata(in: index..<index + length)
        index += length
        return subdata
    }
    
    fileprivate func consumeLength() throws -> Int {
        let lengthByte = try consume(length: 1).firstByte
        guard lengthByte >= 0x80 else { return Int(lengthByte) }
        let nextByteCount = lengthByte - 0x80
        let length = try consume(length: Int(nextByteCount))
        return length.integer
    }
    
    enum ScannerError: Error {
        case outOfBounds
    }

}

private extension Data {
    
    var firstByte: UInt8 {
        var byte: UInt8 = 0
        copyBytes(to: &byte, count: MemoryLayout<UInt8>.size)
        return byte
    }
    
    var integer: Int {
        guard count > 0 else { return 0 }
        var int: UInt32 = 0
        var offset = Int32(count - 1)
        forEach { byte in
            let byte32 = UInt32(byte)
            let shifted = byte32 << (UInt32(offset) * 8)
            int = int | shifted
            offset -= 1
        }
        return Int(int)
    }
    
}
