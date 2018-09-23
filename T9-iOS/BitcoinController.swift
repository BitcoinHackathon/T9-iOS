//
//  BitcoinController.swift
//  T9-iOS
//
//  Created by HINOMORI HIROYA on 2018/09/23.
//  Copyright © 2018年 HINOMORI HIROYA. All rights reserved.
//

import Foundation
import BitcoinKit

class BitcoinController {
    
    private var wallet: Wallet? = Wallet()
    
    func initalize() {
        if wallet == nil {
            let privateKey = PrivateKey(network: .testnet)
            wallet = Wallet(privateKey: privateKey)
            wallet?.save()
        }
    }
    
    func reload(_ completion: ((UInt64) -> ())?) {
        wallet?.reloadBalance(completion: { [unowned self] (utxos) in
            print("🎉 ADDR : ", self.wallet?.address.cashaddr ?? "")
            if let balance = self.wallet?.balance() {
                completion?(balance)
            } else {
                completion?(0)
            }
        })
    }
    
    func checkAuth(contentsID: String, responseHandler: (Bool) -> ()) {
        return responseHandler(Int(contentsID) ?? 0 % 2 == 0)
    }
    
    func messages(_ outputs: [TransactionOutput]) -> [String] {
        let messagesSubstring: [Substring] = outputs
            .map { $0.scriptCode().hex }
            .filter { $0.prefix(2) == "6a" }
            .map { $0[$0.index($0.startIndex, offsetBy: 4)...]}
        
        let messages = messagesSubstring
            .map { Data(hex: String($0))! }
            .map { String(data: $0, encoding: .utf8)! }
        
        return messages
    }

    func buy(_ toAddress: String, _ amount: UInt64, completion: ((String?) -> Void)?) {
        if let address = try? AddressFactory.create(toAddress) {
            try? wallet?.send(to: address, amount: amount, completion: { (response) in
                completion?(response)
            })
        }
    }
    
    func send(_ toAddress: String, _ amount: UInt64, completion: ((String?) -> Void)?) {
        do {
            let address = try AddressFactory.create(toAddress)
            guard let wallet = wallet else {
                return
            }
            let utxos = wallet.utxos()
            let (utxosToSpend, fee) = try StandardUtxoSelector().select(from: utxos, targetValue: amount)
            let totalAmount: UInt64 = utxosToSpend.reduce(UInt64()) { $0 + $1.output.value }
            let change: UInt64 = totalAmount - amount - fee
            
            let unsignedTx = try SendUtility.customTransactionBuild(to: (address, amount), change: (wallet.address, change), utxos: utxosToSpend)
            let signedTx = try SendUtility.customTransactionSign(unsignedTx, with: [wallet.privateKey])
            
            let rawtx = signedTx.serialized().hex
            BitcoinComTransactionBroadcaster(network: .testnet).post(rawtx, completion: completion)
            
        } catch let error {
            print(error)
        }
    }

}
