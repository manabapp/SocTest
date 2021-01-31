//
//  SocTestFullView.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

struct SocTestFullView: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var asciiText: String
    @Binding var isAsciiDecodable: Bool
    @Binding var hexText: String
    @Binding var isHexDecodable: Bool

    @State private var index: Int = 0
    @State private var isEditable: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if object.orientation.isPortrait {
                Picker("", selection: self.$index) {
                    Text("ASCII").tag(0)
                    Text("HEX").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(height: 32)
                .padding(5)
            }
            if index == 0 {
                SocTestScreen(text: self.$asciiText, isEditable: $isEditable, isDecodable: self.$isAsciiDecodable)
            }
            else {
                SocTestScreen(text: self.$hexText, isEditable: $isEditable, isDecodable: self.$isHexDecodable)
            }
            if object.orientation.isPortrait {
                Form {
                    Button(action: {
                        SocLogger.debug("SocTestFullView: Button: Copy")
                        UIPasteboard.general.string = index == 0 ? self.asciiText : self.hexText
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
                            Text("Button_Copy")
                                .padding(.leading, 10)
                                .padding(.trailing, 20)
                            Spacer()
                        }
                    }
                }
                .frame(height: 110)
            }
        }
        .navigationBarTitle(Text("Full Screen"), displayMode: .inline)
    }
}
