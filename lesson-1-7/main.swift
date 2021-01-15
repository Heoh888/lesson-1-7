//
//  main.swift
//  lesson-1-7
//
//  Created by MacBook on 12.01.2021.
//

import Foundation

struct Card {
    var nameBank: String
    var balance: Double
    var periodValidity: String
    var pinCode: Int
    var currency: String
}
extension Card: CustomStringConvertible {
     var description: String {
        return "Эммитет карты: \(nameBank), Баланс карты: \(balance) \(currency)"
     }
 }

enum AutomatedTellerMachineError: Error {
    case notRecognized
    case invalidPincode
    case insufficientFunds(needFunds: Double)
    case noMoneyAtm
}
extension AutomatedTellerMachineError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notRecognized: return "Карта не распозннана"
        case .invalidPincode: return "Невеный пин-код"
        case let .insufficientFunds(needFunds): return "Недостаточно середств \(needFunds)"
        case .noMoneyAtm: return "Недостаточно середств в банкомате"
        }
    }
}

// Релизовать класс CreditCardHolder
class CreditCardHolder {
    var cashBalanceRub: Double = 10000
    var cashBalanceUsd: Double = 2000
    
    var creditCards: [String: Card] = [
        "Карта 1": .init(nameBank: "Alfa Bank", balance: 100500, periodValidity: "07/2020", pinCode: 4567, currency: "RUB"),
        "Карта 2": .init(nameBank: "SberBank", balance: 4000, periodValidity: "03/2025", pinCode: 4567, currency: "USD")
    ]
}

// Релизовать класс Банкомата
class AutomatedTellerMachine: CreditCardHolder {
    
    var quantityUsd:Double = 20000
    var quantityRub:Double = 15000
    
    func bank(Card name: String, cash: Double, pinCode: Int) -> (item: Card?, erorr: AutomatedTellerMachineError?) {
        guard var card = creditCards[name] else {
            return (nil, .notRecognized)
        }
        guard card.pinCode == pinCode else {
            return (nil, .invalidPincode)
        }
        guard card.balance > cash else {
            let need = card.balance - cash
            return (nil, .insufficientFunds(needFunds: need))
        }
        
        if card.currency == "USD" {
            if cash > 0 {
                if cash <= quantityUsd {
                    cashBalanceUsd += cash
                    quantityUsd += cash
                } else {
                    return (nil, .noMoneyAtm)
                }
            } else {
                if cashBalanceUsd < -cash {
                    let need = cashBalanceUsd + cash
                    return (nil, .insufficientFunds(needFunds: need))
                } else {
                    cashBalanceUsd += cash
                    quantityUsd -= cash
                }
            }
        }
        
        if card.currency == "RUB" {
            if cash > 0 {
                cashBalanceRub += cash
            } else {
                if cashBalanceRub < -cash {
                    let need = cashBalanceRub + cash
                    return (nil, .insufficientFunds(needFunds: need))
                } else {
                    cashBalanceRub += cash
                }
            }
        }
        card.balance -= cash
        return (card, nil)
    }
}

var atm = AutomatedTellerMachine()
let operation1 = atm.bank(Card: "Карта 2", cash: 1000, pinCode: 4567)

if let operation1 = operation1.item {
    print(operation1)
} else if let error = operation1.erorr {
    print(error.localizedDescription)
}


//var operation2 = atm.bank(Card: "Карта 2", cash: 2000, pinCode: 4567)
//print(operation2)
//
//
//

print("Налиных денег \(atm.cashBalanceRub) RUB")
print("Налиных денег \(atm.cashBalanceUsd) USD")
