//
//  SocTestIO.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI
import StoreKit

struct SocTestIO: View {
    @Binding var socket: SocSocket
    var funcId: Int
    
    @State var iodata = SocTestIOData(name: "")  // set name when saving
    
    static let typeSend: Int32 = 0
    static let typeRecv: Int32 = 1
    static let dumpMaxLen: Int = 512
    
    var body: some View {
        VStack {
            switch funcId {
            case FUNC_SEND:
                DataContents(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: nil)
            case FUNC_SENDTO, FUNC_SENDMSG:
                ToAddress(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata)
            case FUNC_RECV:
                BufferSize(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: nil)
            default: //FUNC_RECVFROM, FUNC_RECVMSG
                FromAddress(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata)
            }
        }
    }
}

fileprivate struct ToAddress: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    
    var body: some View {
        List {
            Section(header: Text("Header_DESTINATION_ADDRESS2")) {
                NavigationLink(destination: DataContents(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: nil)) {
                    SocTestCommonRow.withoutAddress
                }
                ForEach(0 ..< self.object.addresses.count, id: \.self) { i in
                    NavigationLink(destination: DataContents(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.object.addresses[i])) {
                        SocTestAddressRow(address: self.object.addresses[i])
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text(SocTestCommonRow.functions[funcId].name), displayMode: .inline)
    }
}

fileprivate struct FromAddress: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_REMOTE_ADDRESS2").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_REMOTE_ADDRESS2").font(.system(size: 12)) : nil) {
                    Toggle(isOn: $object.needAddress) {
                        Text("Label_Obtains_an_address")
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                NavigationLink(destination: BufferSize(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: nil)) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Next")
                            if object.appSettingDescription {
                                Text("Description_New_BufferSize")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.init(UIColor.systemGray))
                            }
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 110)
        }
        .navigationBarTitle(Text(SocTestCommonRow.functions[funcId].name), displayMode: .inline)
    }
}

fileprivate struct DataContents: View {
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    var address: SocAddress?
    
    var body: some View {
        List {
            Section(header: Text("Header_DATA_CONTENTS")) {
                NavigationLink(destination: CustomData(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address)) {
                    SocTestCommonRow.contents[0]
                }
                ForEach(1 ..< SocTestCommonRow.contents.count) { i in
                    ZStack {
                        NavigationLink(destination: BufferSize(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address)) {
                            EmptyView()
                        }
                        Button(action: {
                            SocLogger.debug("DataContents: Button: \(i)")
                            self.iodata.type = SocTestCommonRow.contents[i].type
                        }) {
                            SocTestCommonRow.contents[i]
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text(SocTestCommonRow.functions[funcId].name), displayMode: .inline)
    }
}

fileprivate struct CustomData: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    var address: SocAddress?
    
    @State private var cmsgs: [SocCmsg] = []
    
    var body: some View {
        List {
            Section(header: Text("Header_DATA")) {
                ForEach(0 ..< self.object.iodatas.count, id: \.self) { i in
                    ZStack {
                        if self.object.iodatas[i].type == SocTestIOData.contentTypeCustom && self.object.iodatas[i].size > 0 {
                            switch funcId {
                            case FUNC_SENDMSG:
                                NavigationLink(destination: ControlMessages(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address)) {
                                    EmptyView()
                                }
                            default:
                                NavigationLink(destination: MsgFlags(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address, cmsgs: self.$cmsgs)) {
                                    EmptyView()
                                }
                            }
                        }
                        Button(action: {
                            SocLogger.debug("CustomData: Button: \(i)")
                            self.iodata = self.object.iodatas[i]
                        }) {
                            SocTestIODataRow(iodata: self.object.iodatas[i])
                        }
                        .disabled(self.object.iodatas[i].sendok ? false : true)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text(SocTestCommonRow.functions[funcId].name), displayMode: .inline)
    }
}

fileprivate struct BufferSize: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    var address: SocAddress?
    
    @State private var freeSize: Int = -1
    @State private var stringValue: String = ""
    @State private var indexStart: Int = 1
    @State private var cmsgs: [SocCmsg] = []
    
    var body: some View {
        List {
            Section(header: SocTestCommonRow.functions[funcId].type == SocTestIO.typeSend ? Text("Header_DATA_SIZE") : Text("Header_BUFFER_SIZE")) {
                if self.freeSize < 0 {
                    HStack {
                        SocTestCommonRow.bufSizes[0]
                        TextField("Label_Placeholder_freeSize", text: self.$stringValue)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                        Button(action: {
                            SocLogger.debug("BufferSize: Button: OK")
                            self.setSize()
                        }) {
                            Text("Button_OK")
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
                ForEach(indexStart ..< SocTestCommonRow.bufSizes.count, id: \.self) { i in
                    ZStack {
                        switch funcId {
                        case FUNC_SENDMSG:
                            NavigationLink(destination: ControlMessages(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address)) {
                                EmptyView()
                            }
                        case FUNC_RECVMSG:
                            NavigationLink(destination: ControlBufferSize(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address)) {
                                EmptyView()
                            }
                        default:
                            NavigationLink(destination: MsgFlags(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address, cmsgs: self.$cmsgs)) {
                                EmptyView()
                            }
                        }
                        Button(action: {
                            SocLogger.debug("BufferSize: Button: \(i)")
                            let size = i == 0 ? self.freeSize : Int(SocTestCommonRow.bufSizes[i].type)
                            self.iodata.data = SocTestIOData.createData(type: self.iodata.type, size: size)
                            self.iodata.size = size
                        }) {
                            HStack {
                                SocTestCommonRow.bufSizes[i]
                                Text(i == 0 ? "(\(self.freeSize) \(self.freeSize == 1 ? "byte" : "bytes"))" : "")
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text(SocTestCommonRow.functions[funcId].name), displayMode: .inline)
    }
    
    private func setSize() {
        do {
            guard !self.stringValue.isEmpty else {
                throw SocTestError.NoValue
            }
            guard let size = Int(self.stringValue) else {
                throw SocTestError.InvalidValue
            }
            guard size >= 1 && size <= 65536 else {
                throw SocTestError.InvalidValue
            }
            self.freeSize = size
            self.indexStart = 0
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("BufferSize: \(error)")
        }
    }
}

fileprivate struct ControlMessages: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    var address: SocAddress?
    
    @State private var cmsgs: [SocCmsg] = []
    @State private var fds: [Int32] = []
    @State private var retopts: ip_opts = ip_opts()
    @State private var pktinfo: in_pktinfo = in_pktinfo()
    @State private var isActiveRights: Bool = false
    @State private var isActiveRetopts: Bool = false
    @State private var isActivePktinfo: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_CONTROL_MESSAGES").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_CONTROL_MESSAGES").font(.system(size: 12)) : nil) {
                    ZStack {
                        NavigationLink(destination: ControlMessageRights(fds: self.$fds, check: self.$object.isControlDataChecks[0]),
                                       isActive: self.$isActiveRights) {
                            EmptyView()
                        }
                        Button(action: {
                            SocLogger.debug("ControlMessages: Button: 0")
                            if self.object.isControlDataChecks[0] {
                                self.object.isControlDataChecks[0] = false
                                isActiveRights = false
                            }
                            else {
                                isActiveRights = true
                            }
                        }) {
                            SocTestCommonRow.controlDatas[0]
                        }
                    }
                    
                    HStack {
                        SocTestCommonRow.controlDatas[1]
                            .contentShape(Rectangle())
                            .onTapGesture { self.object.isControlDataChecks[1].toggle() }
                        Image(systemName: "paperclip")
                            .font(.system(size: 12))
                            .foregroundColor(Color.init(UIColor.systemBlue))
                    }
                    
                    ZStack {
                        NavigationLink(destination: ControlMessageRetopts(opts: self.$retopts, check: self.$object.isControlDataChecks[2]),
                                       isActive: self.$isActiveRetopts) {
                            EmptyView()
                        }
                        Button(action: {
                            SocLogger.debug("ControlMessages: Button: 2")
                            if self.object.isControlDataChecks[2] {
                                self.object.isControlDataChecks[2] = false
                                isActiveRetopts = false
                            }
                            else {
                                for i in 0 ..< self.object.isDataChecks.count {
                                    self.object.isDataChecks[i] = false  //reset
                                }
                                isActiveRetopts = true
                            }
                        }) {
                            SocTestCommonRow.controlDatas[2]
                        }
                    }
                    
                    ZStack {
                        NavigationLink(destination: ControlMessagePktinfo(pktinfo: self.$pktinfo, check: self.$object.isControlDataChecks[3]),
                                       isActive: self.$isActivePktinfo) {
                            EmptyView()
                        }
                        Button(action: {
                            SocLogger.debug("ControlMessages: Button: 3")
                            if self.object.isControlDataChecks[3] {
                                self.object.isControlDataChecks[3] = false
                                isActivePktinfo = false
                            }
                            else {
                                isActivePktinfo = true
                            }
                        }) {
                            SocTestCommonRow.controlDatas[3]
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                ZStack {
                    NavigationLink(destination: MsgFlags(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address, cmsgs: self.$cmsgs)) {
                        EmptyView()
                    }
                    Button(action: {
                        SocLogger.debug("ControlMessages: Button: Next")
                        self.cmsgs = []
                        for i in 0 ..< SocTestCommonRow.controlDatas.count {
                            if self.object.isControlDataChecks[i] {
                                let cmsg: SocCmsg
                                switch SocTestCommonRow.controlDatas[i].type {
                                case SCM_RIGHTS:
                                    cmsg = try! SocCmsg.createRightsCmsg(fds: self.fds)
                                case SCM_CREDS:
                                    cmsg = SocCmsg.createCredsCmsg()
                                case IP_RETOPTS:
                                    cmsg = SocCmsg.createRetoptsCmsg(opts: self.retopts)
                                case IP_PKTINFO:
                                    cmsg = SocCmsg.createPktinfoCmsg(pktinfo: self.pktinfo)
                                default:
                                    fatalError("ControlMessages: unknown type = \(SocTestCommonRow.controlDatas[i].type)")
                                }
                                self.cmsgs.append(cmsg)
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Next")
                                    .foregroundColor(Color.init(UIColor.label))
                                if object.appSettingDescription {
                                    Text("Description_Next_MsgFlags")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.init(UIColor.systemGray))
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
            .frame(height: 110)
        }
        .navigationBarTitle(Text("sendmsg"), displayMode: .inline)
    }
}

fileprivate struct ControlMessageRights: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Environment(\.presentationMode) var presentationMode
    @Binding var fds: [Int32]
    @Binding var check: Bool

    @State var fdsString: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("SCM_RIGHTS").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_SCM_RIGHTS").font(.system(size: 12)) : nil) {
                    VStack(alignment: .leading) {
                        TextField("Label_Placeholder_fds", text: self.$fdsString)
                            .keyboardType(.numbersAndPunctuation)
                            .padding(.leading, 10)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("ControlMessageRights: Button: Set")
                    self.setFDs()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "paperclip")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19, height: 19, alignment: .center)
                        Text("Button_Set")
                            .padding(.leading, 10)
                            .padding(.trailing, 20)
                        Spacer()
                    }
                }
            }
            .frame(height: 110)
        }
        .navigationBarTitle(Text("sendmsg"), displayMode: .inline)
    }
    
    private func setFDs() {
        do {
            self.fds = []
            guard !self.fdsString.isEmpty else {
                throw SocTestError.NoValue
            }
            guard fdsString.pregMatche(pattern: "^[0-9,]*$") else {
                SocLogger.debug("ControlMessageRights.setFDs: invalid fds '\(self.fdsString)'")
                throw SocTestError.InvalidValue
            }
            let array: [String] = fdsString.components(separatedBy: ",")
            for i in 0 ..< array.count {
                guard let fd = Int32(array[i]) else {
                    throw SocTestError.InvalidValue
                }
                guard fd >= 0 else {
                    throw SocTestError.InvalidValue
                }
                self.fds.append(fd)
            }
            guard self.fds.count > 0 else {
                throw SocTestError.InvalidValue
            }
            check = true
            self.presentationMode.wrappedValue.dismiss()
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("ControlMessageRights.setFds: \(error)")
        }
    }
}

fileprivate struct ControlMessageRetopts: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Environment(\.presentationMode) var presentationMode
    @Binding var opts: ip_opts
    @Binding var check: Bool
    
    @State var addrString: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("IP_RETOPTS").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_IP_RETOPTS").font(.system(size: 12)) : nil) {
                    VStack(alignment: .leading) {
                        Text("Label_Destination_address")
                            .foregroundColor(Color.init(UIColor.systemGray))
                        TextField("", text: self.$addrString)
                            .keyboardType(.numberPad)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        
                        Text("Label_IP_options")
                            .foregroundColor(Color.init(UIColor.systemGray))
                        ForEach(0 ..< self.object.iodatas.count, id: \.self) { i in
                            SocTestIODataRow(iodata: self.object.iodatas[i], selectable: true, isCheck: self.object.isDataChecks[i])
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !self.object.isDataChecks[i] {
                                        for j in 0 ..< self.object.isDataChecks.count {
                                            self.object.isDataChecks[j] = false
                                        }
                                    }
                                    self.object.isDataChecks[i].toggle()
                                }
                                .disabled(self.object.iodatas[i].sendok ? false : true)
                        }
                        .padding(.leading, 10)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("ControlMessageRetopts: Button: Set")
                    self.setOpts()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "paperclip")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19, height: 19, alignment: .center)
                        Text("Button_Set")
                            .padding(.leading, 10)
                            .padding(.trailing, 20)
                        Spacer()
                    }
                }
            }
            .frame(height: 110)
        }
        .navigationBarTitle(Text("sendmsg"), displayMode: .inline)
    }
    
    private func setOpts() {
        do {
            guard !self.addrString.isEmpty else {
                throw SocTestError.NoValue
            }
            guard self.addrString.isValidIPv4Format else {
                throw SocTestError.InvalidIpAddr
            }
            guard inet_aton(self.addrString, &self.opts.ip_dst) != 0 else {
                throw SocTestError.InvalidIpAddr
            }
            var anyChecked: Bool = false
            for i in 0 ..< self.object.isDataChecks.count {
                if self.object.isDataChecks[i] {
                    let len = self.object.iodatas[i].size > 40 ? 40 : self.object.iodatas[i].size
                    self.object.iodatas[i].data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
                        let unsafeBufferPointer = pointer.bindMemory(to: UInt8.self)
                        Darwin.memcpy(&self.opts.ip_opts, unsafeBufferPointer.baseAddress, len)
                    }
                    anyChecked = true
                }
            }
            guard anyChecked else {
                throw SocTestError.NoData
            }
            check = true
            self.presentationMode.wrappedValue.dismiss()
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("ControlMessageRetopts.setOpts: \(error)")
        }
    }
}

fileprivate struct ControlMessagePktinfo: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Environment(\.presentationMode) var presentationMode
    @Binding var pktinfo: in_pktinfo
    @Binding var check: Bool
    
    @State var indexString: String = ""
    @State var addr1String: String = ""
    @State var addr2String: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("IP_PKTINFO").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_IP_PKTINFO").font(.system(size: 12)) : nil) {
                    VStack(alignment: .leading) {
                        Text("Label_Interface_index")
                            .foregroundColor(Color.init(UIColor.systemGray))
                        TextField("", text: self.$indexString)
                            .keyboardType(.numberPad)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        
                        Text("Label_Local_address")
                            .foregroundColor(Color.init(UIColor.systemGray))
                        TextField("", text: self.$addr1String)
                            .keyboardType(.numberPad)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        
                        Text("Label_Destination_address")
                            .foregroundColor(Color.init(UIColor.systemGray))
                        TextField("", text: self.$addr2String)
                            .keyboardType(.numberPad)
                            .padding(.leading, 10)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("ControlMessagePktinfo: Button: Set")
                    self.setInfo()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "paperclip")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19, height: 19, alignment: .center)
                        Text("Button_Set")
                            .padding(.leading, 10)
                            .padding(.trailing, 20)
                        Spacer()
                    }
                }
            }
            .frame(height: 110)
        }
        .navigationBarTitle(Text("sendmsg"), displayMode: .inline)
    }
    
    private func setInfo() {
        do {
            guard !self.indexString.isEmpty else {
                throw SocTestError.NoValue
            }
            guard let index = UInt32(self.indexString) else {
                throw SocTestError.InvalidIndex
            }
            self.pktinfo.ipi_ifindex = index
            guard !self.addr1String.isEmpty else {
                throw SocTestError.NoValue
            }
            guard self.addr1String.isValidIPv4Format else {
                throw SocTestError.InvalidIpAddr
            }
            guard inet_aton(self.addr1String, &self.pktinfo.ipi_spec_dst) != 0 else {
                throw SocTestError.InvalidIpAddr
            }
            guard !self.addr2String.isEmpty else {
                throw SocTestError.NoValue
            }
            guard self.addr2String.isValidIPv4Format else {
                throw SocTestError.InvalidIpAddr
            }
            guard inet_aton(self.addr2String, &self.pktinfo.ipi_addr) != 0 else {
                throw SocTestError.InvalidIpAddr
            }
            check = true
            self.presentationMode.wrappedValue.dismiss()
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("ControlMessagePktinfo.setInfo: \(error)")
        }
    }
}

fileprivate struct ControlBufferSize: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    var address: SocAddress?
    
    @State private var cmsgs: [SocCmsg] = []
    
    var body: some View {
        List {
            Section(header: Text("Header_CONTROL_BUFFER_SIZE")) {
                ForEach(0 ..< SocTestCommonRow.controlBufSizes.count, id: \.self) { i in
                    ZStack {
                        NavigationLink(destination: MsgFlags(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, address: self.address, cmsgs: self.$cmsgs, controlLen: Int(SocTestCommonRow.controlBufSizes[i].type))) {
                            SocTestCommonRow.controlBufSizes[i]
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text(SocTestCommonRow.functions[funcId].name), displayMode: .inline)
    }
}

fileprivate struct MsgFlags: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    var address: SocAddress?
    @Binding var cmsgs: [SocCmsg]
    var controlLen: Int = 1024

    @State private var dumpText: String = ""
    @State private var isGoBackActive = false
    @State private var isActive = false

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_MESSAGE_FLAGS").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_MESSAGE_FLAGS").font(.system(size: 12)) : nil) {
                    ForEach(0 ..< SocTestCommonRow.msgFlags.count) { i in
                        SocTestCommonRow.msgFlags[i]
                            .contentShape(Rectangle())
                            .onTapGesture { self.object.isMsgFlagChecks[i].toggle() }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Section() {
                    ZStack {
#if !DEBUG
                        NavigationLink(destination: SocTestSocketSimulator(), isActive: self.$isGoBackActive) {
                            EmptyView()
                        }
#endif
                        Button(action: {
#if DEBUG
                            self.socket.isActive = false
#else
                            self.isGoBackActive = true
#endif
                        }) {
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Go back Top")
                                        .foregroundColor(Color.init(UIColor.label))
                                    if object.appSettingDescription {
                                        Text("Description_Go_back_Top")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.init(UIColor.systemGray))
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                }
                Button(action: {
                    SocLogger.debug("MsgFlags: Button: Done \(SocTestCommonRow.functions[self.funcId].name)")
                    self.executeIO()
                }) {
                    ZStack {
                        NavigationLink(destination: DumpView(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata, text: $dumpText),
                                       isActive: $isActive) {
                            EmptyView()
                        }
                        HStack {
                            Spacer()
                            Image(systemName: "return")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 19, height: 19, alignment: .center)
                            Text("Button_Done")
                                .padding(.leading, 10)
                                .padding(.trailing, 20)
                            Spacer()
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .navigationBarTitle(Text(SocTestCommonRow.functions[funcId].name), displayMode: .inline)
    }
    
    private func executeIO() {
        var flags: Int32 = 0
        for i in 0 ..< SocTestCommonRow.msgFlags.count {
            if self.object.isMsgFlagChecks[i] {
                flags |= SocTestCommonRow.msgFlags[i].type
            }
        }
        self.object.isProcessing = true
        DispatchQueue.global().async {
            do {
                self.dumpText += "Data:\n"
                switch self.funcId {
                case FUNC_SEND:
                    self.iodata.size = try self.socket.send(data: self.iodata.data, flags: flags)
                    self.dumpText += self.iodata.getDump(maxLen: SocTestIO.dumpMaxLen)
                
                case FUNC_SENDTO:
                    self.iodata.size = try self.socket.sendto(data: self.iodata.data, flags: flags, address: self.address)
                    self.dumpText += self.iodata.getDump(maxLen: SocTestIO.dumpMaxLen)
                    if let to = self.address {
                        self.dumpText += "\nDestination:\n"
                        self.dumpText += self.dispAddress(address: to)
                    }
                    
                case FUNC_SENDMSG:
                    self.iodata.size = try self.socket.sendmsg(datas: [self.iodata.data], control: self.cmsgs, flags: flags, address: self.address)
                    self.dumpText += self.iodata.getDump(maxLen: SocTestIO.dumpMaxLen)
                    if let to = self.address {
                        self.dumpText += "\nDestination:\n"
                        self.dumpText += self.dispAddress(address: to)
                    }
                    if cmsgs.count > 0 {
                        self.dumpText += "\nControl Message:\n"
                        for i in 0 ..< cmsgs.count {
                            self.dumpText += " CMSG Len=\(cmsgs[i].hdr.cmsg_len), Level=\(cmsgs[i].levelName), Type=\(cmsgs[i].typeName)\n"
                            self.dumpText += cmsgs[i].data.dump
                            self.dumpText += "\n"
                        }
                    }
                    
                case FUNC_RECV:
                    self.iodata.size = try self.socket.recv(data: &self.iodata.data, flags: flags)
                    self.dumpText += self.iodata.getDump(maxLen: SocTestIO.dumpMaxLen)
                
                case FUNC_RECVFROM:
                    let ret = try self.socket.recvfrom(data: &self.iodata.data, flags: flags, needAddress: self.object.needAddress)
                    self.iodata.size = ret.0
                    self.dumpText += self.iodata.getDump(maxLen: SocTestIO.dumpMaxLen)
                    if let from = ret.1 {
                        self.dumpText += "\nSource:\n"
                        self.dumpText += self.dispAddress(address: from)
                    }
                    
                default: // FUNC_RECVMSG
                    var datas: [Data] = [self.iodata.data]
                    let ret = try self.socket.recvmsg(datas: &datas, controlLen: controlLen, flags: flags, needAddress: self.object.needAddress)
                    self.iodata.data = datas[0]
                    self.iodata.size = ret.0
                    self.dumpText += self.iodata.getDump(maxLen: SocTestIO.dumpMaxLen)
                    if let from = ret.3 {
                        self.dumpText += "\nSource:\n"
                        self.dumpText += self.dispAddress(address: from)
                    }
                    let msgFlags = ret.2
                    if msgFlags > 0 {
                        self.dumpText += "\nMessage Flags:\n"
                        self.dumpText += SocLogger.getMsgFlagsMask(msgFlags)
                        self.dumpText += "\n"
                    }
                    let cmsgs = ret.1
                    if cmsgs.count > 0 {
                        self.dumpText += "\nControl Message:\n"
                        for i in 0 ..< cmsgs.count {
                            self.dumpText += " CMSG Len=\(cmsgs[i].hdr.cmsg_len), Level=\(cmsgs[i].levelName), Type=\(cmsgs[i].typeName)\n"
                            self.dumpText += cmsgs[i].data.dump
                            self.dumpText += "\n"
                        }
                    }
                }
                DispatchQueue.main.async {
                    if SocTestCommonRow.functions[self.funcId].type == SocTestIO.typeRecv && self.iodata.size == 0 {
                        self.socket.isRdShutdown = true
                    }
                    if self.object.appSettingAutoMonitoring {
                        SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                        SocTestSocketSimulator.postPoll(socket: &self.socket)
                        SocTestSocketSimulator.postErrno(socket: &self.socket)
                    }
                }
                self.isActive.toggle()
            }
            catch let error as SocError {
                DispatchQueue.main.async {
                    if SocTestCommonRow.functions[self.funcId].type == SocTestIO.typeSend {
                        if error.code == EPIPE {
                            self.socket.isWrShutdown = true
                        }
                        if error.code == ECONNRESET {
                            self.socket.isRdShutdown = true
                            self.socket.isWrShutdown = true
                        }
                        if !self.socket.isConnecting && error.code == ENOTCONN {
                            self.socket.isRdShutdown = true
                            self.socket.isWrShutdown = true
                        }
                    }
                    else {  //SocTestIO.typeRecv
                        if error.code == ECONNRESET || error.code == ENOTCONN {
                            self.socket.isRdShutdown = true
                            self.socket.isWrShutdown = true
                        }
                        if self.socket.isConnecting && error.code != EAGAIN {
                            self.socket.isConnecting = false
                            self.socket.connErrno = error.code
                        }
                    }
                    if self.object.appSettingAutoMonitoring {
                        SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                        SocTestSocketSimulator.postPoll(socket: &self.socket)
                        SocTestSocketSimulator.postErrno(socket: &self.socket)
                    }
                    self.object.alertMessage = error.message
                    self.object.alertDetail = error.detail
                    self.object.isPopAlert = true
                }
            }
            catch {
                fatalError("MsgFlags.executeIO: \(error)")
            }
            DispatchQueue.main.async {
                self.object.isProcessing = false
            }
        }
    }
    
    private func dispAddress(address: SocAddress) -> String {
        var text: String = ""
        if address.isInet {
            text += " AF_INET\n"
            text += " \(address.addr):\(address.port)\n"
        }
        else {
            text += " AF_UNIX\n"
            text += address.addr.isEmpty ? " no path\n" : " \(address.addr)\n"
        }
        return text
    }
}

fileprivate struct DumpView: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    @Binding var text: String
    
    @State private var isEditable: Bool = false
    @State private var isDecodable: Bool = true
    
    var body: some View {
        VStack {
            if object.orientation.isPortrait {
                VStack {
                    SocTestScreen(text: self.$text, isEditable: $isEditable, isDecodable: $isDecodable)
                        .frame(minHeight: SocTestScreen.dumpScreenHeight, maxHeight: .infinity)
                    Text(self.iodata.label)
                        .font(.system(size: 14))
                        .padding(.top, -3)
                    DumpViewMenu(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata)
                }
            }
            else {
                HStack(alignment: .top) {
                    VStack {
                        SocTestScreen(text: self.$text, isEditable: $isEditable, isDecodable: $isDecodable)
                            .frame(width: object.deviceWidth)
                            .frame(maxHeight: .infinity)
                        Text(self.iodata.label)
                            .font(.system(size: 14))
                            .padding(.top, -3)
                            .padding(.bottom, 3)  //for landspace
                    }
                    DumpViewMenu(socket: self.$socket, funcId: self.funcId, iodata: self.$iodata)
                }
            }
        }
        .navigationBarTitle(Text(SocTestCommonRow.functions[funcId].name), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
}
 
fileprivate struct DumpViewMenu: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    var funcId: Int
    @Binding var iodata: SocTestIOData
    
    @State private var fullAsciiText: String = ""
    @State private var fullHexText: String = ""
    @State private var isAsciiDecodable: Bool = true
    @State private var isHexDecodable: Bool = true
    @State private var isActive: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                ZStack {
#if !DEBUG
                    NavigationLink(destination: SocTestSocketSimulator(), isActive: self.$isActive) {
                        EmptyView()
                    }
#endif
                    Button(action: {
#if DEBUG
                        self.socket.isActive = false
#else
                        self.isActive = true
#endif
                    }) {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Go back Top")
                                    .foregroundColor(Color.init(UIColor.label))
                                if object.appSettingDescription {
                                    Text("Description_Go_back_Top")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.init(UIColor.systemGray))
                                }
                            }
                            Spacer()
                        }
                    }
                }
                ZStack {
                    NavigationLink(destination: SocTestFullView(asciiText: self.$fullAsciiText, isAsciiDecodable: self.$isAsciiDecodable,
                                                                hexText: self.$fullHexText, isHexDecodable: self.$isHexDecodable)) {
                        EmptyView()
                    }
                    Button(action: {
                        SocLogger.debug("DumpViewMenu: Button: Full Screen")
                        self.setFullText()
                    }) {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Full Screen")
                                    .foregroundColor(Color.init(UIColor.label))
                                if object.appSettingDescription {
                                    Text("Description_Full_Screen")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.init(UIColor.systemGray))
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
            .frame(height: SocTestCommonRow.functions[funcId].type == SocTestIO.typeRecv ? 140 : 155)
            
            if SocTestCommonRow.functions[funcId].type == SocTestIO.typeRecv {
                Form {
                    ZStack {
                        Button(action: {
                            SocLogger.debug("DumpViewMenu: Button: Save")
                            self.save()
                        }) {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "tray.and.arrow.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 19, height: 19, alignment: .center)
                                    Text("Button_Save")
                                        .padding(.leading, 10)
                                        .padding(.trailing, 20)
                                    Spacer()
                                }
                                if !object.orientation.isPortrait {
                                    if object.appSettingDescription {
                                        Text("Description_RecvSave")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.init(UIColor.systemGray))
                                    }
                                }
                            }
                        }
                        .disabled(self.iodata.size == 0)
                    }
                }
                .frame(height: 110)
            }
        }
    }
    
    private func setFullText() {
        var isCRLF: Bool = false  //not use
        if let asciiString = self.iodata.getAscii(isCRLF: &isCRLF) {
            self.fullAsciiText = asciiString
            self.isAsciiDecodable = true
        }
        else {
            self.fullAsciiText = NSLocalizedString("Label_Non-unicode_character_data", comment: "")
            self.isAsciiDecodable = false
        }
        self.fullHexText = self.iodata.getDump()
        self.isHexDecodable = true
    }
    
    private func save() {
        do {
            try self.iodata.save()
            self.object.iodatas.append(self.iodata)
            object.alertMessage = NSLocalizedString("Message_Data_saving_done", comment: "")
            object.isAlerting = true
            DispatchQueue.global().async {
                sleep(1)
                DispatchQueue.main.async {
                    object.isAlerting = false
                }
            }
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("DumpViewMenu.save: \(error)")
        }
    }
}
