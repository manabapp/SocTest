//
//  SocTestMenu.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

let MAIL_ADDRESS = "manabapp@gmail.com"
let COPYRIGHT = "Copyright © 2021 manabapp. All rights reserved."
let URL_BASE = "https://manabapp.github.io/"
let URL_WEBPAGE = URL_BASE + "Apps/index.html"
let URL_WEBPAGE_JA = URL_BASE + "Apps/index_ja.html"
let URL_HELP = URL_BASE + "SocTest/help.html"
let URL_HELP_JA = URL_BASE + "SocTest/help_ja.html"
let URL_POLICY = URL_BASE + "SocTest/PrivacyPolicy.html"
let URL_POLICY_JA = URL_BASE + "SocTest/PrivacyPolicy_ja.html"
let URL_TERMS = URL_BASE + "SocTest/TermsOfService.html"
let URL_TERMS_JA = URL_BASE + "SocTest/TermsOfService_ja.html"

let URL_MANPAGE = "https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/"
let MAN_PAGES: [(String, String, String)] = [
    ("SOCKET(2)",      "socket.2.html",      "socket -- create an endpoint for communication"),
    ("SOCKET(2)",      "socket.2.html",      "socket -- create an endpoint for communication"),
    ("GETSOCKOPT(2)",  "getsockopt.2.html",  "getsockopt, setsockopt -- get and set options on sockets"),
    ("BIND(2)",        "bind.2.html",        "bind -- bind a name to a socket"),
    ("CONNECT(2)",     "connect.2.html",     "connect -- initiate a connection on a socket"),
    ("LISTEN(2)",      "listen.2.html",      "listen -- listen for connections on a socket"),
    ("ACCEPT(2)",      "accept.2.html",      "accept -- accept a connection on a socket"),
    ("SEND(2)",        "send.2.html",        "send, sendmsg, sendto -- send a message from a socket"),
    ("RECV(2)",        "recv.2.html",        "recv, recvfrom, recvmsg -- receive a message from a socket"),
    ("GETSOCKNAME(2)", "getsockname.2.html", "getsockname -- get socket name"),
    ("GETPEERNAME(2)", "getpeername.2.html", "getpeername -- get name of connected peer"),
    ("SHUTDOWN(2)",    "shutdown.2.html",    "shutdown -- shut down part of a full-duplex connection"),
    ("FCNTL(2)",       "fcntl.2.html",       "fcntl -- file control"),
    ("POLL(2)",        "poll.2.html",        "poll -- synchronous I/O multiplexing")
]

struct SocTestMenu: View {
    @EnvironmentObject var object: SocTestSharedObject
    @State private var logText: String = ""
    
    var body: some View {
        List {
            Section(header: Text("Header_PREFERENCES")) {
                NavigationLink(destination: AppSetting()) {
                    SocTestCommonRow.menu[0]
                }
            }
            Section(header: Text("Header_LOG")) {
                ZStack {
                    NavigationLink(destination: SocTestLogViewer(text: $logText)) {
                        EmptyView()
                    }
                    Button(action: {
                        SocLogger.debug("SocTestMenu: Button: Log Viewer")
                        self.logText = SocLogger.getLog()
                    }) {
                        SocTestCommonRow.menu[1]
                    }
                }
            }
            Section(header: Text("Header_INFORMATION")) {
                NavigationLink(destination: AboutApp()) {
                    SocTestCommonRow.menu[2]
                }
                NavigationLink(destination: ErrorNumbers()) {
                    SocTestCommonRow.menu[3]
                }
                NavigationLink(destination: Manpages()) {
                    SocTestCommonRow.menu[4]
                }
                Button(action: {
                    SocLogger.debug("SocTestMenu: Button: Help")
                    self.openURL(urlString: SocTestSharedObject.isJa ? URL_HELP_JA : URL_HELP)
                }) {
                    SocTestCommonRow.menu[5]
                }
                Button(action: {
                    SocLogger.debug("SocTestMenu: Button: Policy")
                    self.openURL(urlString: SocTestSharedObject.isJa ? URL_POLICY_JA : URL_POLICY)
                }) {
                    SocTestCommonRow.menu[6]
                }
                Button(action: {
                    SocLogger.debug("SocTestMenu: Button: Terms")
                    self.openURL(urlString: SocTestSharedObject.isJa ? URL_TERMS_JA : URL_TERMS)
                }) {
                    SocTestCommonRow.menu[7]
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Menu", displayMode: .inline)
    }
    
    func openURL(urlString: String) {
        do {
            guard let url = URL(string: urlString) else {
                throw SocTestError.CantOpenURL
            }
            guard UIApplication.shared.canOpenURL(url) else {
                throw SocTestError.CantOpenURL
            }
            UIApplication.shared.open(url)
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("SocTestMenu.openURL(\(urlString)): \(error)")
        }
    }
}

fileprivate struct AppSetting: View {
    @EnvironmentObject var object: SocTestSharedObject

    var body: some View {
        List {
            Section(header: Text("DESCRIPTION").font(.system(size: 16, weight: .semibold)),
                    footer: object.appSettingDescription ? Text("Footer_DESCRIPTION").font(.system(size: 12)) : nil) {
                Toggle(isOn: self.$object.appSettingDescription) {
                    Text("Label_Enabled")
                }
            }
            Section(header: Text("AUTO MONITORING").font(.system(size: 16, weight: .semibold)),
                    footer: object.appSettingDescription ? Text("Footer_AUTO_MONITORING").font(.system(size: 12)) : nil) {
                Toggle(isOn: self.$object.appSettingAutoMonitoring) {
                    Text("Label_Enabled")
                }
            }
            Section(header: Text("IDLE TIMER").font(.system(size: 16, weight: .semibold)),
                    footer: object.appSettingDescription ? Text("Footer_IDLE_TIMER").font(.system(size: 12)) : nil) {
                Toggle(isOn: self.$object.appSettingIdleTimerDisabled) {
                    Text("Label_Disabled")
                }
            }
            Section(header: Text("SCREEN COLOR").font(.system(size: 16, weight: .semibold)),
                    footer: object.appSettingDescription ? Text("Footer_SCREEN_COLOR").font(.system(size: 12)) : nil) {
                Toggle(isOn: self.$object.appSettingScreenColorInverted) {
                    Text("Label_Inverted")
                }
            }
            Section(header: Text("SYSTEM CALL TRACE").font(.system(size: 16, weight: .semibold)),
                    footer: object.appSettingDescription ? Text("Footer_SYSTEM_CALL_TRACE").font(.system(size: 12)) : nil) {
                Picker("", selection: self.$object.appSettingTraceLevel) {
                    Text("Label_TRACE_Level1").tag(SocLogger.traceLevelNoData)
                    Text("Label_TRACE_Level2").tag(SocLogger.traceLevelInLine)
                    Text("Label_TRACE_Level3").tag(SocLogger.traceLevelHexDump)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
#if DEBUG
            Section(header: Text("DEBUG").font(.system(size: 16, weight: .semibold)),
                    footer: object.appSettingDescription ? Text("Footer_DEBUG").font(.system(size: 12)) : nil) {
                Toggle(isOn: self.$object.appSettingDebugEnabled) {
                    Text("Label_Enabled")
                }
            }
#endif
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("App Setting", displayMode: .inline)
    }
}

fileprivate struct SocTestLogViewer: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var text: String
    @State private var isEditable: Bool = false
    @State private var isDecodable: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            SocTestScreen(text: self.$text, isEditable: self.$isEditable, isDecodable: self.$isDecodable)
            if object.orientation.isPortrait {
                HStack(spacing: 0) {
                    Form {
                        Button(action: {
                            SocLogger.debug("SocTestLogViewer: Button: Reload")
                            self.text = SocLogger.getLog()
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 19, height: 19, alignment: .center)
                                Text("Button_Reload2")
                                    .padding(.leading, 5)
                                Spacer()
                            }
                        }
                    }
                    Form {
                        Button(action: {
                            SocLogger.debug("SocTestLogViewer: Button: Copy")
                            self.text = SocLogger.getLog()
                            UIPasteboard.general.string = self.text
                            object.alertMessage = NSLocalizedString("Message_Copied_to_clipboard", comment: "")
                            object.isAlerting = true
                            DispatchQueue.global().async {
                                sleep(1)
                                DispatchQueue.main.async {
                                    object.isAlerting = false
                                }
                            }
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "doc.on.doc")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 19, height: 19, alignment: .center)
                                Text("Button_Copy2")
                                    .padding(.leading, 5)
                                Spacer()
                            }
                        }
                    }
                    Form {
                        Button(action: {
                            SocLogger.debug("SocTestLogViewer: Button: Clear")
                            SocLogger.clearLog()
                            self.text = SocLogger.getLog()
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "trash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 19, height: 19, alignment: .center)
                                Text("Button_Clear2")
                                    .padding(.leading, 5)
                                Spacer()
                            }
                        }
                    }
                }
                .frame(height: 110)
            }
        }
        .navigationBarTitle(Text("Log Viewer"), displayMode: .inline)
    }
}

fileprivate struct AboutApp: View {
    @EnvironmentObject var object: SocTestSharedObject
    
    var body: some View {
        VStack {
            Image("SplashImage")
                .resizable()
                .scaledToFit()
                .frame(width: 80, alignment: .center)
            Text("SocTest")
                .font(.system(size: 26, weight: .bold))
            Text("version " + object.appVersion)
                .font(.system(size: 16))
                .padding(.bottom, 5)

            Text("This app is interactive socket simulator with POSIX Socket API.")
                .font(.system(size: 11))
            Button(action: {
                SocLogger.debug("AboutApp: Button: webpage")
                self.openURL(urlString: SocTestSharedObject.isJa ? URL_WEBPAGE_JA : URL_WEBPAGE)
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "safari")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text("Developer Website")
                        .font(.system(size: 11))
                    Spacer()
                }
                .padding(.bottom, 5)
            }
            
            Text("Support OS: iOS 14.0 or newer")
                .font(.system(size: 11))
            Text("Localization: en, ja")
                .font(.system(size: 11))
                .padding(.bottom, 20)
            
            Text("Please feel free to contact me if you have any feedback.")
                .font(.system(size: 11))
            Button(action: {
                SocLogger.debug("SocTestMenu: Button: mailto")
                let url = URL(string: "mailto:" + MAIL_ADDRESS)!
                UIApplication.shared.open(url)
            }) {
                Text(MAIL_ADDRESS)
                    .font(.system(size: 12))
                    .padding(5)
            }
            
            Text(COPYRIGHT)
                .font(.system(size: 11))
                .foregroundColor(Color.init(UIColor.systemGray))
        }
        .navigationBarTitle("About App", displayMode: .inline)
    }
    
    private func openURL(urlString: String) {
        do {
            guard let url = URL(string: urlString) else {
                throw SocTestError.CantOpenURL
            }
            guard UIApplication.shared.canOpenURL(url) else {
                throw SocTestError.CantOpenURL
            }
            UIApplication.shared.open(url)
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("AboutApp.openURL(\(urlString)): \(error)")
        }
    }
}

fileprivate struct ErrorNumbers: View {
    @EnvironmentObject var object: SocTestSharedObject
    
    var body: some View {
        List {
            Section(header: Text("Header_ERROR_NUMBER_LIST")) {
                ForEach(1 ..< ERRNO_NAMES.count, id: \.self) { i in
                    HStack {
                        Image(systemName: "e.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, alignment: .center)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Err#\(i)")
                                .font(.system(size: 12))
                            Text(ERRNO_NAMES[i])
                                .font(.system(size: 19, weight: .bold))
                            Text(String(cString: strerror(Int32(i))))
                                .font(.system(size: 15))
                            if object.appSettingDescription && SocTestSharedObject.isJa {
                                Text(LocalizedStringKey("Strerror_" + ERRNO_NAMES[i]))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.init(UIColor.systemGray))
                            }
                            if let name = self.ariasName(errno: Int32(i)) {
                                Text("Err#\(i)")
                                    .font(.system(size: 12))
                                    .padding(.top,  10)
                                Text(name)
                                    .font(.system(size: 19, weight: .bold))
                                Text(self.ariasStrerror(errno: Int32(i))!)
                                    .font(.system(size: 15))
                                if object.appSettingDescription && SocTestSharedObject.isJa {
                                    Text(LocalizedStringKey("Strerror_" + name))
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.init(UIColor.systemGray))
                                }
                            }
                        }
                        .padding(.leading)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("errno", displayMode: .inline)
    }
    
    private func ariasName(errno: Int32) -> String? {
        switch errno {
        case 35:
            return "EWOULDBLOCK"
        case 106:
            return "ELAST"
        default:
            return nil
        }
    }
    
    private func ariasStrerror(errno: Int32) -> String? {
        switch errno {
        case 35:
            return "Operation would block"
        case 106:
            return "Must be equal largest errno"
        default:
            return nil
        }
    }
}

fileprivate struct Manpages: View {
    @EnvironmentObject var object: SocTestSharedObject
    
    var body: some View {
        List {
            Section(header: Text("Header_MANUAL_LIST")) {
                ForEach(0 ..< MAN_PAGES.count, id: \.self) { i in
                    Button(action: {
                        SocLogger.debug("Manpages: Button: Manpage[\(i)]")
                        self.openURL(urlString: URL_MANPAGE + MAN_PAGES[i].1)
                    }) {
                        HStack {
                            Image(systemName: "book")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, alignment: .center)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(MAN_PAGES[i].0)
                                    .font(.system(size: 18))
                                if object.appSettingDescription {
                                    HStack {
                                        Text(MAN_PAGES[i].2)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.init(UIColor.systemGray))
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.leading)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("man", displayMode: .inline)
    }
    
    private func openURL(urlString: String) {
        do {
            guard let url = URL(string: urlString) else {
                throw SocTestError.CantOpenURL
            }
            guard UIApplication.shared.canOpenURL(url) else {
                throw SocTestError.CantOpenURL
            }
            UIApplication.shared.open(url)
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("Manpages.openURL(\(urlString)): \(error)")
        }
    }
}
