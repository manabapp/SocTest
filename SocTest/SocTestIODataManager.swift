//
//  SocTestIODataManager.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

struct SocTestIODataManager: View {
    @EnvironmentObject var object: SocTestSharedObject
    
    static let maxRegistNumber: Int = 32
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_DATA_LIST").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text("Footer_DATA_LIST").font(.system(size: 12)) : nil) {
                    if self.object.iodatas.count > 0 {
                        ForEach(0 ..< self.object.iodatas.count, id: \.self) { i in
                            NavigationLink(destination: DataEditor(iodata: self.$object.iodatas[i])) {
                                SocTestIODataRow(iodata: self.object.iodatas[i], onManager: true)
                            }
                        }
                        .onDelete { indexSet in
                            SocLogger.debug("SoctestIODataManager: onDelete: \(indexSet)")
                            indexSet.forEach { i in
                                do {
                                    try self.object.iodatas[i].delete()
                                    self.object.iodatas.remove(at: i)
                                }
                                catch let error as SocTestError {
                                    self.object.alertMessage = error.message
                                    self.object.alertDetail = ""
                                    self.object.isPopAlert = true
                                }
                                catch {
                                    fatalError("SoctestIODataManager: \(error)")
                                }
                            }
                        }
                    }
                    else {
                        SocTestCommonRow.noData
                            .foregroundColor(Color.init(UIColor.systemGray))
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                NavigationLink(destination: IODataRegister()) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("New Data")
                            if object.appSettingDescription {
                                Text("Description_New_Data")
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
        .navigationBarTitle("Data Manager", displayMode: .inline)
    }
}

fileprivate struct IODataRegister: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Environment(\.presentationMode) var presentationMode
    @State private var nameString: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Header_DATA_NAME").font(.system(size: 16, weight: .semibold)),
                        footer: object.appSettingDescription ? Text(NSLocalizedString("Footer_DATA_NAME", comment: "") + FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path).font(.system(size: 12)) : nil) {
                    TextField("http.get", text: $nameString)
                        .keyboardType(.URL)
                }
            }
            .listStyle(PlainListStyle())
            
            Form {
                Button(action: {
                    SocLogger.debug("IODataRegister: Button: Regist")
                    self.register()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.square.fill")
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
        .navigationBarTitle("New Data", displayMode: .inline)
    }
    
    private func register() {
        do {
            guard !self.nameString.isEmpty else {
                SocLogger.debug("IODataRegister.register: no path")
                throw SocTestError.NoName
            }
            guard self.nameString.count <= 32 else {
                SocLogger.debug("IODataRegister.register: name too long '\(self.nameString)'")
                throw SocTestError.TooLongName
            }
            guard self.nameString.isValidPath else {
                SocLogger.debug("IODataRegister.register: invalid data name '\(self.nameString)'")
                throw SocTestError.InvalidName
            }
            for iodata in self.object.iodatas {
                if iodata.name == self.nameString {
                    SocLogger.debug("IODataRegister.register: \(self.nameString) exists")
                    throw SocTestError.AlreadyNameExist
                }
            }
            if self.object.iodatas.count >= SocTestIODataManager.maxRegistNumber {
                SocLogger.debug("IODataRegister.register: \(self.object.iodatas.count) >= \(SocTestIODataManager.maxRegistNumber) exceeded")
                throw SocTestError.IODataExceeded
            }
            var iodata = SocTestIOData(name: self.nameString, editable: true, type: SocTestIOData.contentTypeCustom)
            SocLogger.debug("IODataRegister.register: success \(self.nameString)")
            try iodata.save()
            self.object.iodatas.append(iodata)
            self.presentationMode.wrappedValue.dismiss()
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("IODataRegister.register: \(error)")
        }
    }
}

fileprivate struct DataEditor: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var iodata: SocTestIOData
    @State var editdata = SocTestIOData(name: "dummy")
    @State var returnCodeIndex = 1
    @State var asciiText: String = ""
    @State var hexText: String = ""
    @State var indexText: String = ""
    @State var charsText: String = ""
    @State var isAsciiEditable: Bool = false  //Changes depend on ioType(send/recv) or data content
    @State var isAsciiDecodable: Bool = true  //Changes depend on data content
    @State var isHexEditable: Bool = true  //Changes depend on ioType(send/recv)
    @State var isHexDecodable: Bool = true  //Fixed
    @State var isOtherEditable: Bool = false  //Fixed
    @State var isOtherDecodable: Bool = true  //Fixed
    
    init(iodata: Binding<SocTestIOData>) {
        self._iodata = iodata
        _editdata = State(initialValue: self.iodata)
        if self.iodata.size == 0 {
            _isHexEditable = State(initialValue: self.iodata.editable)
            _isAsciiEditable = State(initialValue: self.iodata.editable)
            return
        }
        _hexText = State(initialValue: self.iodata.getHex())
        _isHexEditable = State(initialValue: self.iodata.editable)
        
        _indexText = State(initialValue: self.iodata.getIndex())
        _charsText = State(initialValue: self.iodata.getChars())
        
        var isCRLF: Bool = false
        guard let text = self.iodata.getAscii(isCRLF: &isCRLF) else {
            _asciiText = State(initialValue: NSLocalizedString("Label_Non-unicode_character_data", comment: ""))
            _isAsciiEditable = State(initialValue: false)
            _isAsciiDecodable = State(initialValue: false)
            return
        }
        _asciiText = State(initialValue: text)
        _returnCodeIndex = State(initialValue: isCRLF ? 1 : 0)
        _isAsciiEditable = State(initialValue: self.iodata.editable ? true : false)
        _isAsciiDecodable = State(initialValue: true)
    }
    
    var body: some View {
        VStack {
            if object.orientation.isPortrait {
                VStack {
                    HStack(alignment: .bottom) {
                        Text("ASCII")
                            .font(.system(size: 16))
                            .foregroundColor(Color.init(UIColor.systemGray))
                            .padding(.leading, 8)
                            .padding(.bottom, 2)
                        Spacer()
                        Picker("", selection: self.$returnCodeIndex) {
                            Text("LF").tag(0)
                            Text("CRLF").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 200, height: 32, alignment: .bottomTrailing)
                        .padding(.top, 2)
                        .padding(.trailing, 2)
                        .disabled(!self.iodata.editable)
                    }
                    SocTestScreen(text: self.$asciiText, isEditable: self.$isAsciiEditable, isDecodable: self.$isAsciiDecodable)
                        .padding(.top, -5)
                        .padding(.leading, 0)
                    HStack {
                        Text("HEX")
                            .font(.system(size: 16))
                            .foregroundColor(Color.init(UIColor.systemGray))
                            .padding(.leading, 8)
                            .padding(.bottom, -3)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        SocTestScreen(text: self.$indexText, isEditable: self.$isOtherEditable, isDecodable: self.$isOtherDecodable)
                            .frame(width: SocTestScreen.editorIndexWidth)
                        SocTestScreen(text: self.$hexText, isEditable: self.$isHexEditable, isDecodable: self.$isHexDecodable)
                            .frame(width: SocTestScreen.editorHexWidth)
                        SocTestScreen(text: self.$charsText, isEditable: self.$isOtherEditable, isDecodable: self.$isOtherDecodable)
                            .frame(width: SocTestScreen.editorCharsWidth)
                    }
                    HStack {
                        Spacer()
                        Text(self.editdata.label)
                            .font(.system(size: 14))
                            .padding(.top, -3)
                        Spacer()
                    }
                    
                    DataEditorMenu(iodata: self.$iodata,
                                   editdata: self.$editdata,
                                   returnCodeIndex: self.$returnCodeIndex,
                                   asciiText: self.$asciiText,
                                   hexText: self.$hexText,
                                   indexText: self.$indexText,
                                   charsText: self.$charsText,
                                   isAsciiEditable: self.$isAsciiEditable,
                                   isAsciiDecodable: self.$isAsciiDecodable)
                }
            }
            else {
                HStack(alignment: .top) {
                    VStack(spacing: 3) {
                        HStack(alignment: .bottom) {
                            Text("ASCII")
                                .font(.system(size: 16))
                                .foregroundColor(Color.init(UIColor.systemGray))
                                .padding(.top, 5)
                                .padding(.leading, 8)
                                .padding(.bottom, -3)
                            Spacer()
                        }
                        SocTestScreen(text: self.$asciiText, isEditable: self.$isAsciiEditable, isDecodable: self.$isAsciiDecodable)
                        HStack {
                            Text("HEX")
                                .font(.system(size: 16))
                                .foregroundColor(Color.init(UIColor.systemGray))
                                .padding(.leading, 8)
                                .padding(.bottom, -3)
                            Spacer()
                        }
                        HStack(spacing: 0) {
                            SocTestScreen(text: self.$indexText, isEditable: self.$isOtherEditable, isDecodable: self.$isOtherDecodable)
                                .frame(width: SocTestScreen.editorIndexWidth)
                            SocTestScreen(text: self.$hexText, isEditable: self.$isHexEditable, isDecodable: self.$isHexDecodable)
                                .frame(width: SocTestScreen.editorHexWidth)
                            SocTestScreen(text: self.$charsText, isEditable: self.$isOtherEditable, isDecodable: self.$isOtherDecodable)
                                .frame(width: SocTestScreen.editorCharsWidth)
                        }
                        HStack {
                            Spacer()
                            Text(self.editdata.label)
                                .font(.system(size: 14))
                                .padding(.top, -3)
                                .padding(.bottom, 3)
                            Spacer()
                        }
                    }
                    .frame(width: object.deviceWidth)
                    
                    VStack(spacing: 0) {
                        HStack(alignment: .center) {
                            Spacer()
                            Picker("", selection: self.$returnCodeIndex) {
                                Text("LF").tag(0)
                                Text("CRLF").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 200, height: 32, alignment: .bottomTrailing)
                            .padding(.top, 2)
                            .padding(.trailing, 2)
                            .disabled(!self.iodata.editable)
                        }
                        DataEditorMenu(iodata: self.$iodata,
                                       editdata: self.$editdata,
                                       returnCodeIndex: self.$returnCodeIndex,
                                       asciiText: self.$asciiText,
                                       hexText: self.$hexText,
                                       indexText: self.$indexText,
                                       charsText: self.$charsText,
                                       isAsciiEditable: self.$isAsciiEditable,
                                       isAsciiDecodable: self.$isAsciiDecodable)
                    }
                }
            }
        }
        .navigationBarTitle(self.iodata.name, displayMode: .inline)
    }
}

fileprivate struct DataEditorMenu: View {
    @EnvironmentObject var object: SocTestSharedObject
    @Binding var iodata: SocTestIOData
    @Binding var editdata: SocTestIOData
    @Binding var returnCodeIndex: Int
    @Binding var asciiText: String
    @Binding var hexText: String
    @Binding var indexText: String
    @Binding var charsText: String
    @Binding var isAsciiEditable: Bool  //Changes depend on ioType(send/recv) or data content
    @Binding var isAsciiDecodable: Bool  //Changes depend on data content
    @State private var isEdited: Bool = false
    @State var fullAsciiText: String = ""
    @State var fullHexText: String = ""
    @State var isHexDecodable: Bool = true  //Fixed
    
    var body: some View {
        VStack(spacing: 0) {
            if object.orientation.isPortrait {
                Form {
                    ZStack {
                        NavigationLink(destination: SocTestFullView(asciiText: self.$fullAsciiText, isAsciiDecodable: self.$isAsciiDecodable,
                                                                    hexText: self.$fullHexText, isHexDecodable: self.$isHexDecodable)) {
                            EmptyView()
                        }
                        Button(action: {
                            SocLogger.debug("DataEditorMenu: Button: Full Screen")
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
                .frame(height: self.iodata.editable ? 90 : 110)
                
                if self.iodata.editable {
                    HStack(spacing: 0) {
                        Form {
                            Button(action: {
                                SocLogger.debug("DataEditorMenu: Button: Convert A2X")
                                self.convertA2X()
                            }) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "arrowtriangle.down.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 19, height: 19, alignment: .center)
                                    Text("Button_Convert2")
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                            }
                            .disabled(!self.isAsciiEditable)
                        }
                        Form {
                            Button(action: {
                                SocLogger.debug("DataEditorMenu: Button: Convert X2A")
                                self.convertX2A()
                            }) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "arrowtriangle.up.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 19, height: 19, alignment: .center)
                                    Text("Button_Convert2")
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                            }
                        }
                        Form {
                            Button(action: {
                                SocLogger.debug("DataEditorMenu: Button: Save")
                                self.save()
                            }) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "tray.and.arrow.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 19, height: 19, alignment: .center)
                                    Text("Button_Save2")
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                            }
                            .disabled(!self.isEdited)
                        }
                    }
                    .frame(height: 110)
                }
            }
            else {
                Form {
                    ZStack {
                        NavigationLink(destination: SocTestFullView(asciiText: self.$fullAsciiText, isAsciiDecodable: self.$isAsciiDecodable,
                                                                    hexText: self.$fullHexText, isHexDecodable: self.$isHexDecodable)) {
                            EmptyView()
                        }
                        Button(action: {
                            SocLogger.debug("DataEditorMenu: Button: Full Screen")
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
                    if self.iodata.editable {
                        Button(action: {
                            SocLogger.debug("DataEditorMenu: Button: Convert A2X")
                            self.convertA2X()
                        }) {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "arrowtriangle.down.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 19, height: 19, alignment: .center)
                                    Text("Button_Convert")
                                        .padding(.leading, 10)
                                        .padding(.trailing, 20)
                                    Spacer()
                                }
                                if object.appSettingDescription {
                                    Text("Description_ConvertA2X")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.init(UIColor.systemGray))
                                }
                            }
                        }
                        .disabled(!self.isAsciiEditable)
                        
                        Button(action: {
                            SocLogger.debug("DataEditorMenu: Button: Convert X2A")
                            self.convertX2A()
                        }) {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "arrowtriangle.up.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 19, height: 19, alignment: .center)
                                    Text("Button_Convert")
                                        .padding(.leading, 10)
                                        .padding(.trailing, 20)
                                    Spacer()
                                }
                                if object.appSettingDescription {
                                    Text("Description_ConvertX2A")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.init(UIColor.systemGray))
                                }
                            }
                        }
                        
                        Button(action: {
                            SocLogger.debug("DataEditorMenu: Button: Save")
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
                                if object.appSettingDescription {
                                    Text("Description_EditorSave")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.init(UIColor.systemGray))
                                }
                            }
                        }
                        .disabled(self.isEdited ? false : true)
                    }
                }
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
        if self.iodata.editable {
            do {
                try self.editdata.setHex(self.hexText)
                self.fullHexText = self.editdata.getDump()
            }
            catch let error as SocTestError {
                self.object.alertMessage = error.message
                self.object.alertDetail = ""
                self.object.isPopAlert = true
            }
            catch {
                fatalError("DataEditorMenu: \(error)")
            }
        }
        else {
            self.fullHexText = self.iodata.getDump()
        }
        self.isHexDecodable = true
    }
    
    private func convertA2X() {
        self.editdata.setAscii(self.asciiText, isCRLF: returnCodeIndex == 1)
        if self.editdata.data != self.iodata.data {
            SocLogger.debug("DataEditor: Data edited.")
            self.isEdited = true
        }
        self.indexText = self.editdata.getIndex()
        self.hexText = self.editdata.getHex()
        self.charsText = self.editdata.getChars()
    }
    
    private func convertX2A() {
        do {
            try self.editdata.setHex(self.hexText)
            if self.editdata.data != self.iodata.data {
                SocLogger.debug("DataEditorMenu: Data edited.")
                self.isEdited = true
            }
            self.indexText = self.editdata.getIndex()
            self.hexText = self.editdata.getHex()
            self.charsText = self.editdata.getChars()
            var isCRLF: Bool = false
            guard let text = self.editdata.getAscii(isCRLF: &isCRLF) else {
                SocLogger.debug("DataEditorMenu: getAscii failed")
                self.asciiText = NSLocalizedString("Label_Non-unicode_character_data", comment: "")
                self.isAsciiEditable = false
                self.isAsciiDecodable = false
                return
            }
            SocLogger.debug("DataEditorMenu: getAscii success")
            self.returnCodeIndex = isCRLF ? 1 : 0
            self.asciiText = text
            self.isAsciiEditable = true
            self.isAsciiDecodable = true
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("DataEditorMenu: \(error)")
        }
    }
    
    private func save() {
        do {
            try self.editdata.save()
            self.iodata = self.editdata
            self.isEdited = false
            object.alertMessage = NSLocalizedString("Message_Data_saving_done", comment: "")
            object.isAlerting = true
            DispatchQueue.global().async {
                sleep(1)
                DispatchQueue.main.async {
                    object.isAlerting = false
                }
            }
        }
        catch let error as SocTestError {
            self.object.alertMessage = error.message
            self.object.alertDetail = ""
            self.object.isPopAlert = true
        }
        catch {
            fatalError("DataEditorMenu.save: \(error)")
        }
    }
}
