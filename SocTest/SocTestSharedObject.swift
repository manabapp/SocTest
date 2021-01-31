//
//  SocTestSharedObject.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

class SocTestSharedObject: ObservableObject {
    static var isJa: Bool { return Locale.preferredLanguages.first!.hasPrefix("ja") }
    
    @Published var appVersion: String = ""
    @Published var orientation: UIInterfaceOrientation = .unknown
    @Published var sockets: [SocSocket] = []
    @Published var interfaces = [SocTestInterface(deviceType: SocTestInterface.deviceTypeWifi),
                                 SocTestInterface(deviceType: SocTestInterface.deviceTypeCellurar),
                                 SocTestInterface(deviceType: SocTestInterface.deviceTypeHotspot),
                                 SocTestInterface(deviceType: SocTestInterface.deviceTypeLoopback)]
    @Published var needAddress: Bool = true
    @Published var isPollEventChecks = [Bool](repeating: false, count: SocTestCommonRow.pollEvents.count)
    @Published var isControlDataChecks = [Bool](repeating: false, count: SocTestCommonRow.controlDatas.count)
    @Published var isMsgFlagChecks = [Bool](repeating: false, count: SocTestCommonRow.msgFlags.count)
    @Published var isCmsgRetoptsChecks = [Bool](repeating: false, count: SocTestIODataManager.maxRegistNumber)
    @Published var deviceWidth: CGFloat = 0.0
    @Published var isAlerting: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertDetail: String = ""
    @Published var isPopAlert: Bool = false
    @Published var isProcessing: Bool = false
    
    //
    // App's loading parameters are follows.
    //
    @Published var addresses: [SocAddress] = []
    @Published var iodatas: [SocTestIOData] = []
    @Published var isAgree: Bool = false
    @Published var agreementDate: Date? = nil
    @Published var appSettingDescription: Bool = true {
        didSet {
            UserDefaults.standard.set(appSettingDescription, forKey: "appSettingDescription")
            SocLogger.debug("SocTestSharedObject: appSettingDescription = \(appSettingDescription)")
        }
    }
    @Published var appSettingAutoMonitoring: Bool = false {
        didSet {
            UserDefaults.standard.set(appSettingAutoMonitoring, forKey: "appSettingAutoMonitoring")
            SocLogger.debug("SocTestSharedObject: appSettingAutoMonitoring = \(appSettingAutoMonitoring)")
        }
    }
    @Published var appSettingIdleTimerDisabled: Bool = false {
        didSet {
            UserDefaults.standard.set(appSettingIdleTimerDisabled, forKey: "appSettingIdleTimerDisabled")
            UIApplication.shared.isIdleTimerDisabled = appSettingIdleTimerDisabled
            SocLogger.debug("SocTestSharedObject: appSettingIdleTimerDisabled = \(appSettingIdleTimerDisabled)")
            SocLogger.debug("SocTestSharedObject: UIApplication.shared.isIdleTimerDisabled = \(appSettingIdleTimerDisabled)")
        }
    }
    @Published var appSettingScreenColorInverted: Bool = false {
        didSet {
            UserDefaults.standard.set(appSettingScreenColorInverted, forKey: "appSettingScreenColorInverted")
            SocLogger.debug("SocTestSharedObject: appSettingScreenColorInverted = \(appSettingScreenColorInverted)")
        }
    }
    @Published var appSettingTraceLevel: Int = SocLogger.traceLevelNoData {
        didSet {
            UserDefaults.standard.set(appSettingTraceLevel, forKey: "appSettingTraceLevel")
            SocLogger.debug("SocTestSharedObject: appSettingTraceLevel = \(appSettingTraceLevel)")
            SocLogger.setTraceLevel(appSettingTraceLevel)
        }
    }
    @Published var appSettingDebugEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(appSettingDebugEnabled, forKey: "appSettingDebugEnabled")
            SocLogger.debug("SocTestSharedObject: appSettingDebugEnabled = \(appSettingDebugEnabled)")
            if appSettingDebugEnabled {
                SocLogger.enableDebug()
            }
            else {
                SocLogger.disableDebug()
            }
        }
    }
    
    func getAgreementDate() -> String {
        let value = UserDefaults.standard.object(forKey: "agreementDate")
        guard let date = value as? Date else {
            return "N/A"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "C")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    static func saveAddresses(addresses: [SocAddress]) {
        var stringsArray: [String] = []
        
        for address in addresses {
            stringsArray.append("\(address.family):\(address.addr):\(address.port):\(address.hostName)")
        }
        if stringsArray.count > 0 {
            SocLogger.debug("SocTestSharedObject.saveAddresses: \(stringsArray.count) addresses")
            UserDefaults.standard.set(stringsArray, forKey: "addresses")
            SocLogger.debug("SocTestSharedObject.saveAddresses: done")
        }
        else {
            SocLogger.debug("SocTestSharedObject.saveAddresses: removeObject")
            UserDefaults.standard.removeObject(forKey: "addresses")
        }
    }
    
    init() {
        isAgree = UserDefaults.standard.bool(forKey: "isAgree")
        if UserDefaults.standard.object(forKey: "appSettingDescription") != nil {  //Default is true
            appSettingDescription = UserDefaults.standard.bool(forKey: "appSettingDescription")
        }
        appSettingAutoMonitoring = UserDefaults.standard.bool(forKey: "appSettingAutoMonitoring")
        appSettingIdleTimerDisabled = UserDefaults.standard.bool(forKey: "appSettingIdleTimerDisabled")
        appSettingScreenColorInverted = UserDefaults.standard.bool(forKey: "appSettingScreenColorInverted")
        appSettingTraceLevel = UserDefaults.standard.integer(forKey: "appSettingTraceLevel")
        appSettingDebugEnabled = UserDefaults.standard.bool(forKey: "appSettingDebugEnabled")
        
        SocSocket.initSoc()
        SocLogger.setTraceLevel(appSettingTraceLevel)
        if appSettingDebugEnabled {
            SocLogger.enableDebug()
        }
        if let string = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            appVersion = string
        }
        SocLogger.debug("App Version = \(appVersion)")
        SocLogger.debug("Agreed the Terms of Service: \(self.getAgreementDate())")
        FileManager.default.changeCurrentDirectoryPath(FileManager.default.temporaryDirectory.path)
        for i in 0 ..< self.interfaces.count {
            self.interfaces[i].ifconfig(isLaunching: true)
        }
        let width = CGFloat(UIScreen.main.bounds.width)
        let height = CGFloat(UIScreen.main.bounds.height)
        deviceWidth = width < height ? width : height
        SocTestScreen.initSize(width: deviceWidth)
        SocTestIOData.initNameFormat()
        SocLogger.debug("Load App Setting:")
        SocLogger.debug("appSettingDescription = \(appSettingDescription)")
        SocLogger.debug("appSettingAutoMonitoring = \(appSettingAutoMonitoring)")
        SocLogger.debug("appSettingIdleTimerDisabled = \(appSettingIdleTimerDisabled)")
        SocLogger.debug("appSettingScreenColorInverted = \(appSettingScreenColorInverted)")
        SocLogger.debug("appSettingTraceLevel = \(appSettingTraceLevel)")
        SocLogger.debug("appSettingDebugEnabled = \(appSettingDebugEnabled)")
        SocLogger.debug("Load Address:")
        if UserDefaults.standard.object(forKey: "addresses") != nil {
            if let stringsArray: [String] = UserDefaults.standard.stringArray(forKey: "addresses") {
                for stringsElement in stringsArray {
                    let array: [String] = stringsElement.components(separatedBy: ":")
                    if array.count != 4 || array[1].isEmpty {
                        SocLogger.error("Invalid address - \(stringsElement)")
                        assertionFailure("Invalid address - \(stringsElement)")
                        break
                    }
                    if let family = Int32(array[0]), let port = UInt16(array[2]) {
                        let address = SocAddress(family: family, addr: array[1], port: port, hostName: array[3])
                        addresses.append(address)
                        SocLogger.debug("address - \(stringsElement)")
                    }
                }
            }
        }
        SocLogger.debug("Load Data:")
        SocTestIOData.loadIODatas(iodatas: &self.iodatas)
        SocLogger.debug("Check Device Configuration:")
        SocLogger.debug("WiFi Address = \(interfaces[SocTestInterface.deviceTypeWifi].inet.addr)")
        SocLogger.debug("Cellurar Address = \(interfaces[SocTestInterface.deviceTypeCellurar].inet.addr)")
        SocLogger.debug("Hotspot Address = \(interfaces[SocTestInterface.deviceTypeHotspot].inet.addr)")
        SocLogger.debug("Loopback Address = \(interfaces[SocTestInterface.deviceTypeLoopback].inet.addr)")
        SocLogger.debug("Current Directory = \(FileManager.default.currentDirectoryPath)")
        SocLogger.debug("Appearance = \(UITraitCollection.current.userInterfaceStyle == .dark ? "Dark mode" : "Light mode")")
        SocLogger.debug("TimeZone = \(TimeZone.current)")
        SocLogger.debug("Languages = \(Locale.preferredLanguages)")
        SocLogger.debug("Screen Size = \(width) * \(height)")
        SocLogger.debug("SocTestSharedObject.init: all done")
    }
}
