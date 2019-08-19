//
//  Extensions.swift
//  Bitsy
//
//  Created by sphota on 8/16/19.
//  Copyright © 2019 alevkov. All rights reserved.
//

import Foundation
import CoreGraphics

infix operator %%
func %% (percentage: Int, number: CGFloat) -> Int {
  return Int((Float(percentage) / 100) * Float(number))
}
