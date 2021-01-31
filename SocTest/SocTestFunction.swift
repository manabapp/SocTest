//
//  SocTestFunction.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

let FUNC_SOCKET: Int = 0
let FUNC_SETSOCKOPT: Int = 1
let FUNC_BIND: Int = 2
let FUNC_CONNECT: Int = 3
let FUNC_LISTEN: Int = 4
let FUNC_ACCEPT: Int = 5
let FUNC_SEND: Int = 6
let FUNC_SENDTO: Int = 7
let FUNC_SENDMSG: Int = 8
let FUNC_RECV: Int = 9
let FUNC_RECVFROM: Int = 10
let FUNC_RECVMSG: Int = 11
let FUNC_GETSOCKNAME: Int = 12
let FUNC_GETPEERNAME: Int = 13
let FUNC_SHUTDOWN: Int = 14
let FUNC_FCNTL: Int = 15
let FUNC_POLL: Int = 16
let FUNC_CLOSE: Int = 17

struct SocTestFunction: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    
    @State private var fcntlFlags: Int32 = 0
    @State private var fcntlBoolValue: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("Header_SYSTEM_CALLS")) {
                NavigationLink(destination: SocTestOption(socket: self.$socket)) {
                    SocTestCommonRow.functions[FUNC_SETSOCKOPT]
                }
                NavigationLink(destination: FunctionBind(socket: self.$socket)) {
                    SocTestCommonRow.functions[FUNC_BIND]
                }
                NavigationLink(destination: FunctionConnect(socket: self.$socket)) {
                    SocTestCommonRow.functions[FUNC_CONNECT]
                }
                NavigationLink(destination: FunctionListen(socket: self.$socket)) {
                    SocTestCommonRow.functions[FUNC_LISTEN]
                }
                NavigationLink(destination: FunctionAccept(socket: self.$socket)) {
                    SocTestCommonRow.functions[FUNC_ACCEPT]
                }
                Group {
                    ForEach(FUNC_SEND ..< FUNC_RECVMSG + 1) { id in
                        NavigationLink(destination: SocTestIO(socket: self.$socket, funcId: id)) {
                            SocTestCommonRow.functions[id]
                        }
                    }
                    Button(action: {
                        SocLogger.debug("SocTestFunction: Button: getsockname")
                        self.executeGetsockname()
                    }) {
                        HStack {
                            SocTestCommonRow.functions[FUNC_GETSOCKNAME]
                            Image(systemName: "return")
                                .font(.system(size: 12))
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                    Button(action: {
                        SocLogger.debug("SocTestFunction: Button: getpeername")
                        self.executeGetpeername()
                    }) {
                        HStack {
                            SocTestCommonRow.functions[FUNC_GETPEERNAME]
                            Image(systemName: "return")
                                .font(.system(size: 12))
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
                NavigationLink(destination: FunctionShutdown(socket: self.$socket)) {
                    SocTestCommonRow.functions[FUNC_SHUTDOWN]
                }
                ZStack {
                    NavigationLink(destination: FunctionFcntl(socket: self.$socket, flags: self.$fcntlFlags, boolValue: self.$fcntlBoolValue)) {
                        EmptyView()
                    }
                    Button(action: {
                        SocLogger.debug("SocTestFunction: Button: fcntl")
                        self.executeFcntl()
                    }) {
                        SocTestCommonRow.functions[FUNC_FCNTL]
                    }
                }
                NavigationLink(destination: FunctionPoll(socket: self.$socket)) {
                    SocTestCommonRow.functions[FUNC_POLL]
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text(SocTestSocketSimulator.getName(socket: self.socket)), displayMode: .inline)
    }
    
    func executeGetsockname() {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            let address = try self.socket.getsockname()
            if address.isValid {
                self.socket.localAddress = address
                object.alertMessage = address.isInet ? "\(address.addr):\(address.port)" : address.addr
            }
            else {
                object.alertMessage = NSLocalizedString("Label_No_address", comment: "")
            }
//            object.alertMessage = SocTestAddressManager.getTitle(address: address)
            object.isAlerting = true
            DispatchQueue.global().async {
                sleep(1)
                DispatchQueue.main.async {
                    object.isAlerting = false
                }
            }
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("SocTestFunction.executeGetsockname: \(error)")
        }
    }
    
    func executeGetpeername() {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            let address = try self.socket.getpeername()
            if address.isValid {
                self.socket.remoteAddress = address
                object.alertMessage = address.isInet ? "\(address.addr):\(address.port)" : address.addr
            }
            else {
                object.alertMessage = NSLocalizedString("Label_No_address", comment: "")
            }
//            object.alertMessage = SocTestAddressManager.getTitle(address: address)
            object.isAlerting = true
            DispatchQueue.global().async {
                sleep(1)
                DispatchQueue.main.async {
                    object.isAlerting = false
                }
            }
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("SocTestFunction.executeGetpeername: \(error)")
        }
    }
    
    func executeFcntl() {
        do {
            self.fcntlFlags = try self.socket.fcntl(cmd: F_GETFL, flags: 0)
            self.fcntlBoolValue = (self.fcntlFlags & O_NONBLOCK == O_NONBLOCK)
        }
        catch let error as SocError {
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("SocTestFunction.executeFcntl: \(error)")
        }
    }
}

fileprivate struct FunctionBind: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    
    var body: some View {
        List {
            Section(header: Text("Header_SOCKET_ADDRESS")) {
                ForEach(0 ..< self.object.addresses.count, id: \.self) { i in
                    Button(action: {
                        SocLogger.debug("FunctionBind: Button: \(i)")
                        self.execute(address: self.object.addresses[i])
                    }) {
                        HStack {
                            SocTestAddressRow(address: self.object.addresses[i])
                            Image(systemName: "return")
                                .font(.system(size: 12))
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text("bind"), displayMode: .inline)
    }
    
    private func execute(address: SocAddress) {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.bind(address: address)
            self.socket.localAddress = address
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
            fatalError("FunctionBind.execute: \(error)")
        }
    }
}

fileprivate struct FunctionConnect: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    
    var body: some View {
        List {
            Section(header: Text("Header_DESTINATION_ADDRESS")) {
                ForEach(0 ..< self.object.addresses.count, id: \.self) { i in
                    Button(action: {
                        SocLogger.debug("FunctionConnect: Button: \(i)")
                        self.execute(address: self.object.addresses[i])
                    }) {
                        HStack {
                            SocTestAddressRow(address: self.object.addresses[i])
                            Image(systemName: "return")
                                .font(.system(size: 12))
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text("connect"), displayMode: .inline)
    }
    
    private func execute(address: SocAddress) {
        self.object.isProcessing = true
        DispatchQueue.global().async {
            do {
                try self.socket.connect(address: address)
                DispatchQueue.main.async {
                    self.socket.remoteAddress = address
                    self.socket.isConnected = true
                    self.socket.isRdShutdown = false
                    self.socket.isWrShutdown = false
                    if self.object.appSettingAutoMonitoring {
                        SocTestSocketSimulator.postAddress(socket: &self.socket)
                        SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                        SocTestSocketSimulator.postPoll(socket: &self.socket)
                        SocTestSocketSimulator.postErrno(socket: &self.socket)
                    }
#if DEBUG
                    self.socket.isActive = false
#else
                    self.presentationMode.wrappedValue.dismiss()
#endif
                }
            }
            catch let error as SocError  {
                DispatchQueue.main.async {
                    if self.socket.isConnecting {
                        if error.code == EALREADY {
                            self.object.alertMessage = "Connect in progress."
                        }
                        else if error.code == EISCONN {
                            self.socket.isConnecting = false
                            self.socket.isConnected = true
                            self.object.alertMessage = "Connect in background ended."
                        }
                        else {
                            self.socket.isConnecting = false
                            self.socket.connErrno = error.code
                            self.object.alertMessage = "Connect in background ended with error."
                        }
                        if self.object.appSettingAutoMonitoring {
                            SocTestSocketSimulator.postAddress(socket: &self.socket)
                            SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                        }
                    }
                    else {
                        if error.code == EINPROGRESS {
                            self.socket.remoteAddress = address
                            self.socket.isConnecting = true
                            self.object.alertMessage = "Connect in progress."
                            if self.object.appSettingAutoMonitoring {
                                SocTestSocketSimulator.postAddress(socket: &self.socket)
                            }
                        }
                        else {
                            if self.socket.connErrno == 0 {
                                self.socket.connErrno = error.code
                            }
                            if self.object.appSettingAutoMonitoring {
                                SocTestSocketSimulator.postAddress(socket: &self.socket)
                                SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                                SocTestSocketSimulator.postPoll(socket: &self.socket)
                            }
                        }
                    }
                    self.object.alertDetail = error.detail
                    self.object.isPopAlert = true
                }
            }
            catch {
                fatalError("FunctionConnect.execute: \(error)")
            }
            DispatchQueue.main.async {
                self.object.isProcessing = false
            }
        }
    }
}

fileprivate struct FunctionListen: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    
    @State private var freeBacklog: Int32 = -1
    @State private var stringValue: String = ""
    @State private var indexStart: Int = 1
    
    var body: some View {
        List {
            Section(header: Text("Header_BACKLOG")) {
                if self.freeBacklog < 0 {
                    HStack {
                        SocTestCommonRow.listenBacklogs[0]
                        TextField("Label_Placeholder_freeBacklog", text: self.$stringValue)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                        Button(action: {
                            SocLogger.debug("FunctionListen: Button: OK")
                            self.setBacklog()
                        }) {
                            Text("Button_OK")
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
                ForEach(indexStart ..< SocTestCommonRow.listenBacklogs.count, id: \.self) { i in
                    Button(action: {
                        SocLogger.debug("FunctionListen: Button: \(i)")
                        let backlog = SocTestCommonRow.listenBacklogs[i].type < 0 ? self.freeBacklog : SocTestCommonRow.listenBacklogs[i].type
                        self.execute(backlog: backlog)
                    }) {
                        HStack {
                            SocTestCommonRow.listenBacklogs[i]
                            if i == 0 {
                                Text("(\(self.freeBacklog))")
                                Spacer()
                            }
                            Image(systemName: "return")
                                .font(.system(size: 12))
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text("listen"), displayMode: .inline)
    }
    
    private func setBacklog() {
        do {
            guard !self.stringValue.isEmpty else {
                throw SocTestError.NoValue
            }
            guard let backlog = Int32(self.stringValue) else {
                throw SocTestError.InvalidValue
            }
            guard backlog >= 0 else {
                throw SocTestError.InvalidValue
            }
            self.freeBacklog = backlog
            self.indexStart = 0
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("FunctionListen: \(error)")
        }
    }
    
    private func execute(backlog: Int32) {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postAddress(socket: &self.socket)
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.listen(backlog: backlog)
            self.socket.isServer = true
            self.socket.isListening = true
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
            fatalError("FunctionListen.execute: \(error)")
        }
    }
}

fileprivate struct FunctionAccept: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_REMOTE_ADDRESS").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_REMOTE_ADDRESS").font(.system(size: 12)) : nil) {
                    Toggle(isOn: $object.needAddress) {
                        Text("Label_Obtains_an_address")
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("FunctionAccept: Button: Done")
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
        .navigationBarTitle(Text("accept"), displayMode: .inline)
    }
    
    private func execute() {
        self.object.isProcessing = true
        DispatchQueue.global().async {
            do {
                defer {
                    DispatchQueue.main.async {
                        if self.object.appSettingAutoMonitoring {
                            SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                            SocTestSocketSimulator.postPoll(socket: &self.socket)
                            SocTestSocketSimulator.postErrno(socket: &self.socket)
                        }
                    }
                }
                let ret = try self.socket.accept(needAddress: self.object.needAddress)
                var connSocket = ret.0
                connSocket.isNonBlocking = self.socket.isNonBlocking
                connSocket.localAddress = self.socket.localAddress
                if let address = ret.1 {
                    connSocket.remoteAddress = address
                }
                connSocket.isServer = true
                connSocket.isConnected = true
                DispatchQueue.main.async {
                    if self.object.appSettingAutoMonitoring {
                        SocTestSocketSimulator.postConnInfo(socket: &connSocket)
                        SocTestSocketSimulator.postPoll(socket: &connSocket)
                        SocTestSocketSimulator.postErrno(socket: &connSocket)
                    }
                    self.object.sockets.append(connSocket)
#if DEBUG
                    self.socket.isActive = false
#else
                    self.presentationMode.wrappedValue.dismiss()
#endif
                    }
            }
            catch let error as SocError {
                DispatchQueue.main.async {
                    self.object.alertMessage = error.message
                    self.object.alertDetail = error.detail
                    self.object.isPopAlert = true
                }
            }
            catch {
                fatalError("FunctionAccept.execute: \(error)")
            }
            DispatchQueue.main.async {
                self.object.isProcessing = false
            }
        }
    }
}

fileprivate struct FunctionShutdown: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    
    var body: some View {
        List {
            Section(header: Text("Header_HOW")) {
                ForEach(0 ..< SocTestCommonRow.shutdownHows.count, id: \.self) { i in
                    Button(action: {
                        SocLogger.debug("FunctionShutdown: Button: \(i)")
                        self.execute(how: SocTestCommonRow.shutdownHows[i].type)
                    }) {
                        HStack {
                            SocTestCommonRow.shutdownHows[i]
                            Image(systemName: "return")
                                .font(.system(size: 12))
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text("shutdown"), displayMode: .inline)
    }
    
    private func execute(how: Int32) {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            try self.socket.shutdown(how: how)
            switch how {
            case SHUT_RD:
                self.socket.isRdShutdown = true
            case SHUT_WR:
                self.socket.isWrShutdown = true
            default: //SHUT_RDWR
                self.socket.isRdShutdown = true
                self.socket.isWrShutdown = true
            }
#if DEBUG
            self.socket.isActive = false
#else
            self.presentationMode.wrappedValue.dismiss()
#endif
        }
        catch let error as SocError {
            if error.code == ENOTCONN {
                self.socket.isRdShutdown = true
                self.socket.isWrShutdown = true
            }
            self.object.alertMessage = error.message
            self.object.alertDetail = error.detail
            self.object.isPopAlert = true
        }
        catch {
            fatalError("FunctionShutdown.execute: \(error)")
        }
    }
}

fileprivate struct FunctionFcntl: View {
    @EnvironmentObject var object: SocTestSharedObject
#if !DEBUG
    @Environment(\.presentationMode) var presentationMode
#endif
    @Binding var socket: SocSocket
    @Binding var flags: Int32
    @Binding var boolValue: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("O_NONBLOCK").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_O_NONBLOCK").font(.system(size: 12)) : nil) {
                    Toggle(isOn: $boolValue) {
                        Text("Label_Enabled")
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("FunctionFcntl: Button: Done")
                    self.execute(flags: self.boolValue ? (self.flags | O_NONBLOCK) : (self.flags & ~O_NONBLOCK))
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
        .navigationBarTitle(Text("fcntl"), displayMode: .inline)
    }
    
    private func execute(flags: Int32) {
        do {
            defer {
                if self.object.appSettingAutoMonitoring {
                    SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                    SocTestSocketSimulator.postPoll(socket: &self.socket)
                    SocTestSocketSimulator.postErrno(socket: &self.socket)
                }
            }
            _ = try self.socket.fcntl(cmd: F_SETFL, flags: flags)
            self.socket.isNonBlocking = self.boolValue
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
            fatalError("FunctionFcntl.execute: \(error)")
        }
    }
}

fileprivate struct FunctionPoll: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    
    @State private var timeout: Int32 = 0
    @State private var freePeriod: Int32 = -1
    @State private var stringValue: String = ""
    @State private var indexStart: Int = 1

    var body: some View {
        List {
            Section(header: Text("Header_TIMEOUT_PERIOD")) {
                if self.freePeriod < 0 {
                    HStack {
                        SocTestCommonRow.pollTimers[0]
                        TextField("Label_Placeholder_freePeriod", text: self.$stringValue)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                        Button(action: {
                            SocLogger.debug("FunctionPoll: Button: OK")
                            self.setTimeout()
                        }) {
                            Text("Button_OK")
                                .foregroundColor(Color.init(UIColor.systemBlue))
                        }
                    }
                }
                ForEach(indexStart ..< SocTestCommonRow.pollTimers.count, id: \.self) { i in
                    ZStack {
                        NavigationLink(destination: Polling(socket: self.$socket, timeout: self.$timeout)) {
                            EmptyView()
                        }
                        Button(action: {
                            SocLogger.debug("FunctionPoll: Button: \(i)")
                            self.timeout = i == 0 ? self.freePeriod : SocTestCommonRow.pollTimers[i].type
                        }) {
                            HStack {
                                SocTestCommonRow.pollTimers[i]
                                if i == 0 {
                                    Text("(\(self.freePeriod) msec)")
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text("poll"), displayMode: .inline)
    }

    private func setTimeout() {
        do {
            guard !self.stringValue.isEmpty else {
                throw SocTestError.NoValue
            }
            guard let timeout = Int32(self.stringValue) else {
                throw SocTestError.InvalidValue
            }
            guard timeout >= 1 && timeout <= 3600000 else {
                throw SocTestError.InvalidValue
            }
            self.freePeriod = timeout
            self.indexStart = 0
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("FunctionPoll.setTimeout: \(error)")
        }
    }
}

fileprivate struct Polling: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var socket: SocSocket
    @Binding var timeout: Int32
    
    @State private var isActive: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_REQUEST_EVENTS").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_REQUEST_EVENTS").font(.system(size: 12)) : nil) {
                    ForEach(0 ..< SocTestCommonRow.pollEvents.count, id: \.self) { i in
                        SocTestCommonRow.pollEvents[i]
                            .contentShape(Rectangle())
                            .onTapGesture { self.object.isPollEventChecks[i].toggle() }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
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
            }
            .frame(height: 90)
            
            Form {
                Button(action: {
                    SocLogger.debug("Polling: Button: Done")
                    self.execute(timeout: self.timeout)
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
        .navigationBarTitle(Text("poll"), displayMode: .inline)
    }
    
    private func execute(timeout: Int32) {
        self.object.isProcessing = true
        DispatchQueue.global().async {
            do {
                var events: Int32 = 0
                for i in 0 ..< SocTestCommonRow.pollEvents.count {
                    if self.object.isPollEventChecks[i] {
                        events |= SocTestCommonRow.pollEvents[i].type
                    }
                }
                let revents = try self.socket.poll(events: events, timeout: timeout)
                DispatchQueue.main.async {
                    self.object.isProcessing = false
                    //Note: Puts back control from bg to fg, because main-thread should rend view.
                    self.socket.revents |= revents
                    self.socket.revents &= ~(events & (events ^ revents))
                    if self.object.appSettingAutoMonitoring {
                        SocTestSocketSimulator.postConnInfo(socket: &self.socket)
                        SocTestSocketSimulator.postErrno(socket: &self.socket)
                    }
                    if revents > 0 {
                        self.object.alertMessage = NSLocalizedString("Label_Returned_events", comment: "") + SocLogger.getEventsMask(revents)
                    }
                    else {
                        self.object.alertMessage = NSLocalizedString(timeout == 0 ? "Label_No_events" : "Label_Timed_out", comment: "")
                    }
                    object.isAlerting = true
                    DispatchQueue.global().async {
                        sleep(1)
                        DispatchQueue.main.async {
                            object.isAlerting = false
                        }
                    }
                }
            }
            catch let error as SocError {
                DispatchQueue.main.async {
                    self.object.alertMessage = error.message
                    self.object.alertDetail = error.detail
                    self.object.isPopAlert = true
                }
            }
            catch {
                fatalError("Polling.execute: \(error)")
            }
            DispatchQueue.main.async {
                self.object.isProcessing = false
            }
        }
    }
}
