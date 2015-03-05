//
//  whereIs.swift
//  Caret
//
//  Created by Nate Armstrong on 3/3/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation

typealias Range = (Double, Double)
func whereIs(v: Double, of world: Range, within pixel: Range) -> Double {
  let r = (v-world.0)/(world.1-world.0)
  return pixel.0+(pixel.1-pixel.0)*r
}
