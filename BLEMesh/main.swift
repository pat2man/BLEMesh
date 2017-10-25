//
//  main.swift
//  BLEMesh
//
//  Created by Patrick Tescher on 10/24/17.
//  Copyright © 2017 Patrick Tescher. All rights reserved.
//

import CoreBluetooth

let runLoop = RunLoop.current

let scanner = BLEMeshScanner()

let central = CBCentralManager(delegate: scanner, queue: DispatchQueue.main)

while scanner.shouldKeepRunning && runLoop.run(mode: .defaultRunLoopMode, before: .distantFuture) {
    
}
