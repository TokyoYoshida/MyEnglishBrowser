//
//  DejizoApi.swift
//  MyEnglishBrowser
//
//  Created by TokyoMac on 2016/03/18.
//  Copyright © 2016年 TokyoMac. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SWXMLHash

enum ResultWord {
    case NotFound(from_word:String)
    case IndexFound(from_word: String,index: String)
    case WordFound(from_word: String,to_word: String)

    var index: String? {
        switch self {
        case .IndexFound(let touple):
            return touple.index
        default:
            return nil
        }
    }

    var from_word: String {
        switch self {
        case .NotFound(let string):
            return string
        case .IndexFound(let touple):
            return touple.from_word
        case .WordFound(let touple):
            return touple.from_word
        }
    }
    
    var to_word: String? {
        switch self {
        case .WordFound(let touple):
            return touple.to_word
        default:
            return nil
        }
    }
}
class DejizoDictionary: WordDictionary {
    let urlString = "http://public.dejizo.jp/NetDicV09.asmx/"
    
    func search(from_word: PublishSubject<String>) -> Observable<ResultWord?> {
        return from_word.flatMap {[unowned self] in
            self.searchWordIndex($0).flatMap {
                self.getWordAtIndex($0!)
            }
        }
    }

    private func searchWordIndex(from_word: String) -> Observable<ResultWord?> {
        print("search for")
        print(from_word)
        return Observable.create({ [unowned self](observer) -> Disposable in
            let postBody = [
                "Dic": "EJdict",
                "Scope": "HEADWORD",
                "Match": "STARTWITH",
                "Merge": "AND",
                "Prof": "XHTML",
                "PageSize": "20",
                "PageIndex": "0",
                "Word": from_word
            ]
            let request = Alamofire.request(.GET,self.urlString + "SearchDicItemLite", parameters: postBody)
                .response { (request, response, data, error) in
                    if let error = error {
                        observer.onError(error)
                    } else if let data = data {
                        let xml = SWXMLHash.parse(data)
                        let list = xml["SearchDicItemResult"]["TitleList"].children
                        if list.count == 0 {
                            observer.onNext(ResultWord.NotFound(from_word: from_word))
                            print("complete index not found")
                        } else {
                            for e in list {
                                observer.onNext(ResultWord.IndexFound(from_word: from_word, index: (e["ItemID"].element?.text)!))
                            }
                            print("complete index found")
                        }
                        observer.onCompleted()
                    }
            }
            return AnonymousDisposable{
                request.cancel()
            }
        })
    }
    
    private func getWordAtIndex(index: ResultWord) -> Observable<ResultWord?> {
        return Observable.create({ [unowned self](observer) -> Disposable in
            guard let indexStr = index.index else {
                observer.onNext(ResultWord.NotFound(from_word: index.from_word))
                observer.onCompleted()
                return AnonymousDisposable{
                    return
                }
            }
            let postBody = [
                "Dic": "EJdict",
                "Item": indexStr,
                "Loc": "",
                "Prof": "XHTML",
            ]
            let request = Alamofire.request(.GET,self.urlString + "GetDicItemLite", parameters: postBody)
                .response { (request, response, data, error) in
                    if let error = error {
                        observer.onError(error)
                    } else if let data = data {
                        let xml = SWXMLHash.parse(data)
                        observer.onNext (ResultWord.WordFound(from_word: index.from_word , to_word:  (xml["GetDicItemResult"]["Body"]["div"]["div"].element?.text)!))
                    }
                    print("complete words")
                    observer.onCompleted()
            }
            return AnonymousDisposable{
                request.cancel()
            }
        })
    }

}
