//
//  ViewController.swift
//  Peak
//
//  Created by Zhao on 2025/12/29.
//

import UIKit


struct PeakModel {
    var peakImage: UIImage?
    var peakValue: Int? //麻将的大小
    
    /// Initialize and verify image loading
    init(peakImage: UIImage?, peakValue: Int?) {
        self.peakImage = peakImage
        self.peakValue = peakValue
        
        // Debug: Check if image loaded successfully
        if peakImage == nil {
        }
    }
}


let peakA0 = PeakModel(peakImage: UIImage(named: "peakA 0"), peakValue: 1)
let peakA1 = PeakModel(peakImage: UIImage(named: "peakA 1"), peakValue: 2)
let peakA2 = PeakModel(peakImage: UIImage(named: "peakA 2"), peakValue: 3)
let peakA3 = PeakModel(peakImage: UIImage(named: "peakA 3"), peakValue: 4)
let peakA4 = PeakModel(peakImage: UIImage(named: "peakA 4"), peakValue: 5)
let peakA5 = PeakModel(peakImage: UIImage(named: "peakA 5"), peakValue: 6)
let peakA6 = PeakModel(peakImage: UIImage(named: "peakA 6"), peakValue: 7)
let peakA7 = PeakModel(peakImage: UIImage(named: "peakA 7"), peakValue: 8)
let peakA8 = PeakModel(peakImage: UIImage(named: "peakA 8"), peakValue: 9)



let peakB0 = PeakModel(peakImage: UIImage(named: "peakB 0"), peakValue: 1)
let peakB1 = PeakModel(peakImage: UIImage(named: "peakB 1"), peakValue: 2)
let peakB2 = PeakModel(peakImage: UIImage(named: "peakB 2"), peakValue: 3)
let peakB3 = PeakModel(peakImage: UIImage(named: "peakB 3"), peakValue: 4)
let peakB4 = PeakModel(peakImage: UIImage(named: "peakB 4"), peakValue: 5)
let peakB5 = PeakModel(peakImage: UIImage(named: "peakB 5"), peakValue: 6)
let peakB6 = PeakModel(peakImage: UIImage(named: "peakB 6"), peakValue: 7)
let peakB7 = PeakModel(peakImage: UIImage(named: "peakB 7"), peakValue: 8)
let peakB8 = PeakModel(peakImage: UIImage(named: "peakB 8"), peakValue: 9)



let peakC0 = PeakModel(peakImage: UIImage(named: "peakC 0"), peakValue: 1)
let peakC1 = PeakModel(peakImage: UIImage(named: "peakC 1"), peakValue: 2)
let peakC2 = PeakModel(peakImage: UIImage(named: "peakC 2"), peakValue: 3)
let peakC3 = PeakModel(peakImage: UIImage(named: "peakC 3"), peakValue: 4)
let peakC4 = PeakModel(peakImage: UIImage(named: "peakC 4"), peakValue: 5)
let peakC5 = PeakModel(peakImage: UIImage(named: "peakC 5"), peakValue: 6)
let peakC6 = PeakModel(peakImage: UIImage(named: "peakC 6"), peakValue: 7)
let peakC7 = PeakModel(peakImage: UIImage(named: "peakC 7"), peakValue: 8)
let peakC8 = PeakModel(peakImage: UIImage(named: "peakC 8"), peakValue: 9)

/// 所有麻将模型列表
let allPeakModels: [PeakModel] = [
    peakA0, peakA1, peakA2, peakA3, peakA4, peakA5, peakA6, peakA7, peakA8,
    peakB0, peakB1, peakB2, peakB3, peakB4, peakB5, peakB6, peakB7, peakB8,
    peakC0, peakC1, peakC2, peakC3, peakC4, peakC5, peakC6, peakC7, peakC8
]

/// 按牌面点数筛选模型
func peakModels(withValue value: Int) -> [PeakModel] {
    allPeakModels.filter { $0.peakValue == value }
}

