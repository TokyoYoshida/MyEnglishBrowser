//
//  WordDictionary.swift
//  MyEnglishBrowser
//
//  Created by TokyoMac on 2016/03/21.
//  Copyright © 2016年 TokyoMac. All rights reserved.
//

import Foundation
import RxSwift

protocol WordDictionary{
    associatedtype FromWordType
    associatedtype ToWordType
    
    func search(from_word: FromWordType) -> Observable<ToWordType?>
}

