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
    var balance: UInt64 {
        return wallet?.balance() ?? 0
    }
    
    var address: String {
        return wallet?.address.cashaddr ?? ""
    }
    
    func initalize(_ completion: ((UInt64) -> ())? = nil) {
        if wallet == nil {
            let privateKey = PrivateKey(network: .testnet)
            wallet = Wallet(privateKey: privateKey)
            wallet?.save()
        }
        reload(completion)
    }
    
    func reload(_ completion: ((UInt64) -> ())?) {
        wallet?.reloadTransactions()
        wallet?.reloadBalance(completion: { [unowned self] (utxos) in
            print("🎉 ADDR : ", self.wallet?.address.cashaddr ?? "")
            if let balance = self.wallet?.balance() {
                completion?(balance)
            } else {
                completion?(0)
            }
        })
    }
    
    func checkAuth(contentsID: String, responseHandler: @escaping (Bool) -> ()) {
        dummyAuth(contentsID: contentsID, responseHandler: responseHandler)
    }
    
    
    // TODO: Transaction.inputからOP_RETURNの値を取得できなかったためダミー機能
    func dummyAuth(contentsID: String, responseHandler: @escaping (Bool) -> ()) {
        APIClient().getTransaction(withAddresses: address) { (transactions) in
            var txidList = [Data?]()
            txidList = transactions.map { $0.txid.data(using: .utf8) } // ほんとはこれをURL Bodyに入れる
            print(txidList)
            if let url = URL(string: "https://totemonagaiurl/checkauth") {
                URLSession.shared.dataTask(with: url) { (data, res, error) in
                    return responseHandler(Int(contentsID) ?? 0 % 2 == 0)
                    }.resume()
            } else {
                return responseHandler(Int(contentsID) ?? 0 % 2 == 0)
            }
        }
    }

    func buy(_ toAddress: String, _ amount: UInt64, completion: ((String?) -> Void)?) {
        if let address = try? AddressFactory.create(toAddress) {
            try? wallet?.send(to: address, amount: amount, completion: { (response) in
                completion?(response)
            })
        }
    }
    
    
    private let dummyContentID = "0"
    private let dummyUID = "abc123"
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
            let unsignedTx = try SendUtility.customTransactionBuild(param: (dummyContentID, dummyUID),
                                                                    to: (address, amount),
                                                                    change: (wallet.address, change),
                                                                    utxos: utxosToSpend)
            let signedTx = try SendUtility.customTransactionSign(unsignedTx, with: [wallet.privateKey])
            
            let rawtx = signedTx.serialized().hex
            BitcoinComTransactionBroadcaster(network: .testnet).post(rawtx, completion: completion)
            
        } catch let error {
            print(error)
        }
    }

}
