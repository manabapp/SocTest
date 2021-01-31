//
//  SocTestIODataRow.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

struct SocTestIODataRow: View {
    @EnvironmentObject var object: SocTestSharedObject
    let iodata: SocTestIOData
    var onManager: Bool = false
    var selectable: Bool = false
    var isCheck: Bool = false
    var imageName: String { iodata.editable ? "square.and.pencil" : "square" }
    
    var body: some View {
        HStack {
            if self.selectable {
                Image(systemName: self.isCheck ? "checkmark.square.fill" : imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22, alignment: .center)
                    .foregroundColor(Color.init(self.isCheck ? UIColor.systemBlue : UIColor.systemGray))
            }
            else {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, alignment: .center)
            }
            VStack(alignment: .leading, spacing: 2) {
                if onManager {
                    Text(iodata.label)
                        .font(.system(size: 12))
                    Text(iodata.name)
                        .font(.system(size: 19))
                        .padding(.trailing, -5)
                }
                else {
                    HStack {
                        Text(iodata.name)
                            .font(.system(size: 19))
                            .padding(.trailing, -5)
                            .foregroundColor(Color.init(iodata.sendok ? UIColor.label : UIColor.systemGray))
                        Spacer()
                        Text(iodata.label)
                            .font(.system(size: 12))
                            .foregroundColor(Color.init(UIColor.systemGray))
                    }
                }
                Text(iodata.getHeaderChars(maxLen: 100, isQuote: false))
                    .font(.system(size: 12))
                    .foregroundColor(Color.init(UIColor.systemGray))
                    .lineLimit(1)
            }
            .padding(.leading)
            Spacer()
        }
    }
}
