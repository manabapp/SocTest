//
//  SocTestCommonRow.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI

struct SocTestCommonRow: View {
    @EnvironmentObject var object: SocTestSharedObject
    let id: Int
    let type: Int32
    let subType: Int
    var name: String
    let image: String?
    let detail: LocalizedStringKey?
    
    static let checkTypePollEvents: Int = 1
    static let checkTypeControlDatas: Int = 2
    static let checkTypeMsgFlags: Int = 3
    
    static let withoutAddress = Self(id:0, type:0, subType:0, name:"Without address", image:"nosign", detail:"Description_Without_address")
    static let clearOptions = Self(id:0, type:0, subType:0, name:"Clear options", image:"square.slash", detail:"Description_Clear_options")
    static let noAddress = Self(id:0, type:0, subType:0, name:"No address", image:"globe", detail:"Description_No_address")
    static let noData = Self(id:0, type:0, subType:0, name:"No data", image:"square", detail:"Description_No_data")
    
    static let functions: [SocTestCommonRow] = [
        Self(id:FUNC_SOCKET, type:0, subType:0, name:"socket", image:"plus.circle", detail:"Description_socket"),
        Self(id:FUNC_SETSOCKOPT, type:0, subType:0, name:"getsockopt / setsockopt", image:"gearshape", detail:"Description_setsockopt"),
        Self(id:FUNC_BIND, type:0, subType:0, name:"bind", image:"square.and.arrow.down", detail:"Description_bind"),
        Self(id:FUNC_CONNECT, type:0, subType:0, name:"connect", image:"square.and.arrow.up", detail:"Description_connect"),
        Self(id:FUNC_LISTEN, type:0, subType:0, name:"listen", image:"paperplane.circle", detail:"Description_listen"),
        Self(id:FUNC_ACCEPT, type:0, subType:0, name:"accept", image:"paperplane.circle.fill", detail:"Description_accept"),
        Self(id:FUNC_SEND, type:SocTestIO.typeSend, subType:0, name:"send", image:"arrow.up.square", detail:"Description_send"),
        Self(id:FUNC_SENDTO, type:SocTestIO.typeSend, subType:0, name:"sendto", image:"arrow.up.square", detail:"Description_sendto"),
        Self(id:FUNC_SENDMSG, type:SocTestIO.typeSend, subType:0, name:"sendmsg", image:"arrow.up.square", detail:"Description_sendmsg"),
        Self(id:FUNC_RECV, type:SocTestIO.typeRecv, subType:0, name:"recv", image:"arrow.down.square", detail:"Description_recv"),
        Self(id:FUNC_RECVFROM, type:SocTestIO.typeRecv, subType:0, name:"recvfrom", image:"arrow.down.square", detail:"Description_recvfrom"),
        Self(id:FUNC_RECVMSG, type:SocTestIO.typeRecv, subType:0, name:"recvmsg", image:"arrow.down.square", detail:"Description_recvmsg"),
        Self(id:FUNC_GETSOCKNAME, type:0, subType:0, name:"getsockname", image:"magnifyingglass", detail:"Description_getsockname"),
        Self(id:FUNC_GETPEERNAME, type:0, subType:0, name:"getpeername", image:"magnifyingglass", detail:"Description_getpeername"),
        Self(id:FUNC_SHUTDOWN, type:0, subType:0, name:"shutdown", image:"xmark.circle.fill", detail:"Description_shutdown"),
        Self(id:FUNC_FCNTL, type:0, subType:0, name:"fcntl(F_GETFL / F_SETFL)", image:"lock.fill", detail:"Description_fcntl"),
        Self(id:FUNC_POLL, type:0, subType:0, name:"poll", image:"timer", detail:"Description_poll"),
        Self(id:FUNC_CLOSE, type:0, subType:0, name:"close", image:"minus.circle", detail:"Description_close")
    ]
    
    static let listenBacklogs: [SocTestCommonRow] = [
        Self(id:0, type:-1, subType:0, name:"Free value", image:"square.stack.3d.up", detail:nil),
        Self(id:1, type:0, subType:0, name:"0", image:"square.stack.3d.up", detail:nil),
        Self(id:2, type:1, subType:0, name:"1", image:"square.stack.3d.up", detail:nil),
        Self(id:3, type:2, subType:0, name:"2", image:"square.stack.3d.up", detail:nil),
        Self(id:4, type:3, subType:0, name:"3", image:"square.stack.3d.up", detail:nil),
        Self(id:5, type:4, subType:0, name:"4", image:"square.stack.3d.up", detail:nil),
        Self(id:6, type:5, subType:0, name:"5", image:"square.stack.3d.up", detail:nil),
        Self(id:7, type:8, subType:0, name:"8", image:"square.stack.3d.up", detail:nil),
        Self(id:8, type:16, subType:0, name:"16", image:"square.stack.3d.up", detail:nil),
        Self(id:9, type:32, subType:0, name:"32", image:"square.stack.3d.up", detail:nil),
        Self(id:10, type:64, subType:0, name:"64", image:"square.stack.3d.up", detail:nil),
        Self(id:11, type:128, subType:0, name:"128", image:"square.stack.3d.up", detail:nil),
        Self(id:12, type:256, subType:0, name:"256", image:"square.stack.3d.up", detail:nil),
        Self(id:13, type:512, subType:0, name:"512", image:"square.stack.3d.up", detail:nil),
        Self(id:14, type:1024, subType:0, name:"1024", image:"square.stack.3d.up", detail:nil),
    ]
    
    static let shutdownHows: [SocTestCommonRow] = [
        Self(id:0, type:SHUT_RD, subType:0, name:"SHUT_RD", image:"xmark.circle.fill", detail:"Description_SHUT_RD"),
        Self(id:1, type:SHUT_WR, subType:0, name:"SHUT_WR", image:"xmark.circle.fill", detail:"Description_SHUT_WR"),
        Self(id:2, type:SHUT_RDWR, subType:0, name:"SHUT_RDWR", image:"xmark.circle.fill", detail:"Description_SHUT_RDWR")
    ]
    
    static let pollEvents: [SocTestCommonRow] = [
        Self(id:0, type:POLLIN, subType:checkTypePollEvents, name:"POLLIN", image:nil, detail:"Description_POLLIN"),
        Self(id:1, type:POLLPRI, subType:checkTypePollEvents, name:"POLLPRI", image:nil, detail:"Description_POLLPRI"),
        Self(id:2, type:POLLOUT, subType:checkTypePollEvents, name:"POLLOUT", image:nil, detail:"Description_POLLOUT"),
        Self(id:3, type:POLLERR, subType:checkTypePollEvents, name:"POLLERR", image:nil, detail:"Description_POLLERR"),
        Self(id:4, type:POLLHUP, subType:checkTypePollEvents, name:"POLLHUP", image:nil, detail:"Description_POLLHUP"),
        Self(id:5, type:POLLNVAL, subType:checkTypePollEvents, name:"POLLNVAL", image:nil, detail:"Description_POLLNVAL")
    ]
    
    static let pollTimers: [SocTestCommonRow] = [
        Self(id:0, type:-1, subType:0, name:"Free period", image:"timer", detail:nil),
        Self(id:1, type:-1, subType:0, name:"No timeout", image:"timer", detail:"Description_pollTimerNo"),
        Self(id:2, type:0, subType:0, name:"0 seconds (0 msec)", image:"timer", detail:"Description_pollTimer0"),
        Self(id:3, type:100, subType:0, name:"0.1 second (100 msec)", image:"timer", detail:nil),
        Self(id:4, type:500, subType:0, name:"0.5 second (500 msec)", image:"timer", detail:nil),
        Self(id:5, type:1000, subType:0, name:"1 second (1,000 msec)", image:"timer", detail:nil),
        Self(id:6, type:5000, subType:0, name:"5 seconds (5,000 msec)", image:"timer", detail:nil),
        Self(id:7, type:10000, subType:0, name:"10 seconds (10,000 msec)", image:"timer", detail:nil),
        Self(id:8, type:30000, subType:0, name:"30 seconds (30,000 msec)", image:"timer", detail:nil),
        Self(id:9, type:60000, subType:0, name:"1 minute (60,000 msec)", image:"timer", detail:nil),
        Self(id:10, type:300000, subType:0, name:"5 minutes (300,000 msec)", image:"timer", detail:nil),
        Self(id:11, type:600000, subType:0, name:"10 minutes (600,000 msec)", image:"timer", detail:nil)
    ]
    
    static let solOptions: [SocTestCommonRow] = [
        Self(id:0, type:SO_DEBUG, subType:0, name:"SO_DEBUG", image:"gearshape", detail:"Description_SO_DEBUG"),
        Self(id:1, type:SO_ACCEPTCONN, subType:0, name:"SO_ACCEPTCONN", image:"gearshape", detail:"Description_SO_ACCEPTCONN"),
        Self(id:2, type:SO_REUSEADDR, subType:0, name:"SO_REUSEADDR", image:"gearshape", detail:"Description_SO_REUSEADDR"),
        Self(id:3, type:SO_KEEPALIVE, subType:0, name:"SO_KEEPALIVE", image:"gearshape", detail:"Description_SO_KEEPALIVE"),
        Self(id:4, type:SO_DONTROUTE, subType:0, name:"SO_DONTROUTE", image:"gearshape", detail:"Description_SO_DONTROUTE"),
        Self(id:5, type:SO_BROADCAST, subType:0, name:"SO_BROADCAST", image:"gearshape", detail:"Description_SO_BROADCAST"),
        Self(id:6, type:SO_USELOOPBACK, subType:0, name:"SO_USELOOPBACK", image:"gearshape", detail:"Description_SO_USELOOPBACK"),
        Self(id:7, type:SO_LINGER, subType:0, name:"SO_LINGER", image:"gearshape", detail:"Description_SO_LINGER"),
        Self(id:8, type:SO_OOBINLINE, subType:0, name:"SO_OOBINLINE", image:"gearshape", detail:"Description_SO_OOBINLINE"),
        Self(id:9, type:SO_REUSEPORT, subType:0, name:"SO_REUSEPORT", image:"gearshape", detail:"Description_SO_REUSEPORT"),
        Self(id:10, type:SO_TIMESTAMP, subType:0, name:"SO_TIMESTAMP", image:"gearshape", detail:"Description_SO_TIMESTAMP"),
        Self(id:11, type:SO_TIMESTAMP_MONOTONIC, subType:0, name:"SO_TIMESTAMP_MONOTONIC", image:"gearshape", detail:"Description_SO_TIMESTAMP_MONOTONIC"),
        Self(id:12, type:SO_SNDBUF, subType:0, name:"SO_SNDBUF", image:"gearshape", detail:"Description_SO_SNDBUF"),
        Self(id:13, type:SO_RCVBUF, subType:0, name:"SO_RCVBUF", image:"gearshape", detail:"Description_SO_RCVBUF"),
        Self(id:14, type:SO_SNDLOWAT, subType:0, name:"SO_SNDLOWAT", image:"gearshape", detail:"Description_SO_SNDLOWAT"),
        Self(id:15, type:SO_RCVLOWAT, subType:0, name:"SO_RCVLOWAT", image:"gearshape", detail:"Description_SO_RCVLOWAT"),
        Self(id:16, type:SO_SNDTIMEO, subType:0, name:"SO_SNDTIMEO", image:"gearshape", detail:"Description_SO_SNDTIMEO"),
        Self(id:17, type:SO_RCVTIMEO, subType:0, name:"SO_RCVTIMEO", image:"gearshape", detail:"Description_SO_RCVTIMEO"),
        Self(id:18, type:SO_ERROR, subType:0, name:"SO_ERROR", image:"gearshape", detail:"Description_SO_ERROR"),
        Self(id:19, type:SO_TYPE, subType:0, name:"SO_TYPE", image:"gearshape", detail:"Description_SO_TYPE"),
        Self(id:20, type:SO_NUMRCVPKT, subType:0, name:"SO_NUMRCVPKT", image:"gearshape", detail:"Description_SO_NUMRCVPKT"),
        Self(id:21, type:SO_NET_SERVICE_TYPE, subType:0, name:"SO_NET_SERVICE_TYPE", image:"gearshape", detail:"Description_SO_NET_SERVICE_TYPE"),
        Self(id:22, type:SO_NETSVC_MARKING_LEVEL, subType:0, name:"SO_NETSVC_MARKING_LEVEL", image:"gearshape", detail:"Description_SO_NETSVC_MARKING_LEVEL")
    ]
    
    static let tcpOptions: [SocTestCommonRow] = [
        Self(id:0, type:TCP_NODELAY, subType:0, name:"TCP_NODELAY", image:"gearshape", detail:"Description_TCP_NODELAY"),
        Self(id:1, type:TCP_MAXSEG, subType:0, name:"TCP_MAXSEG", image:"gearshape", detail:"Description_TCP_MAXSEG"),
        Self(id:2, type:TCP_NOOPT, subType:0, name:"TCP_NOOPT", image:"gearshape", detail:"Description_TCP_NOOPT"),
        Self(id:3, type:TCP_NOPUSH, subType:0, name:"TCP_NOPUSH", image:"gearshape", detail:"Description_TCP_NOPUSH"),
        Self(id:4, type:TCP_KEEPALIVE, subType:0, name:"TCP_KEEPALIVE", image:"gearshape", detail:"Description_TCP_KEEPALIVE"),
        Self(id:5, type:TCP_CONNECTIONTIMEOUT, subType:0, name:"TCP_CONNECTIONTIMEOUT", image:"gearshape", detail:"Description_TCP_CONNECTIONTIMEOUT"),
        Self(id:6, type:TCP_RXT_CONNDROPTIME, subType:0, name:"TCP_RXT_CONNDROPTIME", image:"gearshape", detail:"Description_TCP_RXT_CONNDROPTIME"),
        Self(id:7, type:TCP_RXT_FINDROP, subType:0, name:"TCP_RXT_FINDROP", image:"gearshape", detail:"Description_TCP_RXT_FINDROP"),
        Self(id:8, type:TCP_KEEPINTVL, subType:0, name:"TCP_KEEPINTVL", image:"gearshape", detail:"Description_TCP_KEEPINTVL"),
        Self(id:9, type:TCP_KEEPCNT, subType:0, name:"TCP_KEEPCNT", image:"gearshape", detail:"Description_TCP_KEEPCNT"),
        Self(id:10, type:TCP_SENDMOREACKS, subType:0, name:"TCP_SENDMOREACKS", image:"gearshape", detail:"Description_TCP_SENDMOREACKS"),
        Self(id:11, type:TCP_ENABLE_ECN, subType:0, name:"TCP_ENABLE_ECN", image:"gearshape", detail:"Description_TCP_ENABLE_ECN"),
        Self(id:12, type:TCP_FASTOPEN, subType:0, name:"TCP_FASTOPEN", image:"gearshape", detail:"Description_TCP_FASTOPEN"),
        Self(id:13, type:TCP_CONNECTION_INFO, subType:0, name:"TCP_CONNECTION_INFO", image:"gearshape", detail:"Description_TCP_CONNECTION_INFO"),
        Self(id:14, type:TCP_NOTSENT_LOWAT, subType:0, name:"TCP_NOTSENT_LOWAT", image:"gearshape", detail:"Description_TCP_NOTSENT_LOWAT")
    ]
    
    static let udpOptions: [SocTestCommonRow] = [
        Self(id:0, type:UDP_NOCKSUM, subType:0, name:"UDP_NOCKSUM", image:"gearshape", detail:"Description_UDP_NOCKSUM")
    ]
    
    static let ipOptions: [Self] = [
        Self(id:0, type:IP_OPTIONS, subType:0, name:"IP_OPTIONS", image:"gearshape", detail:"Description_IP_OPTIONS"),
        Self(id:1, type:IP_HDRINCL, subType:0, name:"IP_HDRINCL", image:"gearshape", detail:"Description_IP_HDRINCL"),
        Self(id:2, type:IP_TOS, subType:0, name:"IP_TOS", image:"gearshape", detail:"Description_IP_TOS"),
        Self(id:3, type:IP_TTL, subType:0, name:"IP_TTL", image:"gearshape", detail:"Description_IP_TTL"),
        Self(id:4, type:IP_RECVOPTS, subType:0, name:"IP_RECVOPTS", image:"gearshape", detail:"Description_IP_RECVOPTS"),
        Self(id:5, type:IP_RECVRETOPTS, subType:0, name:"IP_RECVRETOPTS", image:"gearshape", detail:"Description_IP_RECVRETOPTS"),
        Self(id:6, type:IP_RECVDSTADDR, subType:0, name:"IP_RECVDSTADDR", image:"gearshape", detail:"Description_IP_RECVDSTADDR"),
        Self(id:7, type:IP_RETOPTS, subType:0, name:"IP_RETOPTS", image:"gearshape", detail:"Description_IP_RETOPTS"),
        Self(id:8, type:IP_MULTICAST_IF, subType:0, name:"IP_MULTICAST_IF", image:"gearshape", detail:"Description_IP_MULTICAST_IF"),
        Self(id:9, type:IP_MULTICAST_TTL, subType:0, name:"IP_MULTICAST_TTL", image:"gearshape", detail:"Description_IP_MULTICAST_TTL"),
        Self(id:10, type:IP_MULTICAST_LOOP, subType:0, name:"IP_MULTICAST_LOOP", image:"gearshape", detail:"Description_IP_MULTICAST_LOOP"),
        Self(id:11, type:IP_ADD_MEMBERSHIP, subType:0, name:"IP_ADD_MEMBERSHIP", image:"gearshape", detail:"Description_IP_ADD_MEMBERSHIP"),
        Self(id:12, type:IP_DROP_MEMBERSHIP, subType:0, name:"IP_DROP_MEMBERSHIP", image:"gearshape", detail:"Description_IP_DROP_MEMBERSHIP"),
        Self(id:14, type:IP_PORTRANGE, subType:0, name:"IP_PORTRANGE", image:"gearshape", detail:"Description_IP_PORTRANGE"),
        Self(id:15, type:IP_RECVIF, subType:0, name:"IP_RECVIF", image:"gearshape", detail:"Description_IP_RECVIF"),
        Self(id:16, type:IP_STRIPHDR, subType:0, name:"IP_STRIPHDR", image:"gearshape", detail:"Description_IP_STRIPHDR"),
        Self(id:17, type:IP_RECVTTL, subType:0, name:"IP_RECVTTL", image:"gearshape", detail:"Description_IP_RECVTTL"),
        Self(id:18, type:IP_BOUND_IF, subType:0, name:"IP_BOUND_IF", image:"gearshape", detail:"Description_IP_BOUND_IF"),
        Self(id:19, type:IP_PKTINFO, subType:0, name:"IP_PKTINFO", image:"gearshape", detail:"Description_IP_PKTINFO"),
        Self(id:20, type:IP_RECVTOS, subType:0, name:"IP_RECVTOS", image:"gearshape", detail:"Description_IP_RECVTOS"),
        Self(id:21, type:IP_DONTFRAG, subType:0, name:"IP_DONTFRAG", image:"gearshape", detail:"Description_IP_DONTFRAG")
    ]
    
    static let contents: [SocTestCommonRow] = [
        Self(id:0, type:SocTestIOData.contentTypeCustom, subType:0, name:"Custom Data", image:"doc", detail:"Description_contentsCustom"),
        Self(id:1, type:SocTestIOData.contentTypeAllZeroDigit, subType:0, name:"All Zero Digit", image:"doc", detail:"Description_contentsAllZeroDigit"),
        Self(id:2, type:SocTestIOData.contentTypeDigit, subType:0, name:"Digit", image:"doc", detail:"Description_contentsDigit"),
        Self(id:3, type:SocTestIOData.contentTypeRandomDigit, subType:0, name:"Random Digit", image:"doc", detail:"Description_contentsRandomDigit"),
        Self(id:4, type:SocTestIOData.contentTypeRandomAlphaDigit, subType:0, name:"Random Alphabet & Digit", image:"doc", detail:"Description_contentsRandomAlphaDigit"),
        Self(id:5, type:SocTestIOData.contentTypeRandomPrintable, subType:0, name:"Random Printable Ascii", image:"doc", detail:"Description_contentsRandomPrintable"),
        Self(id:6, type:SocTestIOData.contentTypeAllZeroBinaly, subType:0, name:"All 0 Binary", image:"doc", detail:"Description_contentsAllZeroBinary"),
        Self(id:7, type:SocTestIOData.contentTypeAllOneBinaly, subType:0, name:"All 1 Binary", image:"doc", detail:"Description_contentsAllOneBinary"),
        Self(id:8, type:SocTestIOData.contentTypeRandomBinaly, subType:0, name:"Random Binaly", image:"doc", detail:"Description_contentsRandomBinary")
    ]
    
    static let bufSizes: [SocTestCommonRow] = [
        Self(id:0, type:-1, subType:0, name:"Free size", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:1, type:1, subType:0, name:"1 byte", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:2, type:2, subType:0, name:"2 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:3, type:4, subType:0, name:"4 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:4, type:8, subType:0, name:"8 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:5, type:16, subType:0, name:"16 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:6, type:32, subType:0, name:"32 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:7, type:64, subType:0, name:"64 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:8, type:128, subType:0, name:"128 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:9, type:256, subType:0, name:"256 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:10, type:512, subType:0, name:"512 bytes", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:11, type:1024, subType:0, name:"1 KB", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:12, type:2048, subType:0, name:"2 KB", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:13, type:4096, subType:0, name:"4 KB", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:14, type:8192, subType:0, name:"8 KB", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:15, type:16384, subType:0, name:"16 KB", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:16, type:32768, subType:0, name:"32 KB", image:"circle.grid.3x3.fill", detail:nil),
        Self(id:17, type:65536, subType:0, name:"64 KB", image:"circle.grid.3x3.fill", detail:nil)
    ]
    
    static let controlDatas: [SocTestCommonRow] = [
        Self(id:0, type:SCM_RIGHTS, subType:checkTypeControlDatas, name:"SCM_RIGHTS", image:nil, detail:"Description_Control_SCM_RIGHTS"),
        Self(id:1, type:SCM_CREDS, subType:checkTypeControlDatas, name:"SCM_CREDS", image:nil, detail:"Description_Control_SCM_CREDS"),
        Self(id:2, type:IP_RETOPTS, subType:checkTypeControlDatas, name:"IP_RETOPTS", image:nil, detail:"Description_Control_IP_RETOPTS"),
        Self(id:3, type:IP_PKTINFO, subType:checkTypeControlDatas, name:"IP_PKTINFO", image:nil, detail:"Description_Control_IP_PKTINFO")
    ]
    
    static let controlBufSizes: [SocTestCommonRow] = [
        Self(id:0, type:0, subType:0, name:"0 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:1, type:4, subType:0, name:"4 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:2, type:8, subType:0, name:"8 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:3, type:12, subType:0, name:"12 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:4, type:16, subType:0, name:"16 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:5, type:24, subType:0, name:"24 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:6, type:32, subType:0, name:"32 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:7, type:64, subType:0, name:"64 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:8, type:128, subType:0, name:"128 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:9, type:256, subType:0, name:"256 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:10, type:512, subType:0, name:"512 bytes", image:"circle.grid.3x3", detail:nil),
        Self(id:11, type:1024, subType:0, name:"1 KB", image:"circle.grid.3x3", detail:nil),
        Self(id:12, type:2048, subType:0, name:"2 KB", image:"circle.grid.3x3", detail:nil),
        Self(id:13, type:4096, subType:0, name:"4 KB", image:"circle.grid.3x3", detail:nil),
        Self(id:14, type:8192, subType:0, name:"8 KB", image:"circle.grid.3x3", detail:nil),
        Self(id:15, type:16384, subType:0, name:"16 KB", image:"circle.grid.3x3", detail:nil),
        Self(id:16, type:32768, subType:0, name:"32 KB", image:"circle.grid.3x3", detail:nil),
        Self(id:17, type:65536, subType:0, name:"64 KB", image:"circle.grid.3x3", detail:nil)
    ]
    
    static let msgFlags: [SocTestCommonRow] = [
        Self(id:0, type:MSG_OOB, subType:checkTypeMsgFlags, name:"MSG_OOB", image:nil, detail:"Description_MSG_OOB"),
        Self(id:1, type:MSG_DONTROUTE, subType:checkTypeMsgFlags, name:"MSG_DONTROUTE", image:nil, detail:"Description_MSG_DONTROUTE"),
        Self(id:2, type:MSG_PEEK, subType:checkTypeMsgFlags, name:"MSG_PEEK", image:nil, detail:"Description_MSG_PEEK"),
        Self(id:3, type:MSG_WAITALL, subType:checkTypeMsgFlags, name:"MSG_WAITALL", image:nil, detail:"Description_MSG_WAITALL"),
        Self(id:4, type:MSG_TRUNC, subType:checkTypeMsgFlags, name:"MSG_TRUNC", image:nil, detail:"Description_MSG_TRUNC"),
        Self(id:5, type:MSG_CTRUNC, subType:checkTypeMsgFlags, name:"MSG_CTRUNC", image:nil, detail:"Description_MSG_CTRUNC")
    ]
    
    static let menu: [SocTestCommonRow] = [
        Self(id:0, type:0, subType:0, name:"App Setting", image:"wrench", detail:"Description_Menu_App_Setting"),
        Self(id:1, type:0, subType:0, name:"Log Viewer", image:"note.text", detail:"Description_Menu_Log_Viewer"),
        Self(id:2, type:0, subType:0, name:"About App", image:"info.circle", detail:"Description_Menu_About_App"),
        Self(id:3, type:0, subType:0, name:"errno", image:"e.circle", detail:"Description_Menu_errno"),
        Self(id:4, type:0, subType:0, name:"man", image:"book", detail:"Description_Menu_man"),
        Self(id:5, type:0, subType:0, name:"Help", image:"questionmark.circle", detail:"Description_Menu_Help"),
        Self(id:6, type:0, subType:0, name:"Privacy Policy", image:"hand.raised.fill", detail:"Description_Menu_Privacy_Policy"),
        Self(id:7, type:0, subType:0, name:"Terms of Service", image:"doc.plaintext", detail:"Description_Menu_Terms_of_Service")
    ]
    
    var isCheck: Bool {
        switch self.subType {
        case SocTestCommonRow.checkTypePollEvents:
            return object.isPollEventChecks[id]
        case SocTestCommonRow.checkTypeControlDatas:
            return object.isControlDataChecks[id]
        case SocTestCommonRow.checkTypeMsgFlags:
            return object.isMsgFlagChecks[id]
        default:
            return false  // not reachable
        }
    }
    
    var body: some View {
        HStack {
            if let image = self.image {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22, alignment: .center)
            }
            else {
                Image(systemName: self.isCheck ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22, alignment: .center)
                    .foregroundColor(Color.init(self.isCheck ? UIColor.systemBlue : UIColor.systemGray))
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if self.subType > 0 {
                        Text(self.name)
                            .font(.system(size: 20))
                            .foregroundColor(Color.init(UIColor.label))
                    }
                    else {
                        Text(self.name)
                            .font(.system(size: 20))
                    }
                    if self.type >= 0 {  //Free xxx is no spacer.
                        Spacer()
                    }
                }
                if object.appSettingDescription && self.detail != nil {
                    HStack {
                        Text(self.detail!)
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
