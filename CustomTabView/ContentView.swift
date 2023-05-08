//
//  ContentView.swift
//  CustomTabView
//
//  Created by sss on 08.05.2023.
//

import SwiftUI

struct TabItemPreferenceKey: PreferenceKey {
    static var defaultValue: [TabItem] = []
    static func reduce(value: inout [TabItem], nextValue: () -> [TabItem]) {
        value += nextValue()
    }
}

struct TabItemModifier: ViewModifier {
    let tabBarItem: TabItem
    
    func body(content: Content) -> some View {
        content
            .preference(key: TabItemPreferenceKey.self, value: [tabBarItem])
    }
}

extension View {
    func myTabItem(_ label: () -> TabItem) -> some View {
        modifier(TabItemModifier(tabBarItem: label()))
    }
}

struct TabItem: Identifiable, Equatable {
    var id = UUID()
    var text: String
    var icon: String
}

struct CustomTabView <Content: View>: View {
    
    @Binding var selection: Int
    @Namespace private var tabBarItem
     
    @State private var tabs: [TabItem] = [.init(text: "Home", icon: "house.fill"), .init(text: "Selected", icon: "star.fill")]
    
    private var content: Content
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
            HStack {
                tabsView
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.vertical, 5)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
            .cornerRadius(10)
            .shadow(radius: 25)
            .padding()
        }
        .onPreferenceChange(TabItemPreferenceKey.self) { value in
            self.tabs = value
        }
    }
    
    init(selection: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.content = content()
        //нижнее подчеркивание из-за @Binding
        _selection = selection
    }
    
    private var tabsView: some View {
        ForEach(Array(tabs.enumerated()), id: \.offset) { index, element in
            Spacer()
            VStack(spacing: 5) {
                Image(systemName: element.icon)
                Text(element.text)
                    .font(.system(size: 10))
            }
            .foregroundColor(selection == index ? .black: .gray)
            .background(
                ZStack(content: {
                    if selection == index {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.yellow.opacity(0.4))
                            .frame(width: 70, height: 50)
                            .matchedGeometryEffect(id: "tabBarItem", in: tabBarItem )
                    }
                })
            )
            .onTapGesture {
                withAnimation {
                    selection = index
                }
            }
            Spacer()
        }
    }
}

struct ContentView: View {
    
    @State var selection = 0
    
    var body: some View {
        CustomTabView(selection: $selection) {
            
            Color.red
                .myTabItem {
                    TabItem(text: "Home", icon: "house.fill")
                }
                .opacity(selection == 0 ? 1: 0)
            
            Color.green
                .myTabItem {
                    TabItem(text: "Selected", icon: "star.fill")
                }
                .opacity(selection == 1 ? 1: 0)
            
            Color.blue
                .myTabItem {
                    TabItem(text: "Settings", icon: "gearshape.fill")
                }
                .opacity(selection == 2 ? 1: 0)
        }
        .ignoresSafeArea(edges: .all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
