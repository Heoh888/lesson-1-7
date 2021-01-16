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
    var pinCode: Int
    var currency: String
}
extension Card: CustomStringConvertible {
     var description: String {
        return "Эмитент карты: \(nameBank), Баланс карты: \(balance) \(currency)"
     }
 }

enum AutomatedTellerMachineError: Error {
    case notRecognized
    case invalidPincode
    case insufficientFunds(needFunds: Double)
    case noMoneyAtm
    case noSuchCurrency
    case noIssuer
}
extension AutomatedTellerMachineError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notRecognized: return "Карта не распознана"
        case .invalidPincode: return "Неверный пин-код"
        case let .insufficientFunds(needFunds): return "Недостаточно середств \(needFunds)"
        case .noMoneyAtm: return "Недостаточно средств в банкомате"
        case .noSuchCurrency: return "Данная валюта не поддерживается АТМ"
        case .noIssuer: return "АТМ не поддерживает эмитент карты"
        }
    }
}

// Релизовать класс CreditCardHolder
class CreditCardHolder {
    var cashRub: Double = 10000
    var cashUsd: Double = 0
    
    var creditCards: [String: Card] = [
        "Карта 1": .init(nameBank: "Alfa Bank", balance: 100500, pinCode: 4567, currency: "RUB"),
        "Карта 2": .init(nameBank: "SberBank", balance: 4000, pinCode: 1920, currency: "USD"),
        "Карта 3": .init(nameBank: "Saxo Bank", balance: 2000, pinCode: 3049, currency: "EUR"),
        "Карта 4": .init(nameBank: "DenizBank Güzeloba", balance: 2000, pinCode: 3390, currency: "TRY")
    ]
}

// Реализовать класс Банкомата
class AutomatedTellerMachine: CreditCardHolder {
    
    var quantityUsd:Double = 20000  // Количество "USD" в банкомате
    var quantityRub:Double = 15000  // Количество "RUB" в банкомате
    let currency = ["RUB", "USD"]   // Принимаемые валюты
    let namesBank = ["Alfa Bank", "SberBank", "Saxo Bank", "ВТБ", "Росбанк", "Tinkoff"] // Доступные эмитенты
    
    func bank(Card name: String, cash: Double, pinCode: Int) throws -> Card {
        // Ошибка ката не распознона
        guard var card = creditCards[name] else {
            throw AutomatedTellerMachineError.notRecognized
        }
        // Ошибка не верный пин-код
        guard card.pinCode == pinCode else {
            throw AutomatedTellerMachineError.invalidPincode
        }
        // Определим доступен эмитент банка
        let iNamesBank = namesBank.firstIndex(of: card.nameBank)
        guard iNamesBank != nil else {
            throw AutomatedTellerMachineError.noIssuer
        }
        // Определим доступна запрашиваемая валюта
        let iCurrency = currency.firstIndex(of: card.currency)
        var cashBalance:Double = 0
        var quantity:Double = 0
        guard iCurrency != nil else {
            throw AutomatedTellerMachineError.noSuchCurrency
        }
        // Ошибка недостатоный баланс на карте
        guard card.balance >= cash else {
            let need = card.balance - cash
            throw AutomatedTellerMachineError.insufficientFunds(needFunds: need)
        }
        // Определим с какой валютой сейчас работаем и достанем значения с переменных
        if currency[iCurrency!] == "USD" {
            cashBalance = cashUsd
            quantity = quantityUsd
        }
        if currency[iCurrency!] == "RUB" {
            cashBalance = cashRub
            quantity = quantityRub
        }
        
        if cash > 0 { // Обработаем запрос для внесение наличных в АТМ
            if cash <= quantity {
                cashBalance += cash
                quantity += cash
            } else {
                throw AutomatedTellerMachineError.noMoneyAtm // Не хватает средств в банкомате
            }
        } else { // Обработаем запрос для получение наличных из АТМ
            if cashBalance < -cash {
                let need = cashBalance + cash
                throw AutomatedTellerMachineError.insufficientFunds(needFunds: need) // Не хватает средств для внесение в банкомат
            } else {
                cashBalance += cash
                quantity -= cash
            }
        }
        // Вернем значение в переменные
        if currency[iCurrency!] == "USD" {
            cashUsd = cashBalance
            quantityUsd = quantity
        }
        if currency[iCurrency!] == "RUB" {
            cashRub = cashBalance
            quantityRub = cashBalance
        }
        
        card.balance -= cash
        return card
    }
}
// Инициализируем экземпляр
var atm = AutomatedTellerMachine()

// Проведем операции по картам
do {
    let operation1 = try atm.bank(Card: "Карта 1", cash: 1000, pinCode: 4567)
    print(operation1)
} catch let error {
    print(error.localizedDescription)
}

do {
    let operation2 = try atm.bank(Card: "Карта 2", cash: 2000, pinCode: 1920)
    print(operation2)
} catch let error {
    print(error.localizedDescription)
}

do {
    let operation3 = try atm.bank(Card: "Карта 3", cash: 2000, pinCode: 3049)
    print(operation3)
} catch let error {
    print(error.localizedDescription)
}

do {
    let operation4 = try atm.bank(Card: "Карта 4", cash: 2000, pinCode: 3390)
    print(operation4)
} catch let error {
    print(error.localizedDescription)
}

print("Налиных денег \(atm.cashRub) RUB")
print("Налиных денег \(atm.cashUsd) USD")

