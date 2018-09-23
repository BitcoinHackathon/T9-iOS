//
//  APIClient.swift
//  T9-iOS
//
//  Created by HINOMORI HIROYA on 2018/09/23.
//  Copyright © 2018年 HINOMORI HIROYA. All rights reserved.
//

import Foundation
class APIClient {
    private let apiEndPoint = "https://test-bch-insight.bitpay.com/api"
    func getTransaction(withAddresses address: String, completionHandler: @escaping ([CodableTx]) -> ()) {
        let url = "\(apiEndPoint)/txs"
        print("Transactions by Address: url = \(url)")
        get(url: url, completion: { (data) in
            do {
                let transactions = try JSONDecoder().decode(Transactions.self, from: data)
                completionHandler(transactions.transactions)
            } catch {
                print("Serialize Error")
            }
        }, queryItems: [URLQueryItem(name: "address", value: address)])
    }
    
    func get(url urlString: String, completion: @escaping (Data) -> (), queryItems: [URLQueryItem]? = nil) {
        var compnents = URLComponents(string: urlString)
        compnents?.queryItems = queryItems
        guard let url = compnents?.url else {
            print("cannot create url")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    print("error: \(error)")
                } else {
                    print("Unknown Error")
                }
                return
            }
            completion(data)
        }
        
        task.resume()
    }
}

struct Transactions: Codable {
    let transactions: [CodableTx]
    
    private enum CodingKeys: String, CodingKey {
        case transactions = "txs"
    }
}

struct CodableTx: Codable {
    
    let blockHash: String?
    let blockHeight: Int64?
    let blockTime: Int64?
    let confirmations: Int64
    let time: Int64
    let txid: String
    let inputs: [Input]
    let outputs: [Output]
    
    private enum CodingKeys: String, CodingKey {
        case blockHash = "blockhash"
        case blockHeight = "blockheight"
        case blockTime = "blocktime"
        case confirmations
        case time
        case txid
        case inputs = "vin"
        case outputs = "vout"
    }
}

struct Input: Codable {
    
    let address: String
    let index: Int64
    let txID: String
    let value: Decimal
    let satoshi: Int64
    
    private enum CodingKeys: String, CodingKey {
        case address = "addr"
        case index = "n"
        case txID = "txid"
        case value = "value"
        case satoshi = "valueSat"
    }
}

struct Output: Codable {
    
    let index: Int64
    let scriptPubKey: ScriptPubKey
    let value: Decimal
    
    struct ScriptPubKey: Codable {
        let addresses: [String]?
        let type: String?
        let hex: String
    }
    
    private enum CodingKeys: String, CodingKey {
        case index = "n"
        case scriptPubKey
        case value
    }
}

extension Output {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = try container.decode(Int64.self, forKey: .index)
        scriptPubKey = try container.decode(ScriptPubKey.self, forKey: .scriptPubKey)
        
        guard let decimalValue = Decimal(string: try container.decode(String.self, forKey: .value)) else {
            throw DecodingError.typeMismatch(
                Decimal.self,
                .init(codingPath: [CodingKeys.value], debugDescription: "Failed to convert String to Decimal")
            )
        }
        value = decimalValue
    }
}

enum Direction {
    case sent, received
}

extension CodableTx {
    func direction(addresses: [String]) -> Direction {
        let sending = inputs
            .map { input -> Bool in
                return addresses.contains(input.address)
            }
            .contains(true)
        
        return sending ? .sent : .received
    }
    
    func amount(addresses: [String]) -> Decimal {
        var amount = outputs
            .filter { $0.scriptPubKey.addresses != nil }
            .filter({ $0.scriptPubKey.addresses!
                // [Bool] : 各txoutが自分のアドレス宛どうかの配列
                .map { addresses.contains($0) }
                // [Bool] : receiveの場合は自分宛のもののみTrue, sentの場合は相手宛のもののみTrueの配列
                .contains(direction(addresses: addresses) == .received)
            })
            .map { $0.value }
            .reduce(0, +)
        
        amount += outputs
            .filter { $0.scriptPubKey.addresses == nil }
            .map { $0.value }
            .reduce(0, +)
        
        return amount
    }
    
    func messages() -> [String] {
        let messagesSubstring: [Substring] = outputs
            .map { $0.scriptPubKey.hex }
            .filter { $0.prefix(2) == "6a" }
            .map { $0[$0.index($0.startIndex, offsetBy: 4)...]}
        
        let messages = messagesSubstring
            .map { Data(hex: String($0))! }
            .map { String(data: $0, encoding: .utf8)! }
        
        return messages
    }
}
