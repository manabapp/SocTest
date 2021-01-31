//
//  ContentView.swift
//  SocTest
//
//  Created by Hirose Manabu on 2021/01/31.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject var object: SocTestSharedObject
    @State private var isPresented: Bool = true
    @State private var selection = 0
    
    init() {
        if UserDefaults.standard.bool(forKey: "isAgreed") {
            _isPresented = State(initialValue: false)
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                NavigationView {
#if DEBUG
                    DummyView()
#else
                    SocTestSocketSimulator()
#endif
                }
                .tabItem {
                    VStack {
                        Image(systemName: "paperplane")
                        Text("Socket")
                    }
                }
                .tag(0)
                .navigationViewStyle(StackNavigationViewStyle())
                
                NavigationView {
                    SocTestInterfaceConfiguration()
                }
                .tabItem {
                    VStack {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                        Text("Interface")
                    }
                }
                .tag(1)
                .navigationViewStyle(StackNavigationViewStyle())
                            
                NavigationView {
                    SocTestAddressManager()
                }
                .tabItem {
                    VStack {
                        Image(systemName: "globe")
                        Text("Address")
                    }
                }
                .tag(2)
                .navigationViewStyle(StackNavigationViewStyle())
                
                NavigationView {
                    SocTestIODataManager()
                }
                .tabItem {
                    VStack {
                        Image(systemName: "square.and.pencil")
                        Text("Data")
                    }
                }
                .tag(3)
                .navigationViewStyle(StackNavigationViewStyle())
                
                NavigationView {
                    SocTestMenu()
                }
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape.2")
                        Text("Menu")
                    }
                }
                .tag(4)
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .fullScreenCover(isPresented: self.$isPresented) {
                VStack(spacing: 0) {
                    ZStack {
                        Color(red: 0.000, green: 0.478, blue: 1.000, opacity: 1.0)
                            .edgesIgnoringSafeArea(.all)
                        HStack(alignment: .center) {
                            Spacer()
                            Text("ToS_Title")
                                .foregroundColor(Color.white)
                                .font(.system(size: 20, weight: .semibold))
                            Spacer()
                        }
                    }
                    .frame(height: 50)

                    WebView(url: self.getTermsURL())
                    
                    ZStack {
                        Color(red: 0.918, green: 0.918, blue: 0.937, opacity: 1.0)
                            .edgesIgnoringSafeArea(.all)
                        Button(action: {
                            SocLogger.debug("ContentView: Button: Agree")
                            UserDefaults.standard.set(true, forKey: "isAgreed")
                            UserDefaults.standard.set(Date(), forKey: "agreementDate")
                            self.isPresented = false
                        }) {
                            HStack {
                                Spacer()
                                Text("ToS_Agree")
                                    .font(.system(size: 20))
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 60)
                }
            }
            .blur(radius: (object.isProcessing || object.isAlerting) ? 2 : 0)
            .alert(isPresented: self.$object.isPopAlert) {
                Alert(title: Text(self.object.alertMessage), message: Text(self.object.alertDetail))
            }
            
            if object.isAlerting {
                VStack() {
                    Text(object.alertMessage)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(7)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color(.systemBackground))
                        .background(Color(.label).opacity(0.85))
                        .cornerRadius(20.0)
                    Spacer()
                }
                .padding(.top, 4)
                .padding(.horizontal, 20)
            }
            
            if object.isProcessing {
                Color.init(UIColor.systemGray)
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
            }
            
            ActivityIndicator(isAnimating: self.$object.isProcessing, style: .large)
        }
    }
    
    private func getTermsURL() -> URL {
        let url = Bundle.main.url(forResource: SocTestSharedObject.isJa ? "TermsOfService_ja" : "TermsOfService", withExtension: "html")
        assert(url != nil, "Bundle.main.url failed")
        return url!
    }
}

fileprivate struct WebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

fileprivate struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool

    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

#if DEBUG
fileprivate struct DummyView: View {
    @State private var isActive: Bool = true
    
    var body: some View {
        NavigationLink(destination: SocTestSocketSimulator(), isActive: self.$isActive) {
            EmptyView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
