//
//  SocTestAddressRow.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

struct SocTestAddressRow: View {
    @EnvironmentObject var object: SocTestSharedObject
    let address: SocAddress
    var isDispClass: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: self.address.isInet ? "globe" : "u.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 22, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(address.isInet ? "\(address.addr):\(address.port)" : address.addr)
                        .font(.system(size: 19))
                    Spacer()
                    if isDispClass {
                        Text(address.classLabel)
                            .font(.system(size: 12))
                            .foregroundColor(Color.init(UIColor.systemGray))
                    }
                }
                if let detailText = self.detail {
                    detailText
                        .font(.system(size: 12))
                        .foregroundColor(Color.init(UIColor.systemGray))
                }
            }
            .padding(.leading)
        }
    }
    
    var detail: Text? {
        if self.address.hasHostName {
            return Text(self.address.hostName)
        }
        if !object.appSettingDescription {
            return nil
        }
        if self.address.isUnix {
            return Text("Description_UNIX_address")
        }
        if self.address.isAny {
            return Text("Description_ANY_address")
        }
        if self.address.isPrivate {
            return Text("Description_Private_address")
        }
        return Text("Description_Unknown_host")
    }
}
