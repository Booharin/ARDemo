//
//  BitMaskCategory.swift
//  ARDemo
//
//  Created by Booharin on 03/01/2019.
//  Copyright © 2019 Booharin. All rights reserved.
//

struct BitMaskCategory {
    
    static let none = 0 << 0  // 00000000...0 0
    static let box = 1 << 0   // 00000000...1 1
    static let plane = 1 << 1 // 0000000...10 2
    
}
