//
//  SocTestScreen.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

struct SocTestScreen: UIViewRepresentable {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var text: String
    @Binding var isEditable: Bool
    @Binding var isDecodable: Bool
    
    static var fontSize: CGFloat = 9.5
    static var defaultWidth: CGFloat = 0
    static var defaultHeight: CGFloat = 0
    static var dumpScreenHeight: CGFloat = 330.0
    static var editorIndexWidth: CGFloat = 45.0
    static var editorHexWidth: CGFloat = 220.0
    static var editorCharsWidth: CGFloat = 110.0
    
    static func initSize(width: CGFloat) {
        if width <= 0.0 {
            SocLogger.error("SocTestScreen.initSize: width = \(width)")
            assertionFailure("SocTestScreen.initSize: width = \(width)")
            return
        }
        //Devices supported iOS 14 or newer
        if width >= 428 {  //Device width 428pt : iPhone 12 Pro Max
            Self.fontSize = 10.7
            Self.dumpScreenHeight = 377
            Self.editorIndexWidth = 52
            Self.editorHexWidth = 251
        }
        else if width >= 414 {  //Device width 414pt : iPhone 6s Plus, 7 Plus, 8 Plus, XR, 11, XS Max, 11 Pro Max
            Self.fontSize = 10.4
            Self.dumpScreenHeight = 365.0
            Self.editorIndexWidth = 50.0
            Self.editorHexWidth = 243.0
        }
        else if width >= 390 {  //Device width 390pt : iPhone 12, 12 Pro
            Self.fontSize = 9.8
            Self.dumpScreenHeight = 343.0
            Self.editorIndexWidth = 48.0
            Self.editorHexWidth = 229.0
        }
        else if width >= 375 {  //Device width 375pt : iPhone 6s, 7, 8, SE(2nd Gen), X, XS, 11 Pro, 12 mini
            Self.fontSize = 9.5
            Self.dumpScreenHeight = 330.0
            Self.editorIndexWidth = 45.0
            Self.editorHexWidth = 220.0
        }
        else {  //Device width 320pt : iPhone SE(1st Gen), iPod touch(7th Gen)
            Self.fontSize = 8.0
            Self.dumpScreenHeight = 282.0
            Self.editorIndexWidth = 39.0
            Self.editorHexWidth = 188.0
        }
        Self.editorCharsWidth = width - (Self.editorIndexWidth + Self.editorHexWidth)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let myTextArea = UITextView()
        myTextArea.keyboardType = .asciiCapable
        myTextArea.isEditable = isEditable
        myTextArea.delegate = context.coordinator
        myTextArea.font = isDecodable ? UIFont(name: "Courier", size: SocTestScreen.fontSize) : UIFont.boldSystemFont(ofSize: SocTestScreen.fontSize)
        myTextArea.textAlignment = isDecodable ? .left : .center
        if self.object.appSettingScreenColorInverted {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                //secondarySystemBackground in Dark #F2F2F7
                myTextArea.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1.0)
                myTextArea.textColor = UIColor.black
            }
            else {
                //secondarySystemBackground in Dark #1C1C1E
                myTextArea.backgroundColor = UIColor(red: 0.110, green: 0.110, blue: 0.118, alpha: 1.0)
                myTextArea.textColor = UIColor.white
            }
        }
        else {
            myTextArea.backgroundColor = UIColor.secondarySystemBackground
            myTextArea.textColor = UIColor.label
        }
        return myTextArea
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.isEditable = isEditable
        uiView.font = isDecodable ? UIFont(name: "Courier", size: SocTestScreen.fontSize) : UIFont.boldSystemFont(ofSize: SocTestScreen.fontSize + 1.0)
        uiView.textAlignment = isDecodable ? .left : .center
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: SocTestScreen
        
        init(_ uiTextView: SocTestScreen) {
            self.parent = uiTextView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            self.parent.isEditable = textView.isEditable
        }
    }
}
