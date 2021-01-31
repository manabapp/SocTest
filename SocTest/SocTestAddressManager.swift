//
//  SocTestAddressManager.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

struct SocTestAddressManager: View {
    @EnvironmentObject var object: SocTestSharedObject
    
    static let maxRegistNumber: Int = 32
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_ADDRESS_LIST").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_ADDRESS_LIST").font(.system(size: 12)) : nil) {
                    if self.object.addresses.count > 0 {
                        ForEach(0 ..< self.object.addresses.count, id: \.self) { i in
                            SocTestAddressRow(address: self.object.addresses[i], isDispClass: true)
                        }
                        .onDelete { indexSet in
                            SocLogger.debug("SocTestAddressManager: onDelete: \(indexSet)")
                            indexSet.forEach { i in
                                do {
                                    if self.object.addresses[i].isUnix {
                                        try self.object.addresses[i].delete()
                                    }
                                    self.object.addresses.remove(at: i)
                                }
                                catch let error as SocError {
                                    self.object.alertMessage = error.message
                                    self.object.alertDetail = error.detail
                                    self.object.isPopAlert = true
                                }
                                catch {
                                    fatalError("SocTestAddressManager: \(error)")
                                }
                            }
                            SocTestSharedObject.saveAddresses(addresses: self.object.addresses)
                        }
                        .onMove(perform: { (fromIndex, toIndex) in
                            SocLogger.debug("SocTestAddressManager: onMove: \(fromIndex) <---> \(toIndex)")
                            object.addresses.move(fromOffsets: fromIndex, toOffset: toIndex)
                            SocTestSharedObject.saveAddresses(addresses: self.object.addresses)
                        })
                    }
                    else {
                        SocTestCommonRow.noAddress
                            .foregroundColor(Color.init(UIColor.systemGray))
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarItems(trailing: EditButton())
            
            Form {
                NavigationLink(destination: AddressRegister()) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("New Address")
                            if object.appSettingDescription {
                                Text("Description_New_Address")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.init(UIColor.systemGray))
                            }
                        }
                        Spacer()
                    }
                }
            }
            .listStyle(PlainListStyle())
            .frame(height: 110)
        }
        .navigationBarTitle("Address Manager", displayMode: .inline)
    }
}

fileprivate struct AddressRegister: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Environment(\.presentationMode) var presentationMode
    @State private var familyIndex: Int = 0
    @State private var addrTypeIndex: Int = 0
    @State private var hostString: String = ""
    @State private var pathString: String = ""
    @State private var portString: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_ADDRESS_FAMILY").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_ADDRESS_FAMILY").font(.system(size: 12)) : nil) {
                    Picker("", selection: self.$familyIndex) {
                        Text("AF_INET").tag(0)
                        Text("AF_UNIX").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                if self.familyIndex == 0 {
                    Section(header: Text("Header_ADDRESS").font(.system(size: 16, weight: .semibold)),
                            footer: object.appSettingDescription ? Text("Footer_HOST").font(.system(size: 12)) : nil) {
                        VStack(alignment: .leading) {
                            Picker("", selection: self.$addrTypeIndex) {
                                Text("Label_IPv4_address").tag(0)
                                Text("Label_FQDN").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 10)
                            
                            Text(self.addrTypeIndex == 0 ? "Label_IP_address" : "Label_Host_name")
                                .foregroundColor(Color.init(UIColor.systemGray))
                            TextField(self.addrTypeIndex == 0 ? "8.8.8.8" : "dns.google", text: $hostString)
                                .keyboardType(self.addrTypeIndex == 0 ? .decimalPad : .URL)
                                .padding(.leading, 10)
                                .padding(.bottom, 10)
                            
                            Text("Label_Port_number")
                                .foregroundColor(Color.init(UIColor.systemGray))
                            TextField("53", text: $portString)
                                .keyboardType(.numberPad)
                                .padding(.leading, 10)
                        }
                    }
                }
                else {
                    Section(header: Text("Header_ADDRESS").font(.system(size: 16, weight: .semibold)),
                            footer: object.appSettingDescription ? Text(NSLocalizedString("Footer_PATH", comment: "") + FileManager.default.temporaryDirectory.path).font(.system(size: 12)) : nil) {
                        VStack(alignment: .leading) {
                            Text("Label_UNIX_Path")
                                .foregroundColor(Color.init(UIColor.systemGray))
                            TextField("unixdomain.sock", text: $pathString)
                                .keyboardType(.URL)
                                .padding(.leading, 10)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("AddressRegister: Button: Register")
                    self.register()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19, height: 19, alignment: .center)
                        Text("Button_Register")
                            .padding(.leading, 10)
                            .padding(.trailing, 20)
                        Spacer()
                    }
                }
            }
            .frame(height: 110)
        }
        .navigationBarTitle("New Address", displayMode: .inline)
    }
    
    private func getInetAddress() throws -> SocAddress {
        guard !self.hostString.isEmpty else {
            SocLogger.debug("AddressRegister.getInetAddress: no host")
            throw SocTestError.NoValue
        }
        var newAddress: SocAddress
        if self.addrTypeIndex == 0 {
            guard self.hostString.isValidIPv4Format else {
                throw SocTestError.InvalidIpAddr
            }
        }
        guard !self.portString.isEmpty else {
            SocLogger.debug("AddressRegister.getInetAddress: no port")
            throw SocTestError.NoValue
        }
        guard let port = UInt16(self.portString) else {
            SocLogger.debug("AddressRegister.getInetAddress: invalid port '\(self.portString)'")
            throw SocTestError.InvalidPort
        }
        if self.addrTypeIndex == 0 {
            newAddress = SocAddress(family: AF_INET, addr: hostString, port: port)
            try newAddress.resolveHostName()
        }
        else {
            newAddress = try SocAddress.getAddressByName(name: hostString, port: port)
        }
        for address in self.object.addresses {
            if address.isInet && address.addr == newAddress.addr && address.port == newAddress.port {
                SocLogger.debug("AddressRegister.getInetAddress: \(newAddress.addr):\(newAddress.port) exists")
                throw SocTestError.AlreadyAddressExist
            }
        }
        if self.object.addresses.count >= SocTestAddressManager.maxRegistNumber {
            SocLogger.debug("AddressRegister.getInetAddress: Can't register anymore")
            throw SocTestError.AddressExceeded
        }
        SocLogger.debug("AddressRegister.getInetAddress: success \(newAddress.addr):\(newAddress.port):\(newAddress.hostName)")
        return newAddress
    }
    
    private func getUnixAddress() throws -> SocAddress {
        if self.pathString.isEmpty {
            SocLogger.debug("AddressRegister.getUnixAddress: no path")
            throw SocTestError.NoValue
        }
        guard self.pathString.count <= 100 else {
            throw SocTestError.TooLongPath
        }
        guard self.pathString.isValidPath else {
            throw SocTestError.InvalidPath
        }
        let newAddress = SocAddress(family: AF_UNIX, addr: self.pathString)
        for address in self.object.addresses {
            if address.isUnix && address.addr == newAddress.addr {
                SocLogger.debug("AddressRegister.getUnixAddress: \(newAddress.addr) exists")
                throw SocTestError.AlreadyAddressExist
            }
        }
        if self.object.addresses.count >= SocTestAddressManager.maxRegistNumber {
            SocLogger.debug("AddressRegister.getUnixAddress: \(self.object.addresses.count) >= \(SocTestAddressManager.maxRegistNumber) exceeded")
            throw SocTestError.AddressExceeded
        }
        SocLogger.debug("AddressRegister.getUnixAddress: success \(newAddress.addr)")
        return newAddress
    }
    
    private func register() {
        do {
            let address: SocAddress
            if self.familyIndex == 0 {
                address = try self.getInetAddress()
            }
            else {
                address = try self.getUnixAddress()
            }
            self.object.addresses.append(address)
            SocTestSharedObject.saveAddresses(addresses: self.object.addresses)
            self.presentationMode.wrappedValue.dismiss()
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("AddressRegister: \(error)")
        }
    }
}
