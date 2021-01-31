//
//  SocTestSocketSimulator.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI
    
struct SocTestSocketSimulator: View {
    @EnvironmentObject var object: SocTestSharedObject
    static var canPoll: Bool = true
    static let nsLock = NSLock()
    
    var body: some View {
        List {
            Section(header: HStack { Text("Header_SOCKET_LIST"); Spacer(); grPoint }) {
                ForEach(0 ..< self.object.sockets.count, id: \.self) { i in
#if DEBUG
                    if !self.object.sockets[i].isClosed {
                        NavigationLink(destination: SocTestFunction(socket: self.$object.sockets[i]),
                                       isActive: self.$object.sockets[i].isActive) {
                            SocketRow(socket: self.$object.sockets[i])
                        }
                        .isDetailLink(false)
                    }
#else
                    if !self.object.sockets[i].isClosed {
                        NavigationLink(destination: SocTestFunction(socket: self.$object.sockets[i])) {
                            SocketRow(socket: self.$object.sockets[i])
                        }
                        .isDetailLink(false)
                    }
#endif
                }
                .onDelete { indexSet in
                    indexSet.forEach { i in
                        SocLogger.debug("SocTestSocketSimulator: onDelete: \(i)")
                        self.executeClose(socket: &self.object.sockets[i])
                    }
                }
                
                NavigationLink(destination: FunctionSocket()) {
                    SocTestCommonRow.functions[FUNC_SOCKET]
                }
                .isDetailLink(false)
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Socket Simulator", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
    
    private var grPoint: GeometryReader<Text> {
        GeometryReader { g -> Text in
            let frame = g.frame(in: CoordinateSpace.global)
            if frame.origin.y > 200 {
                SocTestSocketSimulator.nsLock.lock()
                if SocTestSocketSimulator.canPoll {
                    SocTestSocketSimulator.canPoll = false
                    SocLogger.debug("SocTestSocketSimulator.grPoint: pull to poll  Y=\(frame.origin.y)")
                    let ret = SocSocket.poll(sockets: &self.object.sockets)
                    if ret > 0 && self.object.appSettingAutoMonitoring {
                        SocLogger.debug("SocTestSocketSimulator.grPoint: post poll check: start")
                        for i in 0 ..< self.object.sockets.count {
                            Self.postErrno(socket: &self.object.sockets[i])
                        }
                        SocLogger.debug("SocTestSocketSimulator.grPoint: post poll check: end")
                    }
                    Thread.sleep(forTimeInterval: 1.0)
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        SocLogger.debug("SocTestSocketSimulator.grPoint: asyncAfter wake up  Y=\(frame.origin.y)")
                        SocTestSocketSimulator.canPoll = true
                    }
                }
                SocTestSocketSimulator.nsLock.unlock()
            }
            return Text("")
        }
    }
    
    private func executeClose(socket: inout SocSocket) {
        do {
            try socket.close()
            socket.isClosed = true
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("SocTestSocketSimulator.executeClose: \(error)")
        }
    }
    
    static func getName(socket: SocSocket) -> String {
        if let remoteAddress = socket.remoteAddress {
            if remoteAddress.isValid {
                return remoteAddress.isInet ? "Dst \(remoteAddress.addr):\(remoteAddress.port)" : "Dst \(remoteAddress.addr)"
            }
        }
        else if let localAddress = socket.localAddress {
            if (socket.isDgram || socket.isListening) && localAddress.isValid {
                return localAddress.isInet ? "Src \(localAddress.addr):\(localAddress.port)" : "Src \(localAddress.addr)"
            }
        }
        return socket.isInet ? "INET domain socket" : "UNIX domain socket"
    }
    
    static func postAddress(socket: inout SocSocket) {
        SocLogger.debug("SocTestSocketSimulator.postAddress: fd=\(socket.fd)")
        do {
            if socket.isStream && (socket.localAddress == nil || !socket.localAddress!.isValid || socket.localAddress!.isAny) {
                socket.localAddress = try socket.getsockname()
            }
        }
        catch {
            SocLogger.error("SocTestSocketSimulator.postAddress: fd=\(socket.fd): \(error)")  //No assertion
        }
    }

    static func postConnInfo(socket: inout SocSocket) {
        SocLogger.debug("SocTestSocketSimulator.postConnInfo: fd=\(socket.fd)")
        do {
            if socket.isTcp {
                let ret = try socket.getsockopt(level: IPPROTO_TCP, option: TCP_CONNECTION_INFO)
                socket.connInfo = ret.connInfo
            }
        }
        catch {
            SocLogger.error("SocTestSocketSimulator.postConnInfo: fd=\(socket.fd): \(error)")  //No assertion
        }
    }
    
    static func postPoll(socket: inout SocSocket) {
        SocLogger.debug("SocTestSocketSimulator.postPoll: fd=\(socket.fd)")
        do {
            socket.revents = try socket.poll(events: POLLIN|POLLPRI|POLLOUT, timeout: 0)
        }
        catch {
            SocLogger.error("SocTestSocketSimulator.postPoll: fd=\(socket.fd): \(error)")  //No assertion
        }
    }
    
    static func postErrno(socket: inout SocSocket) {
        if socket.isClosed {
            return
        }
        SocLogger.debug("SocTestSocketSimulator.postErrno: fd=\(socket.fd)")
        do {
            if socket.isConnecting && socket.revents > 0 {
                let ret = try socket.getsockopt(level: SOL_SOCKET, option: SO_ERROR)
                let connErrno = Int32(ret.int)
                if connErrno == 0 {
                    if socket.revents & POLLOUT > 0 {
                        socket.isConnecting = false
                        socket.isConnected = true
                    }
                }
                else {
                    socket.isConnecting = false
                    socket.connErrno = connErrno
                }
            }
        }
        catch {
            SocLogger.error("SocTestSocketSimulator.postErrno: fd=\(socket.fd): \(error)")  //No assertion
        }
    }
}

fileprivate struct SocketRow: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    
    var body: some View {
        HStack {
            Image(systemName: self.socket.isServer ? "paperplane.fill" : "paperplane")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                if let src = self.srcName {
                    Text(src)
                        .font(.system(size: 14))
                }
                HStack {
                    Text(SocTestSocketSimulator.getName(socket: self.socket))
                        .font(.system(size: 19, weight: .bold))
                        .padding(.trailing, -5)
                    Spacer()
                    if object.appSettingDescription {
                        self.blockingIcon
                            .font(.system(size: 15, weight: .bold))
                    }
                    if object.appSettingAutoMonitoring && self.socket.isStream {
                        self.statusIcon
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                if object.appSettingDescription {
                    self.descriptionText
                        .font(.system(size: 12))
                        .foregroundColor(Color.init(UIColor.systemGray))
                        .padding(.trailing, -5)
                        .lineLimit(1)
                }
                if object.appSettingAutoMonitoring && self.socket.isStream {
                    self.statusText
                        .font(.system(size: 12))
                        .padding(.trailing, -5)
                        .lineLimit(1)
                }
                if object.appSettingAutoMonitoring && self.socket.isTcp {
                    self.tcpStateText
                        .font(.system(size: 12))
                        .foregroundColor(Color.init(UIColor.systemGray))
                        .padding(.trailing, -5)
                        .lineLimit(1)
                    if self.socket.connInfo.tcpi_state >= 2 { // CLOSED(0), LISTEN(1)
                        self.tcpTrafficRxText
                            .font(.system(size: 12))
                            .foregroundColor(Color.init(UIColor.systemGray))
                            .padding(.trailing, -5)
                            .lineLimit(1)
                        self.tcpTrafficTxText
                            .font(.system(size: 12))
                            .foregroundColor(Color.init(UIColor.systemGray))
                            .padding(.trailing, -5)
                            .lineLimit(1)
                        self.tcpTrafficTxretransmiText
                            .font(.system(size: 12))
                            .foregroundColor(Color.init(UIColor.systemGray))
                            .padding(.trailing, -5)
                            .lineLimit(1)
                        self.tcpRttText
                            .font(.system(size: 12))
                            .foregroundColor(Color.init(UIColor.systemGray))
                            .padding(.trailing, -5)
                            .lineLimit(1)
                    }
                }
                HStack(spacing: 1) {
                    Group {
                        self.getEventMask(bit: POLLIN, bitName: "POLLIN")
                        Text("|").foregroundColor(Color.init(UIColor.systemGray)).font(.system(size: 10, weight: .semibold))
                        self.getEventMask(bit: POLLPRI, bitName: "POLLPRI")
                        Text("|").foregroundColor(Color.init(UIColor.systemGray)).font(.system(size: 10, weight: .semibold))
                        self.getEventMask(bit: POLLOUT, bitName: "POLLOUT")
                        Text("|").foregroundColor(Color.init(UIColor.systemGray)).font(.system(size: 10, weight: .semibold))
                        self.getEventMask(bit: POLLERR, bitName: "POLLERR")
                        Text("|").foregroundColor(Color.init(UIColor.systemGray)).font(.system(size: 10, weight: .semibold))
                        self.getEventMask(bit: POLLHUP, bitName: "POLLHUP")
                        Text("|").foregroundColor(Color.init(UIColor.systemGray)).font(.system(size: 10, weight: .semibold))
                    }
                    self.getEventMask(bit: POLLNVAL, bitName: "POLLNVAL")
                        .padding(.trailing, -25 )
                }
                .lineLimit(1)
                .padding(.vertical, 1)
            }
            .padding(.leading)
        }
    }
    
    private var srcName: String? {
        guard !self.socket.isListening && self.socket.isStream else {
            return nil
        }
        guard let localAddress = self.socket.localAddress else {
            return nil
        }
        guard localAddress.isValid else {
            return nil
        }
        return localAddress.isInet ? "Src \(localAddress.addr):\(localAddress.port)" : "Src \(localAddress.addr)"
    }
    
    private var blockingIcon: some View {
        let imageName: String = self.socket.isNonBlocking ? "lock.open.fill" : "lock.fill"
        let color: UIColor = self.socket.isNonBlocking ? UIColor.label : UIColor.systemGray

        return Image(systemName: imageName).foregroundColor(Color.init(color))
    }
    
    private var statusIcon: some View {
        let imageName: String
        let color: UIColor

        if self.socket.isListening {
            imageName = "paperplane.circle"
            color = UIColor.systemOrange
        }
        else if self.socket.isConnecting {
            imageName = "square.and.arrow.up"
            color = .label
        }
        else if self.socket.isConnected {
            if self.socket.isRdShutdown && self.socket.isWrShutdown {
                imageName = "xmark.circle.fill"
                color = UIColor.systemGray
            }
            else {
                if self.socket.isRdShutdown {
                    imageName = "arrow.up.circle.fill"
                    color = .label
                }
                else if self.socket.isWrShutdown {
                    imageName = "arrow.down.circle.fill"
                    color = .label
                }
                else {
                    imageName = "arrow.up.arrow.down.circle.fill"
                    color = UIColor.systemGreen
                }
            }
        }
        else {
            if self.socket.connErrno > 0 {
                imageName = "exclamationmark.triangle.fill"
                color = UIColor.systemRed
            }
            else {
                imageName = "arrow.up.arrow.down.circle.fill"
                color = UIColor.systemGray
            }
        }
        return Image(systemName: imageName).foregroundColor(Color.init(color))
    }
    
    private var descriptionText: Text {
        var description: String
        
        description = "FD:" + String(self.socket.fd)
        description += self.socket.isInet ? " / PF_INET" : " / PF_UNIX"
        description += self.socket.isStream ? " / SOCK_STREAM" : " / SOCK_DGRAM"
        for i in 1 ..< SocLogger.protocols.count {  // exclude 0
            if SocLogger.protocols[i] == self.socket.proto {
                description += " / \(SocLogger.protocolNames[i])"
                break
            }
        }
        return Text(description)
    }
    
    private var statusText: Text {
        var status = Text("Status: ").foregroundColor(Color.init(UIColor.systemGray))
        
        if self.socket.isListening {
            status = status + Text("Listening").fontWeight(.bold)
        }
        else if self.socket.isConnecting {
            status = status + Text("Connect in progress").fontWeight(.bold)
        }
        else if self.socket.isConnected {
            if !self.socket.isRdShutdown || !self.socket.isWrShutdown {
                status = status + Text("Connected").fontWeight(.bold)
            }
            else {
                status = status + Text("Disconnect").foregroundColor(Color.init(UIColor.systemGray))
            }
        }
        else {
            if self.socket.connErrno > 0 {
                status = status + Text("Connect error").fontWeight(.bold)
                status = status + Text(" -- Err#\(self.socket.connErrno) ").foregroundColor(Color.init(UIColor.systemGray))
                status = status + Text("\(ERRNO_NAMES[Int(self.socket.connErrno)])").foregroundColor(Color.init(UIColor.systemRed)).fontWeight(.bold)
            }
            else if self.socket.localAddress != nil {
                status = status + Text("Bound").foregroundColor(Color.init(UIColor.systemGray))
            }
            else {
                status = status + Text("Idle").foregroundColor(Color.init(UIColor.systemGray))
            }
        }
        return status
    }
    
    private var tcpStateText: Text {
        var tcpState = "TCP State: "
        //refer:/System/Volumes/Data/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/netinet/tcp_fsm.h
        if self.socket.connInfo.tcpi_state >= SocLogger.tcpStateNames.count {
            tcpState += "Unknown"
        }
        else {
            tcpState += SocLogger.tcpStateNames[Int(self.socket.connInfo.tcpi_state)]
        }
        return Text(tcpState)
    }
        
    private var tcpTrafficRxText: Text {
        var tcpTraffic: String
        
        let bytes = self.socket.connInfo.tcpi_rxbytes
        let packets = self.socket.connInfo.tcpi_rxpackets
        tcpTraffic = "RX: \(String.localizedStringWithFormat("%d", bytes)) "
        tcpTraffic += NSLocalizedString(bytes == 1 ? "Label_byte" : "Label_bytes", comment: "")
        tcpTraffic += " / \(String.localizedStringWithFormat("%d", packets)) "
        tcpTraffic += NSLocalizedString(packets == 1 ? "Label_packet" : "Label_packets", comment: "")
        return Text(tcpTraffic)
    }
    
    private var tcpTrafficTxText: Text {
        var tcpTraffic: String
        
        let bytes = self.socket.connInfo.tcpi_txbytes
        let packets = self.socket.connInfo.tcpi_txpackets
        tcpTraffic = "TX: \(String.localizedStringWithFormat("%d", bytes)) "
        tcpTraffic += NSLocalizedString(bytes == 1 ? "Label_byte" : "Label_bytes", comment: "")
        tcpTraffic += " / \(String.localizedStringWithFormat("%d", packets)) "
        tcpTraffic += NSLocalizedString(packets == 1 ? "Label_packet" : "Label_packets", comment: "")
        return Text(tcpTraffic)
    }
    
    private var tcpTrafficTxretransmiText: Text {
        var tcpTraffic: String
        
        let bytes = self.socket.connInfo.tcpi_txretransmitbytes
        let packets = self.socket.connInfo.tcpi_txretransmitpackets
        tcpTraffic = "Retransmit: \(String.localizedStringWithFormat("%d", bytes)) "
        tcpTraffic += NSLocalizedString(bytes == 1 ? "Label_byte" : "Label_bytes", comment: "")
        tcpTraffic += " / \(String.localizedStringWithFormat("%d", packets)) "
        tcpTraffic += NSLocalizedString(packets == 1 ? "Label_packet" : "Label_packets", comment: "")
        return Text(tcpTraffic)
    }
    
    private var tcpRttText: Text {
        var tcpRtt = "Average RTT: "
        tcpRtt += String(format: "%.3f ", Double(self.socket.connInfo.tcpi_srtt) / 1000)
        tcpRtt += NSLocalizedString("Label_sec", comment: "")
        tcpRtt += " / Recent RTT: "
        tcpRtt += String(format: "%.3f ", Double(self.socket.connInfo.tcpi_rttcur) / 1000)
        tcpRtt += NSLocalizedString("Label_sec", comment: "")
        return Text(tcpRtt)
    }
    
    private func getEventMask(bit: Int32, bitName: String) -> Text {
        if self.socket.revents & bit > 0 {
            return Text(bitName)
                .font(.system(size: 10, weight: .bold))
        }
        else {
            return Text(bitName)
                .font(.system(size: 10))
                .foregroundColor(Color.init(UIColor.systemGray))
        }
    }
}

fileprivate struct FunctionSocket: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Environment(\.presentationMode) var presentationMode
    @State private var familyIndex: Int = 0
    @State private var typeIndex: Int = 0
    @State private var protoIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_PROTOCOL_FAMILY").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_PROTOCOL_FAMILY").font(.system(size: 12)) : nil) {
                    Picker("", selection: self.$familyIndex) {
                        Text(SocLogger.protocolFamilyNames[0]).tag(0)
                        Text(SocLogger.protocolFamilyNames[1]).tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Header_SOCKET_TYPE").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_SOCKET_TYPE").font(.system(size: 12)) : nil) {
                    Picker("", selection: self.$typeIndex) {
                        Text(SocLogger.socketTypeNames[0]).tag(0)
                        Text(SocLogger.socketTypeNames[1]).tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Header_PROTOCOL").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_PROTOCOL").font(.system(size: 12)) : nil) {
                    Picker("", selection: self.$protoIndex) {
                        Text("0").tag(0)
                        Text("TCP").tag(1)
                        Text("UDP").tag(2)
#if DEBUG
                        Text("ICMP").tag(3)
#endif
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("FunctionSocket: Button: Done")
                    self.execute()
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
        .navigationBarTitle("socket", displayMode: .inline)
    }
    
    private func execute() {
        let family = SocLogger.protocolFamilies[familyIndex]
        let type = SocLogger.socketTypes[typeIndex]
        let proto = SocLogger.protocols[protoIndex]
        do {
            var socket = try SocSocket(family: family, type: type, proto: proto)
            if self.object.appSettingAutoMonitoring {
                SocTestSocketSimulator.postConnInfo(socket: &socket)
                SocTestSocketSimulator.postPoll(socket: &socket)
                SocTestSocketSimulator.postErrno(socket: &socket)
            }
            self.object.sockets.append(socket)
            self.presentationMode.wrappedValue.dismiss()
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("FunctionSocket.execute: \(error)")
        }
    }
}
