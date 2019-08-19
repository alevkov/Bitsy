//
//  Util.swift
//  Bitsy
//
//  Created by sphota on 8/15/19.
//  Copyright © 2019 alevkov. All rights reserved.
//

import Foundation

func DLog(message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
  print("\(file) : \(function) : \(line) : \(column) - \(message)")
}
