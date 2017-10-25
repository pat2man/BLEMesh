//
//  BLEMeshScanner.swift
//  BLEMesh
//
//  Created by Patrick Tescher on 10/24/17.
//  Copyright © 2017 Patrick Tescher. All rights reserved.
//

import CoreBluetooth

class BLEMeshScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var shouldKeepRunning = true        // global

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("State changed: \(central.state.rawValue)")


        switch central.state {
        case .poweredOff:
            print("Powered off")
        case .poweredOn:
            print("Powered on")
            central.scanForPeripherals(withServices: [meshServiceID], options: nil)
        case .resetting:
            print("Resetting")
        case .unauthorized:
            print("Unauthorized")
        case .unknown:
            print("Unknown state")
        case .unsupported:
            print("Unsupported state")
        }
    }

    var discoveredPeripherals = Set<CBPeripheral>()

    var foundMeshNodes = [CBPeripheral: (CBService, CBCharacteristic, CBCharacteristic)]()

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found peripheral: \(peripheral)")
        discoveredPeripherals.insert(peripheral)
        central.connect(peripheral, options: nil)
    }

    let meshServiceID = CBUUID(string: "0xFEE4")
    let meshMetadataCharacteristicID = CBUUID(string: "0x0004")
    let meshValueCharacteristicID = CBUUID(string: "0x0005")

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([meshServiceID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            print("Found services: \(services)")

            if let meshService = services.first(where: {$0.uuid == meshServiceID}) {
                peripheral.discoverCharacteristics([meshMetadataCharacteristicID, meshValueCharacteristicID], for: meshService)
            }
        }

        if let error = error {
            print("Error finding services:\(error)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if let services = peripheral.services {
            print("Modified services: \(services)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            print("Found characteristics: \(characteristics)")

            if let meshMetadataCharacteristic = characteristics.first(where: {$0.uuid == meshMetadataCharacteristicID}), let meshValueCharacteristic = characteristics.first(where: {$0.uuid == meshValueCharacteristicID}) {
                foundMeshNodes[peripheral] = (service, meshMetadataCharacteristic, meshValueCharacteristic)
            }
        }

        if let error = error {
            print("Error finding characteristics: \(error)")
        }
    }
}
