//
//  DictResultView.swift
//  MyEnglishBrowser
//
//  Created by TokyoMac on 2016/04/02.
//  Copyright © 2016年 TokyoMac. All rights reserved.
//

import UIKit
import RxSwift

class DictResultViewModel {
    let dict = GenericDictionary(DejizoDictionary())
    let disposebag = DisposeBag()
    let search_word = PublishSubject<String>()
    // TODO: to transform view. aggregate results.
    init() {
        self.dict.search(search_word)
            .subscribe {
                print("final subscribe result = ")
                switch $0 {
                case .Next(let result):
                    print(result)
                    if let result = result {
                        switch result {
                        case .NotFound:
                            print("not found retry")
                            self.reTry(result.from_word)
                        default:
                            print("success")
                            print(result.from_word)
                            print(result.to_word)
                        }
                    }
                case .Error(let error):
                    print("on error")
                    print(error)
                case .Completed:
                    print("on completed")
                }
            }.addDisposableTo(disposebag)
    }
    
    func reTry (word: String) {
        switch word {
        case let w where right(w ,length: 2) == "ed" || right(w ,length: 2) == "es":
            search_word.onNext(left(w ,length: w.utf8.count-2 ))
            search_word.onCompleted()
        case let w where right(w ,length: 1) == "s" || right(w ,length: 1) == "d":
            search_word.onNext(left(w ,length: w.utf8.count-1 ))
            search_word.onCompleted()
        default:
            break
        }
    }
    
    func left(str: String ,length: Int) -> String{
        guard str.utf8.count >= length else {
            return ""
        }
        return str.substringToIndex(str.startIndex.advancedBy(length))
    }
    
    func right(str: String ,length: Int) -> String{
        guard str.utf8.count >= length else {
            return ""
        }
        return str.substringFromIndex(str.startIndex.advancedBy(str.utf8.count - length))
    }
}
