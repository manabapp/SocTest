//
//  SocTestError.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import Foundation

enum SocTestError: Error {
    case FileOpenError
    case FileDeleteError
    case NoValue
    case NoName
    case NoData
    case TooLongPath
    case TooLongName
    case TooLargeData
    case InvalidValue
    case InvalidIndex
    case InvalidIpAddr
    case InvalidPort
    case InvalidPath
    case InvalidName
    case InvalidHexCode
    case AlreadyAddressExist
    case AlreadyNameExist
    case AlreadySaved
    case AddressExceeded
    case IODataExceeded
    case CantOpenURL
    case InternalError
}

extension SocTestError: LocalizedError {
    var message: String {
        switch self {
        case .FileOpenError: return NSLocalizedString("Message_FileOpenError", comment: "")
        case .FileDeleteError: return NSLocalizedString("Message_FileDeleteError", comment: "")
        case .NoValue: return NSLocalizedString("Message_NoValue", comment: "")
        case .NoName: return NSLocalizedString("Message_NoName", comment: "")
        case .NoData: return NSLocalizedString("Message_NoData", comment: "")
        case .TooLongPath: return NSLocalizedString("Message_TooLongPath", comment: "")
        case .TooLongName: return NSLocalizedString("Message_TooLongName", comment: "")
        case .TooLargeData: return NSLocalizedString("Message_TooLargeData", comment: "")
        case .InvalidValue: return NSLocalizedString("Message_InvalidValue", comment: "")
        case .InvalidIndex: return NSLocalizedString("Message_InvalidIndex", comment: "")
        case .InvalidIpAddr: return NSLocalizedString("Message_InvalidIpAddr", comment: "")
        case .InvalidPort: return NSLocalizedString("Message_InvalidPort", comment: "")
        case .InvalidPath: return NSLocalizedString("Message_InvalidPath", comment: "")
        case .InvalidName: return NSLocalizedString("Message_InvalidName", comment: "")
        case .InvalidHexCode: return NSLocalizedString("Message_InvalidHexCode", comment: "")
        case .AlreadyAddressExist: return NSLocalizedString("Message_AlreadyAddressExist", comment: "")
        case .AlreadyNameExist: return NSLocalizedString("Message_AlreadyNameExist", comment: "")
        case .AlreadySaved: return NSLocalizedString("Message_AlreadySaved", comment: "")
        case .AddressExceeded: return NSLocalizedString("Message_AddressExceeded", comment: "")
        case .IODataExceeded: return NSLocalizedString("Message_IODataExceeded", comment: "")
        case .CantOpenURL: return NSLocalizedString("Message_CantOpenURL", comment: "")
        default: return NSLocalizedString("Message_default", comment: "")
        }
    }
}
