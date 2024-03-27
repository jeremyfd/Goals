//
//  Test.swift
//  Goals
//
//  Created by Jeremy Daines on 25/03/2024.
//

//import SwiftUI
//
//struct Item: Identifiable {
//    var id: Int
//    var title: String
//    var color: Color
//}
//
//class Store: ObservableObject {
//    @Published var items: [Item]
//    
//    let colors: [Color] = [.red, .orange, .blue, .teal, .mint, .green, .gray, .indigo, .black]
//
//    // dummy data
//    init() {
//        items = []
//        for i in 0...7 {
//            let new = Item(id: i, title: "Item \(i)", color: colors[i])
//            items.append(new)
//        }
//    }
//}
//
//
//struct ContentView2: View {
//    
//    @StateObject var store = Store()
//    @State private var snappedItem = 0.0
//    @State private var draggingItem = 0.0
//    
//    var body: some View {
//        
//        ZStack {
//            ForEach(store.items) { item in
//                
//                // article view
//                ZStack {
//                    RoundedRectangle(cornerRadius: 18)
//                        .fill(item.color)
//                    Text(item.title)
//                        .padding()
//                }
//                .frame(width: 200, height: 200)
//                
//                .scaleEffect(1.0 - abs(distance(item.id)) * 0.2 )
//                .opacity(1.0 - abs(distance(item.id)) * 0.3 )
//                .offset(x: myXOffset(item.id), y: 0)
//                .zIndex(1.0 - abs(distance(item.id)) * 0.1)
//            }
//        }
//        .gesture(
//            DragGesture()
//                .onChanged { value in
//                    draggingItem = snappedItem + value.translation.width / 100
//                }
//                .onEnded { value in
//                    withAnimation {
//                        draggingItem = snappedItem + value.predictedEndTranslation.width / 100
//                        draggingItem = round(draggingItem).remainder(dividingBy: Double(store.items.count))
//                        snappedItem = draggingItem
//                    }
//                }
//        )
//    }
//    
//    func distance(_ item: Int) -> Double {
//        return (draggingItem - Double(item)).remainder(dividingBy: Double(store.items.count))
//    }
//    
//    func myXOffset(_ item: Int) -> Double {
//        let angle = Double.pi * 2 / Double(store.items.count) * distance(item)
//        return sin(angle) * 200
//    }
//    
//}
//
//struct ContentView2_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView2()
//    }
//}
