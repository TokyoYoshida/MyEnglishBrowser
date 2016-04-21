//
//  WordDictonary.swift
//  MyEnglishBrowser
//
//  Created by TokyoMac on 2016/03/18.
//  Copyright © 2016年 TokyoMac. All rights reserved.
//
//

import Foundation
import RxSwift

class  GenericDictionary<F,T>: WordDictionary {
    private let _search:F -> Observable<T?>

    init<D:WordDictionary where D.FromWordType == F, D.ToWordType ==T>(_ dictApi: D){
        _search = dictApi.search
    }

    func search(from_word: F) -> Observable<T?> {
        return _search(from_word)
    }
}