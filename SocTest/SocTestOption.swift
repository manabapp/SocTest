//
//  SocTestOption.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

struct SocTestOption: View {
    @Binding var socket: SocSocket
    
    var body: some View {
        List {
            Section(header: Text("Header_SOL_SOCKET_OPTIONS")) {
                ForEach(0 ..< SocTestCommonRow.solOptions.count) { i in
                    OptionRow(socket: self.$socket, level: SOL_SOCKET, index: i)
                }
            }
            Section(header: Text("Header_IPPROTO_TCP_OPTIONS")) {
                ForEach(0 ..< SocTestCommonRow.tcpOptions.count) { i in
                    OptionRow(socket: self.$socket, level: IPPROTO_TCP, index: i)
                }
            }
            Section(header: Text("Header_IPPROTO_UDP_OPTIONS")) {
                ForEach(0 ..< SocTestCommonRow.udpOptions.count) { i in
                    OptionRow(socket: self.$socket, level: IPPROTO_UDP, index: i)
                }
            }
            Section(header: Text("Header_IPPROTO_IP_OPTIONS")) {
                ForEach(0 ..< SocTestCommonRow.ipOptions.count) { i in
                    OptionRow(socket: self.$socket, level: IPPROTO_IP, index: i)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text(SocTestCommonRow.functions[FUNC_SETSOCKOPT].name), displayMode: .inline)
    }
}

fileprivate struct OptionRow: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    let level: Int32
    let index: Int
    
    @State private var option: Int32 = 0
    @State private var value: SocOptval = SocOptval()
    
    var body: some View {
        ZStack {
            NavigationLink(destination: OptionView(socket: self.$socket, level: self.level, option: self.option, value: self.$value)) {
                EmptyView()
            }
            Button(action: {
                SocLogger.debug("OptionRow: Button: level=\(level), index=\(index)")
                self.executeGetsockopt()
            }) {
                switch level {
                case SOL_SOCKET:
                    SocTestCommonRow.solOptions[self.index]
                case IPPROTO_TCP:
                    SocTestCommonRow.tcpOptions[self.index]
                case IPPROTO_UDP:
                    SocTestCommonRow.udpOptions[self.index]
                default: // IPPROTO_IP:
                    SocTestCommonRow.ipOptions[self.index]
                }
            }
        }
    }
    
    private func executeGetsockopt() {
        do {
            switch level {
            case SOL_SOCKET:
                self.option = SocTestCommonRow.solOptions[index].type
            case IPPROTO_TCP:
                self.option = SocTestCommonRow.tcpOptions[index].type
            case IPPROTO_UDP:
                self.option = SocTestCommonRow.udpOptions[index].type
            default: // IPPROTO_IP:
                self.option = SocTestCommonRow.ipOptions[index].type
            }
            if SocOptval.isSetOnly(level: level, option: option) {
                return
            }
            value = try self.socket.getsockopt(level: level, option: self.option)
            
            if self.level == SOL_SOCKET && self.option == SO_ERROR && self.socket.isConnecting {
                let connErrno = Int32(value.int)
                if connErrno > 0 {
                    self.socket.isConnecting = false
                    self.socket.connErrno = connErrno
                }
            }
            if self.level == IPPROTO_TCP && self.option == TCP_CONNECTION_INFO {
                self.socket.connInfo = value.connInfo
            }
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("OptionRow.executeGetsockopt: \(error)")
        }
    }
}

fileprivate struct OptionView: View {
    @Binding var socket: SocSocket
    let level: Int32
    let option: Int32
    @Binding var value: SocOptval
    
    var body: some View {
        VStack {
            if let optType = SocOptval.getOptionType(level: level, option: option) {
                switch optType {
                case SocOptval.typeNWService:
                    NWServiceOptionView(socket: self.$socket, level: self.level, option: self.option, value: self.$value)
                case SocOptval.typePortRange:
                    PortRangeOptionView(socket: self.$socket, level: self.level, option: self.option, value: self.$value)
                case SocOptval.typeInAddr:
                    InAddrOptionView(socket: self.$socket, level: self.level, option: self.option, value: self.$value)
                case SocOptval.typeIpMreq:
                    IpMreqOptionView(socket: self.$socket, level: self.level, option: self.option)
                case SocOptval.typeIpOptions:
                    IpOptionsOptionView(socket: self.$socket, level: self.level, option: self.option, value: self.$value)
                case SocOptval.typeTcpConnInfo:
                    TcpConnInfoOptionView(socket: self.$socket, level: self.level, option: self.option, value: self.$value)
                default: //typeBool, typeBool8, typeInt, typeInt8, typeUsec, typeLinger
                    DefaultOptionView(socket: self.$socket, level: self.level, option: self.option, value: self.$value)
                }
            }
        }
    }
}

fileprivate struct NWServiceOptionView: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    let level: Int32
    let option: Int32
    @Binding var value: SocOptval
    
    private var name: String { SocOptval.getOptionName(level: self.level, option: self.option) }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text(self.name).font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_Option_NWService").font(.system(size: 12)) : nil) {
                    Picker("", selection: self.$value.int) {
                        Text("BE").tag(Int(NET_SERVICE_TYPE_BE))  //0
                        Text("BK").tag(Int(NET_SERVICE_TYPE_BK))  //1
                        Text("SIG").tag(Int(NET_SERVICE_TYPE_SIG))  //2
                        Text("VI").tag(Int(NET_SERVICE_TYPE_VI))  //3
                        Text("VO").tag(Int(NET_SERVICE_TYPE_VO))  //4
                        Text("RV").tag(Int(NET_SERVICE_TYPE_RV))  //5
                        Text("AV").tag(Int(NET_SERVICE_TYPE_AV))  //6
                        Text("OAM").tag(Int(NET_SERVICE_TYPE_OAM))  //7
                        Text("RD").tag(Int(NET_SERVICE_TYPE_RD))  //8
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("NWServiceOptionView: Button: Done")
                    self.executeSetsockopt()
                }) {
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
            .frame(height: 110)
        }
        .navigationBarTitle(Text(SocTestCommonRow.functions[FUNC_SETSOCKOPT].name), displayMode: .inline)
    }
    
    private func executeSetsockopt() {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.setsockopt(level: self.level, option: self.option, value: self.value)
#if DEBUG
            self.socket.isActive = false
#else
            self.presentationMode.wrappedValue.dismiss()
#endif
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("NWServiceOptionView.executeSetsockopt: \(error)")
        }
    }
}

fileprivate struct PortRangeOptionView: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    let level: Int32
    let option: Int32
    @Binding var value: SocOptval
    
    private var name: String { SocOptval.getOptionName(level: self.level, option: self.option) }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text(self.name).font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_Option_PortRange").font(.system(size: 12)) : nil) {
                    Picker("", selection: self.$value.int) {
                        Text("Label_PortRange_DEFAULT").tag(Int(IP_PORTRANGE_DEFAULT))  //0
                        Text("Label_PortRange_HIGH").tag(Int(IP_PORTRANGE_HIGH))  //1
                        Text("Label_PortRange_LOW").tag(Int(IP_PORTRANGE_LOW))  //2
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("PortRangeOptionView: Button: Done")
                    self.executeSetsockopt()
                }) {
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
            .frame(height: 110)
        }
        .navigationBarTitle(Text(SocTestCommonRow.functions[FUNC_SETSOCKOPT].name), displayMode: .inline)
    }
    
    private func executeSetsockopt() {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.setsockopt(level: self.level, option: self.option, value: self.value)
#if DEBUG
            self.socket.isActive = false
#else
            self.presentationMode.wrappedValue.dismiss()
#endif
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("PortRangeOptionView.executeSetsockopt: \(error)")
        }
    }
}

fileprivate struct InAddrOptionView: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    let level: Int32
    let option: Int32
    @Binding var value: SocOptval
    
    private var name: String { SocOptval.getOptionName(level: self.level, option: self.option) }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text(self.name).font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_Option_InAddr").font(.system(size: 12)) : nil) {
                    TextField("", text: self.$value.addr)
                        .keyboardType(.decimalPad)
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("InAddrOptionView: Button: Done")
                    self.executeSetsockopt()
                }) {
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
            .frame(height: 110)
        }
        .navigationBarTitle(Text(SocTestCommonRow.functions[FUNC_SETSOCKOPT].name), displayMode: .inline)
    }
    
    private func executeSetsockopt() {
        do {
            guard !self.value.addr.isEmpty else {
                throw SocTestError.NoValue
            }
            guard self.value.addr.isValidIPv4Format else {
                throw SocTestError.InvalidIpAddr
            }
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.setsockopt(level: self.level, option: self.option, value: self.value)
#if DEBUG
            self.socket.isActive = false
#else
            self.presentationMode.wrappedValue.dismiss()
#endif
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
            fatalError("InAddrOptionView.executeSetsockopt: \(error)")
        }
    }
}

fileprivate struct IpMreqOptionView: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    let level: Int32
    let option: Int32
    
    @State var value = SocOptval()
    private var name: String { SocOptval.getOptionName(level: self.level, option: self.option) }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text(name).font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_Option_IpMreq").font(.system(size: 12)) : nil) {
                    VStack(alignment: .leading) {
                        Text("Label_IpMreq_multiaddr")
                            .foregroundColor(Color.init(UIColor.systemGray))
                        TextField("224.0.0.1", text: self.$value.addr)
                            .keyboardType(.decimalPad)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        
                        Text("Label_IpMreq_interface")
                            .foregroundColor(Color.init(UIColor.systemGray))
                        TextField("172.20.10.1", text: self.$value.addr2)
                            .keyboardType(.decimalPad)
                            .padding(.leading, 10)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("IpMreqOptionView: Button: Done")
                    self.executeSetsockopt()
                }) {
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
            .frame(height: 110)
        }
        .navigationBarTitle(Text("setsockopt"), displayMode: .inline)
    }
    
    private func executeSetsockopt() {
        do {
            guard !self.value.addr.isEmpty else {
                throw SocTestError.NoValue
            }
            guard self.value.addr.isValidIPv4Format else {
                throw SocTestError.InvalidIpAddr
            }
            guard !self.value.addr2.isEmpty else {
                throw SocTestError.NoValue
            }
            guard self.value.addr2.isValidIPv4Format else {
                throw SocTestError.InvalidIpAddr
            }
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.setsockopt(level: self.level, option: self.option, value: self.value)
#if DEBUG
            self.socket.isActive = false
#else
            self.presentationMode.wrappedValue.dismiss()
#endif
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
            fatalError("IpMreqOptionView: \(error)")
        }
    }
}

fileprivate struct IpOptionsOptionView: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    let level: Int32
    let option: Int32
    @Binding var value: SocOptval
    
    @State private var isEditable: Bool = false
    @State private var isDecodable: Bool = true
    private var name: String { SocOptval.getOptionName(level: self.level, option: self.option) }
    private var sizeString: String {
        if let data = value.data {
            return "\(data.count) " + NSLocalizedString(data.count == 1 ? "Label_byte" : "Label_bytes", comment: "")
        }
        else {
            return "0 " + NSLocalizedString("Label_bytes", comment: "")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                Text(self.name)
                    .font(.system(size: 16))
                    .foregroundColor(Color.init(UIColor.systemGray))
                    .padding(12)
                Spacer()
            }
            SocTestScreen(text: self.$value.text, isEditable: self.$isEditable, isDecodable: self.$isDecodable)
                .frame(minHeight: SocTestScreen.dumpScreenHeight, maxHeight: .infinity)
            Text(self.sizeString)
                .font(.system(size: 14))
                .padding(3)
            
            Form {
                NavigationLink(destination: IpOptionsSetting(socket: self.$socket, level: self.level, option: self.option, value: self.$value)) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Next")
                            if object.appSettingDescription {
                                Text("Description_Next_IpOptionsSetting")
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
        .navigationBarTitle(Text("getsockopt"), displayMode: .inline)
    }
}

fileprivate struct IpOptionsSetting: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    let level: Int32
    let option: Int32
    @Binding var value: SocOptval
    
    private var name: String { SocOptval.getOptionName(level: self.level, option: self.option) }
    
    var body: some View {
        List {
            Section(header: Text(name)) {
                ZStack {
                    Button(action: {
                        SocLogger.debug("IpOptionsSetting: Button: no data")
                        self.value.data = nil
                        self.executeSetsockopt()
                    }) {
                        HStack {
                            SocTestCommonRow.clearOptions
                            Image(systemName: "return")
                                .font(.system(size: 12))
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
                ForEach(0 ..< self.object.iodatas.count, id: \.self) { i in
                    ZStack {
                        Button(action: {
                            SocLogger.debug("IpOptionsSetting: Button: \(i)")
                            self.value.data = self.object.iodatas[i].data
                            self.executeSetsockopt()
                        }) {
                            HStack {
                                SocTestIODataRow(iodata: self.object.iodatas[i])
                                Image(systemName: "return")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.init(self.object.iodatas[i].sendok ? UIColor.systemBlue : UIColor.systemGray))
                            }
                        }
                        .disabled(self.object.iodatas[i].sendok ? false : true)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text("setsockopt"), displayMode: .inline)
    }
    
    private func executeSetsockopt() {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.setsockopt(level: self.level, option: self.option, value: self.value)
#if DEBUG
            self.socket.isActive = false
#else
            self.presentationMode.wrappedValue.dismiss()
#endif
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("IpOptionsSetting.executeSetsockopt: \(error)")
        }
    }
}

fileprivate struct TcpConnInfoOptionView: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket //nouse
    let level: Int32
    let option: Int32 //nouse
    @Binding var value: SocOptval
    
    private var name: String { SocOptval.getOptionName(level: self.level, option: self.option) }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text(self.name).font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_Option_TcpConnInfo").font(.system(size: 12)) : nil) {
                    Group {
                        HStack {
                            Text("tcpi_state")
                            Spacer()
                            if self.value.connInfo.tcpi_state >= SocLogger.tcpStateNames.count {
                                Text("Unknown(\(self.value.connInfo.tcpi_state))")
                            }
                            else {
                                Text(SocLogger.tcpStateNames[Int(self.value.connInfo.tcpi_state)] + "(\(self.value.connInfo.tcpi_state))")
                            }
                        }
                        HStack {
                            Text("tcpi_snd_wscale")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_snd_wscale))
                        }
                        HStack {
                            Text("tcpi_rcv_wscale")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_rcv_wscale))
                        }
                        HStack(alignment: .top) {
                            Text("tcpi_options")
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(self.value.connInfo.tcpi_options))
                                if Int32(self.value.connInfo.tcpi_options) & TCPCI_OPT_TIMESTAMPS == TCPCI_OPT_TIMESTAMPS {
                                    Text("TIMESTAMPS(0x1)")
                                }
                                if Int32(self.value.connInfo.tcpi_options) & TCPCI_OPT_SACK == TCPCI_OPT_SACK {
                                    Text("SACK(0x2)")
                                }
                                if Int32(self.value.connInfo.tcpi_options) & TCPCI_OPT_WSCALE == TCPCI_OPT_WSCALE {
                                    Text("WSCALE(0x4)")
                                }
                                if Int32(self.value.connInfo.tcpi_options) & TCPCI_OPT_ECN == TCPCI_OPT_ECN {
                                    Text("ECN(0x8)")
                                }
                            }
                        }
                        HStack(alignment: .top) {
                            Text("tcpi_flags")
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(self.value.connInfo.tcpi_flags))
                                if Int32(self.value.connInfo.tcpi_flags) & TCPCI_FLAG_LOSSRECOVERY == TCPCI_FLAG_LOSSRECOVERY {
                                    Text("LOSSRECOVERY(0x1)")
                                }
                                if Int32(self.value.connInfo.tcpi_flags) & TCPCI_FLAG_REORDERING_DETECTED == TCPCI_FLAG_REORDERING_DETECTED {
                                    Text("REORDERING_DETECTED(0x2)")
                                }
                            }
                        }
                        HStack {
                            Text("tcpi_rto")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_rto))
                        }
                        HStack {
                            Text("tcpi_maxseg")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_maxseg))
                        }
                        HStack {
                            Text("tcpi_snd_ssthresh")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_snd_ssthresh))
                        }
                        HStack {
                            Text("tcpi_snd_cwnd")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_snd_cwnd))
                        }
                        HStack {
                            Text("tcpi_snd_wnd")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_snd_wnd))
                        }
                    }
                    Group {
                        HStack {
                            Text("tcpi_snd_sbbytes")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_snd_sbbytes))
                        }
                        HStack {
                            Text("tcpi_rcv_wnd")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_rcv_wnd))
                        }
                        HStack {
                            Text("tcpi_rttcur")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_rttcur))
                        }
                        HStack {
                            Text("tcpi_srtt")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_srtt))
                        }
                        HStack {
                            Text("tcpi_rttvar")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_rttvar))
                        }
                    }

                    Group {
                        HStack {
                            Text("tcpi_tfo_cookie_req")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_cookie_req)
                        }
                        HStack {
                            Text("tcpi_tfo_cookie_rcv")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_cookie_rcv)
                        }
                        HStack {
                            Text("tcpi_tfo_syn_loss")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_syn_loss)
                        }
                        HStack {
                            Text("tcpi_tfo_syn_data_sent")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_syn_data_sent)
                        }
                        HStack {
                            Text("tcpi_tfo_syn_data_acked")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_syn_data_acked)
                        }
                        HStack {
                            Text("tcpi_tfo_syn_data_rcv")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_syn_data_rcv)
                        }
                        HStack {
                            Text("tcpi_tfo_cookie_req_rcv")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_cookie_req_rcv)
                        }
                        HStack {
                            Text("tcpi_tfo_cookie_sent")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_cookie_sent)
                        }
                        HStack {
                            Text("tcpi_tfo_cookie_invalid")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_cookie_invalid)
                        }
                        HStack {
                            Text("tcpi_tfo_cookie_wrong")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_cookie_wrong)
                        }
                    }
                    Group {
                        HStack {
                            Text("tcpi_tfo_no_cookie_rcv")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_no_cookie_rcv)
                        }
                        HStack {
                            Text("tcpi_tfo_heuristics_disable")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_heuristics_disable)
                        }
                        HStack {
                            Text("tcpi_tfo_send_blackhole")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_send_blackhole)
                        }
                        HStack {
                            Text("tcpi_tfo_recv_blackhole")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_recv_blackhole)
                        }
                        HStack {
                            Text("tcpi_tfo_onebyte_proxy")
                            Spacer()
                            CheckMark(flag: self.value.connInfo.tcpi_tfo_onebyte_proxy)
                        }
                    }
                    Group {
                        HStack {
                            Text("tcpi_txpackets")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_txpackets))
                        }
                        HStack {
                            Text("tcpi_txbytes")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_txbytes))
                        }
                        HStack {
                            Text("tcpi_txretransmitbytes")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_txretransmitbytes))
                        }
                        HStack {
                            Text("tcpi_rxpackets")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_rxpackets))
                        }
                        HStack {
                            Text("tcpi_rxbytes")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_rxbytes))
                        }
                        HStack {
                            Text("tcpi_rxoutoforderbytes")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_rxoutoforderbytes))
                        }
                        HStack {
                            Text("tcpi_txretransmitpackets")
                            Spacer()
                            Text(String(self.value.connInfo.tcpi_txretransmitpackets))
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarTitle(Text("getsockopt"), displayMode: .inline)
    }
    
    fileprivate struct CheckMark: View {
        let flag: UInt32
        
        var body: some View {
            if flag == 1 {
                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .bold))
            }
            else {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .thin))
                    .foregroundColor(Color.init(UIColor.systemGray))
            }
        }
    }
}

fileprivate struct DefaultOptionView: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    let level: Int32
    let option: Int32
    @Binding var value: SocOptval
    
    private var name: String { SocOptval.getOptionName(level: self.level, option: self.option) }
    private var isReadOnly: Bool { SocOptval.isGetOnly(level: level, option: option) }
    private var isBoolInverted: Bool { self.level == IPPROTO_TCP && (self.option == TCP_NOOPT || self.option == TCP_NOPUSH) }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                if let optType = SocOptval.getOptionType(level: level, option: option) {
                    switch optType {
                    case SocOptval.typeBool, SocOptval.typeBool8:
                        Section(header: Text(self.name).font(.system(size: 16, weight: .semibold)),
                                footer: object.appSettingDescription ? Text("Footer_Option_Bool").font(.system(size: 12)) : nil) {
                            Toggle(isOn: self.$value.bool) {
                                Text(self.isBoolInverted ? "Label_Disabled" : "Label_Enabled")
                            }
                            .disabled(isReadOnly)
                        }
                    case SocOptval.typeInt, SocOptval.typeInt8:
                        Section(header: Text(self.name).font(.system(size: 16, weight: .semibold)),
                                footer: object.appSettingDescription ? Text("Footer_Option_Int").font(.system(size: 12)) : nil) {
                            TextField("", text: self.$value.text)
                                .keyboardType(.numberPad)
                                .disabled(isReadOnly)
                        }
                    case SocOptval.typeUsec:
                        Section(header: Text(self.name).font(.system(size: 16, weight: .semibold)),
                                footer: object.appSettingDescription ? Text(level == SOL_SOCKET ? "Footer_Option_Usec" : "Footer_Option_Usec2").font(.system(size: 12)) : nil) {
                            TextField("", text: self.$value.text)
                                .keyboardType(.decimalPad)
                                .disabled(isReadOnly)
                        }
                    default: //SocOptval.typeLinger
                        Section(header: Text(self.name).font(.system(size: 16, weight: .semibold)),
                                footer: object.appSettingDescription ? Text("Footer_Option_Linger").font(.system(size: 12)) : nil) {
                            VStack(alignment: .leading) {
                                Toggle(isOn: self.$value.bool) {
                                    Text("Label_Enabled")
                                }
                                .padding(.bottom, 10)
                                
                                Text("Label_Linger_timeout")
                                    .foregroundColor(Color.init(UIColor.systemGray))
                                TextField("10", text: self.$value.text)
                                    .keyboardType(.numberPad)
                                    .padding(.leading, 10)
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            if !self.isReadOnly {
                Form {
                    Button(action: {
                        SocLogger.debug("DefaultOptionView: Button: Done")
                        self.executeSetsockopt()
                    }) {
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
                .frame(height: 110)
            }
        }
        .navigationBarTitle(Text(self.isReadOnly ? "getsockopt" : SocTestCommonRow.functions[FUNC_SETSOCKOPT].name), displayMode: .inline)
    }
    
    private func executeSetsockopt() {
        do {
            if let optType = SocOptval.getOptionType(level: self.level, option: self.option) {
                switch optType {
                case SocOptval.typeInt, SocOptval.typeLinger:
                    guard !self.value.text.isEmpty else {
                        throw SocTestError.NoValue
                    }
                    guard let intValue = Int32(self.value.text) else {
                        throw SocTestError.InvalidValue
                    }
                    guard intValue >= 0 else {
                        throw SocTestError.InvalidValue
                    }
                    self.value.int = Int(intValue)
                    
                case SocOptval.typeInt8:
                    guard !self.value.text.isEmpty else {
                        throw SocTestError.NoValue
                    }
                    guard let intValue = Int8(self.value.text) else {
                        throw SocTestError.InvalidValue
                    }
                    guard intValue >= 0 else {
                        throw SocTestError.InvalidValue
                    }
                    self.value.int = Int(intValue)
                    
                case SocOptval.typeUsec:
                    guard !self.value.text.isEmpty else {
                        throw SocTestError.NoValue
                    }
                    guard let doubleValue = Double(self.value.text) else {
                        throw SocTestError.InvalidValue
                    }
                    guard doubleValue >= 0.0 && doubleValue < Double(Int32.max) else {
                        throw SocTestError.InvalidValue
                    }
                    self.value.double = doubleValue
                    
                default:
                    break
                }
            }
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.setsockopt(level: self.level, option: self.option, value: self.value)
#if DEBUG
            self.socket.isActive = false
#else
            self.presentationMode.wrappedValue.dismiss()
#endif
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
            fatalError("DefaultOptionView.executeSetsockopt: \(error)")
        }
    }
}
